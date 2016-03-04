## Installing RVM on Ubuntu 14.04

**Find out whether you already have Ruby on your system**

```
which ruby
```
**If you already have Ruby on your system, please rename the executable:**
```
sudo mv /usr/bin/ruby /usr/bin/ruby_orig
```

**Is your DPKG package database up to date?**
```
sudo apt-get update
```
**We need a few packages before we begin:**
```
sudo apt-get install ca-certificates vim git-core curl autoconf bison build-essential gawk libssl-dev libreadline-dev zlib1g zlib1g-dev sqlite3 libsqlite3-dev libtool libyaml-dev libxslt-dev libxml2-dev libgdbm-dev libncurses5-dev pkg-config libffi-dev npm
```
**Install RVM (visit [the RVM site](https://rvm.io/rvm/install/) for reference, but do follow the instructions below).**  
**First, install the required public key and copy the cert file to the location where `curl` expects it:**
```
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
sudo mkdir -p /etc/pki/tls/certs
sudo cp /etc/ssl/certs/ca-certificates.crt /etc/pki/tls/certs/ca-bundle.crt
```
**Then, download and install RVM:**
```
curl -L https://get.rvm.io | bash
```
**Using your favorite text editor, append the line below to the end of your ~/.bashrc:**
```
[[ -s ~/.rvm/scripts/rvm ]] && . ~/.rvm/scripts/rvm
```
**Install Ruby:**
```
source ~/.rvm/scripts/rvm && rvm install 2.3.0
```
**Install the needed gems:**
```
gem update --system 2.2.2
gem install --no-ri --no-rdoc bundler spring sinatra sqlite3 sinatra-activerecord test-unit json rails
```
**Fix the Gemfile template:**
```
for gemFile in $(ls ${GEM_HOME}/gems/railties-*/lib/rails/generators/rails/app/templates/Gemfile)
do
cat > ${gemFile} <<EOF
source 'https://rubygems.org'

gem 'rails'
gem 'sqlite3'
gem 'spring', group: :development
EOF
done
```
**That's it. You're done.**
