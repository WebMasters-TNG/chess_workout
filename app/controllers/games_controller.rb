class GamesController < ApplicationController
  before_action :authenticate_user!

  def index
    @games = Game.all
  end

  def show
    # .find_by_id will return a nil value if the id doesn't exist.
    @game = Game.find_by_id(params[:id])
    return render_not_found if @game.blank?
  end

  def create
    # @game = Game.create(game_params)
    @game = Game.create_game
    if @game.valid?
      redirect_to game_path(@game)
    else
      render_not_found(:unprocessable_entity)
    end
  end


  private
  def game_params
    params.require(:game).permit(:white_player_id, :black_player_id, :turn, :winner)
  end

  def render_not_found(status=:not_found)
    render :text => "#{status.to_s.titleize}", :status => status
  end
end
