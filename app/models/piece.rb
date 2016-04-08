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
      if @black_king.captured != true
        check?
      end
    else
      @white_king = game.pieces.where(:type => "King", :color => "white").first
      if @white_king.captured != true
        check?
      end
    end
    # Will the opposing player's king be put into check if this move is made?
    # check?
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

  def white?
    self.color == 'white'
  end

  def black?
    self.color == 'black'
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
    # if self.color == "white"
    #   checkmate? if @x1 == @black_king.x_position && @y1 == @black_king.y_position
    # else
    #   checkmate? if @x1 == @white_king.x_position && @y1 == @white_king.y_position
    # end
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

  def possible_moves
    @possible_moves ||= white_pieces_moves + black_pieces_moves
  end

  def white_pieces_moves
    @possible_moves ||= self.game.white_pieces.map do |piece|
      piece.possible_moves
    end
  end

  def black_pieces_moves
    @possible_moves ||= self.game.black_pieces.map do |piece|
      piece.possible_moves
    end

  end

  def check?
    # a) Determine a list of valid player moves that could put an enemy's king in check based upon where it is:
    # all_white_possible_moves[0] == white_pawn_possible_moves
    # all_white_possible_moves[1] == white_rook_possible_moves
    # all_white_possible_moves[2] == white_knight_possible_moves
    # all_white_possible_moves[3] == white_bishop_possible_moves
    # all_white_possible_moves[4] == white_queen_possible_moves
    # all_white_possible_moves[5] == white_king_possible_moves
    white_possible_moves
    black_possible_moves

    # White pieces
    if self.color == "white"
      # n will be the piece type (6 piece types)
      for n in 0..5
        # Pawns
        if n == 0
          if @all_white_possible_moves[n] != nil
            # There can be up to 8 pawns on the board
            for m in 0..7
              # The pawn exists:
              if @all_white_possible_moves[n][m] != nil
                # Each piece has up to 8 pairs of possible move coordinates returned.
                for o in 0..7
                  # The oth move of the pawn exists:
                  if @all_white_possible_moves[n][m][o] != nil
                    # e.g. all_white_possible_moves[0][0][0] == [x, y] of first possible move of the first pawn
                    if @all_white_possible_moves[n][m][o][0] == @black_king.x_position && @all_white_possible_moves[n][m][o][1] == @black_king.y_position
                      checkmate?
                      return true
                    end
                  end
                end
              end
            end
          end
        elsif n == 1 || n == 2 || n == 3
          # Rooks, knights, and bishops
          if @all_white_possible_moves[n] != nil
            # Rooks, knights, and bishops come in pairs
            for m in 0..1
              if @all_white_possible_moves[n][m] != nil
                for o in 0..7
                  if @all_white_possible_moves[n][m][o] != nil
                    if @all_white_possible_moves[n][m][o][0] == @black_king.x_position && @all_white_possible_moves[n][m][o][1] == @black_king.y_position
                      checkmate?
                      return true
                    end
                  end
                end
              end
            end
          end
        else
          # Queen or king
          if @all_white_possible_moves[n] != nil
            if @all_white_possible_moves[n][0] != nil
            # King or queen are unique pieces (m will always be 0)
              for o in 0..7
                if @all_white_possible_moves[n][m][o] != nil
                  if @all_white_possible_moves[n][m][o][0] == @black_king.x_position && @all_white_possible_moves[n][m][o][1] == @black_king.y_position
                    checkmate?
                    return true
                  end
                end
              end
            end
          end
        end
      end

    # Black pieces
    else
      for n in 0..5
        if n == 0
          if @all_black_possible_moves[n] != nil
            for m in 0..7
              if @all_black_possible_moves[n][m] != nil
                for o in 0..7
                  if @all_black_possible_moves[n][m][o] != nil
                    if @all_black_possible_moves[n][m][o][0] == @white_king.x_position && @all_black_possible_moves[n][m][o][1] == @white_king.y_position
                      checkmate?
                      return true
                    end
                  end
                end
              end
            end
          end
        elsif n == 1 || n == 2 || n == 3
          if @all_black_possible_moves[n] != nil
            for m in 0..1
              if @all_black_possible_moves[n][m] != nil
                for o in 0..7
                  if @all_black_possible_moves[n][m][o] != nil
                    if @all_black_possible_moves[n][m][o][0] == @white_king.x_position && @all_black_possible_moves[n][m][o][1] == @white_king.y_position
                      checkmate?
                      return true
                    end
                  end
                end
              end
            end
          end
        else
          if @all_black_possible_moves[n] != nil
            if @all_black_possible_moves[n][0] != nil
              for o in 0..7
                if @all_black_possible_moves[n][m][o] != nil
                  if @all_black_possible_moves[n][m][o][0] == @white_king.x_position && @all_black_possible_moves[n][m][o][1] == @white_king.y_position
                    checkmate?
                    return true
                  end
                end
              end
            end
          end
        end
      end
    end

    # 1) Capture threatening pieces
    # 2) Block threatening pieces
    # 3) Move King to unchecking position
    # b) Check whether moving the current piece would place the king in check
  end

# *** Consider making a possible_moves method within each piece type model. ***

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
    # n = 0
    white_pawns.each do |white_pawn|
      white_pawn_possible_moves += [white_pawn.possible_moves] if white_pawn != nil
      # n += 1
      # white_pawn_possible_moves.flatten(1) if n == white_pawns.count - 1
    end

    white_rook_possible_moves = []
    white_rooks.each do |white_rook|
      white_rook_possible_moves += [white_rook.possible_moves] if white_rook != nil
    end

    white_knight_possible_moves = []
    white_knights.each do |white_knight|
      white_knight_possible_moves += [white_knight.possible_moves] if white_knight != nil
    end

    white_bishop_possible_moves = []
    white_bishops.each do |white_bishop|
      white_bishop_possible_moves += [white_bishop.possible_moves] if white_bishop != nil
    end

    white_queen_possible_moves = [white_queen.possible_moves] if white_queen != nil

    white_king_possible_moves = [white_king.possible_moves] if white_king != nil

    @all_white_possible_moves = [white_pawn_possible_moves, white_rook_possible_moves, white_knight_possible_moves, white_bishop_possible_moves, white_queen_possible_moves, white_king_possible_moves]
    binding.pry
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
      black_pawn_possible_moves += [black_pawn.possible_moves] if black_pawn != nil
    end

    black_rook_possible_moves = []
    black_rooks.each do |black_rook|
      black_rook_possible_moves += [black_rook.possible_moves] if black_rook != nil
    end


    black_knight_possible_moves = []
    black_knights.each do |black_knight|
      black_knight_possible_moves += [black_knight.possible_moves] if black_knight != nil
    end

    black_bishop_possible_moves = []
    black_bishops.each do |black_bishop|
      black_bishop_possible_moves += [black_bishop.possible_moves] if black_bishop != nil
    end

    black_queen_possible_moves = [black_queen.possible_moves] if black_queen != nil

    black_king_possible_moves = [black_king.possible_moves] if black_king != nil

    @all_black_possible_moves = [black_pawn_possible_moves, black_rook_possible_moves, black_knight_possible_moves, black_bishop_possible_moves, black_queen_possible_moves, black_king_possible_moves]
    binding.pry
  end

# *** Checkmate isn't when the king is captured.  It is when the king can be captured and there is no way to prevent it. ***
  # def checkmate?
  #   escape_checks = []

  #   if check?
  #     if self.color == "white"
  #       # Scan through the possible moves for the black king, to see if the black player can get out of check by moving his king.  Compare the possible moves of the black king with the possible moves of all of the white player's pieces.
  #       # @all_black_possible_moves[5] == black_king_possible_moves
  #       # *** ALSO, scan through all potential friendly blocking moves (can the checking piece be blocked?). ***
  #       # *** ALSO2, can the checking piece be captured? ***
  #       for o in 0..(@all_black_possible_moves[5].size - 1)
  #         # Scan through all possible moves of the player:
  #         for n in 0..5
  #         # Each piece has up to 8 pairs of possible move coordinates returned.
  #           for m in 0..7
  #             # e.g. @all_white_possible_moves[0][0] == [x, y] of first possible pawn move
  #             if @all_white_possible_moves[n][m][0] != @all_black_possible_moves[5][o][0] && @all_white_possible_moves[n][m][1] != @all_black_possible_moves[5][o][1]
  #               escape_checks += [@all_black_possible_moves[5][o][0], @all_black_possible_moves[5][o][1]]
  #             end
  #           end
  #         end
  #       end

  #       #  *** Might be able to use an instance variable within the check method. ***
  #       threatening_pieces = []
  #       # Find the piece that is placing the player's king in check:
  #       for n in 0..5
  #         for m in 0..7
  #           if @all_black_possible_moves[n][m][0] == @white_king.x_position &&
  #             @all_black_possible_moves[n][m][1] == @white_king.y_position
  #             case n
  #             when 0
  #             when 1
  #               # threatening_pieces.each do |black_rooK|
  #                 # CHECK THIS CODE BELOW:
  #                 # if black_rook.x_position == @white_king.x_position && black_rook.y_position + n == @white_king.y_position && black_rook.x_position == @all_white_possible_moves[n][m][0] && black_rook.y_position + n - o == @all_white_possible_moves[n][m][1]
  #                 #     threatening_pieces += [@all_white_possible_moves[n][m][0], @all_white_possible_moves[n][m][1]]
  #                 # end
  #               # end
  #             when 2
  #               # Knight
  #               black_knights = game.pieces.where(:type => "Knight", :color => "black", :captured => nil).all
  #               black_knights.each do |black_knight|
  #                 # 2 up, 1 right to capture:
  #                 if black_knight.x_position + 1 == @white_king.x_position && black_knight.y_position + 2 == @white_king.y_position
  #                   threatening_pieces += [black_knight.x_position, black_knight.y_position]
  #                 # 2 up, 1 left to capture:
  #                 elsif black_knight.x_position - 1 == @white_king.x_position && black_knight.y_position + 2 == @white_king.y_position
  #                   threatening_pieces += [black_knight.x_position, black_knight.y_position]
  #                 # 1 up, 2 right to capture:
  #                 elsif
  #                 end
  #               end
  #             when 3
  #             when 4
  #             when 5

  #             end
  #           end
  #         end
  #       end

  #       blocking_checks = []
  #       # *** Find the possible moves of the threatening piece. ***
  #       # Scan through all potential blocking moves by friendly pieces (blocking check), excluding the king:
  #       for n in 0..4
  #         for m in 0..7
  #           case n
  #           # Blocking doesn't apply to pawns.
  #           when 1
  #             threatening_pieces.each do |black_rook|
  #               # Complete potential capture path is up to 7 squares away:
  #               for o in 1..7
  #                 # Upward vertical potential capture of the king:
  #                 if black_rook.x_position == @white_king.x_position && black_rook.y_position + n == @white_king.y_position && black_rook.x_position == @all_white_possible_moves[n][m][0] && black_rook.y_position + n - o == @all_white_possible_moves[n][m][1]
  #                   blocking_checks += [@all_white_possible_moves[n][m][0], @all_white_possible_moves[n][m][1]]
  #                 end
  #               end
  #             end
  #           # Blocking doesn't apply to knights.
  #           when 3
  #           when 4
  #           end
  #         end
  #       end

  #       captured_checks = []
  #       # Scan through all potential capturing moves of the enemy piece that is currently placing the player's king in check:
  #       for n in 0..5
  #         for m in 0..7
  #           threatening_pieces.each do |threatening_piece|
  #             if @all_white_possible_moves[n][m][0] == threatening_piece.x_position && @all_white_possible_moves[n][m][1] == threatening_piece.y_position
  #               captured_checks += [@all_white_possible_moves[n][m][0], @all_white_possible_moves[n][m][1]]
  #             end
  #           end
  #         end
  #       end

  #       # *** What happens if there are multiple enemy pieces putting the player's king in check? ***
  #       if (escape_checks.size > 0 || blocking_checks.size > 0 || captured_checks.size > 0) && threatening_pieces.size < 2
  #         return false
  #       else
  #         game.winner = "white"
  #         return true
  #       end

  #     elsif self.color == "black"
  #       for o in 0..(@all_white_possible_moves[5].size - 1)
  #         for n in 0..5
  #           for m in 0..7
  #             if @all_black_possible_moves[n][m][0] != @all_white_possible_moves[5][o][0] && @all_black_possible_moves[n][m][1] != @all_white_possible_moves[5][o][1]
  #               escape_checks += [@all_white_possible_moves[5][o][0], @all_white_possible_moves[5][o][1]]
  #             end
  #           end
  #         end
  #       end
  #       if escape_checks.size > 0
  #         return false
  #       else
  #         game.winner = "black"
  #         return true
  #       end
  #     end
  #   else
  #     return false
  #   end
  # end

  def update_move
    moves.where(piece_id: id).first.nil? ? inc_move = 1 : inc_move = moves.where(piece_id: id).last.move_count + 1
    Move.create(game_id: game.id, piece_id: id, move_count: inc_move, old_x: @x0, new_x: @x1, old_y: @y0, new_y: @y1)
  end

  # *** Use this for the pawns !!***
  def first_move?
    self.moves.first.nil?
  end

  def self.join_as_black(user)
    self.all.each do |black_piece|
      black_piece.update_attributes(player_id: user.id)
    end
  end

end
