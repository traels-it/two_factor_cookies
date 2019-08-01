# TwoFactorCookies
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'two_factor_cookies', git: 'git@bitbucket.org:cs2software/two_factor_cookies.git', branch: 'master'
```

And then execute:
```bash
$ bundle
```

The gem is a rails engine, so it needs to be mounted to a location in `routes.rb`:
```ruby
# two factor cookies
mount TwoFactorCookies::Engine, at: '/two_factor_cookies'
```

Todo: Document initializeer

In your ApplicationController you must include TwoFactorAuthentication

The gem includes a template for submitting one time passwords. To override it, a partial named 'show' must be placed under `two_factor_cookies/two_factor_authentication`

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
