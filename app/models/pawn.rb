class Pawn < Piece
  def valid_move?(params)
    return false unless super
    if self.color == "white" && @y0 == 4 && @y1 == 3 || self.color == "black" && @y0 == 5 && @y1 == 6
      return true if en_passant?(@x0, @y0, @x1, @y1)
    elsif !backwards_move? && (diagonal_capture? || pawn_straight_move?)
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

  def en_passant?(x0, y0, x1, y1)
    # Assume this current piece is not pinned.
    # Check if player's pawn is at the correct vertical square (only possibilities are y = 4 for white, y = 5 for black).
    if self.color == "white" && y0 == 4
      # Check for an enemy pawn to either side of the player's pawn that has only made one move.
      black_pawn = Piece.all.where(:type => "Pawn", :color => "black", :x_position => x0 + 1, :y_position => y0).first
      black_pawn2 = Piece.all.where(:type => "Pawn", :color => "black", :x_position => x0 - 1, :y_position => y0).first
      # 1) Check if the enemy pawn has moved two vertical squares in its last turn.
      # 2) Check if the diagonal movement is 1 space.
      # 3) Check that there is no piece on the destination square.
      # 4) Check that the player's pawn's destination is in the same column as the enemy pawn.
      # ****=============****
      # 5) Check that the player's pawn was already in its current starting position in the turn before the enemy pawn has made its starting two square advance.
      # ****=============****
      # black_pawn.moves.move_count cannot always be used here, because in a valid case moves will have not been created yet for this piece (before the black pawn's first move, black_pawn.moves is an empty array).
      if !black_pawn.nil? && black_pawn.moves.count <= 1 && (y1 - y0).abs == (x1 - x0).abs && (y1 - y0).abs == 1 && destination_piece.nil? && x1 == black_pawn.x_position
        # && self.old_y == self.new_y
        black_pawn.update_attributes(captured: true)
        # binding.pry
        return true
      elsif !black_pawn2.nil? && black_pawn2.moves.count <= 1 && (y1 - y0).abs == (x1 - x0).abs && (y1 - y0).abs == 1 && destination_piece.nil? && x1 == black_pawn2.x_position
        black_pawn2.update_attributes(captured: true)
        # binding.pry
        return true
      end
    elsif self.color == "black" && y0 == 5
      white_pawn = Piece.all.where(:type => "Pawn", :color => "white", :x_position => x0 + 1, :y_position => y0)
      white_pawn2 = Piece.all.where(:type => "Pawn", :color => "white", :x_position => x0 - 1, :y_position => y0)
      if !white_pawn.nil? && white_pawn.moves.count <= 1 && (y1 - y0).abs == (x1 - x0).abs && (y1 - y0).abs == 1 && destination_piece.nil? && x1 == white_pawn.x_position
        white_pawn.update_attributes(captured: true)
        # binding.pry
        return true
      elsif !white_pawn2.nil? && white_pawn2.moves.count <= 1 && (y1 - y0).abs == (x1 - x0).abs && (y1 - y0).abs == 1 && destination_piece.nil? && x1 == white_pawn2.x_position
        white_pawn2.update_attributes(captured: true)
        # binding.pry
        return true
      end
    else
      return false
    end

    # if #last move + #Pawn
    #  # && (destination_piece(x0, y0) - destination_piece(x1, y1) == 2)

    # end
    # Check if enemy pawn's current position - 1y square would be capturable.

    # If these two checks pass, move the player pawn to the enemy pawn's current position - y.

    # *** ALTERNATIVELY, we could have the player whose pawn is capturable with the en passant move have a flag set on their own pawn after a check for an adjacent pawn. ***
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
    @sy.abs == @sx.abs && @sy.abs == 1 && !destination_piece.nil?
  end

  def pawn_straight_move?
    @x1 == @x0 && move_size? && destination_piece.nil?
  end

  # Ensure that the pawns do not move more than:
  # (a) 2 vertical spaces on THE PAWN's (not the player's) first move.
  # (b) 1 vertical space beyond their first move.
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
