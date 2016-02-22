require 'rails_helper'

RSpec.describe PiecesController, type: :controller do
  describe "Action: pieces#update" do
    it "should create a move when a move is valid" do
      user_sign_in
      game = FactoryGirl.create(:game)
      # Test a white pawn's movement on its first turn:
      piece = FactoryGirl.create(:piece)
      move = FactoryGirl.create(:move)
      patch :update, :id => game.id, :pieces => {  }
      piece_params = { x_position: piece.x_position, y_position: piece.y_position }
      if piece.valid_move?(piece_params)
        # Move the pawn and count the move:
        move.new_x = 1
        move.new_y = 5
        expect(move.move_count).to eq 1
      else
        expect(move.move_count).to eq "Nonsense"
      end
    end
  end

  private
  def user_sign_in
    user = FactoryGirl.create(:user)
    sign_in user
  end
end
