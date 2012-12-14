## User authentication

The purpose of this document is to show the simplest way to do password authentication in Ruby, while still maintaining a reasonable degree of password security.

### Ingredients

We need the **bcrypt-ruby** RubyGem.

### Scenario 1: The user provides a password when signing up

```
require 'bcrypt'

hash = BCrypt::Password.create("superpass")
 => "$2a$10$SpBlkuQNwtvipxafmL2aEOIyPo2o2M8eK0phdkP3x7Nv/8wrb3h0q"

hash.salt
 => "$2a$10$SpBlkuQNwtvipxafmL2aEO"

hash.checksum
 => "IyPo2o2M8eK0phdkP3x7Nv/8wrb3h0q"
```

### Scenario 2: The user provides a password when logging in

```
require 'bcrypt'

my_password = BCrypt::Password.new("$2a$10$SpBlkuQNwtvipxafmL2aEOIyPo2o2M8eK0phdkP3x7Nv/8wrb3h0q")

my_password == "superpass"       #=> true

my_password == "not my password" #=> false
```

### The "low friction, low commitment" approach to soft-launching your shiny new web app

A web developer's first instinct when designing a new service-oriented web application is that it's perfectly reasonable to demand that new users create a login before they are granted access to the service. While this approach may have worked well in the 1990s - when the web was new to most people - it doesn't work very well anymore nowadays.

If you build a new site and then make it publicly available, it's very likely that tech-savvy users from your online community of peers are going to be the first wave of people you rely on for early feedback (via "Show HN" or "Show Reddit" submissions). But these are also the people who are the most painfully aware of ongoing issues with user credential security on the Internet - not even high-profile targets are safe anymore (e.g. Linkedin).

Therefore, it's very likely that the first kind of feedback you receive from your tech-savvy peers is going to be in the form of sarcastic comments like:  
**"Hey! We just met! Why are you asking for the keys to my car and my house?"**  
What they mean is that the burden of proof is on you to demonstrate that your service is useful enough to them before they decide to log in with Facebook/Twitter or supply a combination of e-mail address and password.

This anti-pattern is so pervasive especially among inexperienced web developers, that Ryan Bates of Railscasts fame has even dedicated an entire screencast to it. See [Guest User Record](http://railscasts.com/episodes/393-guest-user-record)  
In that screencast, Ryan makes the following argument:  
**Instead of presenting a signup form to the user, consider creating a temporary guest record so the user can try out the application without filling in their information upfront. They can then become a permanent member after they become convinced of the value of your application.**

