class Bishop < Piece
  def legal_move?
    return false unless diagonal_move? && path_clear?
    capture_piece?
  end

end
