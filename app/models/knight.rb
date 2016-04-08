class Knight < Piece
  def valid_move?(params)
    return false unless super
    return false unless rectangle_move?
    capture_piece?
  end

  def rectangle_move?
    sx_abs = @sx.abs
    sy_abs = @sy.abs
    (sx_abs == 1 && sy_abs == 2) || (sx_abs == 2 && sy_abs == 1)
  end

  def possible_moves

    possible_moves = []

    if self.color == "white"
      # Check the 8 possible L-shaped moves for a friendly piece at the destination square only.
      # 2 down, 1 right:
      friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position + 1, :y_position => self.y_position + 2, :captured => nil).first
      if friendly_piece == nil && self.x_position + 1 < 9 && self.y_position + 2 < 9
        possible_moves += [[self.x_position + 1, self.y_position + 2]]
      end

      # 2 down, 1 left:
      friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position - 1, :y_position => self.y_position + 2, :captured => nil).first
      if friendly_piece == nil && self.x_position - 1 > 0 && self.y_position + 2 < 9
        possible_moves += [[self.x_position - 1, self.y_position + 2]]
      end

      # 1 down, 2 right:
      friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position + 2, :y_position => self.y_position + 1, :captured => nil).first
      if friendly_piece == nil && self.x_position + 2 < 9 && self.y_position + 1 < 9
        possible_moves += [[self.x_position + 2, self.y_position + 1]]
      end

      # 1 down, 2 left:
      friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position - 2, :y_position => self.y_position + 1, :captured => nil).first
      if friendly_piece == nil && self.x_position - 2 > 0 && self.y_position + 1 < 9
        possible_moves += [[self.x_position - 2, self.y_position + 1]]
      end

      # 2 up, 1 right:
      friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position + 1, :y_position => self.y_position - 2, :captured => nil).first
      if friendly_piece == nil && self.x_position + 1 < 9 && self.y_position - 2 > 0
        possible_moves += [[self.x_position + 1, self.y_position - 2]]
      end

      # 2 up, 1 left:
      friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position - 1, :y_position => self.y_position - 2, :captured => nil).first
      if friendly_piece == nil && self.x_position - 1 > 0 && self.y_position - 2 > 0
        possible_moves += [[self.x_position - 1, self.y_position - 2]]
      end

      # 1 up, 2 right:
      friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position + 2, :y_position => self.y_position - 1, :captured => nil).first
      if friendly_piece == nil && self.x_position + 2 < 9 && self.y_position - 1 > 0
        possible_moves += [[self.x_position + 2, self.y_position - 1]]
      end

      # 1 up, 2 left:
      friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position - 2, :y_position => self.y_position - 1, :captured => nil).first
      if friendly_piece == nil && self.x_position - 2 > 0 && self.y_position - 1 > 0
        possible_moves += [[self.x_position - 2, self.y_position - 1]]
      end

    else
    # Black knights
      # Check the 8 possible L-shaped moves for a friendly piece at the destination square only.
      # 2 up, 1 right:
      friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position + 1, :y_position => self.y_position + 2, :captured => nil).first
      if friendly_piece == nil && self.x_position + 1 < 9 && self.y_position + 2 < 9
        possible_moves += [[self.x_position + 1, self.y_position + 2]]
      end

      # 2 up, 1 left:
      friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position - 1, :y_position => self.y_position + 2, :captured => nil).first
      if friendly_piece == nil && self.x_position - 1 > 0 && self.y_position + 2 < 9
        possible_moves += [[self.x_position - 1, self.y_position + 2]]
      end

      # 1 up, 2 right:
      friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position + 2, :y_position => self.y_position + 1, :captured => nil).first
      if friendly_piece == nil && self.x_position + 2 < 9 && self.y_position + 1 < 9
        possible_moves += [[self.x_position + 2, self.y_position + 1]]
      end

      # 1 up, 2 left:
      friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position - 2, :y_position => self.y_position + 1, :captured => nil).first
      if friendly_piece == nil && self.x_position - 2 > 0 && self.y_position + 1 < 9
        possible_moves += [[self.x_position - 2, self.y_position + 1]]
      end

      # 2 down, 1 right:
      friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position + 1, :y_position => self.y_position - 2, :captured => nil).first
      if friendly_piece == nil && self.x_position + 1 < 9 && self.y_position - 2 > 0
        possible_moves += [[self.x_position + 1, self.y_position - 2]]
      end

      # 2 down, 1 left:
      friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position - 1, :y_position => self.y_position - 2, :captured => nil).first
      if friendly_piece == nil && self.x_position - 1 > 0 && self.y_position - 2 > 0
        possible_moves += [[self.x_position - 1, self.y_position - 2]]
      end

      # 1 down, 2 right:
      friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position + 2, :y_position => self.y_position - 1, :captured => nil).first
      if friendly_piece == nil && self.x_position + 2 < 9 && self.y_position - 1 > 0
        possible_moves += [[self.x_position + 2, self.y_position - 1]]
      end

      # 1 down, 2 left:
      friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position - 2, :y_position => self.y_position - 1, :captured => nil).first
      if friendly_piece == nil && self.x_position - 2 > 0 && self.y_position - 1 > 0
        possible_moves += [[self.x_position - 2, self.y_position - 1]]
      end
    end

    return possible_moves
  end
end
