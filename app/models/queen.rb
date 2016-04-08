class Queen < Piece
  def legal_move?
    return false unless (straight_move? || diagonal_move?) && path_clear?
    capture_piece?
  end
end

