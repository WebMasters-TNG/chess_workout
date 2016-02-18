class Queen < Piece
  def valid_move?(params)
    return false unless super
    (straight_move? || diagonal_move?) && path_clear?
  end

  def diagonal_move?
    @sy.abs == @sx.abs
  end

  def straight_move?
    @x1 == @x0 || @y1 == @y0
  end

  def path_clear?
    sx_arr = [0]
    sy_arr = [0]
    if @sx > 0
      sx_arr = (1).upto(@sx - 1).to_a
    elsif @sx < 0
      sx_arr = (-1).downto(@sx + 1).to_a
    end
    if @sy > 0
      sy_arr = (1).upto(@sy - 1).to_a
    elsif @sy < 0
      sy_arr = (-1).downto(@sy + 1).to_a
    end

    if diagonal_move?
      return true if @sx.abs == 1
      sx_arr.each_with_index do |i, index_i|
        sy_arr.each_with_index do |j, index_j|
          if index_i == index_j
            return false unless self.game.pieces.where(captured: nil, x_position: @x0 + i, y_position: @y0 + j).empty?
          end
        end
      end
    end

    if straight_move?
      sx_arr.each do |i|
        sy_arr.each do |j|
          return false unless self.game.pieces.where(captured: nil, x_position: @x0 + i, y_position: @y0 + j).empty?
        end
      end
    end
    true
  end
end
