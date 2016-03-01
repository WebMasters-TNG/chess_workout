FactoryGirl.define do

  factory :user do
    sequence :email do |n|
      "dummyEmail#{n}@gmail.com"
    end
    sequence :username do |n|
      "guest#{n}@gmail.com"
    end
    password "secretPassword"
    password_confirmation "secretPassword"
  end

  factory :game do
    association :white_player, factory: :user
    association :black_player, factory: :user
    turn 1
  end

  factory :piece do
    association :game
    captured false
  end

  factory :white_pawn, :class => Pawn, :parent => :piece do
    type "Pawn"
    color "white"
    x_position 1
    y_position 2
  end

  factory :black_pawn, :class => Pawn, :parent => :piece do
    type "Pawn"
    color "black"
    x_position 1
    y_position 7
  end

  factory :white_rook, :class => Rook, :parent => :piece do
    type "Rook"
    color "white"
    x_position 2
    y_position 4
  end

  # Set up an initially empty move, then adjust the values after checking that a piece can be moved:
  factory :move do
    association :piece
    old_x 1
    old_y 2
    new_x 1
    new_y 4
    move_count 0
  end

end
