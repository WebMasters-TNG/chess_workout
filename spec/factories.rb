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
    # *** Consider making a database association between Game and User ***
    # association :user
  end

  factory :piece do

  end

  # factory :game_params do

  # end

end
