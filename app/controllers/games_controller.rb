class GamesController < ApplicationController
  before_action :authenticate_user!

  def index
    @game_new = Game.new
    @games = Game.all
    @user = User.all
  end

  def show
    # .find_by_id will return a nil value if the id doesn't exist.
    # Use a hash to reduce the number of queries:
    if Game.find_by_id(params[:id]) != nil
      @game = Game.find_by_id(params[:id])
    else
      return render_not_found
    end
    @game.moves.where(game_id: @game.id).last.nil? ? @last_move_id = 0 : @last_move_id = @game.moves.where(game_id: @game.id).last.id
    session[:current_game] = @game.id
    # @piece_hash =
    # @game.pieces.each do |piece|
    #   @piece_hash["#{piece.x_position}_#{piece.y_position}"] = piece
    # end
    return render_not_found if @game.blank?
  end

  # This action is called by AJAX request to check the server for new moves.
  def refresh_game
    move_id = params[:move_id].to_i
    game_id = params[:game_id]
    @game = Game.find(session[:current_game])
    new_moves = @game.moves.where("moves.id >= ?", move_id + 1)
    render json: {new_move: new_moves, turn: @game.turn, status: @game.status}  # Return last move, turn, and game status data to client side
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

  def destroy
    current_game.pieces.destroy_all
    current_game.moves.destroy_all
    current_game.destroy
    redirect_to games_path
  end

  # def update
  #   current_game.update_attributes(game_params)
  #   redirect_to game_path(current_game)
  # end

  def join_game
    if current_game.black_player_id == nil
      current_game.join_as_black(current_user)
    end
    session[:current_game] = current_game.id
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
