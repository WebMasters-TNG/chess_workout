class Rook < Piece
  def valid_move?(params)
    return false unless super
    return false unless straight_move? && path_clear?
    capture_piece?
  end

  def possible_moves

    possible_moves = []

    if self.color == "white"
      # Check that each white rook has a clear path (no friendly pieces along the way or at the destination spot, or any enemy pieces along the way).

      # Check the right horizontal path:
      friendly_pieces = []
      enemy_pieces = []
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "white", :x_position => self.x_position + n, :y_position => self.y_position, :captured => nil).first
        friendly_pieces += [friendly_piece]
        # Enemy pieces at the destination square can be captured, but others on the movement path (n - 1) will block the white rook:
        enemy_piece = game.pieces.where(:color => "black", :x_position => self.x_position + n - 1, :y_position => self.y_position, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        # Friendly pieces or enemy pieces are present in the path:
        if friendly_pieces[m - 1] != nil || enemy_pieces[m - 1] != nil
          break
        # Neither friendly nor enemy pieces are present in the path:
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

    else
    # Black rooks

      friendly_pieces = []
      enemy_pieces = []

      # Check the right horizontal path:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position + n, :y_position => self.y_position, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "white", :x_position => self.x_position + n - 1, :y_position => self.y_position, :captured => nil).first
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
        friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position - n, :y_position => self.y_position, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "white", :x_position => self.x_position - n + 1, :y_position => self.y_position, :captured => nil).first
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
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position, :y_position => self.y_position + n, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "white", :x_position => self.x_position, :y_position => self.y_position + n - 1, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1 + 14] != nil || enemy_pieces[m - 1 + 14] != nil
          break
        else
          if self.y_position + m < 9
            possible_moves += [[self.x_position, self.y_position + m]]
          end
        end
      end

      # Check the downward vertical path:
      for n in 1..7
        friendly_piece = game.pieces.where(:color => "black", :x_position => self.x_position, :y_position => self.y_position - n, :captured => nil).first
        friendly_pieces += [friendly_piece]
        enemy_piece = game.pieces.where(:color => "white", :x_position => self.x_position, :y_position => self.y_position - n + 1, :captured => nil).first
        enemy_pieces += [enemy_piece]
      end
      for m in 1..7
        if friendly_pieces[m - 1 + 21] != nil || enemy_pieces[m - 1 + 21] != nil
          break
        else
          if self.y_position - m > 0
            possible_moves += [[self.x_position, self.y_position - m]]
          end
        end
      end
    end

    return possible_moves
  end

end
