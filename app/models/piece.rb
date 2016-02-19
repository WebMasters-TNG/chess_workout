class Piece < ActiveRecord::Base
	# shared functionality for all pieces goes here
  belongs_to :game

  # # Check if move is valid for selected piece
  # # This method is called from the piece type's model via the valid_move? method to run validations
  # # common to all piece types, many of which should be defined in this model.
  # def attempt_move?(params)
  #   return false if !is_turn?
  #   true
  # end

  # # This method is called from the child method 
  # def valid_move?(params)
  #   # Assigning instance variables for use in this and all other piece type models
  #   @target_x = params[:x_position].to_i
  #   @target_y = params[:y_position].to_i
  #   @current_x = self.x_position
  #   @current_y = self.y_position
  # end

  # # This method can be called by all piece types except the knight, whose moves are not considered below. 
  # # This will return true if there is a piece along the chosen movement path that has not been captured.
  # # Therefore the capture_piece? method should be called first.
  # def is_blocked?
  #   if @current_x != @target_x && @current_y == @target_y
  #     x = @target_x
  #     until x == @current_x do         
  #       return true if game.pieces.where(x_position: x, y_position: @current_y, captured: false).first != nil
  #       x -= 1 if x > @current_x
  #       x += 1 if x < @current_x
  #     end
  #   elsif @current_x == @target_x && @current_y != @target_y
  #     y = @target_y
  #     until y == @current_y do         
  #       return true if game.pieces.where(x_position: @current_x, y_position: y, captured: false).first != nil
  #       y -= 1 if y > @current_y
  #       y += 1 if y < @current_y
  #     end
  #   elsif @current_x != @target_x && @current_y != @target_y
  #     x = @target_x
  #     y = @target_y
  #     until x == @current_x && y == @current_y do
  #       return true if game.pieces.where(x_position: x, y_position: y, captured: false).first != nil
  #       x -= 1 if x > @current_x
  #       x += 1 if x < @current_x
  #       y -= 1 if y > @current_y
  #       y += 1 if y < @current_y
  #     end
  #   else
  #     false
  #   end
  # end

  # # This method can be called by all piece types and will determine if there is a piece of the opposite color 
  # # in the target square and, if so, update the status of the captured piece accordingly.
  # def capture_piece?
  #   captured_piece = game.pieces.where(x_position:  @target_x, y_position: @target_y).first
  #   binding.pry
  #   captured_piece.update_attributes(captured: true) if captured_piece
  #   binding.pry
  # end

  # def is_turn?
  #   if self.color == "white" && game.turn.odd?
  #     return true
  #   elsif self.color == "black" && game.turn.even?
  #     return true
  #   else
  #     return false
  #   end

  # belongs_to :player, class_name: "User", foreign_key: :player_id
  # Have the game keep track of which user a piece belongs to, instead of directly associating the pieces with a user.

  # Check if move is valid for selected piece
  def valid_move?(params)
    @x0 = self.x_position
    @y0 = self.y_position
    @x1 = params[:x_position].to_i
    @y1 = params[:y_position].to_i
    @sx = @x1 - @x0 # sx = displacement_x
    @sy = @y1 - @y0 # sy = displacement_y
    return false if pinned?
    return false if this_captured? || same_sq?(params) ||  !capture_dest_piece?(@x1, @y1).nil?
    true
  end

  # ***********************************************************
  # Pinning needs specific attention!!
  # => It involves checking whether the King will be under
  # check if this piece is moved.
  # => AND!! This method MUST be called BEFORE capture_dest_piece?
  # or otherwise an innocent piece will be captured.
  # ***********************************************************

  def pinned?
    false # Placeholder value. Assume this current piece is not pinned.
  end

  # Check if this requesting piece is already captured.
  def this_captured?
    !self.captured.blank?
  end

  # Check the piece currently at the destination square. If there is no piece, return nil.
  def destination_piece(x, y)
    self.game.pieces.where(x_position: x, y_position: y, captured: nil).order("updated_at DESC").first
  end

  def capture_dest_piece?(x, y)
    dest_piece = destination_piece(x, y)
    return false if !dest_piece.nil? && dest_piece.color == self.color
  end

  def capture_piece(params)
    x1 = params[:x_position].to_i
    y1 = params[:y_position].to_i
    dest_piece = destination_piece(x1, y1)
    dest_piece.update_attributes(captured: true) if !dest_piece.nil?
  end

  def self.join_as_black(user)
    self.all.each do |black_piece|
      black_piece.update_attributes(player_id: user.id)
    end
  end

  def same_sq?(params)
    x0 = self.x_position
    y0 = self.y_position
    x1 = params[:x_position].to_i
    y1 = params[:y_position].to_i
    x0 == x1 && y0 == y1
  end
end
