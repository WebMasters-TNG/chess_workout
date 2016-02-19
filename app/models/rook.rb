class Rook < Piece
  def valid_move?(params)
    return false unless super
    straight_move? && path_clear?
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
    sx_arr.each do |i|
      sy_arr.each do |j|
        return false unless self.game.pieces.where(captured: nil, x_position: @x0 + i, y_position: @y0 + j).empty?
      end
    end
    true
  end
end

