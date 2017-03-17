
# Omniauth BBVA

This gem contains an OAuth2 strategy for BBVA API MARKET. It is based on [omniauth](https://github.com/intridea/omniauth).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-bbva', git: 'git://github.com/the-cocktail/omniauth-bbva.git'
```

And then execute:

    $ bundle

##### How to use in Rails:
- Add bbva provider to your config/omniauth.rb

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  args = {
    site:           ENV['BBVA_SITE'], 
    authorize_url:  ENV['BBVA_AUTHORIZE_URL'],
    token_url:      ENV['BBVA_TOKEN_URL'],
    callback:       ENV['YOUR_APP_CALLBACK']
  }
  provider :bbva , CLIENT_ID, CLIENT_SECRET, args
end
````
*Only 'callback' param must be set to your app callback path. 'site','authorize_url' and 'token_url' are set by default using BBVA SandBox Environment.


- Define your callback route in routes.rb

```ruby
  #BBVA Omniauth callback
  get '/auth/:bbva/callback', :to => 'sessions#create'
```

The callback will receive the 'credentials' in ```request.env['omniauth.auth']```, an example could be:

```ruby
{"provider"=>"bbva",
 "credentials"=>
  {"token"=>"xxxxxx",
   "refresh_token"=>"yyyy",
   "expires_at"=>1462527094,
   "expires"=>true,
   "code"=>"cpJ26x"},
 "extra"=>{}}
```

## Basic example for Rails application
Configure your callback route in `routes.rb`. By example:
```ruby
  get '/auth/:bbva/callback', :to => 'sessions#create'
```
Save the omniauth info in the `create` method placed in your `sessions_controller.rb`. By example:
```ruby
  def create
    session[:auth] = request.env['omniauth.auth']
    redirect_to root_path
  end
```
Now, you need to add the authorization checking, token obtaining and refreshing, etc. In your `application_controller.rb`. By example:

- Configure before_filter/action (it depends on your rails version) to call `authorize` method
```ruby
  before_filter :authorize
```

- Your authorize method could look like this one:
```ruby
  def authorize
    unless session_active?
      # Do whatever you need when user is not logged. Like redirect to home
      # Be careful with redirection loops
    else
      # Do whatever you need when user is logged OK
    end
  end
```
- Our `session_active?` method could look like this one:
```ruby
    def session_active?
      if request.env['omniauth.auth'] || session[:auth]
        refresh_token! if token_expired?
        true
      else
        false
      end
    end
```

- Now we need the functionality to get/refresh our token:
```ruby
    def token_expired?
      session[:auth] && (session[:auth]["credentials"]["expires_at"] < Time.now.to_i)
    end
```

```ruby
def refresh_token!

      @client = Bbva::Api::Market::Client.new(session[:auth]["credentials"].merge({client_id: CLIENT_ID , secret: CLIENT_SECRET}))
      begin
        data    = JSON.parse(@client.refresh_token)
        Rails.logger.info("refresh_token!")
        #Renovate credentials
        session[:auth]["credentials"]["expires_at"]    = Time.now.to_i + data["expires_in"]
        session[:auth]["credentials"]["token"]         = data["access_token"]
        session[:auth]["credentials"]["refresh_token"] = data["refresh_token"]
      rescue Exception => e
        # refresh_token also have expiration time ("refresh_expires_in"=>43199) so we have to authorize again.
        redirect_to "/auth/bbva"
      end
    end
```

This is an idea of what do you need. But you can do it in your own way :)
