class Piece < ActiveRecord::Base
	# shared functionality for all pieces goes here
  belongs_to :game
  # Have the game keep track of which user a piece belongs to, instead of directly associating the pieces with a user.

  # Check if move is valid for selected piece
  def valid_move?
  end
  # Check if the piece is a knight, for purposes of passing over another piece on the board:
  def is_knight?
  end

  # When castling, you simultaneously move your king, and one of your rooks. The king moves two squares towards a rook, and that rook moves to the square at the other side of the king.
  def castling?
  end

  def is_blocked?
    # if !is_knight && (self.x_position != other_player_piece.x_position && self.y_position != other_player_piece.y_position)
  end

  def outside_board?
  end

  def destination_has_piece?
  end

  def is_turn?
  end

  # belongs_to :player, class_name: "User", foreign_key: :player_id

  def self.join_as_black(game, user)
    self.all.each do |black_piece|
      black_piece.update_attributes(player_id: user.id)
    end
  end
end
