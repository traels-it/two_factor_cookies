# TwoFactorCookies
Simple two factor logon - with Twilio SMS for code delivery
The aim is to be configurable and work with as many kinds of authentication as possible.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'two_factor_cookies', '0.1.0'
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

The gem needs to be configured. The example below can be copied and placed in an initializer, eg. `config/initializers/2fa_setup.rb`
```ruby
TwoFactorCookies.configure do |config|
  # One time password (otp) generation and verification
  # Must be a 160 bit (32 character) base32 secret. The rotp gem included in the project can generate such a key by typing this in the console: ROTP::Base32.random
  config.otp_generation_secret_key =  MUST BE FILLED

  # Cookie expiry
  # When a user will need to perform 2fa again
  # config.two_factor_authentication_expiry = 30.days.from_now
  # How much time a user has to type in the otp sent to his phone
  # config.otp_expiry = 30.minutes.from_now

  # Twilio API credentials
  config.twilio_account_sid = MUST BE FILLED
  # phone number is the number, that will be shown on the receiving phone. It can also be a string, for example the name of your company
  config.twilio_phone_number = MUST BE FILLED
  config.twilio_auth_token = MUST BE FILLED

  # User model
  # user_model_name is used as the permit option in toggle_two_factor_controller
  # config.user_model_name = :user
  # config.phone_number_field_name = :phone_number
  # config.username_field_name = :username

  # Controllers
  # The route you want two_factor_authentication_controller to redirect to. Would typically be where, your user is redirected to after logging in.
  config.two_factor_authentication_success_route = MUST BE FILLED
  # The route you want toggle_two_factor_controller to route to after a user has toggled two factor
  config.toggle_two_factor_success_route = MUST BE FILLED
  # The route you want toggle_two_factor_controller to route to after a user has confirmed their phone number
  config.confirm_phone_number_success_route = MUST BE FILLED

  # If you need or want to replace the layout in the two_factor_authentication_controller, add a path here, eg. 'two_factor_cookies/two_factor_authentication'
  #config.layout_path = nil

  # In order to know which user is attempting to login, the two factor authentication controller checks current_user. It
  # looks at its parent for this method. The default parent is ApplicationController. If you use devise or have
  # implemented current_user elsewhere, you need to supply the parent constant here
  # config.two_factor_authentication_controller_parent = '::ApplicationController'

  # If you check for additional values when determining if a user is authenticated, you need to tell the controller how
  # to determine these values. Add a hash of key-value pairs here, where the key is the name, you want in the cookie,
  # the value is the method used to find whatever value you want as a string. Example:
  # { customer_no: 'current_company.customer_no' }
  # config.additional_authentication_values = nil

  # any params sent along when enabling 2fa that needs to be updated on the user model, for example a phone number
  # config.update_params = nil

  # If another engine than main_app contains the routes you want the 2fa controllers to redirect to, write the engine
  # name here as a string
  #config.engine_name = 'main_app'
end

```

In your ApplicationController you must include TwoFactorAuthentication
```ruby
class ApplicationController < ActionController::Base
  include TwoFactorAuthenticate
```

The gem includes a template for submitting one time passwords. To override it, a partial named 'show' must be placed under `two_factor_cookies/two_factor_authentication`

### Necessary methods on your user model
TwoFactorCookies relies on a number of methods being present on your user model: `enabled_two_factor?`, `confirmed_phone_number?`, `disable_two_factor!`, `enable_two_factor!`, `confirm_phone_number!` and `disaffirm_phone_number!`.

If using standard ActiveRecord or Mongoid, `enabled_two_factor?` and `confirmed_phone_number?` will be automatically added, if your user model has fields named respectively `enabled_two_factor` and `confirmed_phone_number`

#### Example implementations
```ruby
   def disable_two_factor!
    self.enabled_two_factor = false
    save
  end
```
If for example you want to delete the phone number, when disabling 2fa, it could be done here
```ruby
  def disaffirm_phone_number!
    self.confirmed_phone_number = false
    self.phone_number = nil
    save
  end
```

When disabling two factor authentication, `disaffirm_phone_number!` is also called and a new confirmation of the phone number is required, if 2fa is enabled again.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
