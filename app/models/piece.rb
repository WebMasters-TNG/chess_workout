class Piece < ActiveRecord::Base
	# shared functionality for all pieces goes here
  belongs_to :game
  has_many :moves
  # belongs_to :player, class_name: "User", foreign_key: :player_id
  # Have the game keep track of which user a piece belongs to, instead of directly associating the pieces with a user.

  # Check if move is valid for selected piece
  def valid_move?(params)
    @x0 = self.x_position
    @y0 = self.y_position
    @x1 = params[:x_position].to_i
    @y1 = params[:y_position].to_i
    @sx = @x1 - @x0 # sx = displacement_x
    @sy = @y1 - @y0 # sy = displacement_y
    return false if pinned?
    true
  end

  # Check to see if the movement path is a valid diagonal move
  def diagonal_move?
    @sy.abs == @sx.abs
  end

  # Check to see if the movement pat is a valid straight move
  def straight_move?
    @x1 == @x0 || @y1 == @y0
  end

  # This method can be called by all piece types except the knight, whose moves are not considered below.
  # This will return true if there is no piece along the chosen movement path that has not been captured.
  def path_clear?
    clear = true
    if @x0 != @x1 && @y0 == @y1
      @x1 > @x0 ? x = @x1 - 1 : x = @x1 + 1
      until x == @x0 do
        clear = false if game.pieces.where(x_position: x, y_position: @y0, captured: nil).first != nil
        x > @x0 ? x -= 1 : x += 1
      end
    elsif @x0 == @x1 && @y0 != @y1
      @y1 > @y0 ? y = @y1 - 1 : y = @y1 + 1
      until y == @y0 do
        clear = false if game.pieces.where(x_position: @x0, y_position: y, captured: nil).first != nil
        y > @y0 ? y -= 1 : y += 1
      end
    elsif @x0 != @x1 && @y0 != @y1
      @x1 > @x0 ? x = @x1 - 1 : x = @x1 + 1
      @y1 > @y0 ? y = @y1 - 1 : y = @y1 + 1
      until x == @x0 && y == @y0 do
        clear = false if game.pieces.where(x_position: x, y_position: y, captured: nil).first != nil
        x > @x0 ? x -= 1 : x += 1
        y > @y0 ? y -= 1 : y += 1
      end
    end
    clear
  end

  # This method can be called by all piece types and will determine if there is a piece of the opposite color
  # in the target square and, if so, update the status of the captured piece accordingly. This should be called
  # after checking path_clear? with the exception being the knight.
  def capture_piece?
    captured_piece = game.pieces.where(x_position:  @x1, y_position: @y1, captured: nil).first
    return false if captured_piece && captured_piece.color == self.color
    captured_piece.update_attributes(captured: true) if captured_piece
    true
  end

  # ***********************************************************
  # Pinning needs specific attention!!
  # => It involves checking whether the King will be under
  # check if this piece is moved.
  # => AND!! This method MUST be called BEFORE capture_dest_piece?
  # or otherwise an innocent piece will be captured.
  # ***********************************************************

  def is_blocked?
    # Are there any pieces in between your origin and destination square?
    # if !is_knight && (self.x_position != other_player_piece.x_position && self.y_position != other_player_piece.y_position)
    true
  end

  def pinned?
    false # Placeholder value. Assume this current piece is not pinned.
  end





  # def path_clear?
  #   sx_arr = [0]
  #   sy_arr = [0]
  #   if @sx > 0
  #     sx_arr = (1).upto(@sx - 1).to_a
  #   elsif @sx < 0
  #     sx_arr = (-1).downto(@sx + 1).to_a
  #   end
  #   if @sy > 0
  #     sy_arr = (1).upto(@sy - 1).to_a
  #   elsif @sy < 0
  #     sy_arr = (-1).downto(@sy + 1).to_a
  #   end

  #   if diagonal_move?
  #     return true if @sx.abs == 1
  #     sx_arr.each_with_index do |i, index_i|
  #       sy_arr.each_with_index do |j, index_j|
  #         if index_i == index_j
  #           return false unless self.game.pieces.where(captured: nil, x_position: @x0 + i, y_position: @y0 + j).empty?
  #         end
  #       end
  #     end
  #   end

  #   if straight_move?
  #     sx_arr.each do |i|
  #       sy_arr.each do |j|
  #         return false unless self.game.pieces.where(captured: nil, x_position: @x0 + i, y_position: @y0 + j).empty?
  #       end
  #     end
  #   end
  #   true
  # end



  # Check if this requesting piece is already captured.
  # def this_captured?
  #   !self.captured.blank?
  # end

  # Check the piece currently at the destination square. If there is no piece, return nil.
  # *** Why was this method commented out after the last commit? ***
  def destination_piece(x, y)
    self.game.pieces.where(x_position: x, y_position: y, captured: nil).order("updated_at DESC").first
  end

  # def capture_dest_piece?(x, y)
  #   dest_piece = destination_piece(x, y)
  #   return false if !dest_piece.nil? && dest_piece.color == self.color
  # end

  # def capture_piece(params)
  #   x1 = params[:x_position].to_i
  #   y1 = params[:y_position].to_i
  #   dest_piece = destination_piece(x1, y1)
  #   dest_piece.update_attributes(captured: true) if !dest_piece.nil?
  # end

  def self.join_as_black(user)
    self.all.each do |black_piece|
      black_piece.update_attributes(player_id: user.id)
    end
  end

  # def same_sq?(params)
  #   x0 = self.x_position
  #   y0 = self.y_position
  #   x1 = params[:x_position].to_i
  #   y1 = params[:y_position].to_i
  #   x0 == x1 && y0 == y1
  # end
end
