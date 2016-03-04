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
    y_position 7
  end

  factory :black_pawn, :class => Pawn, :parent => :piece do
    type "Pawn"
    color "black"
    x_position 1
    y_position 2
  end

  factory :white_rook, :class => Rook, :parent => :piece do
    type "Rook"
    color "white"
    x_position 1
    y_position 8
  end

  factory :white_knight, :class => Knight, :parent => :piece do
    type "Knight"
    color "white"
    x_position 2
    y_position 8
  end

  factory :white_bishop, :class => Bishop, :parent => :piece do
    type "Bishop"
    color "white"
    x_position 3
    y_position 8
  end

  factory :white_queen, :class => Queen, :parent => :piece do
    type "Queen"
    color "white"
    x_position 4
    y_position 8
  end

  factory :white_king, :class => King, :parent => :piece do
    type "King"
    color "white"
    x_position 5
    y_position 8
  end

  factory :black_king, :class => King, :parent => :piece do
    type "King"
    color "black"
    x_position 5
    y_position 1
  end

  # Set up an initially empty move, then adjust the values after checking that a piece can be moved:
  factory :move do
    association :piece
    # association :white_pawn, :factory => :piece
    # association :black_pawn, :factory => :piece
    # association :white_rook, :factory => :piece
    old_x 0
    old_y 0
    new_x 0
    new_y 0
    move_count 0
  end

end
