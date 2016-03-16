class Piece < ActiveRecord::Base
  # shared functionality for all pieces goes here
  belongs_to :game
  has_many :moves

  # Check if move is valid for selected piece
  def valid_move?(params)
    @x0 = self.x_position
    @y0 = self.y_position
    @x1 = params[:x_position].to_i
    @y1 = params[:y_position].to_i
    @sx = @x1 - @x0 # sx = displacement_x
    @sy = @y1 - @y0 # sy = displacement_y
    return false if pinned?
    if self.color == "white"
      @black_king = game.pieces.where(:type => "King", :color => "black").first
    else
      @white_king = game.pieces.where(:type => "King", :color => "white").first
    end
    return false if check?
    # *** Must also allow check to return false if the threatening piece is captured by the move. ***
    true
  end

# *** Alternate approach to check: ***
# Uses what we currently have, but doesn't check that the move is within the boundary of the board.
# def check
  # opponent pieces
  # friendly_king
  # opponent_pieces.each do |piece|
  #   return false if piece.valid_check_move?(friendly_king)
  # end
# end

  # Check to see if the movement path is a valid diagonal move
  def diagonal_move?
    @sy.abs == @sx.abs
  end

  # Check to see if the movement pat is a valid straight move
  def straight_move?
    @x1 == @x0 || @y1 == @y0
  end

  # This method can be called by all piece types except the knight, whose moves are not considered below.
  # This will return true if there is no piece along the chosen movement path that has not been captured.
  def path_clear?
    clear = true
    if @x0 != @x1 && @y0 == @y1
      @x1 > @x0 ? x = @x1 - 1 : x = @x1 + 1
      until x == @x0 do
        clear = false if game.pieces.where(x_position: x, y_position: @y0, captured: nil).first != nil
        x > @x0 ? x -= 1 : x += 1
      end
    elsif @x0 == @x1 && @y0 != @y1
      @y1 > @y0 ? y = @y1 - 1 : y = @y1 + 1
      until y == @y0 do
        clear = false if game.pieces.where(x_position: @x0, y_position: y, captured: nil).first != nil
        y > @y0 ? y -= 1 : y += 1
      end
    elsif @x0 != @x1 && @y0 != @y1
      @x1 > @x0 ? x = @x1 - 1 : x = @x1 + 1
      @y1 > @y0 ? y = @y1 - 1 : y = @y1 + 1
      until x == @x0 && y == @y0 do
        clear = false if game.pieces.where(x_position: x, y_position: y, captured: nil).first != nil
        x > @x0 ? x -= 1 : x += 1
        y > @y0 ? y -= 1 : y += 1
      end
    end
    clear
  end


  # Check the piece currently at the destination square. If there is no piece, return nil.
  def destination_piece
    game.pieces.where(x_position: @x1, y_position: @y1, captured: nil).first
  end

  # in the target square and, if so, update the status of the captured piece accordingly. This should be called
  # after checking path_clear? with the exception being the knight.
  def capture_piece?
    # captured_piece = game.pieces.where(x_position:  @x1, y_position: @y1, captured: nil).first
    return false if destination_piece && destination_piece.color == color
    Move.create(game_id: game.id, piece_id: destination_piece.id, old_x: @x1, old_y: @y1, captured_piece: true) if destination_piece
    destination_piece.update_attributes(captured: true) if destination_piece
    # Check for checkmate if the destination square has the king of the opposite color.
    if self.color == "white"
      checkmate? if @black_king.x_position == @x1 && @black_king.y_position == @y1
    else
      checkmate? if @white_king.x_position == @x1 && @white_king.y_position == @y1
    end
    true
  end

  # ***********************************************************
  # Pinning needs specific attention!!
  # => It involves checking whether the King will be under
  # check if this piece is moved.
  # => AND!! This method MUST be called BEFORE capture_dest_piece?
  # or otherwise an innocent piece will be captured.
  # ***********************************************************

  ## ***********************************************************
  # Check & Checkmate needs specific attention!!
  # => It involves all potentially threatening pieces
  # => Three moves allowed under check
  # => 1) Capture threatening pieces
  # => 2) Block threatening pieces
  # => 3) Move King to unchecking position
  # ***********************************************************
  def pinned?
    # Determine possible moves of all pieces that would put the king in check.
    false # Placeholder value. Assume this current piece is not pinned.
  end

  def check?
    # a) Check whether the current player's king is in check where it is.  If so, determine a list of valid moves:
    # all_white_possible_moves[0] == white_pawn_possible_moves
    # all_white_possible_moves[1] == white_rook_possible_moves
    # all_white_possible_moves[2] == white_knight_possible_moves
    # all_white_possible_moves[3] == white_bishop_possible_moves
    # all_white_possible_moves[4] == white_queen_possible_moves
    # all_white_possible_moves[5] == white_king_possible_moves
    for n in 0..5
      # Each piece has up to 8 pairs of possible move coordinates returned.
      for m in 0..7
        # e.g. all_white_possible_moves[0][0] == [x, y] of first possible pawn move
        if self.color == "white" && all_black_possible_moves[n][m][0] == @white_king.x_position && all_black_possible_moves[n][m][1] == @white_king.y_position
          return true
        end
      end
    end

    for n in 0..5
      for m in 0..7
        if self.color == "black" && all_white_possible_moves[n][m][0] == @black_king.x_position && all_white_possible_moves[n][m][1] == @black_king.y_position
          return true
        end
      end
    end

    # 1) Capture threatening pieces
    # 2) Block threatening pieces
    # 3) Move King to unchecking position
    # b) Check whether moving the current piece would place the king in check
  end

  def white_possible_moves
    # Store all of the active (non-captured) white pieces on the board:
    white_pawns = game.pieces.where(:type => "Pawn", :color => "white", :captured => nil).all
    white_rooks = game.pieces.where(:type => "Rook", :color => "white", :captured => nil).all
    white_knights = game.pieces.where(:type => "Knight", :color => "white", :captured => nil).all
    white_bishops = game.pieces.where(:type => "Bishop", :color => "white", :captured => nil).all
    white_queen = game.pieces.where(:type => "Queen", :color => "white", :captured => nil).first
    white_king = game.pieces.where(:type => "King", :color => "white", :captured => nil).first

    # For each white piece, check for and store all valid moves:
    white_pawn_possible_moves = []
    white_pawns.each do |white_pawn|
      # Check that the pawn's path is clear when it tries to make a move allowable by its own movement rules:
      # Has the pawn made its first move or not, and is there a piece at the location of movement or along the way?
      if white_pawn.move_count < 2 && game.pieces.where(:x_position => white_pawn.x_position, :y_position => white_pawn.y_position - 1).first == nil && game.pieces.where(:x_position => white_pawn.x_position, :y_position => white_pawn.y_position - 2).first == nil
        white_pawn_possible_moves += [white_pawn.x_position, white_pawn.y_position - 2]
      elsif white_pawn.move_count >= 2 && game.pieces.where(:x_position => white_pawn.x_position, :y_position => white_pawn.y_position - 1).first == nil && white_pawn.y_position - 1 > 0
        white_pawn_possible_moves += [white_pawn.x_position, white_pawn.y_position - 1]
      end

      # Check for a capturable piece that is to a forward diagonal position of the pawn:
      if game.pieces.where(:x_position => white_pawn.x_position + 1, :y_position => white_pawn.y_position - 1, :color => "black").first != nil && white_pawn.x_position + 1 < 9 && white_pawn.y_position - 1 > 0
        white_pawn_possible_moves += [white_pawn.x_position + 1, white_pawn.y_position - 1]
      elsif game.pieces.where(:x_position => white_pawn.x_position - 1, :y_position => white_pawn.y_position - 1, :color => "black").first != nil && white_pawn.x_position - 1 > 0 && white_pawn.y_position - 1 > 0
        white_pawn_possible_moves += [white_pawn.x_position - 1, white_pawn.y_position - 1]
      end
    end

    white_rook_possible_moves = []
    white_rooks.each do |white_rook|
      # Check that each white rook has a clear path (no friendly pieces along the way or at the destination spot, or any enemy pieces along the way).
      # Check the right horizontal path:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => white_rook.x_position + n, :y_position => white_rook.y_position).first
        # Enemy pieces at the destination square can be captured, but others on the movement path will block the white rook:
        enemy_piece = game.pieces.where(:color => "black", :x_position => white_rook.x_position + n - 1, :y_position => white_rook.y_position).first
        if white_rook.x_position + n != friendly_piece.x_position && white_rook.x_position + n != enemy_piece.x_position && white_rook.x_position + n < 9
          white_rook_possible_moves += [white_rook.x_position + n, white_rook.y_position]
        end
      end

      # Check the left horizontal path:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => white_rook.x_position - n, :y_position => white_rook.y_position).first
        enemy_piece = game.pieces.where(:color => "black", :x_position => white_rook.x_position - n + 1, :y_position => white_rook.y_position).first
        if white_rook.x_position - n != friendly_piece.x_position && white_rook.x_position - n != enemy_piece.x_position && white_rook.x_position - n > 0
          white_rook_possible_moves += [white_rook.x_position - n, white_rook.y_position]
        end
      end

      # Check the upward vertical path:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => white_rook.x_position, :y_position => white_rook.y_position + n).first
        enemy_piece = game.pieces.where(:color => "black", :x_position => white_rook.x_position, :y_position => white_rook.y_position + n - 1).first
        if white_rook.y_position + n != friendly_piece.y_position && white_rook.y_position + n != enemy_piece.y_position && white_rook.y_position + n < 9
          white_rook_possible_moves += [white_rook.x_position, white_rook.y_position + n]
        end
      end

      # Check the downward vertical path:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => white_rook.x_position, :y_position => white_rook.y_position - n).first
        enemy_piece = game.pieces.where(:color => "black", :x_position => white_rook.x_position, :y_position => white_rook.y_position - n + 1).first
        if white_rook.y_position - n != friendly_piece.y_position && white_rook.y_position - n != enemy_piece.y_position && white_rook.y_position - n > 0
          white_rook_possible_moves += [white_rook.x_position, white_rook.y_position - n]
        end
      end
    end

    white_knight_possible_moves = []
    white_knights.each do |white_knight|
      # Check the 8 possible L-shaped moves for a friendly piece at the destination square only.
      # 2 up, 1 right:
      friendly_piece = game.pieces.where(:color => "white", :x_position => white_knight.x_position + 1, :y_position => white_knight.y_position + 2).first
      if white_knight.x_position + 1 != friendly_piece.x_position && white_knight.y_position + 2 != friendly_piece.y_position && white_knight.x_position + 1 < 9 && white_knight.y_position + 2 < 9
        white_knight_possible_moves += [white_knight.x_position + 1, white_knight.y_position + 2]
      end

      # 2 up, 1 left:
      friendly_piece = game.pieces.where(:color => "white", :x_position => white_knight.x_position - 1, :y_position => white_knight.y_position + 2).first
      if white_knight.x_position - 1 != friendly_piece.x_position && white_knight.y_position + 2 != friendly_piece.y_position && white_knight.x_position - 1 > 0 && white_knight.y_position + 2 < 9
        white_knight_possible_moves += [white_knight.x_position - 1, white_knight.y_position + 2]
      end

      # 1 up, 2 right:
      friendly_piece = game.pieces.where(:color => "white", :x_position => white_knight.x_position + 2, :y_position => white_knight.y_position + 1).first
      if white_knight.x_position + 2 != friendly_piece.x_position && white_knight.y_position + 1 != friendly_piece.y_position && white_knight.x_position + 2 < 9 && white_knight.y_position + 1 < 9
        white_knight_possible_moves += [white_knight.x_position + 2, white_knight.y_position + 1]
      end

      # 1 up, 2 left:
      friendly_piece = game.pieces.where(:color => "white", :x_position => white_knight.x_position - 2, :y_position => white_knight.y_position + 1).first
      if white_knight.x_position - 2 != friendly_piece.x_position && white_knight.y_position + 1 != friendly_piece.y_position && white_knight.x_position - 2 > 0 && white_knight.y_position + 1 < 9
        white_knight_possible_moves += [white_knight.x_position - 2, white_knight.y_position + 1]
      end

      # 2 down, 1 right:
      friendly_piece = game.pieces.where(:color => "white", :x_position => white_knight.x_position + 1, :y_position => white_knight.y_position - 2).first
      if white_knight.x_position + 1 != friendly_piece.x_position && white_knight.y_position - 2 != friendly_piece.y_position && white_knight.x_position + 1 < 9 && white_knight.y_position - 2 > 0
        white_knight_possible_moves += [white_knight.x_position + 1, white_knight.y_position - 2]
      end

      # 2 down, 1 left:
      friendly_piece = game.pieces.where(:color => "white", :x_position => white_knight.x_position - 1, :y_position => white_knight.y_position - 2).first
      if white_knight.x_position - 1 != friendly_piece.x_position && white_knight.y_position - 2 != friendly_piece.y_position && white_knight.x_position - 1 > 0 && white_knight.y_position - 2 > 0
        white_knight_possible_moves += [white_knight.x_position - 1, white_knight.y_position - 2]
      end

      # 1 down, 2 right:
      friendly_piece = game.pieces.where(:color => "white", :x_position => white_knight.x_position + 2, :y_position => white_knight.y_position - 1).first
      if white_knight.x_position + 2 != friendly_piece.x_position && white_knight.y_position - 1 != friendly_piece.y_position && white_knight.x_position + 2 < 9 && white_knight.y_position - 1 > 0
        white_knight_possible_moves += [white_knight.x_position + 2, white_knight.y_position - 1]
      end

      # 1 down, 2 left:
      friendly_piece = game.pieces.where(:color => "white", :x_position => white_knight.x_position - 2, :y_position => white_knight.y_position - 1).first
      if white_knight.x_position - 2 != friendly_piece.x_position && white_knight.y_position - 1 != friendly_piece.y_position && white_knight.x_position - 2 > 0 && white_knight.y_position - 1 > 0
        white_knight_possible_moves += [white_knight.x_position - 2, white_knight.y_position - 1]
      end
    end

    white_bishop_possible_moves = []
    white_bishops.each do |white_bishop|
      # Check that each white bishop has clear diagonal path (4 possible diagonal directions)
      # Check upper right diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => white_bishop.x_position + n, :y_position => white_bishop.y_position + n).first
        # Enemy pieces at the destination square can be captured, but others on the movement path will block the white bishop:
        enemy_piece = game.pieces.where(:color => "black", :x_position => white_bishop.x_position + n - 1, :y_position => white_bishop.y_position + n - 1).first
        if white_bishop.x_position + n != friendly_piece.x_position && white_bishop.y_position + n != friendly_piece.y_position && white_bishop.x_position + n != enemy_piece.x_position && white_bishop.y_position + n != enemy_piece.y_position && white_bishop.x_position + n < 9 && white_bishop.y_position + n < 9
          white_bishop_possible_moves += [white_bishop.x_position + n, white_bishop.y_position + n]
        end
      end

      # Check upper left diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => white_bishop.x_position - n, :y_position => white_bishop.y_position + n).first
        enemy_piece = game.pieces.where(:color => "black", :x_position => white_bishop.x_position - n + 1, :y_position => white_bishop.y_position + n - 1).first
        if white_bishop.x_position - n != friendly_piece.x_position && white_bishop.y_position + n != friendly_piece.y_position && white_bishop.x_position - n != enemy_piece.x_position && white_bishop.y_position + n != enemy_piece.y_position && white_bishop.x_position - n > 0 && white_bishop.y_position + n < 9
          white_bishop_possible_moves += [white_bishop.x_position - n, white_bishop.y_position + n]
        end
      end

      # Check lower right diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => white_bishop.x_position + n, :y_position => white_bishop.y_position - n).first
        enemy_piece = game.pieces.where(:color => "black", :x_position => white_bishop.x_position + n - 1, :y_position => white_bishop.y_position - n + 1).first
        if white_bishop.x_position + n != friendly_piece.x_position && white_bishop.y_position - n != friendly_piece.y_position && white_bishop.x_position + n != enemy_piece.x_position && white_bishop.y_position - n != enemy_piece.y_position && white_bishop.x_position + n < 9 && white_bishop.y_position - n > 0
          white_bishop_possible_moves += [white_bishop.x_position + n, white_bishop.y_position - n]
        end
      end


      # Check lower left diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => white_bishop.x_position - n, :y_position => white_bishop.y_position - n).first
        enemy_piece = game.pieces.where(:color => "black", :x_position => white_bishop.x_position - n + 1, :y_position => white_bishop.y_position - n + 1).first
        if white_bishop.x_position - n != friendly_piece.x_position && white_bishop.y_position - n != friendly_piece.y_position && white_bishop.x_position - n != enemy_piece.x_position && white_bishop.y_position - n != enemy_piece.y_position && white_bishop.x_position - n > 0 && white_bishop.y_position - n > 0
          white_bishop_possible_moves += [white_bishop.x_position - n, white_bishop.y_position - n]
        end
      end
    end

    white_queen_possible_moves = []
    # Check the 8 possible movement paths for the queen.
    # Check upward vertical paths:
    for n in 1..7
      friendly_piece = game.pieces.where(:color => "white", :x_position => white_queen.x_position, :y_position => white_queen.y_position + n).first
        enemy_piece = game.pieces.where(:color => "black", :x_position => white_queen.x_position, :y_position => white_queen.y_position + n - 1).first
        if white_queen.y_position + n != friendly_piece.y_position && white_queen.y_position + n != enemy_piece.y_position && white_queen.y_position + n < 9
          white_queen_possible_moves += [white_queen.x_position, white_queen.y_position + n]
        end
    end

    # Check downward vertical paths:
    for n in 1..7
      friendly_piece = game.pieces.where(:color => "white", :x_position => white_queen.x_position, :y_position => white_queen.y_position - n).first
      enemy_piece = game.pieces.where(:color => "black", :x_position => white_queen.x_position, :y_position => white_queen.y_position - n + 1).first
      if white_queen.y_position - n != friendly_piece.y_position && white_queen.y_position - n != enemy_piece.y_position && white_queen.y_position - n > 0
        white_queen_possible_moves += [white_queen.x_position, white_queen.y_position - n]
      end
    end

    # Check upper right diagonal paths:
    for n in 1..7
      friendly_piece = game.pieces.where(:color => "white", :x_position => white_queen.x_position + n, :y_position => white_queen.y_position + n).first
      enemy_piece = game.pieces.where(:color => "black", :x_position => white_queen.x_position + n - 1, :y_position => white_queen.y_position + n - 1).first
      if white_queen.x_position + n != friendly_piece.x_position && white_queen.y_position + n != friendly_piece.y_position && white_queen.x_position + n != enemy_piece.x_position && white_queen.y_position + n != enemy_piece.y_position && white_queen.x_position + n < 9 && white_queen.y_position + n < 9
        white_queen_possible_moves += [white_queen.x_position + n, white_queen.y_position + n]
      end
    end

    # Check upper left diagonal paths:
    for n in 1..7
      friendly_piece = game.pieces.where(:color => "white", :x_position => white_queen.x_position - n, :y_position => white_queen.y_position + n).first
      enemy_piece = game.pieces.where(:color => "black", :x_position => white_queen.x_position - n + 1, :y_position => white_queen.y_position + n - 1).first
      if white_queen.x_position - n != friendly_piece.x_position && white_queen.y_position + n != friendly_piece.y_position && white_queen.x_position - n != enemy_piece.x_position && white_queen.y_position + n != enemy_piece.y_position && white_queen.x_position - n > 0 && white_queen.y_position + n < 9
        white_queen_possible_moves += [white_queen.x_position - n, white_queen.y_position + n]
      end
    end

    # Check lower right diagonal paths:
    for n in 1..7
      friendly_piece = game.pieces.where(:color => "white", :x_position => white_queen.x_position + n, :y_position => white_queen.y_position - n).first
      enemy_piece = game.pieces.where(:color => "black", :x_position => white_queen.x_position + n - 1, :y_position => white_queen.y_position - n + 1).first
      if white_queen.x_position + n != friendly_piece.x_position && white_queen.y_position - n != friendly_piece.y_position && white_queen.x_position + n != enemy_piece.x_position && white_queen.y_position - n != enemy_piece.y_position && white_queen.x_position + n < 9 && white_queen.y_position - n > 0
        white_queen_possible_moves += [white_queen.x_position + n, white_queen.y_position - n]
      end
    end


    # Check lower left diagonal paths:
    for n in 1..7
      friendly_piece = game.pieces.where(:color => "white", :x_position => white_queen.x_position - n, :y_position => white_queen.y_position - n).first
      enemy_piece = game.pieces.where(:color => "black", :x_position => white_queen.x_position - n + 1, :y_position => white_queen.y_position - n + 1).first
      if white_queen.x_position - n != friendly_piece.x_position && white_queen.y_position - n != friendly_piece.y_position && white_queen.x_position - n != enemy_piece.x_position && white_queen.y_position - n != enemy_piece.y_position && white_queen.x_position - n > 0 && white_queen.y_position - n > 0
        white_queen_possible_moves += [white_queen.x_position - n, white_queen.y_position - n]
      end
    end

    # Check the right horizontal path:
    for n in 1..7
      friendly_piece = game.pieces.where(:color => "white", :x_position => white_queen.x_position + n, :y_position => white_queen.y_position).first
      # Enemy pieces at the destination square can be captured, but others on the movement path will block the white rook:
      enemy_piece = game.pieces.where(:color => "black", :x_position => white_queen.x_position + n - 1, :y_position => white_queen.y_position).first
      if white_queen.x_position + n != friendly_piece.x_position && white_queen.x_position + n != enemy_piece.x_position && white_queen.x_position + n < 9
        white_queen_possible_moves += [white_queen.x_position + n, white_queen.y_position]
      end
    end

    # Check the left horizontal path:
    for n in 1..7
      friendly_piece = game.pieces.where(:color => "white", :x_position => white_queen.x_position - n, :y_position => white_queen.y_position).first
      enemy_piece = game.pieces.where(:color => "black", :x_position => white_queen.x_position - n + 1, :y_position => white_queen.y_position).first
      if white_queen.x_position - n != friendly_piece.x_position && white_queen.x_position - n != enemy_piece.x_position && white_queen.x_position - n > 0
        white_queen_possible_moves += [white_queen.x_position - n, white_queen.y_position]
      end
    end

    white_king_possible_moves = []
    # Check the 8 possible movement paths for the king.
    # Check upward vertical paths:
    friendly_piece = game.pieces.where(:color => "white", :x_position => white_king.x_position, :y_position => white_king.y_position + 1).first
    if white_king.y_position + 1 != friendly_piece.y_position && white_king.y_position + 1 < 9
      white_king_possible_moves += [white_king.x_position, white_king.y_position + 1]
    end

    # Check downward vertical paths:
    friendly_piece = game.pieces.where(:color => "white", :x_position => white_king.x_position, :y_position => white_king.y_position - 1).first
    if white_king.y_position - 1 != friendly_piece.y_position && white_king.y_position - 1 > 0
      white_king_possible_moves += [white_king.x_position, white_king.y_position - 1]
    end

    # Check upper right diagonal paths:
    friendly_piece = game.pieces.where(:color => "white", :x_position => white_king.x_position + 1, :y_position => white_king.y_position + 1).first
    if white_king.x_position + 1 != friendly_piece.x_position && white_king.y_position + 1 != friendly_piece.y_position && white_king.x_position + 1 < 9 && white_king.y_position + 1 < 9
      white_king_possible_moves += [white_king.x_position + 1, white_king.y_position + 1]
    end

    # Check upper left diagonal paths:
    friendly_piece = game.pieces.where(:color => "white", :x_position => white_king.x_position - 1, :y_position => white_king.y_position + 1).first
    if white_king.x_position - 1 != friendly_piece.x_position && white_king.y_position + 1 != friendly_piece.y_position && white_king.x_position - 1 > 0 && white_king.y_position + 1 < 9
      white_king_possible_moves += [white_king.x_position - 1, white_king.y_position + 1]
    end

    # Check lower right diagonal paths:
    friendly_piece = game.pieces.where(:color => "white", :x_position => white_king.x_position + 1, :y_position => white_king.y_position - 1).first
    if white_king.x_position + 1 != friendly_piece.x_position && white_king.y_position - 1 != friendly_piece.y_position && white_king.x_position + 1 < 9 && white_king.y_position - 1 > 0
      white_king_possible_moves += [white_king.x_position + 1, white_king.y_position - 1]
    end

    # Check lower left diagonal paths:
    friendly_piece = game.pieces.where(:color => "white", :x_position => white_king.x_position - 1, :y_position => white_king.y_position - 1).first
    if white_king.x_position - 1 != friendly_piece.x_position && white_king.y_position - 1 != friendly_piece.y_position && white_king.x_position - 1 > 0 && white_king.y_position - 1 > 0
      white_king_possible_moves += [white_king.x_position - 1, white_king.y_position - 1]
    end

    # Check the right horizontal path:
    friendly_piece = game.pieces.where(:color => "white", :x_position => white_king.x_position + 1, :y_position => white_king.y_position).first
    if white_king.x_position + 1 != friendly_piece.x_position && white_king.x_position + 1 < 9
      white_king_possible_moves += [white_king.x_position + 1, white_king.y_position]
    end

    # Check the left horizontal path:
    friendly_piece = game.pieces.where(:color => "white", :x_position => white_king.x_position - 1, :y_position => white_king.y_position).first
    if white_king.x_position - 1 != friendly_piece.x_position && white_king.x_position - 1 > 0
      white_king_possible_moves += [white_king.x_position - 1, white_king.y_position]
    end

    all_white_possible_moves = white_pawn_possible_moves + white_rook_possible_moves + white_bishop_possible_moves + white_queen_possible_moves + white_king_possible_moves
    return all_white_possible_moves
  end


def black_possible_moves
    # Store all of the active (non-captured) black pieces on the board:
    black_pawns = game.pieces.where(:type => "Pawn", :color => "black", :captured => nil).all
    black_rooks = game.pieces.where(:type => "Rook", :color => "black", :captured => nil).all
    black_knights = game.pieces.where(:type => "Knight", :color => "black", :captured => nil).all
    black_bishops = game.pieces.where(:type => "Bishop", :color => "black", :captured => nil).all
    black_queen = game.pieces.where(:type => "Queen", :color => "black", :captured => nil).first
    black_king = game.pieces.where(:type => "King", :color => "black", :captured => nil).first

    # For each black piece, check for and store all valid moves:
    black_pawn_possible_moves = []
    black_pawns.each do |black_pawn|
      # Check that the pawn's path is clear when it tries to make a move allowable by its own movement rules:
      # Has the pawn made its first move or not, and is there a piece at the location of movement or along the way?
      if black_pawn.move_count < 2 && game.pieces.where(:x_position => black_pawn.x_position, :y_position => black_pawn.y_position - 1).first == nil && game.pieces.where(:x_position => black_pawn.x_position, :y_position => black_pawn.y_position - 2).first == nil
        black_pawn_possible_moves += [black_pawn.x_position, black_pawn.y_position - 2]
      elsif black_pawn.move_count >= 2 && game.pieces.where(:x_position => black_pawn.x_position, :y_position => black_pawn.y_position - 1).first == nil && black_pawn.y_position - 1 > 0
        black_pawn_possible_moves += [black_pawn.x_position, black_pawn.y_position - 1]
      end

      # Check for a capturable piece that is to a forward diagonal position of the pawn:
      if game.pieces.where(:x_position => black_pawn.x_position + 1, :y_position => black_pawn.y_position - 1, :color => "white").first != nil && black_pawn.x_position + 1 < 9 && black_pawn.y_position - 1 > 0
        black_pawn_possible_moves += [black_pawn.x_position + 1, black_pawn.y_position - 1]
      elsif game.pieces.where(:x_position => black_pawn.x_position - 1, :y_position => black_pawn.y_position - 1, :color => "white").first != nil && black_pawn.x_position - 1 > 0 && black_pawn.y_position - 1 > 0
        black_pawn_possible_moves += [black_pawn.x_position - 1, black_pawn.y_position - 1]
      end
    end

    black_rook_possible_moves = []
    black_rooks.each do |black_rook|
      # Check that each black rook has a clear path (no friendly pieces along the way or at the destination spot, or any enemy pieces along the way).
      # Check the right horizontal path:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => black_rook.x_position + n, :y_position => black_rook.y_position).first
        # Enemy pieces at the destination square can be captured, but others on the movement path will block the black rook:
        enemy_piece = game.pieces.where(:color => "black", :x_position => black_rook.x_position + n - 1, :y_position => black_rook.y_position).first
        if black_rook.x_position + n != friendly_piece.x_position && black_rook.x_position + n != enemy_piece.x_position && black_rook.x_position + n < 9
          black_rook_possible_moves += [black_rook.x_position + n, black_rook.y_position]
        end
      end

      # Check the left horizontal path:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => black_rook.x_position - n, :y_position => black_rook.y_position).first
        enemy_piece = game.pieces.where(:color => "black", :x_position => black_rook.x_position - n + 1, :y_position => black_rook.y_position).first
        if black_rook.x_position - n != friendly_piece.x_position && black_rook.x_position - n != enemy_piece.x_position && black_rook.x_position - n > 0
          black_rook_possible_moves += [black_rook.x_position - n, black_rook.y_position]
        end
      end

      # Check the upward vertical path:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => black_rook.x_position, :y_position => black_rook.y_position + n).first
        enemy_piece = game.pieces.where(:color => "black", :x_position => black_rook.x_position, :y_position => black_rook.y_position + n - 1).first
        if black_rook.y_position + n != friendly_piece.y_position && black_rook.y_position + n != enemy_piece.y_position && black_rook.y_position + n < 9
          black_rook_possible_moves += [black_rook.x_position, black_rook.y_position + n]
        end
      end

      # Check the downward vertical path:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => black_rook.x_position, :y_position => black_rook.y_position - n).first
        enemy_piece = game.pieces.where(:color => "white", :x_position => black_rook.x_position, :y_position => black_rook.y_position - n + 1).first
        if black_rook.y_position - n != friendly_piece.y_position && black_rook.y_position - n != enemy_piece.y_position && black_rook.y_position - n > 0
          black_rook_possible_moves += [black_rook.x_position, black_rook.y_position - n]
        end
      end
    end

    black_knight_possible_moves = []
    black_knights.each do |black_knight|
      # Check the 8 possible L-shaped moves for a friendly piece at the destination square only.
      # 2 up, 1 right:
      friendly_piece = game.pieces.where(:color => "black", :x_position => black_knight.x_position + 1, :y_position => black_knight.y_position + 2).first
      if black_knight.x_position + 1 != friendly_piece.x_position && black_knight.y_position + 2 != friendly_piece.y_position && black_knight.x_position + 1 < 9 && black_knight.y_position + 2 < 9
        black_knight_possible_moves += [black_knight.x_position + 1, black_knight.y_position + 2]
      end

      # 2 up, 1 left:
      friendly_piece = game.pieces.where(:color => "black", :x_position => black_knight.x_position - 1, :y_position => black_knight.y_position + 2).first
      if black_knight.x_position - 1 != friendly_piece.x_position && black_knight.y_position + 2 != friendly_piece.y_position && black_knight.x_position - 1 > 0 && black_knight.y_position + 2 < 9
        black_knight_possible_moves += [black_knight.x_position - 1, black_knight.y_position + 2]
      end

      # 1 up, 2 right:
      friendly_piece = game.pieces.where(:color => "black", :x_position => black_knight.x_position + 2, :y_position => black_knight.y_position + 1).first
      if black_knight.x_position + 2 != friendly_piece.x_position && black_knight.y_position + 1 != friendly_piece.y_position && black_knight.x_position + 2 < 9 && black_knight.y_position + 1 < 9
        black_knight_possible_moves += [black_knight.x_position + 2, black_knight.y_position + 1]
      end

      # 1 up, 2 left:
      friendly_piece = game.pieces.where(:color => "black", :x_position => black_knight.x_position - 2, :y_position => black_knight.y_position + 1).first
      if black_knight.x_position - 2 != friendly_piece.x_position && black_knight.y_position + 1 != friendly_piece.y_position && black_knight.x_position - 2 > 0 && black_knight.y_position + 1 < 9
        black_knight_possible_moves += [black_knight.x_position - 2, black_knight.y_position + 1]
      end

      # 2 down, 1 right:
      friendly_piece = game.pieces.where(:color => "black", :x_position => black_knight.x_position + 1, :y_position => black_knight.y_position - 2).first
      if black_knight.x_position + 1 != friendly_piece.x_position && black_knight.y_position - 2 != friendly_piece.y_position && black_knight.x_position + 1 < 9 && black_knight.y_position - 2 > 0
        black_knight_possible_moves += [black_knight.x_position + 1, black_knight.y_position - 2]
      end

      # 2 down, 1 left:
      friendly_piece = game.pieces.where(:color => "black", :x_position => black_knight.x_position - 1, :y_position => black_knight.y_position - 2).first
      if black_knight.x_position - 1 != friendly_piece.x_position && black_knight.y_position - 2 != friendly_piece.y_position && black_knight.x_position - 1 > 0 && black_knight.y_position - 2 > 0
        black_knight_possible_moves += [black_knight.x_position - 1, black_knight.y_position - 2]
      end

      # 1 down, 2 right:
      friendly_piece = game.pieces.where(:color => "black", :x_position => black_knight.x_position + 2, :y_position => black_knight.y_position - 1).first
      if black_knight.x_position + 2 != friendly_piece.x_position && black_knight.y_position - 1 != friendly_piece.y_position && black_knight.x_position + 2 < 9 && black_knight.y_position - 1 > 0
        black_knight_possible_moves += [black_knight.x_position + 2, black_knight.y_position - 1]
      end

      # 1 down, 2 left:
      friendly_piece = game.pieces.where(:color => "black", :x_position => black_knight.x_position - 2, :y_position => black_knight.y_position - 1).first
      if black_knight.x_position - 2 != friendly_piece.x_position && black_knight.y_position - 1 != friendly_piece.y_position && black_knight.x_position - 2 > 0 && black_knight.y_position - 1 > 0
        black_knight_possible_moves += [black_knight.x_position - 2, black_knight.y_position - 1]
      end
    end

    black_bishop_possible_moves = []
    black_bishops.each do |black_bishop|
      # Check that each black bishop has clear diagonal path (4 possible diagonal directions)
      # Check upper right diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => black_bishop.x_position + n, :y_position => black_bishop.y_position + n).first
        # Enemy pieces at the destination square can be captured, but others on the movement path will block the black bishop:
        enemy_piece = game.pieces.where(:color => "white", :x_position => black_bishop.x_position + n - 1, :y_position => black_bishop.y_position + n - 1).first
        if black_bishop.x_position + n != friendly_piece.x_position && black_bishop.y_position + n != friendly_piece.y_position && black_bishop.x_position + n != enemy_piece.x_position && black_bishop.y_position + n != enemy_piece.y_position && black_bishop.x_position + n < 9 && black_bishop.y_position + n < 9
          black_bishop_possible_moves += [black_bishop.x_position + n, black_bishop.y_position + n]
        end
      end

      # Check upper left diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => black_bishop.x_position - n, :y_position => black_bishop.y_position + n).first
        enemy_piece = game.pieces.where(:color => "white", :x_position => black_bishop.x_position - n + 1, :y_position => black_bishop.y_position + n - 1).first
        if black_bishop.x_position - n != friendly_piece.x_position && black_bishop.y_position + n != friendly_piece.y_position && black_bishop.x_position - n != enemy_piece.x_position && black_bishop.y_position + n != enemy_piece.y_position && black_bishop.x_position - n > 0 && black_bishop.y_position + n < 9
          black_bishop_possible_moves += [black_bishop.x_position - n, black_bishop.y_position + n]
        end
      end

      # Check lower right diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => black_bishop.x_position + n, :y_position => black_bishop.y_position - n).first
        enemy_piece = game.pieces.where(:color => "white", :x_position => black_bishop.x_position + n - 1, :y_position => black_bishop.y_position - n + 1).first
        if black_bishop.x_position + n != friendly_piece.x_position && black_bishop.y_position - n != friendly_piece.y_position && black_bishop.x_position + n != enemy_piece.x_position && black_bishop.y_position - n != enemy_piece.y_position && black_bishop.x_position + n < 9 && black_bishop.y_position - n > 0
          black_bishop_possible_moves += [black_bishop.x_position + n, black_bishop.y_position - n]
        end
      end


      # Check lower left diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => black_bishop.x_position - n, :y_position => black_bishop.y_position - n).first
        enemy_piece = game.pieces.where(:color => "white", :x_position => black_bishop.x_position - n + 1, :y_position => black_bishop.y_position - n + 1).first
        if black_bishop.x_position - n != friendly_piece.x_position && black_bishop.y_position - n != friendly_piece.y_position && black_bishop.x_position - n != enemy_piece.x_position && black_bishop.y_position - n != enemy_piece.y_position && black_bishop.x_position - n > 0 && black_bishop.y_position - n > 0
          black_bishop_possible_moves += [black_bishop.x_position - n, black_bishop.y_position - n]
        end
      end
    end

    black_queen_possible_moves = []
    # Check the 8 possible movement paths for the queen.
    # Check upward vertical paths:
    for n in 1..7
      friendly_piece = game.pieces.where(:color => "black", :x_position => black_queen.x_position, :y_position => black_queen.y_position + n).first
        enemy_piece = game.pieces.where(:color => "white", :x_position => black_queen.x_position, :y_position => black_queen.y_position + n - 1).first
        if black.y_position + n != friendly_piece.y_position && black.y_position + n != enemy_piece.y_position && black.y_position + n < 9
          black_possible_moves += [black.x_position, black.y_position + n]
        end
    end

    # Check downward vertical paths:
    for n in 1..7
      friendly_piece = game.pieces.where(:color => "black", :x_position => black_queen.x_position, :y_position => black_queen.y_position - n).first
      enemy_piece = game.pieces.where(:color => "white", :x_position => black_queen.x_position, :y_position => black_queen.y_position - n + 1).first
      if black_queen.y_position - n != friendly_piece.y_position && black_queen.y_position - n != enemy_piece.y_position && black_queen.y_position - n > 0
        black_queen_possible_moves += [black_queen.x_position, black_queen.y_position - n]
      end
    end

    # Check upper right diagonal paths:
    for n in 1..7
      friendly_piece = game.pieces.where(:color => "black", :x_position => black_queen.x_position + n, :y_position => black_queen.y_position + n).first
      enemy_piece = game.pieces.where(:color => "white", :x_position => black_queen.x_position + n - 1, :y_position => black_queen.y_position + n - 1).first
      if black_queen.x_position + n != friendly_piece.x_position && black_queen.y_position + n != friendly_piece.y_position && black_queen.x_position + n != enemy_piece.x_position && black_queen.y_position + n != enemy_piece.y_position && black_queen.x_position + n < 9 && black_queen.y_position + n < 9
        black_queen_possible_moves += [black_queen.x_position + n, black_queen.y_position + n]
      end
    end

    # Check upper left diagonal paths:
    for n in 1..7
      friendly_piece = game.pieces.where(:color => "black", :x_position => black_queen.x_position - n, :y_position => black_queen.y_position + n).first
      enemy_piece = game.pieces.where(:color => "white", :x_position => black_queen.x_position - n + 1, :y_position => black_queen.y_position + n - 1).first
      if black_queen.x_position - n != friendly_piece.x_position && black_queen.y_position + n != friendly_piece.y_position && black_queen.x_position - n != enemy_piece.x_position && black_queen.y_position + n != enemy_piece.y_position && black_queen.x_position - n > 0 && black_queen.y_position + n < 9
        black_queen_possible_moves += [black_queen.x_position - n, black_queen.y_position + n]
      end
    end

    # Check lower right diagonal paths:
    for n in 1..7
      friendly_piece = game.pieces.where(:color => "black", :x_position => black_queen.x_position + n, :y_position => black_queen.y_position - n).first
      enemy_piece = game.pieces.where(:color => "white", :x_position => black_queen.x_position + n - 1, :y_position => black_queen.y_position - n + 1).first
      if black_queen.x_position + n != friendly_piece.x_position && black_queen.y_position - n != friendly_piece.y_position && black_queen.x_position + n != enemy_piece.x_position && black_queen.y_position - n != enemy_piece.y_position && black_queen.x_position + n < 9 && black_queen.y_position - n > 0
        black_queen_possible_moves += [black_queen.x_position + n, black_queen.y_position - n]
      end
    end


    # Check lower left diagonal paths:
    for n in 1..7
      friendly_piece = game.pieces.where(:color => "black", :x_position => black_queen.x_position - n, :y_position => black_queen.y_position - n).first
      enemy_piece = game.pieces.where(:color => "white", :x_position => black_queen.x_position - n + 1, :y_position => black_queen.y_position - n + 1).first
      if black_queen.x_position - n != friendly_piece.x_position && black_queen.y_position - n != friendly_piece.y_position && black_queen.x_position - n != enemy_piece.x_position && black_queen.y_position - n != enemy_piece.y_position && black_queen.x_position - n > 0 && black_queen.y_position - n > 0
        black_queen_possible_moves += [black_queen.x_position - n, black_queen.y_position - n]
      end
    end

    # Check the right horizontal path:
    for n in 1..7
      friendly_piece = game.pieces.where(:color => "black", :x_position => black_queen.x_position + n, :y_position => black_queen.y_position).first
      # Enemy pieces at the destination square can be captured, but others on the movement path will block the black rook:
      enemy_piece = game.pieces.where(:color => "white", :x_position => black_queen.x_position + n - 1, :y_position => black_queen.y_position).first
      if black_queen.x_position + n != friendly_piece.x_position && black_queen.x_position + n != enemy_piece.x_position && black_queen.x_position + n < 9
        black_queen_possible_moves += [black_queen.x_position + n, black_queen.y_position]
      end
    end

    # Check the left horizontal path:
    for n in 1..7
      friendly_piece = game.pieces.where(:color => "black", :x_position => black_queen.x_position - n, :y_position => black_queen.y_position).first
      enemy_piece = game.pieces.where(:color => "white", :x_position => black_queen.x_position - n + 1, :y_position => black_queen.y_position).first
      if black_queen.x_position - n != friendly_piece.x_position && black_queen.x_position - n != enemy_piece.x_position && black_queen.x_position - n > 0
        black_queen_possible_moves += [black_queen.x_position - n, black_queen.y_position]
      end
    end

    black_king_possible_moves = []
    # Check the 8 possible movement paths for the king.
    # Check upward vertical paths:
    friendly_piece = game.pieces.where(:color => "black", :x_position => black_king.x_position, :y_position => black_king.y_position + 1).first
    if black_king.y_position + 1 != friendly_piece.y_position && black_king.y_position + 1 < 9
      black_king_possible_moves += [black_king.x_position, black_king.y_position + 1]
    end

    # Check downward vertical paths:
    friendly_piece = game.pieces.where(:color => "black", :x_position => black_king.x_position, :y_position => black_king.y_position - 1).first
    if black_king.y_position - 1 != friendly_piece.y_position && black_king.y_position - 1 > 0
      black_king_possible_moves += [black_king.x_position, black_king.y_position - 1]
    end

    # Check upper right diagonal paths:
    friendly_piece = game.pieces.where(:color => "black", :x_position => black_king.x_position + 1, :y_position => black_king.y_position + 1).first
    if black_king.x_position + 1 != friendly_piece.x_position && black_king.y_position + 1 != friendly_piece.y_position && black_king.x_position + 1 < 9 && black_king.y_position + 1 < 9
      black_king_possible_moves += [black_king.x_position + 1, black_king.y_position + 1]
    end

    # Check upper left diagonal paths:
    friendly_piece = game.pieces.where(:color => "black", :x_position => black_king.x_position - 1, :y_position => black_king.y_position + 1).first
    if black_king.x_position - 1 != friendly_piece.x_position && black_king.y_position + 1 != friendly_piece.y_position && black_king.x_position - 1 > 0 && black_king.y_position + 1 < 9
      black_king_possible_moves += [black_king.x_position - 1, black_king.y_position + 1]
    end

    # Check lower right diagonal paths:
    friendly_piece = game.pieces.where(:color => "black", :x_position => black_king.x_position + 1, :y_position => black_king.y_position - 1).first
    if black_king.x_position + 1 != friendly_piece.x_position && black_king.y_position - 1 != friendly_piece.y_position && black_king.x_position + 1 < 9 && black_king.y_position - 1 > 0
      black_king_possible_moves += [black_king.x_position + 1, black_king.y_position - 1]
    end

    # Check lower left diagonal paths:
    friendly_piece = game.pieces.where(:color => "black", :x_position => black_king.x_position - 1, :y_position => black_king.y_position - 1).first
    if black_king.x_position - 1 != friendly_piece.x_position && black_king.y_position - 1 != friendly_piece.y_position && black_king.x_position - 1 > 0 && black_king.y_position - 1 > 0
      black_king_possible_moves += [black_king.x_position - 1, black_king.y_position - 1]
    end

    # Check the right horizontal path:
    friendly_piece = game.pieces.where(:color => "black", :x_position => black_king.x_position + 1, :y_position => black_king.y_position).first
    if black_king.x_position + 1 != friendly_piece.x_position && black_king.x_position + 1 < 9
      black_king_possible_moves += [black_king.x_position + 1, black_king.y_position]
    end

    # Check the left horizontal path:
    friendly_piece = game.pieces.where(:color => "black", :x_position => black_king.x_position - 1, :y_position => black_king.y_position).first
    if black_king.x_position - 1 != friendly_piece.x_position && black_king.x_position - 1 > 0
      black_king_possible_moves += [black_king.x_position - 1, black_king.y_position]
    end

    all_black_possible_moves = black_pawn_possible_moves + black_rook_possible_moves + black_bishop_possible_moves + black_queen_possible_moves + black_king_possible_moves
    return all_black_possible_moves
  end

  def checkmate?
    # If this king has been captured, mark the other player as the game's winner:
    # binding.pry
    if @white_king.captured == true && game.winner != "white"
      game.winner = "black"
    elsif @black_king.captured == true && game.winner != "black"
      game.winner = "white"
    else
      return false
    end
  end

  def update_move
    moves.where(piece_id: id).first.nil? ? inc_move = 1 : inc_move = moves.where(piece_id: id).last.move_count + 1
    Move.create(game_id: game.id, piece_id: id, move_count: inc_move, old_x: @x0, new_x: @x1, old_y: @y0, new_y: @y1)
  end

  def first_move?
    self.moves.first.nil?
  end




  # def path_clear?
  #   sx_arr = [0]
  #   sy_arr = [0]
  #   if @sx > 0
  #     sx_arr = (1).upto(@sx - 1).to_a
  #   elsif @sx < 0
  #     sx_arr = (-1).downto(@sx + 1).to_a
  #   end
  #   if @sy > 0
  #     sy_arr = (1).upto(@sy - 1).to_a
  #   elsif @sy < 0
  #     sy_arr = (-1).downto(@sy + 1).to_a
  #   end

  #   if diagonal_move?
  #     return true if @sx.abs == 1
  #     sx_arr.each_with_index do |i, index_i|
  #       sy_arr.each_with_index do |j, index_j|
  #         if index_i == index_j
  #           return false unless self.game.pieces.where(captured: nil, x_position: @x0 + i, y_position: @y0 + j).empty?
  #         end
  #       end
  #     end
  #   end

  #   if straight_move?
  #     sx_arr.each do |i|
  #       sy_arr.each do |j|
  #         return false unless self.game.pieces.where(captured: nil, x_position: @x0 + i, y_position: @y0 + j).empty?
  #       end
  #     end
  #   end
  #   true
  # end



  # Check if this requesting piece is already captured.
  # def this_captured?
  #   !self.captured.blank?
  # end

  # def capture_dest_piece?(x, y)
  #   dest_piece = destination_piece(x, y)
  #   return false if !dest_piece.nil? && dest_piece.color == self.color
  # end

  # def capture_piece(params)
  #   x1 = params[:x_position].to_i
  #   y1 = params[:y_position].to_i
  #   dest_piece = destination_piece(x1, y1)
  #   dest_piece.update_attributes(captured: true) if !dest_piece.nil?
  # end

  def self.join_as_black(user)
    self.all.each do |black_piece|
      black_piece.update_attributes(player_id: user.id)
    end
  end

  # def same_sq?(params)
  #   x0 = self.x_position
  #   y0 = self.y_position
  #   x1 = params[:x_position].to_i
  #   y1 = params[:y_position].to_i
  #   x0 == x1 && y0 == y1
  # end
end
