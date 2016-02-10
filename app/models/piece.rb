class Piece < ActiveRecord::Base
	# shared functionality for all pieces goes here
  belongs_to :game
  # Have the game keep track of which user a piece belongs to, instead of directly associating the pieces with a user.
end
