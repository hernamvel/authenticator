# Authenticator

## About

This repository contains the codebase for a simple RESTFUL API authentication service defining
the endpoints for the following features:

- Sign in
- Sign out
- User resource (CRUD)

## Basic dependencies

This service was built on ruby `2.7.6` and rails `6.1.7`. I don't expect
any troubles running the service on a similar version of ruby.

## Installation

- Clone this repository
- Run bundle

```bundle install```

- Create the master key

```echo <MASTER_KEY> > ./config/master.key ```

Where <MASTER_KEY> will be provided privately by email.

- Create the database

We are using sqllite so no database engine has to be installed.

```
rails db:create
rails db:migrate
rails db:seed
```

To run the tests:

`rspec`

You show expect a report like the one (note we have 100% coverage):
```
...............................

Finished in 0.19437 seconds (files took 0.85129 seconds to load)
31 examples, 0 failures

Coverage report generated for RSpec to /xxx/authenticator/coverage. 306 / 306 LOC (100.0%) covered.
```

To run the service

`rails s`

## Consuming the endpoints

Assuming you have curl and you are using the seeds provided here, 
here are some examples of how to call the endpoints.

Don't forget to change authorization header by the correct one given on
sign in response.

- Sign in

```
curl -X POST -d 'username=hernan&password=12345678' http://localhost:3000/api/v1/sign_in

# Returning authetication token like

{"token":"A_big_string"}
```

- Sign out

```
curl -X DELETE -H "Authorization: the_token_provided_in_sign_in_response" http://localhost:3000/api/v1/sign_out

# This returns :no_content if successful
```

- Listing all users

```
curl -X GET -H "Authorization: the_token_provided_in_sign_in_response" http://localhost:3000/api/v1/users
```

- Querying an user by id (id -> 1 in current seed for this example)

```
curl -X GET -H "Authorization: the_token_provided_in_sign_in_response" http://localhost:3000/api/v1/users/1
```
- Updating an user by id (id -> 1 in current seed for this example)

```
curl -X PATCH -H "Authorization: the_token_provided_in_sign_in_response" -d 'full_name=juan' http://localhost:3000/api/v1/users/1
```

- Creating an user

```
curl -X POST -H "Authorization: the_token_provided_in_sign_in_response" -d 'full_name=juan&email=juan@juan.com&username=juan&password=12345678' http://localhost:3000/api/v1/users
```

You can also look into the requests specs (/specs/requests) for more details on how
the endpoints are built not mentioned here.

## Gems used

- `bcrypt` from authentication
- `jwt` for json web token implementation
- `rspec` for testing
- `simple_cov` for coverage metrics

## Authentication flow

Below is a sequence diagram showing the flow for a 
successful sign in process to illustrate how to navigate
the codebase. Other flows can be inferred from the code and
the standard Rails practices.

```
authentication_controller   authentication_service  user model
 |                              |                       |
 |                              |                       |
 | ------ authenticate() ---->  |                       |
 |                              | --- authenticate() -> |
 |                              |                       | 
 |                              |<- authenticated user  |
 |                              |       with token      | 
 |                              |                       |
 |<- success response with user |                       |
 |        with token            |                       |
 |
 v
 :ok resoponse generated with new token
```


## Why is this production ready?

- All features for a basic authentication service are implemented including
  sign in (that blocks after a number of unsuccessful attempts), sign out and 
  user administration services.
  
- Security issues were considered including encrypting passowrds in the
database and using session tokens via JWT.

- The whole codebase is fully covered by the specs (100% reported by simple_cov)

- Rubocop rules are in place for code legibility.

## Wishlist

- Some sort of roles implementation

- Unblock feature (although it can be done via user update)

- Full token expiration implementation and token blacklist

- Using some CI/CD

- Dockerize to deploy on AWS (ECS Fargate) via CI/CD
