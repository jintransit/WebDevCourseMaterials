## Installing RVM on Ubuntu 12.04

**Find out whether you already have Ruby on your system**

```
which ruby
```

If you already have Ruby on your system, uninstall it now.

**Is your DPKG package database up to date?**

```
sudo apt-get update
```

**We need a few packages before we begin:**

```
sudo apt-get install vim git curl autoconf build-essential libssl-dev libreadline-dev zlib1g zlib1g-dev sqlite3 libsqlite3-dev libtool libyaml-dev
```

**Install RVM (visit [the RVM site](https://rvm.io/rvm/install/) for reference, but do follow the instructions below):**

```
curl -L https://get.rvm.io | bash -s stable
```

**Using your favorite text editor, append the line below to the end of your ~/.bashrc:**

```
[[ -s ~/.rvm/scripts/rvm ]] && . ~/.rvm/scripts/rvm
```

**Close the terminal session you're in, open a new one.**

**Install Ruby version 1.9.3:**

```
rvm install 1.9.3
```

**Set your preference for version 1.9.3 of Ruby:**

```
rvm --default use 1.9.3
```

**Install the needed gems**

```
gem install --no-ri --no-rdoc bundler sinatra sqlite3 sinatra-activerecord test-unit bcrypt-ruby
```

**To verify that RVM was correctly installed, start the interactive console `irb` and type:**

```ruby
require 'sinatra'
```

There shouldn't be any errors.

