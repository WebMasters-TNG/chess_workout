class King < Piece

  def valid_move?(params)
    return false unless super
    move_size && (straight_move? || diagonal_move?) && path_clear?
    capture_piece?
  end

  # ***********************************************************
  # Castling needs specific attention!!
  # => It involves either Rook
  # => It involves checking if King has moved before
  # => It involves checking if King is under check
  # => It involves checking if castling path is under check
  # ***********************************************************

  # ***********************************************************
  # Check & Checkmate needs specific attention!!
  # => It involves all potentially threatening pieces
  # => Three moves allowed under check
  # => 1) Capture threatening pieces
  # => 2) Block threatening pieces
  # => 3) Move King to unchecking position
  # ***********************************************************

  def move_size
    @sx.abs <= 1 && @sy.abs <= 1
  end  
end

