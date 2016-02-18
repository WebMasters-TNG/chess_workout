class Queen < Piece
  def valid_move?(params)
    x0 = self.x_position
    y0 = self.y_position
    x1 = params[:x_position].to_i
    y1 = params[:y_position].to_i
    return false if pinned?
    return false if this_captured? || same_sq?(params) ||  !capture_dest_piece?(x1, y1).nil?
    ( straight_move?(x0, y0, x1, y1) || diagonal_move?(x0, y0, x1, y1) ) && path_clear?(x0, y0, x1, y1)
  end

  def diagonal_move?(x0, y0, x1, y1)
    (y1 - y0).abs == (x1 - x0).abs
  end

  def straight_move?(x0, y0, x1, y1)
    x1 == x0 || y1 == y0
  end

  def path_clear?(x0, y0, x1, y1)
    sx = x1 - x0 # sx = displacement_x
    sy = y1 - y0 # sy = displacement_y
    sx_arr = [0]
    sy_arr = [0]
    if sx > 0
      sx_arr = (1).upto(sx-1).to_a
    elsif sx < 0
      sx_arr = (-1).downto(sx+1).to_a
    end
    if sy > 0
      sy_arr = (1).upto(sy-1).to_a
    elsif sy < 0
      sy_arr = (-1).downto(sy+1).to_a
    end

    if diagonal_move?(x0, y0, x1, y1)
      return true if sx.abs == 1
      sx_arr.each_with_index do |i, index_i|
        sy_arr.each_with_index do |j, index_j|
          if index_i == index_j
            return false unless self.game.pieces.where(x_position: x0 + i, y_position: y0 + j).empty?
          end
        end
      end
    end

    if straight_move?(x0, y0, x1, y1)
      sx_arr.each do |i|
        sy_arr.each do |j|
          return false unless self.game.pieces.where(x_position: x0 + i, y_position: y0 + j).empty?
        end
      end
    end
    true
  end
end
