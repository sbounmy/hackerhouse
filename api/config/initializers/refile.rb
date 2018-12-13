require 'refile/rails'

# Allow to be serialized by ActiveModel Serializer
Refile::File.send :include, ActiveModel::Serialization

if Rails.env.production?
  require "refile/s3"
  aws = {
    access_key_id: ENV['S3_ACCESS'],
    secret_access_key: ENV['S3_SECRET'],
    region: "eu-west-3",
    bucket: ENV['S3_DIRECTORY'] || 'hackerhouse-development'
  }
  Refile.cache = Refile::S3.new(prefix: "cache", **aws)
  Refile.store = Refile::S3.new(prefix: "store", **aws)
end