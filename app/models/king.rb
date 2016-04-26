class King < Piece

  def legal_move?
    return false unless (straight_move? || diagonal_move?) && path_clear?
    return false unless move_size || castle_move
    capture_piece?
  end

  def possible_moves
    possible_moves = []

    # Check the 8 possible movement paths for the king.
    if self.color == "white"
      # White king
      # Check downward vertical paths:
      friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position, :y_position => self.y_position + 1, :captured => nil).first
      if friendly_piece == nil && self.y_position + 1 < 9
        possible_moves += [[self.x_position, self.y_position + 1]]
      end

      # Check upward vertical paths:
      friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position, :y_position => self.y_position - 1, :captured => nil).first
      if friendly_piece == nil && self.y_position - 1 > 0
        possible_moves += [[self.x_position, self.y_position - 1]]
      end

      # Check lower right diagonal paths:
      friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position + 1, :y_position => self.y_position + 1, :captured => nil).first
      if friendly_piece == nil && self.x_position + 1 < 9 && self.y_position + 1 < 9
        possible_moves += [[self.x_position + 1, self.y_position + 1]]
      end

      # Check lower left diagonal paths:
      friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position - 1, :y_position => self.y_position + 1, :captured => nil).first
      if friendly_piece == nil && self.x_position - 1 > 0 && self.y_position + 1 < 9
        possible_moves += [[self.x_position - 1, self.y_position + 1]]
      end

      # Check upper right diagonal paths:
      friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position + 1, :y_position => self.y_position - 1, :captured => nil).first
      if friendly_piece == nil && self.x_position + 1 < 9 && self.y_position - 1 > 0
        possible_moves += [[self.x_position + 1, self.y_position - 1]]
      end

      # Check upper left diagonal paths:
      friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position - 1, :y_position => self.y_position - 1, :captured => nil).first
      if friendly_piece == nil && self.x_position - 1 > 0 && self.y_position - 1 > 0
        possible_moves += [[self.x_position - 1, self.y_position - 1]]
      end

      # Check the right horizontal path:
      friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position + 1, :y_position => self.y_position, :captured => nil).first
      if friendly_piece == nil && self.x_position + 1 < 9
        possible_moves += [[self.x_position + 1, self.y_position]]
      end

      # Check the left horizontal path:
      friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position - 1, :y_position => self.y_position, :captured => nil).first
      if friendly_piece == nil && self.x_position - 1 > 0
        possible_moves += [[self.x_position - 1, self.y_position]]
      end

      # Check for castling:
      friendly_pieces = []
      for n in 2..7
        if n != 5
          friendly_pieces += [game.pieces.where(:color => "white", :x_position => n, :y_position => 8, :captured => nil).first]
        end
      end
      left_rook = game.pieces.where(:color => "white", :type => "Rook", :x_position => 1, :y_position => 8, :captured => nil).first
      right_rook = game.pieces.where(:color => "white", :type => "Rook", :x_position => 8, :y_position => 8, :captured => nil).first
      # Clear path to the left of the king:
      if self != nil && left_rook != nil
        if self.moves.count == 0 && left_rook.moves.count == 0 && friendly_pieces[0] == nil && friendly_pieces[1] == nil && friendly_pieces[2] == nil
          possible_moves += [[self.x_position - 2, self.y_position]]
        end
      end
      # Clear path to the right of the king:
      if self != nil && right_rook != nil
        if self.moves.count == 0 && right_rook.moves.count == 0 && friendly_pieces[3] == nil && friendly_pieces[4] == nil
          possible_moves += [[self.x_position + 2, self.y_position]]
        end
      end

    else
    # Black king
      # Check upward vertical paths:
      friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position, :y_position => self.y_position + 1, :captured => nil).first
      if friendly_piece == nil && self.y_position + 1 < 9
        possible_moves += [[self.x_position, self.y_position + 1]]
      end

      # Check downward vertical paths:
      friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position, :y_position => self.y_position - 1, :captured => nil).first
      if friendly_piece == nil && self.y_position - 1 > 0
        possible_moves += [[self.x_position, self.y_position - 1]]
      end

      # Check upper right diagonal paths:
      friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position + 1, :y_position => self.y_position + 1, :captured => nil).first
      if friendly_piece == nil && self.x_position + 1 < 9 && self.y_position + 1 < 9
        possible_moves += [[self.x_position + 1, self.y_position + 1]]
      end

      # Check upper left diagonal paths:
      friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position - 1, :y_position => self.y_position + 1, :captured => nil).first
      if friendly_piece == nil && self.x_position - 1 > 0 && self.y_position + 1 < 9
        possible_moves += [[self.x_position - 1, self.y_position + 1]]
      end

      # Check lower right diagonal paths:
      friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position + 1, :y_position => self.y_position - 1, :captured => nil).first
      if friendly_piece == nil && self.x_position + 1 < 9 && self.y_position - 1 > 0
        possible_moves += [[self.x_position + 1, self.y_position - 1]]
      end

      # Check lower left diagonal paths:
      friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position - 1, :y_position => self.y_position - 1, :captured => nil).first
      if friendly_piece == nil && self.x_position - 1 > 0 && self.y_position - 1 > 0
        possible_moves += [[self.x_position - 1, self.y_position - 1]]
      end

      # Check the right horizontal path:
      friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position + 1, :y_position => self.y_position, :captured => nil).first
      if friendly_piece == nil && self.x_position + 1 < 9
        possible_moves += [[self.x_position + 1, self.y_position]]
      end

      # Check the left horizontal path:
      friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position - 1, :y_position => self.y_position, :captured => nil).first
      if friendly_piece == nil && self.x_position - 1 > 0
        possible_moves += [[self.x_position - 1, self.y_position]]
      end

      # Check for castling:
      friendly_pieces = []
      for n in 2..7
        if n != 5
          friendly_pieces += [game.pieces.where(:color => "black", :x_position => n, :y_position => 1, :captured => nil).first]
        end
      end
      left_rook = game.pieces.where(:color => "black", :type => "Rook", :x_position => 1, :y_position => 1, :captured => nil).first
      right_rook = game.pieces.where(:color => "black", :type => "Rook", :x_position => 8, :y_position => 1, :captured => nil).first
      # Clear path to the left of the king:
      if self != nil && left_rook != nil
        if self.moves.count == 0 && left_rook.moves.count == 0 && friendly_pieces[0] == nil && friendly_pieces[1] == nil && friendly_pieces[2] == nil
          possible_moves += [[self.x_position - 2, self.y_position]]
        end
      end
      # Clear path to the right of the king:
      if self != nil && right_rook != nil
        if self.moves.count == 0 && right_rook.moves.count == 0 && friendly_pieces[3] == nil && friendly_pieces[4] == nil
          possible_moves += [[self.x_position + 2, self.y_position]]
        end
      end
    end

    return possible_moves
  end

  # ***********************************************************
  # Castling needs specific attention!!
  # => It involves either Rook
  # => It involves checking if King has moved before
  # => It involves checking if King is under check
  # => It involves checking if castling path is under check
  # ***********************************************************

  def castle_move
    return false if @sx.abs != 2
    # If the king is moving two spaces to the left:
    if @x1 < @x0
      @target_rook = game.pieces.where(x_position: 1, y_position: @y0).first
    # If the king is moving two spaces to the right:
    else
      @target_rook = game.pieces.where(x_position: 8, y_position: @y0).first
    end
    return false if @target_rook.nil?
    # Neither the king nor the rook have moved:
    return false if !first_move? || !@target_rook.first_move?
    # Move the rook to the other side of the moved king:
    if @target_rook.x_position == 1
      @target_rook.update_attributes(x_position: 4)
      Move.create(game_id: game.id, piece_id: @target_rook.id, move_count: 1, old_x: 1, new_x: 4, old_y: @y0, new_y: @y0)
    else
      @target_rook.update_attributes(x_position: 6)
      Move.create(game_id: game.id, piece_id: @target_rook.id, move_count: 1, old_x: 8, new_x: 6, old_y: @y0, new_y: @y0)
    end
    true
  end

  # ***********************************************************
  # Check & Checkmate needs specific attention!!
  # => It involves all potentially threatening pieces
  # => Three moves allowed under check
  # => 1) Capture threatening pieces
  # => 2) Block threatening pieces
  # => 3) Move King to unchecking position
  # ***********************************************************

  def under_check
    # Define permitted moves for the king, when under check.
  end

  def move_size
    return false if @sx.abs > 1 || @sy.abs > 1
    @sx.abs <= 1 && @sy.abs <= 1
  end
end

