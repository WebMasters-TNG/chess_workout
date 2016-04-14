class Knight < Piece
  def legal_move?
    return false unless rectangle_move?
    capture_piece?
  end

  def rectangle_move?
    sx_abs = @sx.abs
    sy_abs = @sy.abs
    (sx_abs == 1 && sy_abs == 2) || (sx_abs == 2 && sy_abs == 1)
  end
end
