class GenerateDefaultPasswordToUsers < Mongoid::Migration
  def self.up
    User.all.each do |user|
      if user.password_digest.nil?
        # generate default password atm : stephane@hackerhouse.paris -> stephane42
        user.password = "#{user.email.split('@')[0]}42"
      end
      user.save!
    end
  end

  def self.down
    User.update_all(password_digest: nil)
  end
end