class Queen < Piece
  def valid_move?(params)
    return false unless super
    (straight_move? || diagonal_move?) && path_clear?
    capture_piece?
  end
end

