desc "This task is called by the Heroku scheduler add-on"

task :send_reminders => :environment do
  puts "Sending reminders..."
  users = User.send_reminders(30.days, 15.days, 5.days)
  puts "#{users.length} Reminded : #{users.map {|u| "#{u.email} : #{u.check_out}"}}"
  puts "Done..."
end