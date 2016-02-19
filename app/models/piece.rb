class Piece < ActiveRecord::Base
	# shared functionality for all pieces goes here
  belongs_to :game
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
    return false if this_captured? || same_sq?(params) ||  !capture_dest_piece?(@x1, @y1).nil?
    true
  end

  # ***********************************************************
  # Pinning needs specific attention!!
  # => It involves checking whether the King will be under
  # check if this piece is moved.
  # => AND!! This method MUST be called BEFORE capture_dest_piece?
  # or otherwise an innocent piece will be captured.
  # ***********************************************************

  def pinned?
    false # Placeholder value. Assume this current piece is not pinned.
  end

  # Check if this requesting piece is already captured.
  def this_captured?
    !self.captured.blank?
  end

  # Check the piece currently at the destination square. If there is no piece, return nil.
  def destination_piece(x, y)
    self.game.pieces.where(x_position: x, y_position: y, captured: nil).order("updated_at DESC").first
  end

  def capture_dest_piece?(x, y)
    dest_piece = destination_piece(x, y)
    return false if !dest_piece.nil? && dest_piece.color == self.color
  end

  def capture_piece(params)
    x1 = params[:x_position].to_i
    y1 = params[:y_position].to_i
    dest_piece = destination_piece(x1, y1)
    dest_piece.update_attributes(captured: true) if !dest_piece.nil?
  end

  def self.join_as_black(user)
    self.all.each do |black_piece|
      black_piece.update_attributes(player_id: user.id)
    end
  end

  def same_sq?(params)
    x0 = self.x_position
    y0 = self.y_position
    x1 = params[:x_position].to_i
    y1 = params[:y_position].to_i
    x0 == x1 && y0 == y1
  end
end
