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
    true
  end

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
    # binding.pry
    if self.color == "white"
      # @black_king = game.pieces.where(:type => "King", :color => "black").first
      # binding.pry
      checkmate? if @black_king.x_position == @x1 && @black_king.y_position == @y1
    else
      # @white_king = game.pieces.where(:type => "King", :color => "white").first
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
    wt_possible_moves = white_possible_moves
    # wt_possible_moves[0] = white_pawn_possible_moves
    # wt_possible_moves[1] = white_rook_possible_moves
    # wt_possible_moves[2] = white_knight_possible_moves
    # wt_possible_moves[3] = white_bishop_possible_moves
    # wt_possible_moves[4] = white_queen_possible_moves
    # wt_possible_moves[5] = white_king_possible_moves
    wt_possible_moves[0].each do |white_pawn_possible_move|
      if self.color == "black" && white_pawn_possible_move[0] == @black_king.x_position && white_pawn_possible_move[1] == @black_king.y_position
        return true
      end
    end

    bl_possible_moves = black_possible_moves
    bl_possible_moves[0].each do |black_pawn_possible_move|
      if self.color == "white" && black_pawn_possible_move[0] == @white_king.x_position && black_pawn_possible_move[1] == @white_king.y_position
        return true
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
    # Problem:  the current methods in the Piece model and the individual piece type models rely on a single piece attempting to move on an update.
    white_pawn_possible_moves = []
    white_pawns.each do |white_pawn|
      # Check that the pawn's path is clear when it tries to make a move allowable by its own movement rules:
      # Problem: how to check for a piece present at the destination that is NOT the current piece?  Use the piece_id?
      # Has the pawn made its first move or not, and is there a piece at the location of movement or along the way?
      if white_pawn.move_count < 2 && game.pieces.where(:x_position => white_pawn.x_position, :y_position => white_pawn.y_position - 1).first == nil && game.pieces.where(:x_position => white_pawn.x_position, :y_position => white_pawn.y_position - 2).first == nil
        white_pawn_possible_moves += [white_pawn.x_position, white_pawn.y_position - 2]
      elsif white_pawn.move_count >= 2 && game.pieces.where(:x_position => white_pawn.x_position, :y_position => white_pawn.y_position - 1).first == nil
        white_pawn_possible_moves += [white_pawn.x_position, white_pawn.y_position - 1]
      end

      # Check for a capturable piece that is to a forward diagonal position of the pawn:
      if game.pieces.where(:x_position => white_pawn.x_position + 1, :y_position => white_pawn.y_position - 1, :color => "black").first != nil
        white_pawn_possible_moves += [white_pawn.x_position + 1, white_pawn.y_position - 1]
      elsif game.pieces.where(:x_position => white_pawn.x_position - 1, :y_position => white_pawn.y_position - 1, :color => "black").first != nil
        white_pawn_possible_moves += [white_pawn.x_position - 1, white_pawn.y_position - 1]
      end

    end

    white_rook_possible_moves = []
    white_rooks.each do |white_rook|
      # Check that each white rook has a clear vertical path (no friendly pieces along the way or at the destination spot, or any enemy pieces along the way):
      friendly_pieces_in_vpath = game.pieces.where(:x_position => white_rook.x_position, :color => "white").all
      friendly_pieces_in_vpath.each do |friendly_piece_in_vpath|
        enemy_pieces = game.pieces.where(:x_position => white_rook.x_position, :color => "black").all
        enemy_pieces.each do |enemy_piece|
          case friendly_piece_in_vpath.y_position
          when !(white_rook.y_position - 1)
            white_rook_possible_moves += [white_rook.x_position, white_rook.y_position - 1]
          when !(white_rook.y_position - 2) && !(enemy_piece.y_position - 1)
            white_rook_possible_moves += [white_rook.x_position, white_rook.y_position - 2]
          when !white_rook.y_position - 3 && !(enemy_piece.y_position - 2)  && !(enemy_piece.y_position - 1)
            white_rook_possible_moves += [white_rook.x_position, white_rook.y_position - 3]
          when !white_rook.y_position - 4 && !(enemy_piece.y_position - 3) && !(enemy_piece.y_position - 2) && !(enemy_piece.y_position - 1)
            white_rook_possible_moves += [white_rook.x_position, white_rook.y_position - 4]
          when !white_rook.y_position - 5 && !(enemy_piece.y_position - 4) && !(enemy_piece.y_position - 3) && !(enemy_piece.y_position - 2) && !(enemy_piece.y_position - 1)
            white_rook_possible_moves += [white_rook.x_position, white_rook.y_position - 5]
          when !white_rook.y_position - 6 && !(enemy_piece.y_position - 5) && !(enemy_piece.y_position - 4) && !(enemy_piece.y_position - 3) && !(enemy_piece.y_position - 2) && !(enemy_piece.y_position - 1)
            white_rook_possible_moves += [white_rook.x_position, white_rook.y_position - 6]
          when !white_rook.y_position - 7 && !(enemy_piece.y_position - 6) && !(enemy_piece.y_position - 5) && !(enemy_piece.y_position - 4) && !(enemy_piece.y_position - 3) && !(enemy_piece.y_position - 2) && !(enemy_piece.y_position - 1)
            white_rook_possible_moves += [white_rook.x_position, white_rook.y_position - 7]
          when !white_rook.y_position + 1
            white_rook_possible_moves += [white_rook.x_position, white_rook.y_position - 1]
          when !white_rook.y_position + 2 && !(enemy_piece.y_position + 1)
            white_rook_possible_moves += [white_rook.x_position, white_rook.y_position - 2]
          when !white_rook.y_position + 3 && !(enemy_piece.y_position + 2) && !(enemy_piece.y_position + 1)
            white_rook_possible_moves += [white_rook.x_position, white_rook.y_position - 3]
          when !white_rook.y_position + 4 && !(enemy_piece.y_position + 3) && !(enemy_piece.y_position + 2) && !(enemy_piece.y_position + 1)
            white_rook_possible_moves += [white_rook.x_position, white_rook.y_position - 4]
          when !white_rook.y_position + 5 && !(enemy_piece.y_position + 4) && !(enemy_piece.y_position + 3) && !(enemy_piece.y_position + 2) && !(enemy_piece.y_position + 1)
            white_rook_possible_moves += [white_rook.x_position, white_rook.y_position - 5]
          when !white_rook.y_position + 6 && !(enemy_piece.y_position + 5) && !(enemy_piece.y_position + 6) && !(enemy_piece.y_position + 4) && !(enemy_piece.y_position + 3) && !(enemy_piece.y_position + 2) && !(enemy_piece.y_position + 1)
            white_rook_possible_moves += [white_rook.x_position, white_rook.y_position - 6]
          when !white_rook.y_position + 7 && !(enemy_piece.y_position + 6) && !(enemy_piece.y_position + 5) && !(enemy_piece.y_position + 4) && !(enemy_piece.y_position + 3) && !(enemy_piece.y_position + 2) && !(enemy_piece.y_position + 1)
            white_rook_possible_moves += [white_rook.x_position, white_rook.y_position - 7]
          end
        end
      end

      # Check that each white rook has a clear horizontal path (no friendly pieces along the way or at the destination spot, or any enemy pieces along the way):
      friendly_pieces_in_hpath = game.pieces.where(:y_position => white_rook.y_position, :color => "white").all
      friendly_pieces_in_hpath.each do |friendly_pieces_in_hpath|
        enemy_pieces = game.pieces.where(:y_position => white_rook.y_position, :color => "black").all
        enemy_pieces.each do |enemy_piece|
          case friendly_piece_in_vpath.x_position
          when !(white_rook.x_position - 1)
            white_rook_possible_moves += [white_rook.x_position - 1, white_rook.y_position]
          when !(white_rook.x_position - 2) && !(enemy_piece.x_position - 1)
            white_rook_possible_moves += [white_rook.x_position - 2, white_rook.y_position]
          when !(white_rook.x_position - 3) && !(enemy_piece.x_position - 2) && !(enemy_piece.x_position - 1)
            white_rook_possible_moves += [white_rook.x_position - 3, white_rook.y_position]
          when !(white_rook.x_position - 4) && !(enemy_piece.x_position - 3) && !(enemy_piece.x_position - 2) && !(enemy_piece.x_position - 1)
            white_rook_possible_moves += [white_rook.x_position - 4, white_rook.y_position]
          when !(white_rook.x_position - 5) && !(enemy_piece.x_position - 4) && !(enemy_piece.x_position - 3) && !(enemy_piece.x_position - 2) && !(enemy_piece.x_position - 1)
            white_rook_possible_moves += [white_rook.x_position - 5, white_rook.y_position]
          when !(white_rook.x_position - 6) && !(enemy_piece.x_position - 5) && !(enemy_piece.x_position - 4) && !(enemy_piece.x_position - 3) && !(enemy_piece.x_position - 2) && !(enemy_piece.x_position - 1)
            white_rook_possible_moves += [white_rook.x_position - 6, white_rook.y_position]
          when !(white_rook.x_position - 7) && !(enemy_piece.x_position - 6) && !(enemy_piece.x_position - 5) && !(enemy_piece.x_position - 4) && !(enemy_piece.x_position - 3) && !(enemy_piece.x_position - 2) && !(enemy_piece.x_position - 1)
            white_rook_possible_moves += [white_rook.x_position - 7, white_rook.y_position]
          when !(white_rook.x_position + 1)
            white_rook_possible_moves += [white_rook.x_position + 1, white_rook.y_position]
          when !(white_rook.x_position + 2) && !(enemy_piece.x_position + 1)
            white_rook_possible_moves += [white_rook.x_position + 2, white_rook.y_position]
          when !(white_rook.x_position + 3) && !(enemy_piece.x_position + 2) && !(enemy_piece.x_position + 1)
            white_rook_possible_moves += [white_rook.x_position + 3, white_rook.y_position]
          when !(white_rook.x_position + 4) && !(enemy_piece.x_position + 3) && !(enemy_piece.x_position + 2) && !(enemy_piece.x_position + 1)
            white_rook_possible_moves += [white_rook.x_position + 4, white_rook.y_position]
          when !(white_rook.x_position + 5) && !(enemy_piece.x_position + 4) && !(enemy_piece.x_position + 3) && !(enemy_piece.x_position + 2) && !(enemy_piece.x_position + 1)
            white_rook_possible_moves += [white_rook.x_position + 5, white_rook.y_position]
          when !(white_rook.x_position + 6) && !(enemy_piece.x_position + 5) && !(enemy_piece.x_position + 4) && !(enemy_piece.x_position + 3) && !(enemy_piece.x_position + 2) && !(enemy_piece.x_position + 1)
            white_rook_possible_moves += [white_rook.x_position + 6, white_rook.y_position]
          when !(white_rook.x_position + 7) && !(enemy_piece.x_position + 6) && !(enemy_piece.x_position + 5) && !(enemy_piece.x_position + 4) && !(enemy_piece.x_position + 3) && !(enemy_piece.x_position + 2) && !(enemy_piece.x_position + 1)
            white_rook_possible_moves += [white_rook.x_position + 7, white_rook.y_position]
          end
        end
      end
    end

    white_knight_possible_moves = []
    white_bishop_possible_moves = []
    white_queen_possible_moves = []
    white_king_possible_moves = []

    all_white_possible_moves = white_pawn_possible_moves + white_rook_possible_moves + white_bishop_possible_moves + white_queen_possible_moves + white_king_possible_moves
    return all_white_possible_moves
  end

  def black_possible_moves
    black_pawns = game.pieces.where(:type => "Pawn", :color => "black", :captured => nil).all
    black_rooks = game.pieces.where(:type => "Rook", :color => "black", :captured => nil).all
    black_knights = game.pieces.where(:type => "Knight", :color => "black", :captured => nil).all
    black_bishops = game.pieces.where(:type => "Bishop", :color => "black", :captured => nil).all
    black_queen = game.pieces.where(:type => "Queen", :color => "black", :captured => nil).first
    black_king = game.pieces.where(:type => "King", :color => "black", :captured => nil).first

    black_pawn_possible_moves = []
    black_pawn.each do |black_pawn|
      # Has the pawn made its first move or not?
      if black_pawn.move_count < 2 && game.pieces.where(:x_position => black_pawn.x_position, :y_position => black_pawn.y_position + 1).first == nil && game.pieces.where(:x_position => black_pawn.x_position, :y_position => black_pawn.y_position + 2).first == nil
        black_pawn_possible_moves += [black_pawn.x_position, black_pawn.y_position + 2]
      elsif black_pawn.move_count >= 2 && game.pieces.where(:x_position => black_pawn.x_position, :y_position => black_pawn.y_position + 1).first == nil
        black_pawn_possible_moves += [black_pawn.x_position, black_pawn.y_position + 1]
      end

      # Check for a capturable piece that is to a forward diagonal position of the pawn:
      if game.pieces.where(:x_position => black_pawn.x_position + 1, :y_position => black_pawn.y_position + 1, :color => "white").first
        black_pawn_possible_moves += [black_pawn.x_position + 1, black_pawn.y_position + 1]
      elsif game.pieces.where(:x_position => black_pawn.x_position - 1, :y_position => black_pawn.y_position + 1, :color => "white").first
        black_pawn_possible_moves += [black_pawn.x_position - 1, black_pawn.y_position + 1]
      end
    end

    black_rook_possible_moves = []
    black_rook.each do |black_rook|
      # Check that each black rook has a clear vertical path (no friendly pieces along the way or at the destination spot, or any enemy pieces along the way):
      friendly_pieces_in_vpath = game.pieces.where(:x_position => black_rook.x_position, :color => "black").all
      friendly_pieces_in_vpath.each do |friendly_piece_in_vpath|
        enemy_pieces = game.pieces.where(:x_position => black_rook.x_position, :color => "white").all
        enemy_pieces.each do |enemy_piece|
          case friendly_piece_in_vpath.y_position
          when !(black_rook.y_position - 1)
            black_rook_possible_moves += [black_rook.x_position, black_rook.y_position - 1]
          when !(black_rook.y_position - 2) && !(enemy_piece.y_position - 1)
            black_rook_possible_moves += [black_rook.x_position, black_rook.y_position - 2]
          when !black_rook.y_position - 3 && !(enemy_piece.y_position - 2)  && !(enemy_piece.y_position - 1)
            black_rook_possible_moves += [black_rook.x_position, black_rook.y_position - 3]
          when !black_rook.y_position - 4 && !(enemy_piece.y_position - 3) && !(enemy_piece.y_position - 2) && !(enemy_piece.y_position - 1)
            black_rook_possible_moves += [black_rook.x_position, black_rook.y_position - 4]
          when !black_rook.y_position - 5 && !(enemy_piece.y_position - 4) && !(enemy_piece.y_position - 3) && !(enemy_piece.y_position - 2) && !(enemy_piece.y_position - 1)
            black_rook_possible_moves += [black_rook.x_position, black_rook.y_position - 5]
          when !black_rook.y_position - 6 && !(enemy_piece.y_position - 5) && !(enemy_piece.y_position - 4) && !(enemy_piece.y_position - 3) && !(enemy_piece.y_position - 2) && !(enemy_piece.y_position - 1)
            black_rook_possible_moves += [black_rook.x_position, black_rook.y_position - 6]
          when !black_rook.y_position - 7 && !(enemy_piece.y_position - 6) && !(enemy_piece.y_position - 5) && !(enemy_piece.y_position - 4) && !(enemy_piece.y_position - 3) && !(enemy_piece.y_position - 2) && !(enemy_piece.y_position - 1)
            black_rook_possible_moves += [black_rook.x_position, black_rook.y_position - 7]
          when !black_rook.y_position + 1
            black_rook_possible_moves += [black_rook.x_position, black_rook.y_position - 1]
          when !black_rook.y_position + 2 && !(enemy_piece.y_position + 1)
            black_rook_possible_moves += [black_rook.x_position, black_rook.y_position - 2]
          when !black_rook.y_position + 3 && !(enemy_piece.y_position + 2) && !(enemy_piece.y_position + 1)
            black_rook_possible_moves += [black_rook.x_position, black_rook.y_position - 3]
          when !black_rook.y_position + 4 && !(enemy_piece.y_position + 3) && !(enemy_piece.y_position + 2) && !(enemy_piece.y_position + 1)
            black_rook_possible_moves += [black_rook.x_position, black_rook.y_position - 4]
          when !black_rook.y_position + 5 && !(enemy_piece.y_position + 4) && !(enemy_piece.y_position + 3) && !(enemy_piece.y_position + 2) && !(enemy_piece.y_position + 1)
            black_rook_possible_moves += [black_rook.x_position, black_rook.y_position - 5]
          when !black_rook.y_position + 6 && !(enemy_piece.y_position + 5) && !(enemy_piece.y_position + 6) && !(enemy_piece.y_position + 4) && !(enemy_piece.y_position + 3) && !(enemy_piece.y_position + 2) && !(enemy_piece.y_position + 1)
            black_rook_possible_moves += [black_rook.x_position, black_rook.y_position - 6]
          when !black_rook.y_position + 7 && !(enemy_piece.y_position + 6) && !(enemy_piece.y_position + 5) && !(enemy_piece.y_position + 4) && !(enemy_piece.y_position + 3) && !(enemy_piece.y_position + 2) && !(enemy_piece.y_position + 1)
            black_rook_possible_moves += [black_rook.x_position, black_rook.y_position - 7]
          end
        end
      end

      # Check that each black rook has a clear horizontal path (no friendly pieces along the way or at the destination spot, or any enemy pieces along the way):
      friendly_pieces_in_hpath = game.pieces.where(:y_position => black_rook.y_position, :color => "black").all
      friendly_pieces_in_hpath.each do |friendly_pieces_in_hpath|
        enemy_pieces = game.pieces.where(:y_position => black_rook.y_position, :color => "white").all
        enemy_pieces.each do |enemy_piece|
          case friendly_piece_in_vpath.x_position
          when !(black_rook.x_position - 1)
            black_rook_possible_moves += [black_rook.x_position - 1, black_rook.y_position]
          when !(black_rook.x_position - 2) && !(enemy_piece.x_position - 1)
            black_rook_possible_moves += [black_rook.x_position - 2, black_rook.y_position]
          when !(black_rook.x_position - 3) && !(enemy_piece.x_position - 2) && !(enemy_piece.x_position - 1)
            black_rook_possible_moves += [black_rook.x_position - 3, black_rook.y_position]
          when !(black_rook.x_position - 4) && !(enemy_piece.x_position - 3) && !(enemy_piece.x_position - 2) && !(enemy_piece.x_position - 1)
            black_rook_possible_moves += [black_rook.x_position - 4, black_rook.y_position]
          when !(black_rook.x_position - 5) && !(enemy_piece.x_position - 4) && !(enemy_piece.x_position - 3) && !(enemy_piece.x_position - 2) && !(enemy_piece.x_position - 1)
            black_rook_possible_moves += [black_rook.x_position - 5, black_rook.y_position]
          when !(black_rook.x_position - 6) && !(enemy_piece.x_position - 5) && !(enemy_piece.x_position - 4) && !(enemy_piece.x_position - 3) && !(enemy_piece.x_position - 2) && !(enemy_piece.x_position - 1)
            black_rook_possible_moves += [black_rook.x_position - 6, black_rook.y_position]
          when !(black_rook.x_position - 7) && !(enemy_piece.x_position - 6) && !(enemy_piece.x_position - 5) && !(enemy_piece.x_position - 4) && !(enemy_piece.x_position - 3) && !(enemy_piece.x_position - 2) && !(enemy_piece.x_position - 1)
            black_rook_possible_moves += [black_rook.x_position - 7, black_rook.y_position]
          when !(black_rook.x_position + 1)
            black_rook_possible_moves += [black_rook.x_position + 1, black_rook.y_position]
          when !(black_rook.x_position + 2) && !(enemy_piece.x_position + 1)
            black_rook_possible_moves += [black_rook.x_position + 2, black_rook.y_position]
          when !(black_rook.x_position + 3) && !(enemy_piece.x_position + 2) && !(enemy_piece.x_position + 1)
            black_rook_possible_moves += [black_rook.x_position + 3, black_rook.y_position]
          when !(black_rook.x_position + 4) && !(enemy_piece.x_position + 3) && !(enemy_piece.x_position + 2) && !(enemy_piece.x_position + 1)
            black_rook_possible_moves += [black_rook.x_position + 4, black_rook.y_position]
          when !(black_rook.x_position + 5) && !(enemy_piece.x_position + 4) && !(enemy_piece.x_position + 3) && !(enemy_piece.x_position + 2) && !(enemy_piece.x_position + 1)
            black_rook_possible_moves += [black_rook.x_position + 5, black_rook.y_position]
          when !(black_rook.x_position + 6) && !(enemy_piece.x_position + 5) && !(enemy_piece.x_position + 4) && !(enemy_piece.x_position + 3) && !(enemy_piece.x_position + 2) && !(enemy_piece.x_position + 1)
            black_rook_possible_moves += [black_rook.x_position + 6, black_rook.y_position]
          when !(black_rook.x_position + 7) && !(enemy_piece.x_position + 6) && !(enemy_piece.x_position + 5) && !(enemy_piece.x_position + 4) && !(enemy_piece.x_position + 3) && !(enemy_piece.x_position + 2) && !(enemy_piece.x_position + 1)
            black_rook_possible_moves += [black_rook.x_position + 7, black_rook.y_position]
          end
        end
      end
    end

    black_knight_possible_moves = []
    black_bishop_possible_moves = []
    black_queen_possible_moves = []
    black_king_possible_moves = []

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
