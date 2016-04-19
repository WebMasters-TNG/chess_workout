class Piece < ActiveRecord::Base
  # shared functionality for all pieces goes here
  belongs_to :game
  has_many :moves

  # Check if move is valid for selected piece
  def valid_move?(params)
    # binding.pry
    set_coords(params)
    return false unless legal_move?
    return false if pinned?
    opponent_in_check?
    update_attributes(x_position: @x0, y_position: @y0)
    true
    # binding.pry
  end

  def set_coords(params)
    @x0 = self.x_position
    @y0 = self.y_position
    @x1 = params[:x_position].to_i
    @y1 = params[:y_position].to_i
    @sx = @x1 - @x0 # sx = displacement_x
    @sy = @y1 - @y0 # sy = displacement_y
    # binding.pry
  end

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
    piece_coords = game.piece_map
    if @x0 != @x1 && @y0 == @y1   # Check horizontal path
      @x1 > @x0 ? x = @x0 + 1 : x = @x0 - 1
      until x == @x1 do
        if piece_coords.include?([x, @y0])
          clear = false
          break
        end
        x > @x1 ? x -= 1 : x += 1
      end
    elsif @x0 == @x1 && @y0 != @y1    # Check vertical path
      @y1 > @y0 ? y = @y0 + 1 : y = @y0 - 1
      until y == @y1 do
        if piece_coords.include?([@x0, y])
          clear = false
          break
        end
        y > @y1 ? y -= 1 : y += 1
      end
    elsif @x0 != @x1 && @y0 != @y1    # Check diagonal path
      @x1 > @x0 ? x = @x0 + 1 : x = @x0 - 1
      @y1 > @y0 ? y = @y0 + 1 : y = @y0 - 1
      until x == @x1 && y == @y1 do
        if piece_coords.include?([x, y])
          clear = false
          break
        end
        x > @x1 ? x -= 1 : x += 1
        y > @y1 ? y -= 1 : y += 1
      end
    end
    clear
  end

  # Create arrays of X,Y coordinates for every piece still in play on board for each color
  # def piece_map
  #   @white_pieces_map = []
  #   @black_pieces_map = []
  #   active_pieces = pieces.where(captured: nil)
  #   active_pieces.each do |piece|
  #     @white_pieces_map << [piece.x_position, piece.y_position] if piece.color == "white"
  #     @black_pieces_map << [piece.x_position, piece.y_position] if piece.color == "black"
  #   end
  #   @all_pieces_map = @white_pieces_map + @black_pieces_map
  # end

  # Check the piece currently at the destination square. If there is no piece, return nil.
  def destination_piece
    game.pieces.where(x_position: @x1, y_position: @y1, captured: nil).first
  end

  # Update status of captured piece accordingly and create new move to send to browser to update client side.
  def capture_destination_piece
    if destination_piece && capture_piece?
      Move.create(game_id: game.id, piece_id: destination_piece.id, old_x: @x1, old_y: @y1, captured_piece: true)
      destination_piece.update_attributes(captured: true)
    end
  end

  # Check to see if destination square is occupied by a piece, returning false if it is friendly or true if it is an opponent
  def capture_piece?
    # binding.pry
    return false if destination_piece && destination_piece.color == color
    true
  end

  # ***********************************************************
  # Check & Checkmate needs specific attention!!
  # => It involves all potentially threatening pieces
  # => Three moves allowed under check
  # => 1) Capture threatening pieces
  # => 2) Block threatening pieces
  # => 3) Move King to unchecking position
  # ***********************************************************

  # Use to determine if opposing king in check.
  def demo_check?(player_color)
    player_color == "white" ? opponent_color = "black" : opponent_color = "white"
    @opponent_king = game.pieces.where(type: "King", color: opponent_color).first
    friendly_pieces = game.pieces.where(color: player_color, captured: nil).to_a
    in_check = false
    @threatening_pieces = []
    friendly_pieces.each do |piece|
      piece.set_coords({x_position: @opponent_king.x_position, y_position: @opponent_king.y_position})
      if piece.legal_move?
        in_check = true
        @threatening_pieces << piece
      end
    end
    in_check
  end

  # Determine if opponent is in check or checkmate.
  def opponent_in_check?
    if demo_check?(color)
      if demo_checkmate?
        game.status = "checkmate"
        game.winner = color
      else
        game.status = "check"
      end
    else
      game.status = nil
      return false
    end
  end

  def can_escape?
    can_escape = false
    threatening_pieces = @threatening_pieces
    escape_moves = @opponent_king.possible_moves
    color == "white" ? opponent_possible_moves = black_pieces_moves : opponent_possible_moves = white_pieces_moves
    escape_moves.each do |move|
      can_escape = true if !opponent_possible_moves.include?(move)
      # threatening_pieces.delete_at() ... if can_escape
    end
  end


  def can_block?
    can_block = false
    white_possible_moves
    black_possible_moves
    threatening_pieces = @threatening_pieces
    threatening_pieces.each do |threatening_piece|
      # If one threatening piece remains that cannot be blocked, you can't escape check via blocking:
      can_block = false
      if self.color == "white"
        for n in 0..5
          case threatening_pieces.type
          when "Pawn"
            can_block = false
          when "Rook"
            # There are rooks, knights, or bishops on the board
            if @all_white_possible_moves[1] != nil
              # Rooks, knights, and bishops come in pairs
              for m in 0..1
                # The specific piece exists:
                if @all_white_possible_moves[1][m] != nil
                  # Up to 14 possible moves exist for a rook.
                  for o in 0..13
                    # The oth move of the specific piece exists:
                    if @all_white_possible_moves[1][m][o] != nil
                      # e.g. all_white_possible_moves[n][0][0] == [x, y] of first possible move of the first rook
                      # black_pieces_moves[piece][x], black_pieces[piece][y]
                      # Left to right --> rook, knight, bishop, queen, king, bishop, knight, rook, pawns
                      # if @all_white_possible_moves[0][m][o][0] == black_pieces_moves[][0] && @all_white_possible_moves[0][m][o][1] == black_pieces_moves[][1]
                      if @all_white_possible_moves[1][m][o][0] == @all_black_possible_moves[n][m][o][0] && @all_white_possible_moves[1][m][o][1] == @all_black_possible_moves[n][m][o][1] && @all_black_possible_moves[n][m][o][0] != @opponent_king.x_position && @all_black_possible_moves[n][m][o][1] != @opponent_king.y_position
                        can_block = true
                      end
                    end
                  end
                end
              end
            end
          when "Knight"

          when "Bishop"
            # Up to 13 possible moves exist for a bishop.
          when "Queen"

            # Up to 27 possible moves exist for a queen.
          when "King"
            can_block = false
          end
        end

      else
        case threatening_pieces.type
        when "Pawn"
        when "Rook" || "Knight" || "Bishop"
        when "Queen"
        when "King"
        end
      end
    end

    # 1) A friendly piece (the threatening piece) has a path to the enemy king.
    # 2) An enemy piece (excluding the enemy king) has a possible move within the path of the threatening piece.
    #
    # Alternative approach???
    if threatening_pieces.size > 0
      # It must be possible to block all threatening pieces.
      threatening_pieces.possible_moves.each do |move|
        if opponent_possible_moves.include?(move) && move != opponent_possible_moves
          can_block = true
          # Take out this threatening piece, so that you can determine if there are any remaining threatening pieces as a way to remove check.
          # threatening_pieces.delete_at() ...
        else
          can_block = false
        end
      end
    end

    # # Change in_check into an instance variable?
    # in_check = false if threatening_pieces.size == 0
  end

  # Determine if checkmate on opposing king has occurred.
  def demo_checkmate?
    checkmate = false
    can_escape = false
    can_block = false
    threatening_pieces = @threatening_pieces
    can_capture_threat = false
    escape_moves = @opponent_king.possible_moves
    if color == "white"
      opponent_possible_moves = black_pieces_moves
      friendly_possible_moves = white_pieces_moves
    else
      opponent_possible_moves = white_pieces_moves
      friendly_possible_moves = black_pieces_moves
    end

    # Check if can block threatening piece(s)
    # Required conditions:
    # 1) A friendly piece (the threatening piece) has a path to the enemy king.

    binding.pry

    if threatening_pieces.size > 0
      # It must be possible to block all threatening pieces.
      #
      # *** Undefined method ".possible_moves" on line 217 (threatening pieces is a multi-dimensional array)***
      threatening_pieces.possible_moves.each do |move|
        if opponent_possible_moves.include?(move)
          can_block = true
          # Take out this threatening piece, so that you can determine if there are any remaining threatening pieces as a way to remove check.
          # threatening_pieces.delete_at()
        else
          can_block = false
        end
      end
    end

    # Change in_check into an instance variable?
    in_check = false if threatening_pieces.size == 0

    # 2) An enemy piece (excluding the enemy king) has a possible move within the path of the threatening piece (exclude the location of the enemy king).


    # Determine if king in check can escape
      escape_moves.each do |move|
        can_escape = true if !friendly_possible_moves.include?(move)
      end


    # Determine if threating piece can be captured by opposing player. Can only be true if a singular piece has opposing king in check.
    can_capture_threat = true if opponent_possible_moves.include?([@x1, @y1]) && @threatening_pieces.length == 1
    # Code to determine if opponent can
    # block threatening piece(s) goes here

    checkmate = true if !can_escape && !can_block && !can_capture_threat
    return checkmate
  end

  # ***********************************************************
  # Pinning needs specific attention!!
  # => It involves checking whether the King will be under
  # check if this piece is moved.
  # => AND!! This method MUST be called BEFORE capture_destination_piece?
  # or otherwise an innocent piece will be captured.
  # ***********************************************************
  def pinned?
    pinned = false
    color == "white" ? opponent_color = "black" : opponent_color = "white"
    update_attributes(x_position: @x1, y_position: @y1)
    if demo_check?(opponent_color)
      if capture_threat?
        pinned = false
      else
        update_attributes(x_position: @x0, y_position: @y0)
        pinned = true
      end
    end
    pinned
  end

  # Determine if current move will capture the threatening piece
  def capture_threat?
    if @threatening_pieces.length == 1
      return true if @x1 == @threatening_pieces.first.x_position && @y1 == @threatening_pieces.first.y_position
      return false
    elsif @threatening_pieces.length > 1
      return false
    end
  end

  # Find the diagonal paths for a piece given the starting X and Y coordinates of that piece.
  def diagonal_range(x_coord, y_coord)
    range = []
    x = x_coord - 1
    y = y_coord - 1

    until x == 0 || y == 0 do
      range << [x, y]
      x -= 1
      y -= 1
    end

    x = x_coord + 1
    y = y_coord - 1
    until x == 8 || y == 0 do
      range << [x, y]
      x += 1
      y -= 1
    end

    x = x_coord + 1
    y = y_coord + 1
    until x == 8 || y == 8 do
      range << [x, y]
      x += 1
      y += 1
    end

    x = x_coord - 1
    y = y_coord + 1
    until x == 0 || y == 8 do
      range << [x, y]
      x += 1
      y -= 1
    end

    return range
  end


  def all_possible_moves
    @possible_moves ||= white_pieces_moves + black_pieces_moves
  end

  def white_pieces_moves
    @possible_moves = []
    self.game.white_pieces.where(captured: nil).map do |piece|
      @possible_moves += piece.possible_moves
    end
    return @possible_moves
  end

  def black_pieces_moves
    @possible_moves = []
    self.game.black_pieces.where(captured: nil).map do |piece|
      @possible_moves += piece.possible_moves
    end
    return @possible_moves
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
          # There are pawns on the board
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
        # Rooks, knights, and bishops
        elsif n == 1 || n == 2 || n == 3
          # There are rooks, knights, or bishops on the board
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
        # Queen or king
        else
          # The queen or king is on the board
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
