require 'rails_helper'

RSpec.describe PiecesController, type: :controller do
  describe "Action: pieces#update" do
    it "should create a move when a move is valid" do
      # user_sign_in
      user = FactoryGirl.create(:user)
      sign_in user
      game = FactoryGirl.create(:game, :white_player_id => user.id)
      # Test a white pawn's movement on its first turn:
      piece = FactoryGirl.create(:piece, :game => game, :player_id => user.id)
      if piece.valid_move?({ :x_position => piece.x_position, :y_position => 5, :type => piece.type, :captured => piece.captured })
        # Move the pawn 2 vertical spaces on its first turn, and record the move:
        # *** PROBLEM: The piece's y-position is not being updated. ***
        patch :update, :id => piece.id, :piece => { :y_position => 5 }, :format => :js
        # patch :update, :id => piece.id, :piece => { :x_position => piece.x_position, :y_position => 5, :type => piece.type, :captured => piece.captured }, :format => :js
        # *** piece.reload resets the piece's properties to their initial factory settings (after manually reassigning piece.y_position in rails console), but removing it does not fix the problem. ***
        piece.save
        # piece.reload
        # binding.pry
        move = FactoryGirl.create(:move, :piece => piece)
        expect(piece.y_position).to eq 5
        expect(game.turn).to eq 2
        expect(move.new_x).to eq piece.x_position
        expect(move.new_y).to eq piece.y_position
        expect(move.move_count).to eq 1
      else
        # Safety condition to ensure the test fails visibly when the move is invalid.
        expect(move.move_count).to eq "Invalid move!"
      end
    end

    # it "should recognize en passant as a valid move" do
    #   user_sign_in
    # end

    # it "should recognize castling as a valid move" do
    #   user_sign_in
    # end

    # it "should allow pawn promotion" do
    #   user_sign_in
    #   game = FactoryGirl.create(:game)
    #   piece = FactoryGirl.create(:piece)
    #   move = FactoryGirl.create(:move)
    #   if piece.valid_move?(:x_position => 1, :y_position => piece.y_position, :type => piece.type, :captured => piece.captured)
        #  patch :update, :id => piece.id, :piece => {  }
    #   end
    # end
  end

  private
  def user_sign_in
    user = FactoryGirl.create(:user)
    sign_in user
  end
end
