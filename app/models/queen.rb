class Queen < Piece
  def legal_move?
    return false unless (straight_move? || diagonal_move?) && path_clear?
    capture_piece?
  end

  def possible_moves

    possible_moves = []

    if self.color == "white"
      friendly_pieces = []
      enemy_pieces = []

      # Check the 8 possible movement paths for the queen.
      # Check the right horizontal path:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position + n, :y_position => self.y_position, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "black", :x_position => self.x_position + n - 1, :y_position => self.y_position, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1] != nil || enemy_pieces[m - 1] != nil
          break
        else
           if self.x_position + m < 9
            possible_moves += [[self.x_position + m, self.y_position]]
          end
        end
      end

      # Check the left horizontal path:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position - n, :y_position => self.y_position, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "black", :x_position => self.x_position - n + 1, :y_position => self.y_position, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1 + 7] != nil || enemy_pieces[m - 1 + 7] != nil
          break
        else
           if self.x_position - m > 0
            possible_moves += [[self.x_position - m, self.y_position]]
          end
        end
      end

       # Check the upward vertical path:
       # Note:  "Up" is negative for white.
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position, :y_position => self.y_position - n, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "black", :x_position => self.x_position, :y_position => self.y_position - n + 1, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1 + 14] != nil || enemy_pieces[m - 1 + 14] != nil
          break
        else
          if self.y_position - m > 0
            possible_moves += [[self.x_position, self.y_position - m]]
          end
        end
      end

      # Check the downward vertical path:
      # Note: "Down" is positive for white.
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position, :y_position => self.y_position + n, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "black", :x_position => self.x_position, :y_position => self.y_position + n - 1, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1 + 21] != nil || enemy_pieces[m - 1 + 21] != nil
          break
        else
          if self.y_position + m < 9
            possible_moves += [[self.x_position, self.y_position + m]]
          end
        end
      end

      # Check lower right diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position + n, :y_position => self.y_position + n, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "black", :x_position => self.x_position + n - 1, :y_position => self.y_position + n - 1, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1 + 28] != nil || enemy_pieces[m - 1 + 28] != nil
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
        if friendly_pieces[m - 1 + 35] != nil || enemy_pieces[m - 1 + 35] != nil
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
        if friendly_pieces[m - 1 + 42] != nil || enemy_pieces[m - 1 + 42] != nil
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
        if friendly_pieces[m - 1 + 49] != nil || enemy_pieces[m - 1 + 49] != nil
          break
        else
          if self.x_position - m > 0 && self.y_position - m > 0
            possible_moves += [[self.x_position - m, self.y_position - m]]
          end
        end
      end

    else
    # Black queen
      friendly_pieces = []
      enemy_pieces = []

      # Check upward vertical paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position, :y_position => self.y_position + n, :captured => nil).first
        friendly_pieces += [friendly_piece]
          enemy_piece = game.pieces.where(:color => "white", :x_position => self.x_position, :y_position => self.y_position + n - 1, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1] != nil || enemy_pieces[m - 1] != nil
          break
        else
          if self.y_position + m < 9
            possible_moves += [[self.x_position, self.y_position + m]]
          end
        end
      end

      # Check downward vertical paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position, :y_position => self.y_position - n, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "white", :x_position => self.x_position, :y_position => self.y_position - n + 1, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1 + 7] != nil || enemy_pieces[m - 1 + 7] != nil
          break
        else
          if self.y_position - m > 0
            possible_moves += [[self.x_position, self.y_position - m]]
          end
        end
      end


      # Check upper right diagonal paths:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position + n, :y_position => self.y_position + n, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "white", :x_position => self.x_position + n - 1, :y_position => self.y_position + n - 1, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1 + 14] != nil || enemy_pieces[m - 1 + 14] != nil
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
        if friendly_pieces[m - 1 + 21] != nil || enemy_pieces[m - 1 + 21] != nil
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
        if friendly_pieces[m - 1 + 28] != nil || enemy_pieces[m - 1 + 28] != nil
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
        if friendly_pieces[m - 1 + 35] != nil || enemy_pieces[m - 1 + 35] != nil
          break
        else
          if self.x_position - m > 0 && self.y_position - m > 0
            possible_moves += [[self.x_position - m, self.y_position - m]]
          end
        end
      end

      # Check the right horizontal path:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position + n, :y_position => self.y_position, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "white", :x_position => self.x_position + n - 1, :y_position => self.y_position, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1 + 42] != nil || enemy_pieces[m - 1 + 42] != nil
          break
        else
          if self.x_position + m < 9
            possible_moves += [[self.x_position + m, self.y_position]]
          end
        end
      end

      # Check the left horizontal path:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position - n, :y_position => self.y_position, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "white", :x_position => self.x_position - n + 1, :y_position => self.y_position, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1 + 49] != nil || enemy_pieces[m - 1 + 49] != nil
          break
        else
          if self.x_position - m > 0
            possible_moves += [[self.x_position - m, self.y_position]]
          end
        end
      end
    end

    return possible_moves
  end
end
