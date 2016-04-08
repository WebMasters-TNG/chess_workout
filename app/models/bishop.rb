class Bishop < Piece
  def valid_move?(params)
    return false unless super
    return false unless diagonal_move? && path_clear?
    capture_piece?
  end

  def possible_moves
    possible_moves = []

    if self.color == "white"
      friendly_pieces = []
      enemy_pieces = []
    # Check that each white bishop has clear diagonal path (4 possible diagonal directions)
    # Check lower right diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position + n, :y_position => self.y_position + n, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "black", :x_position => self.x_position + n - 1, :y_position => self.y_position + n - 1, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1] != nil || enemy_pieces[m - 1] != nil
          break
        else
          if self.x_position + m < 9 && self.y_position + m < 9
            possible_moves += [[self.x_position + m, self.y_position + m]]
          end
        end
      end

      # Check lower left diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position - n, :y_position => self.y_position + n, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "black", :x_position => self.x_position - n + 1, :y_position => self.y_position + n - 1, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1 + 7] != nil || enemy_pieces[m - 1 + 7] != nil
          break
        else
          if self.x_position - m > 0 && self.y_position + m < 9
            possible_moves += [[self.x_position - m, self.y_position + m]]
          end
        end
      end

      # Check upper right diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position + n, :y_position => self.y_position - n, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "black", :x_position => self.x_position + n - 1, :y_position => self.y_position - n + 1, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1 + 14] != nil || enemy_pieces[m - 1 + 14] != nil
          break
        else
          if self.x_position + m < 9 && self.y_position - m > 0
            possible_moves += [[self.x_position + m, self.y_position - m]]
          end
        end
      end

      # Check upper left diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position - n, :y_position => self.y_position - n, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "black", :x_position => self.x_position - n + 1, :y_position => self.y_position - n + 1, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1 + 21] != nil || enemy_pieces[m - 1 + 21] != nil
          break
        else
          if self.x_position - m > 0 && self.y_position - m > 0
            possible_moves += [[self.x_position - m, self.y_position - m]]
          end
        end
      end

    else
    # Black bishops
      friendly_pieces = []
      enemy_pieces = []
      # Check that each black bishop has clear diagonal path (4 possible diagonal directions)
      # Check upper right diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position + n, :y_position => self.y_position + n, :captured => nil).first
        friendly_pieces += [friendly_piece]
        # Enemy pieces at the destination square can be captured, but others on the movement path will block the black bishop:
        enemy_piece = game.pieces.where(:color => "white", :x_position => self.x_position + n - 1, :y_position => self.y_position + n - 1, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1] != nil || enemy_pieces[m - 1] != nil
          break
        else
          if self.x_position + m < 9 && self.y_position + m < 9
            possible_moves += [[self.x_position + m, self.y_position + m]]
          end
        end
      end

      # Check upper left diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position - n, :y_position => self.y_position + n, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "white", :x_position => self.x_position - n + 1, :y_position => self.y_position + n - 1, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1 + 7] != nil || enemy_pieces[m - 1 + 7] != nil
          break
        else
          if self.x_position - m > 0 && self.y_position + m < 9
            possible_moves += [[self.x_position - m, self.y_position + m]]
          end
        end
      end

      # Check lower right diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position + n, :y_position => self.y_position - n, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "white", :x_position => self.x_position + n - 1, :y_position => self.y_position - n + 1, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1 + 14] != nil || enemy_pieces[m - 1 + 14] != nil
          break
        else
          if self.x_position + m < 9 && self.y_position - m > 0
            possible_moves += [[self.x_position + m, self.y_position - m]]
          end
        end
      end

      # Check lower left diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position - n, :y_position => self.y_position - n, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "white", :x_position => self.x_position - n + 1, :y_position => self.y_position - n + 1, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1 + 21] != nil || enemy_pieces[m - 1 + 21] != nil
          break
        else
          if self.x_position - m > 0 && self.y_position - m > 0
            possible_moves += [[self.x_position - m, self.y_position - m]]
          end
        end
      end
    end

    return possible_moves
  end

end
