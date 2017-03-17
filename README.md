
# Omniauth BBVA

This gem contains an OAuth2 strategy for BBVA API MARKET. It is based on [omniauth](https://github.com/intridea/omniauth).

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





