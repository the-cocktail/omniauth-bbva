
# Omniauth BBVA

This gem contains an OAuth2 strategy for BBVA API MARKET. It is based in the generic omniauth-oath2.

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

# CLIENT

This gem contains also a client with some basic services of BBVA API MARKET like:
- Identity
- Accounts
- Cards

An also the ```refresh_token```method to used once the credentials have expired.

### Using Client in Rails

- Include the module
    ```ruby
    include Bbva::Api::V1
    ```
    
- Instanciate
    ```ruby
      @client = Bbva::Client.new do |config|
        config.client_id      = "YOUR_CLIENT_ID"
        config.secret         = "YOUR_SECRET"
        config.token          = "YOUR_ACCESS_TOKEN"
        config.refresh_token  = "YOUR_REFRESH_TOKEN"
        config.code           = 'YOUR_CODE'
      end
      #or
      @client = Bbva::Client.new(hash_with_credentials)
    ```
    
- Finally get some data
```ruby
    #Personal information
    @me        = @client.identity
    #Get all acounts
    @accounts  = @client.accounts
    #Get a specific account
    @account   = @client.accounts(account_id)
    #Get all cards
    @cards     = @client.cards
    #Get a specific card
    @card      = @client.cards(card_id)
```



