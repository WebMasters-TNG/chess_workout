class Bishop < Piece
  def valid_move?(params)
    return false unless super
    return false unless diagonal_move? && path_clear?
    capture_piece?
  end

end
