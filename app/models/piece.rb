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
    if @current_x != @target_x && @current_y == @target_y
      x = @target_x
      until x == @current_x do         
        return true if game.pieces.where(x_position: x, y_position: @current_y, captured: false).first != nil
        x -= 1 if x > @current_x
        x += 1 if x < @current_x
      end
    elsif @current_x == @target_x && @current_y != @target_y
      y = @target_y
      until y == @current_y do         
        return true if game.pieces.where(x_position: @current_x, y_position: y, captured: false).first != nil
        y -= 1 if y > @current_y
        y += 1 if y < @current_y
      end
    elsif @current_x != @target_x && @current_y != @target_y
      x = @target_x
      y = @target_y
      until x == @current_x && y == @current_y do
        return true if game.pieces.where(x_position: x, y_position: y, captured: false).first != nil
        x -= 1 if x > @current_x
        x += 1 if x < @current_x
        y -= 1 if y > @current_y
        y += 1 if y < @current_y
      end
    else
      false
    end
  end

  def capture_piece?
    captured_piece = game.pieces.where(x_position:  @target_x, y_position: @target_y).first
    captured_piece.update_attributes(captured: true) if captured_piece
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
