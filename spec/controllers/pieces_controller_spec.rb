require 'rails_helper'

RSpec.describe PiecesController, type: :controller do
  describe "Action: pieces#update" do
    it "should update a pawn's position and advance the game to the next turn after a valid move" do
      user_sign_in
      game = FactoryGirl.create(:game, :white_player_id => @user.id)
      piece = FactoryGirl.create(:white_pawn, :game => game, :player_id => @user.id)

      # Move a white pawn 2 vertical spaces on its first turn:
      put :update, :id => piece.id, :piece => { :x_position => 1, :y_position => 4 }, :format => :js
      piece.reload

      # expect(piece.y_position).to eq 4
      expect(piece.game.turn).to eq 2
    end

    it "should check for invalid pawn moves" do

    end

    it "should check for blocking" do

    end

    it "should update a rook's position and advance the game to the next turn after a valid move" do
      user_sign_in
      game = FactoryGirl.create(:game, :white_player_id => @user.id)
      # The white rook begins at [2, 4]
      white_rook = FactoryGirl.create(:white_rook, :game => game, :player_id => @user.id)

      # Move a white rook 3 horizontal spaces on its first turn:
      put :update, :id => white_rook.id, :piece => { :x_position => 5, :y_position => 4 }, :format => :js
      white_rook.reload

      expect(white_rook.x_position).to eq 5
      expect(white_rook.y_position).to eq 4
      expect(white_rook.game.turn).to eq 2
    end

    it "should recognize en passant as a valid move for the white pawn" do
      user_sign_in
      game = FactoryGirl.create(:game, :white_player_id => @user.id, :black_player_id => @user2.id)
      white_pawn = FactoryGirl.create(:white_pawn, :game => game, :player_id => @user.id)
      # Modify factory piece to start at [2, 4]
      white_pawn.x_position = 2
      white_pawn.y_position = 5
      white_pawn_start_x = white_pawn.x_position
      white_pawn_start_y = white_pawn.y_position

      black_pawn = FactoryGirl.create(:black_pawn, :game => game, :player_id => :black_player_id)

      # The black pawn makes its staring move from [1, 7] to [1, 5]
      put :update, :id => black_pawn.id, :piece => { :x_position => 1, :y_position => 5 }, :format => :js
      black_pawn.reload

      # The white pawn makes an en passant capture on the black pawn, moving from [2, 5] to [1, 6] (assume en passant is valid prior to confirming below)
      put :update, :id => white_pawn.id, :piece => { :x_position => 1, :y_position => 6 }, :format => :js
      white_pawn.reload

      # Check that the white pawn can execute the en_passant move
      expect(white_pawn.en_passant?(white_pawn_start_x, white_pawn_start_y, white_pawn.x_position, white_pawn.y_position)).to eq true

      expect(white_pawn.x_position).to eq 1
      expect(white_pawn.y_position).to eq 6
      expect(black_pawn.captured).to eq true
      expect(white_pawn.game.turn).to eq 3
    end


    it "should recognize en passant as a valid move for the black pawn" do
      # user_sign_in
      # game = FactoryGirl.create(:game, :white_player_id => @user.id, :black_player_id => @user2.id)
      # black_pawn = FactoryGirl.create(:black_pawn, :game => game, :player_id => :black_player_id)
      # # Modify factory piece to start at [, ]
      # black_pawn.x_position =
      # black_pawn.y_position =
      # black_pawn_start_x = black_pawn.x_position
      # black_pawn_start_y = black_pawn.y_position

      # # The black pawn makes an en passant capture on the white pawn, moving from [] to [] (assume en passant is valid prior to confirming below)
      # put :update, :id => black_pawn.id, :piece => { :x_position => , :y_position =>  }, :format => :js
      # black_pawn.reload

      # # *** NEED to put in opponent's id for the :player_id ***
      # white_pawn = FactoryGirl.create(:white_pawn, :game => game, :player_id => :white_player_id)

      # # White pawn starts at [1, 2]
      # white_pawn.x_position =
      # white_pawn.y_position =

      # # The white pawn makes its staring move from [, ] to [, ]
      # put :update, :id => white_pawn.id, :piece => { :x_position => , :y_position =>  }, :format => :js
      # white_pawn.reload

      # # *** Check that the black pawn can execute the en_passant move ***
      # expect(black_pawn.en_passant?(black_pawn_start_x, black_pawn_start_y, black_pawn.x_position, black_pawn.y_position)).to eq true

      # expect(black_pawn.x_position).to eq 1
      # expect(black_pawn.y_position).to eq 6
      # expect(white_pawn.captured).to eq true
      # expect(black_pawn.game.turn).to eq 3
    end


    it "should not recognize an invalid en passant move for the white pawn" do
      user_sign_in
    end


    it "should not recognize an invalid en passant move for the black pawn" do
      user_sign_in
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
    @user2 = FactoryGirl.create(:user)
    sign_in @user
  end
end
