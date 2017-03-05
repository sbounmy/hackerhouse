FactoryGirl.define do

  factory :user do
    email 'paul@42.student.fr'
    password 'tiramisu42'
    moving_on '2016-12-20'
    house
  end
end
