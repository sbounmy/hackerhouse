Intro
-----

HackerHouse are big community houses run by hackers for hackers.
https://hackerhouse.paris

Every houses are self-managed and solidary meaning that when a roomate leaves, he has to be replaced by its staying roomates.

The doc is not up to date.
Will need big help to update doc

We use :
- Ruby On Rails as API (still have a part to migrate to react)
- React as Frontend
- Stripe as payment

Installation
------------

Download docker compose
https://download.docker.com/mac/stable/Docker.dmg

Build all images
docker-compose build

cp api/.env.example api/.env
change HEROKU_API_KEY to your key at https://dashboard.heroku.com/account

Commands
---------

```
# run tests (all)
docker-compose up test

# run single test (all)
docker-compose run --rm test bundle exec rspec spec/features/login_feature_spec.rb

# start rails server api go to http://localhost:3000/v1/users and check if its live
docker-compose up api

# start react app go to http://localhost:3001 careful you will need api to hace proper working app
docker-compose up app

# start react app AND api go to http://localhost:3001
docker-compose up app api

# sometime docker is spawning too much container, do :
docker-compose down
```

