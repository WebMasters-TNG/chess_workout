class Rook < Piece
  def valid_move?(params)
    return false unless super
    straight_move? && path_clear?
  end

end

