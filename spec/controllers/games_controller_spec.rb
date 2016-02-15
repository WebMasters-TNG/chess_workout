require 'rails_helper'


RSpec.describe GamesController, type: :controller do
  describe "Action: games#index" do
    it "should successfully show the index page" do
      user_sign_in
      get :index
      expect(response).to have_http_status(:success)
    end

    it "should require sign in" do
      get :index
      expect(response).to redirect_to new_user_session_path
    end
  end

  describe "Action: games#show" do
    it "should successfully display the show page if the game is found" do
      user_sign_in
      game = FactoryGirl.create(:game)
      get :show, :id => game.id
      expect(response).to have_http_status(:success)
    end

    it "should return a 404 error if the game is not found" do
      user_sign_in
      get :show, :id => "NONSENSE"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "Action: games#create" do
    subject { post :create, :game => { :white_player_id => "", :black_player_id => "", :turn => "", :winner => "" } }

    it "should require users to be logged in" do
      expect(subject).to redirect_to new_user_session_path
    end

    it "should redirect a user to the show page upon creation (pressing the
      'Start Game' button in the Games lobby)" do
      user_sign_in
      expect(subject).to redirect_to("/games/#{assigns(:game).id}")
      expect(Game.count).to eq 1
    end
  end

  private
  def user_sign_in
    user = FactoryGirl.create(:user)
    sign_in user
  end

end

