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
    turn "white"
  end

  factory :piece do

  end

end
