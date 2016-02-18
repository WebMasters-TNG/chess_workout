class Piece < ActiveRecord::Base
	# shared functionality for all pieces goes here
  belongs_to :game
  # Have the game keep track of which user a piece belongs to, instead of directly associating the pieces with a user.

  # Check if move is valid for selected piece
  def attempt_move?(params, piece)
    return false if !is_turn?(piece)
    true
  end

  def is_blocked?
    # if !is_knight && (self.x_position != other_player_piece.x_position && self.y_position != other_player_piece.y_position)
  end

  def outside_board?
  end

  def capture_piece?(params)
  end

  def is_turn?(piece)
    game = piece.game
    if piece.color == "white" && game.turn.odd?
      return true
    elsif piece.color == "black" && game.turn.even?
      return true
    else
      return false
    end
  end

  # belongs_to :player, class_name: "User", foreign_key: :player_id

  def self.join_as_black(game, user)
    self.all.each do |black_piece|
      black_piece.update_attributes(player_id: user.id)
    end
  end
end
