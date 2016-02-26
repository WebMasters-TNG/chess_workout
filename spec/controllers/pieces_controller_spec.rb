require 'rails_helper'

RSpec.describe PiecesController, type: :controller do
  describe "Action: pieces#update" do
    it "should update a piece's position and advance the game to the next turn after a valid move" do
      user_sign_in
      game = FactoryGirl.create(:game, :white_player_id =>
        @user.id)
      white_pawn = FactoryGirl.create(:piece, :game => game, :player_id => @user.id)

      # Move a white pawn 2 vertical spaces on its first turn, and record the move:
      put :update, :id => white_pawn.id, :piece => { :x_position => white_pawn.x_position, :y_position => 5 }, :format => :js
      white_pawn.reload

      expect(white_pawn.y_position).to eq 5
      expect(white_pawn.game.turn).to eq 2
    end

    it "should recognize en passant as a valid move" do
      user_sign_in
      game = FactoryGirl.create(:game, :white_player_id =>
        @user.id)
      white_pawn = FactoryGirl.create(:piece, :game => game, :player_id => @user.id)
      # Modify factory piece to start at [2, 4]
      white_pawn.x_position = 2
      white_pawn.y_position = 4

      # *** NEED to put in opponent's id for the :player_id ***
      black_pawn = FactoryGirl.create(:piece, :game => game, :player_id => @user.id)


      # Modify factory piece to be a black pawn starting at [1, 7]
      black_pawn.color = "black"
      black_pawn.x_position = 1
      black_pawn.y_position = 7

      black_pawn_start_x = black_pawn.x_position
      black_pawn_start_y = black_pawn.y_position

      # The black pawn makes its staring move from [1, 7] to [1, 5]
      put :update, :id => black_pawn.id, :piece => { :x_position => 1, :y_position => 5 }, :format => :js
      black_pawn.reload

      # *** Check that the white pawn can execute the en_passant move ***
      expect(white_pawn.en_passant?(black_pawn_start_x, black_pawn_start_y, black_pawn.x_position, black_pawn.y_position)).to eq true

      # The white pawn makes an en passant capture on the black pawn, moving from [2, 5] to [1, 6]
      put :update, :id => white_pawn.id, :piece => { :x_position => 1, :y_position => 6 }, :format => :js
      white_pawn.reload

      expect(white_pawn.x_position).to eq 1
      expect(white_pawn.y_position).to eq 6
      expect(black_pawn.captured).to eq true
      expect(white_pawn.game.turn).to eq 3
    end

    it "should allow pawn promotion" do
      user_sign_in
    end

    it "should recognize castling as a valid move" do
      user_sign_in
    end

    it "should test for checkmate" do
      user_sign_in
    end
  end

  private
  def user_sign_in
    @user = FactoryGirl.create(:user)
    sign_in @user
  end
end
