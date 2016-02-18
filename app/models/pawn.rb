class Pawn < Piece
  def valid_move?(params)
    x0 = self.x_position
    y0 = self.y_position
    x1 = params[:x_position].to_i
    y1 = params[:y_position].to_i
    return false if pinned?
    return false if this_captured? || same_sq?(params) ||  !capture_dest_piece?(x1, y1).nil?
    return true if en_passant?
    if !backwards_move?(y1) && (diagonal_capture?(x0, y0, x1, y1) || pawn_straight_move?(x0, y0, x1, y1))
      promotion(y1)
      return true
    end
  end

  # ***********************************************************
  # En passant ("in passing") needs specific attention!!
  # => A special pawn capture, that can only occur immediately after a pawn moves two ranks forward from its starting position and an enemy pawn could have captured it had the pawn moved only one square forward.
  # => Must check that the other player's pawn has moved forward two spaces (on their first turn), and that the current_player's pawn is one square to the right or left.
  # ***********************************************************

  def en_passant?
    false # Placeholder value. Assume this current piece is not pinned.
  end

  def promotion(y)
    if ( self.color == "white" && y == 1 ) || ( self.color == "black" && y == 8)
      self.update_attributes(type: "Queen")
    end
  end

  def backwards_move?(y)
    if self.color == "white"
      self.y_position < y
    elsif self.color == "black"
      self.y_position > y
    end
  end

  def diagonal_capture?(x0, y0, x1, y1)
    (y1 - y0).abs == (x1 - x0).abs && (y1 - y0).abs == 1 && !destination_piece(x1, y1).nil?
  end

  def pawn_straight_move?(x0, y0, x1, y1)
    x1 == x0 && move_size?(y1) && destination_piece(x1, y1).nil?
  end

  # Ensure that the pawns do not move more than:
  # (a) 2 vertical spaces on THE PAWN's (not the player's) first turn.
  # (b) 1 vertical space beyond their first turn.
  def move_size?(y)
    if self.color == "white"
      # Check if the white pawn is at its starting y position.
      return true if (self.y_position - y) <= 2 && self.y_position == 7
      self.y_position - y <= 1
    else
      # Check if the black pawn is at its starting y position.
      return true if (y - self.y_position) <= 2 && self.y_position == 2
      y - self.y_position <= 1
    end
  end
end
