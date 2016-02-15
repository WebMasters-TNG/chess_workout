require 'rails_helper'

RSpec.describe Game, type: :model do
  it "creates a game with 32 pieces and begins with the white player's turn" do
    game_params = FactoryGirl.attributes_for(:game)
    game = Game.create(game_params)

    expect(game.pieces.count).to eq 32
  end
end
