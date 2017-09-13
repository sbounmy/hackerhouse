# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# Squarespace

## hh/name
Add mixpanel tracking script
```js
<script type='text/javascript'>
  $(document).ready(function() {
    mixpanel.track("View HackerHouse", {
        "name": 'Canal Street'
    });
  });

  $(document).ready(function() {
    var $form = $('.content-inner form');
    $form.on('submit', function() {
      var params = {};

      $.each($form.serializeArray(), function(i, obj) {
        params[obj.name] = obj.value
      });
      if (params.email) {
        mixpanel.alias(params.email);

        mixpanel.people.set({
          "$first_name": params.fname,
          "$last_name": params.lname,
          "$email": params.email,
          "HackerHouse": "Canal Street"
        });

        mixpanel.track("Signup", {
          "name": 'Canal Street'
        });
      }

    }); //on submit
  }); //document ready
</script>
```


Create new house
----------------
On platform account :
Top left Switch account > New Account : Type new HackerHouse Name

Go to api.hackerhouse.paris/houses/new
Fill in all infos
Click on Authorize access

On platform account > Connect > Connected accounts : verify if customer account is correctly connected

Still need to manually update house : amount
Go to platform account

Add new subcription
-------------------
Add plan fee_monthly rent_monthly
add metadata account_id : house-id (e.g "acct_195cnwDPESwYAX2A")

House account id
----------------
Format : acct_195cnwDPESwYAX2A
Can be fetch through Connect > Connected Accounts