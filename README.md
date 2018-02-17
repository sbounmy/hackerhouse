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

