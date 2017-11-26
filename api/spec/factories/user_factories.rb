FactoryGirl.define do

  factory :user do
    email 'paul@42.student.fr'
    firstname 'Paul'
    lastname 'Amicel'
    password 'tiramisu42'
    check_in '2016-12-20'
    check_out '2017-02-20'
    avatar_url 'http://avatar.slack.com/paul.jpg'
    house
    active true
  end
end
