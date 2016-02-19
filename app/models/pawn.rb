Wellclass Pawn < Piece
  def valid_move?(params)
    return false unless super
    return true if en_passant?
    if !backwards_move? && (diagonal_capture? || pawn_straight_move?)
      promotion
      return true
    end
  end

  # ***********************************************************
  # En passant ("in passing") needs specific attention!!
  # => A special pawn capture, that can only occur immediately after a pawn moves two ranks forward from its starting position and an enemy pawn could have captured it had the pawn moved only one square forward.
  # => Must check that the other player's pawn has moved forward two spaces (on their first turn), and that the current_player's pawn is one square to the right or left.
  # => This involves changing the diagonal_capture method
  # ***********************************************************

  def en_passant?
    false # Placeholder value. Assume this current piece is not pinned.
  end

  def promotion
    if ( self.color == "white" && @y1 == 1 ) || ( self.color == "black" && @y1 == 8 )
      self.update_attributes(type: "Queen")
    end
  end


  # # This method is called from the update action in the Pieces controller and passed the x_position and y_position
  # # of the targeted move destination.
  # def valid_move?(params)
  #   # Call the parent method from the Piece model to run common validations. 
  #   super
  #   # Upon return from the parent method, begin running type specific validations
  #   return false if !attempt_move?(params)
  #   return false if !backwards_move?
  #   return false if move_size? == nil
  #   # As the final step, increment the game turn via the next_turn method
  #   game.next_turn
  # end

  # def backwards_move?
  #   if self.color == "white"
  #     @current_y > @target_y
  #   elsif self.color == "black"
  #     @current_y < @target_y
  #   end

  def backwards_move?
    self.color == "white" ? @y0 < @y1 : @y0 > @y1
  end

  def diagonal_capture?
    @sy.abs == @sx.abs && @sy.abs == 1 && !destination_piece(@x1, @y1).nil?
  end

  def pawn_straight_move?
    @x1 == @x0 && move_size? && destination_piece(@x1, @y1).nil?
  end

  # Ensure that the pawns do not move more than:
  # (a) 2 vertical spaces on THE PAWN's (not the player's) first turn.
  # (b) 1 vertical space beyond their first turn.
  def move_size?
    if self.color == "white"
      # Check if the white pawn is at its starting y position.

    #   return true if (@current_y - @target_y) <= 2 && @current_y == 7
    #   true if (@current_y - @target_y) <= 1
    # else
    #   # Check if the black pawn is at its starting y position.
    #   return true if (@target_y - @current_y) <= 2 && @current_y == 2
    #   true if (@target_y - @current_y) <= 1

      return true if (@sy.abs) == 2 && @y0 == 7
    else
      # Check if the black pawn is at its starting y position.
      return true if (@sy.abs) == 2 && @y0 == 2
    end
    @sy.abs == 1
  end
end
