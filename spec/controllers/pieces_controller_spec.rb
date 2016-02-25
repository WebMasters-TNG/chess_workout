require 'rails_helper'

RSpec.describe PiecesController, type: :controller do
  describe "Action: pieces#update" do
    it "should update a piece's position and advance the game to the next turn after a valid move" do
      user_sign_in
      game = FactoryGirl.create(:game, :white_player_id =>
        @user.id)
      piece = FactoryGirl.create(:piece, :game => game, :player_id => @user.id)
      # Move a white pawn 2 vertical spaces on its first turn, and record the move:
      put :update, :id => piece.id, :piece => { :x_position => piece.x_position, :y_position => 5 }, :format => :js
      piece.reload
      expect(piece.y_position).to eq 5
      expect(piece.game.turn).to eq 2
    end

    it "should recognize en passant as a valid move" do
      user_sign_in
    end

    it "should allow pawn promotion" do
      user_sign_in
    end

    it "should recognize castling as a valid move" do
      user_sign_in
    end
  end

  private
  def user_sign_in
    @user = FactoryGirl.create(:user)
    sign_in @user
  end
end
