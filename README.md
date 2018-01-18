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
docker-compose up test // run tests (all)
```

```
docker-compose run --rm test bundle exec rspec spec/features/login_feature_spec.rb // run single text (all)
```

```
docker-compose up api // start rails server api go to http://localhost:3000/v1/users
```

```
docker-compose up app // start react app go to http://localhost:3001 careful you will need api to hace proper working app
```

```
docker-compose up app api // start react app AND api go to http://localhost:3001
```
