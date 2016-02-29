require 'pry'

class PiecesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_authorized_for_current_game, only: [:update]
  before_action :require_authorized_for_current_piece, only: [:update]
  before_action :valid?, only: [:update]

  def update
    current_piece.capture_piece? # Check for and update captured pieces as part of move validation
    Piece.find_by_id(params[:id]).update_attributes(piece_params) # Do not use current_piece here solely for pawn promotion
    current_piece.update_move 
    current_game.next_turn
    # Send a message back to the JS after the update (after the data object is defined in the AJAX request) to confirm successful update or an error:
    respond_to do |format|
      format.js { render json: {success: true, status: :success} }
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
    params.require(:piece).permit(:x_position, :y_position, :type, :captured)
  end

  def current_game
    @current_game ||= current_piece.game
  end

  def require_authorized_for_current_game
    if current_game.white_player != current_user && current_game.black_player != current_user
      render text: 'Unauthorized', status: :unauthorized
    end
  end

  def valid?
    if !current_game.your_turn?(current_piece) || !current_piece.valid_move?(piece_params)
      render text: 'Unauthorized', status: :unauthorized
    end
  end
end
