# Cobber

G'day cobbers!

This app generates labels for ruby events.

Feel free to contribute, it's been hacked together very quickly.

It's hosted at https://cobber.herokuapp.com/


# How to get a meetup token

1. Configure meetup oauth app

2. Run in console

```ruby
client = MeetupAdapter::Client.new
puts client.auth_url

# open link in browser
# approve
# copy code from url
 
code = 'code from url' 
client.token_from_code(code)
```

3. Profit
