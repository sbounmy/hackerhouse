FROM driftrock/heroku-cli:latest as heroku

FROM ruby:2.4-jessie

MAINTAINER Stephane BOUNMY <stephane@hackerhouse.paris>

# Install apt based dependencies required to run Rails as 
# well as RubyGems. As the Ruby image itself is based on a 
# Debian image, we use apt-get to install those.
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
RUN echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.6 main" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list

RUN apt-get update && apt-get upgrade -y
RUN apt-get install build-essential -y \
            git \
            mongodb-org-tools


# Copy executable from heroku image
COPY --from=heroku /usr/local/bin/heroku /usr/local/bin/heroku
RUN heroku update

# Configure the main working directory. This is the base 
# directory used in any further RUN, COPY, and ENTRYPOINT 
# commands.
# RUN mkdir -p /usr/src/app 
WORKDIR /usr/src/app

# Copy the Gemfile as well as the Gemfile.lock and install 
# the RubyGems. This is a separate step so the dependencies 
# will be cached unless changes to one of those two files 
# are made.
COPY Gemfile* ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

# Copy the main application.
COPY . .