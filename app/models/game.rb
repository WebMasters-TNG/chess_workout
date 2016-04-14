class Game < ActiveRecord::Base
  has_many :pieces
  has_many :moves, through: :pieces
  # The associations below will enable us to use game.white_player, game.black_player:

  belongs_to :white_player, class_name: 'User', foreign_key: :white_player_id
  belongs_to :black_player, class_name: 'User', foreign_key: :black_player_id
  after_create :initialize_board

  # Directly create pieces and add them to the pieces collection.
  def initialize_board
    # Non-pawns for black player:
    Rook.create(x_position: 1, y_position: 1, game_id: id, color: "black", player_id: black_player_id)
    Knight.create(x_position: 2, y_position: 1, game_id: id, color: "black", player_id: black_player_id)
    Bishop.create(x_position: 3, y_position: 1, game_id: id, color: "black", player_id: black_player_id)
    Queen.create(x_position: 4, y_position: 1, game_id: id, color: "black", player_id: black_player_id)
    King.create(x_position: 5, y_position: 1, game_id: id, color: "black", player_id: black_player_id)
    Bishop.create(x_position: 6, y_position: 1, game_id: id, color: "black", player_id: black_player_id)
    Knight.create(x_position: 7, y_position: 1, game_id: id, color: "black", player_id: black_player_id)
    Rook.create(x_position: 8, y_position: 1, game_id: id, color: "black", player_id: black_player_id)

    # Non-pawns for white player:
    Rook.create(x_position: 1, y_position: 8, game_id: id, color: "white", player_id: white_player_id)
    Knight.create(x_position: 2, y_position: 8, game_id: id, color: "white", player_id: white_player_id)
    Bishop.create(x_position: 3, y_position: 8, game_id: id, color: "white", player_id: white_player_id)
    Queen.create(x_position: 4, y_position: 8, game_id: id, color: "white", player_id: white_player_id)
    King.create(x_position: 5, y_position: 8, game_id: id, color: "white", player_id: white_player_id)
    Bishop.create(x_position: 6, y_position: 8, game_id: id, color: "white", player_id: white_player_id)
    Knight.create(x_position: 7, y_position: 8, game_id: id, color: "white", player_id: white_player_id)
    Rook.create(x_position: 8, y_position: 8, game_id: id, color: "white", player_id: white_player_id)

    # Pawns for both players:
    for i in 1..8
      Pawn.create(color: "black", x_position: i, y_position: 2, game_id: id, player_id: black_player_id)
      Pawn.create(color: "white", x_position: i, y_position: 7, game_id: id, player_id: white_player_id)
    end

    self.counter = 0
    # Saves the counter to the database.
    self.save
  end

  def white_pieces
    self.pieces.where(color: 'white')
  end

  def black_pieces
    self.pieces.where(color: 'black')
  end

	def join_as_black(user)
		self.update_attributes(black_player_id: user.id)
		self.pieces.where(color: "black").join_as_black(user)
	end

	def next_turn
		increment_turn = self.turn + 1
		self.update_attributes(turn: increment_turn)
	end

	def your_turn?(piece)
		case self.turn % 2
		when 1
			return true if piece.color == "white"
		when 0
			return true if piece.color == "black"
		end
		false
	end

#
  # def next_move
  #   self.counter += 1
  #   self.save
  #   self.counter
  # end
end
