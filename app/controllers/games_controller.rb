class GamesController < ApplicationController
  before_action :authenticate_user!

  def index
    @game_new = Game.new
    @games = Game.all
    @user = User.all
  end

  def show
    # .find_by_id will return a nil value if the id doesn't exist.
    @game = Game.find_by_id(params[:id])
    return render_not_found if @game.blank?
  end

  def create
    defaults = {white_player_id: current_user.id , turn: 1}
    @game = Game.create(defaults)
    if @game.valid?
      redirect_to game_path(@game)
    else
      render_not_found(:unprocessable_entity)
    end
  end

  def update
    current_game.update_attributes(game_params)
    redirect_to game_path(current_game)
  end

  def join_game
    if current_game.black_player_id == nil
      Game.join_as_black(current_game, current_user)
    end
    redirect_to game_path(current_game)
  end

  private

  # def game_params
  #   params.require(:game).permit(:white_player_id, :black_player_id, :turn, :winner)
  # end

  def current_game
    @current_game ||= Game.find(params[:id])
  end

  def render_not_found(status=:not_found)
    render :text => "#{status.to_s.titleize}", :status => status
  end
end
