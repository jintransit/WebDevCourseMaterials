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
sudo apt-get install --no-install-recommends -y ca-certificates vim git-core curl autoconf automake bison build-essential gawk libgmp-dev libssl-dev libreadline-dev zlib1g zlib1g-dev sqlite3 libsqlite3-dev libtool libyaml-dev libxslt1-dev libxml2-dev libgdbm-dev libncurses5-dev pkg-config libffi-dev npm lynx
```
**Install RVM (visit [the RVM site](https://rvm.io/rvm/install/) for reference, but do follow the instructions below).**  
**First, install the required public key:**
```
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
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
In order to make sure you are installing the current stable version of Ruby, please examine the output of the following bash snippet:
```
lynx -dump https://www.ruby-lang.org/en/downloads/ | grep -o 'The current stable version is.*Please' | rev | sed 's/\.//' | rev | cut -d' ' -f6 | sed 's/^/rvm install /'
```
Run the commands below, making sure in the second command that you are installing the current stable version of Ruby (found in the previous step):
```
source ~/.rvm/scripts/rvm
rvm install 2.3.1
```
**Install the needed gems:**
```
gem update --no-ri --no-rdoc --system 2.2.2
gem install --no-ri --no-rdoc bundler spring listen sqlite3 tzinfo-data rake minitest test-unit mime-types mail sprockets loofah json rails
```
**Fix the Gemfile template:**
```
for gemFile in $(ls ${GEM_HOME}/gems/railties-*/lib/rails/generators/rails/app/templates/Gemfile)
do
cp ${gemFile} ${gemFile}.backup
cat > ${gemFile} <<EOF
source 'https://rubygems.org'

gem 'rails'
gem 'sqlite3'
gem 'tzinfo-data'
gem 'spring', group: :development
gem 'listen', group: :development
EOF
done
```
**That's it. You're done.**
