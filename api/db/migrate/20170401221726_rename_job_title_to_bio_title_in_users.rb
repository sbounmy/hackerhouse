class RenameJobTitleToBioTitleInUsers < Mongoid::Migration
  def self.up
    User.all.rename(job_title: :bio_title)
  end

  def self.down
    User.all.rename(bio_title: :job_title)
  end
end