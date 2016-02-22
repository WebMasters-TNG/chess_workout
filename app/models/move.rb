class Move < ActiveRecord::Base
  belongs_to :piece
  belongs_to :game
end
