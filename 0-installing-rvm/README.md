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
sudo apt-get install vim git-core curl autoconf bison build-essential libssl-dev libreadline-dev zlib1g zlib1g-dev sqlite3 libsqlite3-dev libtool libyaml-dev libxslt-dev libxml2-dev libgdbm-dev libncurses5-dev pkg-config libffi-dev nodejs
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

**Install Ruby version 2.1.5:**
```
rvm install 2.1.5
```
**Set your preference for version 2.1.5 of Ruby:**
```
rvm --default use 2.1.5
```
**Install the needed gems**
```
gem install --no-ri --no-rdoc bundler sinatra sqlite3 sinatra-activerecord test-unit bcrypt nokogiri json rails
```
**That's it. You're done.**
