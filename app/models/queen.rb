class Queen < Piece
  def valid_move?(params)
    return false unless super
    (straight_move? || diagonal_move?) && path_clear?
    capture_piece?
  end

# 	def valid_move?(params)
# 		super
#     return false if !attempt_move?(params)
#     return false if !legal_move?
#     capture_piece?
#     return false if is_blocked?
#     game.next_turn
#   end

#   def legal_move?
#   	if @target_x == @current_x && @target_y != @current_y
#   		return true
#   	elsif @target_x != @current_x && @target_y == @current_y
#   		return true
#   	elsif @target_x != @current_x && @target_y != @current_y
#   		return true if (@target_x - @current_x).abs == (@target_y - @current_y).abs
#   	end
#   	false
#   end
# end

  
end

