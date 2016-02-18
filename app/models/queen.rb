class Queen < Piece

	def valid_move?(params, piece)
    return false if !attempt_move?(params, piece)
    x = params[:x_position].to_i
    y = params[:y_position].to_i
    captured_piece = Piece.where( x_position:  x, y_position: y ).first

    return false if !legal_move?(x, y)
    Game.next_turn(game)
  end

  def legal_move?(x, y)
  	current_x = self.x_position
  	current_y = self.y_position
  	binding.pry
  	if x == current_x && y != current_y
  		return true
  	elsif x != current_x && y == current_y
  		return true
  	elsif x != current_x && y != current_y
  		return true if (x - current_x).abs == (y - current_y).abs
  	end
  	false
  end

end