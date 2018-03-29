FactoryGirl.define do

  factory :message do
    check_in  { 1.month.from_now }
    check_out { 4.month.from_now }
    house
    user
  end

end
