class CopyMovingOnToCheckInToUsers < Mongoid::Migration
  def self.up
  	User.all.each do |user|
		  user.update_attributes check_in: user.moving_on.to_date
  	end
  end

  def self.down
  end
end