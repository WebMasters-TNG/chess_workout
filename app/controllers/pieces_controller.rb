require 'pry'

class PiecesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_authorized_for_current_game, only: [:update]
  before_action :require_authorized_for_current_piece, only: [:update]
  before_action :your_turn?, only: [:update]

  def update
    # if move is valid. Call back methods from model.
    @piece = Piece.find(params[:id])
    if @piece.valid_move?(piece_params, @piece)
      current_piece.update_attributes(piece_params)
      # Send a message back to the JS after the update (after the data object is defined in the AJAX request) to confirm successful update or an error:
      respond_to do |format|
        format.js { render json: {success: true, status: :success} }
      end
    end
  end

  private

  def current_piece
    @current_piece ||= Piece.find_by_id(params[:id])
  end

  def require_authorized_for_current_piece
    if current_piece.player_id != current_user.id
      render text: 'Unauthorized', status: :unauthorized
    end
  end

  def piece_params
    params.require(:piece).permit(:x_position, :y_position, :type, :captured, :game_id)
  end

  def current_game
    @current_game ||= Piece.find_by_id(params[:id]).game
  end

  def require_authorized_for_current_game
    if current_game.white_player != current_user && current_game.black_player != current_user
      render text: 'Unauthorized', status: :unauthorized
    end
  end

  def your_turn?
    render text: 'Unauthorized', status: :unauthorized unless Game.your_turn?(current_game, current_piece)
  end
end
