class Knight < Piece
  def valid_move?(params)
    x0 = self.x_position
    y0 = self.y_position
    x1 = params[:x_position].to_i
    y1 = params[:y_position].to_i
    return false if pinned?
    return false if this_captured? || same_sq?(params) ||  !capture_dest_piece?(x1, y1).nil?
    rectangle_move?(x0, y0, x1, y1)
  end

  def rectangle_move?(x0, y0, x1, y1)
    sx_abs = (x1 - x0).abs # sx = displacement_x
    sy_abs = (y1 - y0).abs # sy = displacement_y
    (sx_abs == 1 && sy_abs == 2) || (sx_abs == 2 && sy_abs == 1)
  end
end
