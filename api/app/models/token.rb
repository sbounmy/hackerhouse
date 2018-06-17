class Token
  include ActiveModel::Serializers::JSON

  # {"emailAddress"=>"stephanebounmy@gmail.com",
  #  "firstName"=>"Stephane",
  #  "headline"=>"Co-Founder HackerHouse - 🍙 Rice (& Durian) Lover - 🏠 IKEA Hacker - 🤓 Very Active Speaker",
  #  "id"=>"koEDMa7bPM",
  #  "industry"=>"Internet",
  #  "lastName"=>"Bounmy",
  #  "location"=>{"country"=>{"code"=>"fr"}, "name"=>"Paris Area, France"},
  #  "pictureUrls"=>{"_total"=>1, "values"=>["https://media.licdn.com/mpr/mprx/0_fvQ1tgoS9LfejF3AaLojtpQ7NQlERNSAac4YNpn_0-rdpv0xu5F099S5RF-"]},
  #  "positions"=>{"_total"=>2, "values"=>[{"company"=>{"id"=>10331406, "industry"=>"Computer Software", "name"=>"HackerHouse Paris", "size"=>"2-10", "type"=>"Privately Held"}, "id"=>743434256, "isCurrent"=>true, "location"=>{"country"=>{"code"=>"fr", "name"=>"France"}, "name"=>"Paris Area, France"}, "startDate"=>{"month"=>11, "year"=>2015}, "summary"=>"\"Do not delegate Growth\"\nProduct Market Fit / Growth Hacking", "title"=>"Co-Founder, Growth Lead"}, {"company"=>{"name"=>"Growth Hacking "}, "id"=>902040060, "isCurrent"=>true, "location"=>{"country"=>{"code"=>"fr", "name"=>"France"}, "name"=>"Paris Area, France"}, "startDate"=>{"month"=>1, "year"=>2016}, "summary"=>"Men lie, Women lie but Data don't. Let your metrics speak for yourself 🍄\nGiving 10+ monthly meetups/workshops about growth and hustling. 🚀\nHelped and advised 100+ early stage startups.", "title"=>"Very Active Speaker"}]},
  #  "publicProfileUrl"=>"https://www.linkedin.com/in/stephanebounmy"}
  #  => https://developer.linkedin.com/docs/fields/basic-profile
  def self.from_linkedin(token, response={})
    data = {
      email: response['emailAddress'],
      firstname: response['firstName'],
      lastname: response['lastName'],
      location: response['location']['name'],
      avatar_url: response['pictureUrl'], # response['pictureUrls']['values'][0] not working
      bio_title: response['headline'],
      bio_url: response['publicProfileUrl'] || response['siteStandardProfileRequest']['url'] # return authenticated profile url when not public profile
    }
    new(token, data)
  end

  attr_accessor :email, :firstname, :lastname, :avatar_url, :bio_title, :bio_url, :location, :token

  def initialize(token, data)
    @token = token
    data.each do |method_name, value|
      self.send("#{method_name}=", value)
    end
  end
end