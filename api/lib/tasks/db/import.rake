namespace :db do
  desc "Import from production env"
  task import: :environment do
    raise 'this should be run in dev mode !!' unless Rails.env == 'development'

    uri = Mongo::URI.new(`heroku config:get MONGODB_URI --app hackerhouse-api`.chomp)
    tmp = Dir::Tmpname.make_tmpname('/tmp/', 'hh-dump')

    puts "Dumping #{uri.servers[0]} to #{tmp}..."
    `mongodump -h #{uri.servers[0]} -d #{uri.database} -u #{uri.credentials[:user]} -p #{uri.credentials[:password]} -o #{tmp}`
    dev = Mongoid.clients['default']
    `mongorestore --host #{dev['hosts'][0]} --drop -d #{dev['database']} #{tmp}/#{uri.database}`
  end
end