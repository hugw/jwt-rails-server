## JWT Rails API Server

A simple API Server that manages users subscriptions and JWT authentication. It offers seamless integration with Firebase custom authentication and is **production ready** for heroku server.

**Stack:** `Firebase` + `Devise` + `JWT` + `CORS`

## Requirements

- Ruby on Rails
- PostgreSQL

## Install instructions

Before everything, locate the file `config/application-sample.yml`, rename it to `application.yml` and fill in the empty fields.

*`SENDGRID_USERNAME` and `SENDGRID_PASSWORD` options are not mandatory if you are going to use the app only in dev/test environment*

Already inside your project folder, type the following command:

```
$ bundle install
```

After all dependencies are installed, setup your database credentials in `config/database.yml`.
When ready, you can run the migrations:

```
$ rake db:create
$ rake db:migrate
# rake db:seed # optional, check db/seeds.rb for more information
```

With the migrations done, you can start the server:

```
$ rails s
```

Make sure to start mailcatcher so your tests and development environment won't break:

```
$ mailcatcher
```

Thats it, your api is up and running.

## Features

- Rack CORS for clients management

*Only selected clients will be allowed to access the api via CORS setup. For more information check out `config/application.rb`*

- Firebase custom authentication

*JWT tokens is already compatible with Firebase, all you need to do is fill in `JWT_SECRET` with the secret key Firebase provided you.*

- Devise authentication integrated with Json Web Tokens(JWTs)

*Each token will expire after 5 days and every 10 minutes the server will return a fresh one, so its up to the client to update it or not.*

- The entire API Server won't return any strings messages, all validations will return string codes and http response codes. With this in mind, is up to the client to handle the entire localization feature.

*Ex: When email is invalid, it will return response code `422` and a string error code `INVALID`*

*Ex: When user isn't found on system, it will return responde code `401` and a string error code `USER_NOT_FOUND`*

## API

### User sign up

**POST /users**

Parameters in JSON format:

```
{
  "user": {
    "name": "Jon Doe",
    "email": "jon@doe.io",
    "password": "jon123",
    "password_confirmation": "jon123"
  }
}
```

### User sign in

**POST /users/sign_in**

Parameters in JSON format:

```
{
  "user": {
    "email": "jon@doe.io",
    "password": "jon123"
  }
}
```

### Recover user password

**POST /users/password**

Parameters in JSON format:

```
{
  "user": {
    "email": "jon@doe.io",
    "callback_url": "http://myclient.io/reset_password"
  }
}
```

*The `callback_url` is sent inside the reset instructions email so the user can be redirected back to your app.*

### Change user password after reset instructions

**PUT /users/password**

Parameters in JSON format:

```
{
  "user": {
    "password": "jon123",
    "password_confirmation": "jon123",
    "reset_password_token": "7f9t4GTKkyWkCXXQseFQ"
  }
}
```

*The `reset_password_token` is located as a query param inside your callback_url after the user is redirected.*

*Ex: `http://myclient.io/reset_password?token=7f9t4GTKkyWkCXXQseFQ`*

### Get current user data while authenticated

**GET /api/v1/user**

### Update current user data while authenticated

**PUT /api/v1/user**

Parameters in JSON format:

```
{
  "user": {
    "name": "Jon Doe",
    "email": "jon@doe.io",
    "password": "jon123",
    "password_confirmation": "jon123"
  }
}
```

*Password and password_confirmation is optional.*

## Testing

Tests are handled via rspec, type the following command to run it:

```
$ rspec
```

## Releases

### Version 0.0.1

Initial version.

***

The MIT License (MIT)

Copyright (c) 2016 Hugo W. - me@hugw.io

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
