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
    @game = Game.find_by_id(params[:id])
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
    last_move = @game.moves.where(id: move_id + 1).first   # Check the server for a move id greater than the last known value
    if !last_move.nil?
      render json: {new_move: last_move, turn: @game.turn}  # Return last move and turn data to client side
    end
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
    binding.pry
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
