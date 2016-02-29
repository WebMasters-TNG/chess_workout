class Bishop < Piece
  def valid_move?(params)
    return false unless super
    diagonal_move? && path_clear?
  end

end
