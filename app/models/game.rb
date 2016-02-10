class Game < ActiveRecord::Base
	has_many :pieces
	has_and_belongs_to_many :users

  # Directly create pieces and add them to the pieces collection.
  def self.create_game
    game = Game.create

    # Non-pawns for black player:
    black_rook1 = Rook.create(x_position: 0, y_position: 7)
    game.pieces << black_rook1
    black_knight1 = Knight.create(x_position: 1, y_position: 7)
    game.pieces << black_knight1
    black_bishop1 = Bishop.create(x_position: 2, y_position: 7)
    game.pieces << black_bishop1
    black_king = King.create(x_position: 3, y_position: 7)
    game.pieces << black_king
    black_queen = Queen.create(x_position: 4, y_position: 7)
    game.pieces << black_queen
    black_bishop2 = Bishop.create(x_position: 5, y_position: 7)
    game.pieces << black_bishop2
    black_knight2 = Knight.create(x_position: 6, y_position: 7)
    game.pieces << black_knight2
    black_rook2 = Rook.create(x_position: 7, y_position: 7)
    game.pieces << black_rook2

    # Non-pawns for white player:
    white_rook1 = Rook.create(x_position: 0, y_position: 0)
    game.pieces << white_rook1
    white_knight1 = Knight.create(x_position: 1, y_position: 0)
    game.pieces << white_knight1
    white_bishop1 = Bishop.create(x_position: 2, y_position: 0)
    game.pieces << white_bishop1
    white_king = King.create(x_position: 3, y_position: 0)
    game.pieces << white_king
    white_queen = Queen.create(x_position: 4, y_position: 0)
    game.pieces << white_queen
    white_bishop2 = Bishop.create(x_position: 5, y_position: 0)
    game.pieces << white_bishop2
    white_knight2 = Knight.create(x_position: 6, y_position: 0)
    game.pieces << white_knight2
    white_rook2 = Rook.create(x_position: 7, y_position: 0)
    game.pieces << white_rook2

    # Pawns for both players:
    for i in 0..7
      game.pieces << Pawn.create(color: "black", x_position: i, y_position: 1)
      game.pieces << Pawn.create(color: "white", x_position: i, y_position: 6)
    end

    # The white player makes the first move
    game.turn = "white"

    return game
  end

end
