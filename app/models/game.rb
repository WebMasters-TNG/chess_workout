class Game < ActiveRecord::Base
	has_many :pieces
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


  end
end
