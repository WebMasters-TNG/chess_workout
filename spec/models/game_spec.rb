require 'rails_helper'

RSpec.describe Game, type: :model do
  it "creates a game with 32 pieces and begins with the white player's turn" do
    # user = FactoryGirl.create(:user)
    # game_params = FactoryGirl.create(:game_params)
    game = Game.create_game
    expect(game.pieces.count).to eq 32
    expect(game.turn).to eq "white"
  end
end
