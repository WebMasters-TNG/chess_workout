class Piece < ActiveRecord::Base
	# shared functionality for all pieces goes here
  belongs_to :game

  # Check if move is valid for selected piece
  # This method is called from the piece type's model via the valid_move? method to run validations
  # common to all piece types, many of which should be defined in this model.
  def attempt_move?(params)
    return false if !is_turn?
    true
  end

  # This method is called from the child method 
  def valid_move?(params)
    # Assigning instance variables for use in this and all other piece type models
    @target_x = params[:x_position].to_i
    @target_y = params[:y_position].to_i
    @current_x = self.x_position
    @current_y = self.y_position
  end

  def is_blocked?
    # if !is_knight && (self.x_position != other_player_piece.x_position && self.y_position != other_player_piece.y_position)
    false
  end

  def outside_board?
  end

  def capture_piece?(params)
    # captured_piece = Piece.where( x_position:  x, y_position: y ).first
  end

  def is_turn?
    if self.color == "white" && game.turn.odd?
      return true
    elsif self.color == "black" && game.turn.even?
      return true
    else
      return false
    end
  end

  # belongs_to :player, class_name: "User", foreign_key: :player_id

  def self.join_as_black(user)
    self.all.each do |black_piece|
      black_piece.update_attributes(player_id: user.id)
    end
  end
end
