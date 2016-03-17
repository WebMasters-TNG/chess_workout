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
    # return false if pinned?
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


  # Check the piece currently at the destination square. If there is no piece, return nil.
  def destination_piece
    game.pieces.where(x_position: @x1, y_position: @y1, captured: nil).first
  end

  # Update status of captured piece accordingly and create new move to send to browser to update client side. 
  def capture_destination_piece
    if capture_piece?
      Move.create(game_id: game.id, piece_id: destination_piece.id, old_x: @x1, old_y: @y1, captured_piece: true)
      destination_piece.update_attributes(captured: true)
    end
  end

  # Check to see if destination square is occupied by a piece, returning false if it is friendly or true if it is an opponent
  def capture_piece?
    return false if destination_piece && destination_piece.color == color
    true
  end

  # def check?(player_color)
  #   player_color == "white" ? opponent_color = "black" : opponent_color = "white"
  #   opponent_king = game.pieces.where(type: "King", color: opponent_color).first
  #   friendly_pieces = game.pieces.where(color: player_color, captured: nil).all
  #   in_check = false
  #   @threatening_pieces = []
  #   friendly_pieces.each do |piece|
  #     if piece.valid_move?(opponent_king.x_position, opponent_king.y_position)
  #       in_check = true 
  #       @threatening_pieces << piece
  #   end
  #   in_check
  # end

  # def checkmate?
  #   if check?(color)

  #   else
  #     return false
  #   end
  # end

  # ***********************************************************
  # Pinning needs specific attention!!
  # => It involves checking whether the King will be under
  # check if this piece is moved.
  # => AND!! This method MUST be called BEFORE capture_destination_piece?
  # or otherwise an innocent piece will be captured.
  # ***********************************************************
  def pinned?
    color == "white" ? opponent_color = "black" : opponent_color = "white"
    return true if check?(opponent_color)
    false # Placeholder value. Assume this current piece is not pinned.
  end

  def update_move
    moves.where(piece_id: id).first.nil? ? inc_move = 1 : inc_move = moves.where(piece_id: id).last.move_count + 1
    Move.create(game_id: game.id, piece_id: id, move_count: inc_move, old_x: @x0, new_x: @x1, old_y: @y0, new_y: @y1)
  end

  def first_move?
    self.moves.first.nil?
  end

  def self.join_as_black(user)
    self.all.each do |black_piece|
      black_piece.update_attributes(player_id: user.id)
    end
  end

end
