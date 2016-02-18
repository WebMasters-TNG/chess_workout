class Pawn < Piece
  # Pawn movement: A pawn can move to the square directly in front of itself, if that square is clear. A pawn on its starting rank has the option of moving two squares.

  # @possible_moves = []

  # # How to set the new_x_position and new_y_position properties?  Grab them from the games#show page with an html data attribute using JavaScript?
  # # games#show page has table.board > tr > td#id
  # # *** Check the Flixter app to see how to do this! ***
  # self.new_x_position = ?....
  # self.new_y_position = ?....

  # @pawn_destination = [self.new_x_position, self.new_y_position]

  # distance_x = self.x_position - @pawn_destination[0]
  # distance_y = self.y_position - @pawn_destination[1]

  # # Return an array of valid pawn moves (destination coordinates) every time a player has a turn.  If a potential move is valid (legal), add the resulting destination to the array of allowable pawn moves:
  # def self.possible_moves
  #   # General check for all pieces.  Check that: the piece is not moving outside of the board and that there is not another piece in the way OR that capturing is legal:
  #   if !self.outside_board? && (!self.is_blocked? || self.is_capturing?)
  #     # Specific check for pawns.  There are three potentially legal pawn moves:
  #     # We need a way to check for the current active player, because a pawn can be moved two spaces on a starting player's turn.  Is there a way to link the black_player_id or the white_player_id to the current turn?
  #     # *** Instead of checking for player's first turn, check if pawn is on starting position for moving 2 spaces. ***
  #     if distance_y == 1 || (distance_y == 2 && @game.current_player.turn == 1) || en_passant?
  #       @possible_moves << [self.new_x_position, self.new_y_position]
  #     end
  #   end
  # end

  # # Define pawn movement:
  # # Pawns can only move vertically, except for the "en passant" move.
  # def move(distance_x, distance_y)
  #   if en_passant?
  #     self.x_position += distance_x && self.y_position += distance_y
  #   else
  #     self.y_position += distance_y
  #   end
  # end

  # # *** We need a turn counter, to check for the first turn. ***
  # # *** Change Game.turn into an integer, because odd turns are always the white player's, and even turns the black player's. ***

  # # If the move is valid (legal), execute it:
  # # If pawn_destination is in the @possible_moves array:
  # def valid_move?
  #   @possible_moves.each do |possible_move|
  #     if @pawn_destination == possible_move
  #       self.move(distance_x, distance_y)
  #     else
  #       "Illegal move for the pawn at #{self.x_position}, #{self.y_position}"
  #     end
  #   end
  # end

  def valid_move?(params)
    super
    return false if !attempt_move?(params)
    
    return false if !backwards_move?
    return false if move_size? == nil
    game.next_turn
  end

  def backwards_move?
    if self.color == "white"
      @current_y > @target_y
    elsif self.color == "black"
      @current_y < @target_y
    end
  end

  # Ensure that the pawns do not move more than:
  # (a) 2 vertical spaces on THE PAWN's (not the player's) first turn.
  # (b) 1 vertical space beyond their first turn.
  def move_size?
    if self.color == "white"
      # Check if the white pawn is at its starting y position.
      return true if (@current_y - @target_y) <= 2 && @current_y == 7
      true if (@current_y - @target_y) <= 1
    else
      # Check if the black pawn is at its starting y position.
      return true if (@target_y - @current_y) <= 2 && @current_y == 2
      true if (@target_y - @current_y) <= 1
    end
  end

  # # Check to see if the piece is able to capture another:
  # # I thought that this method should be written for each type of piece because it must check that the piece's move is valid, which differs for each type of piece.
  # def is_capturing?
  #   if destination_has_piece? && valid_move? && !outside_board
  #     true
  #   end
  # end

  # # En passant ("in passing"):  A special pawn capture, that can only occur immediately after a pawn moves two ranks forward from its starting position and an enemy pawn could have captured it had the pawn moved only one square forward.
  # def en_passant?
  #   # Must check that the other player's pawn has moved forward two spaces (on their first turn), and that the current_player's pawn is one square to the right or left.
  # end

end
