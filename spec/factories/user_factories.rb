FactoryGirl.define do

  factory :user do
    email 'paul@42.student.fr'
    firstname 'Paul'
    lastname 'Amicel'
    password 'tiramisu42'
    moving_on '2016-12-20'
    avatar_url 'http://avatar.slack.com/paul.jpg'
    house
  end
end
