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

**Install Ruby version 2.1.2:**

```
rvm install 2.1.1
```

**Set your preference for version 2.1.1 of Ruby:**

```
rvm --default use 2.1.1
```

**Install the needed gems**

```
gem install --no-ri --no-rdoc bundler sinatra sqlite3 sinatra-activerecord test-unit bcrypt-ruby nokogiri json alphadecimal
```

**To verify that RVM was correctly installed, start the interactive console `irb` and type:**

```ruby
require 'sinatra'
```

There shouldn't be any errors.

If there are no errors, this concludes the installation process.

### Working around issues

For unknown reasons, the installation process may sometimes hang during various phases of `rvm install 1.9.3`.

If that happens, one workaround of last resort might be to "transplant" a binary copy of RVM from another GNU/Linux machine of the same architecture.

For 32-bit, take the steps outlined below.

**Make sure you have `libreadline-dev`:**

```
sudo apt-get install libreadline-dev
```

**Remove the current RVM installation:**

```
rm -rf ~/.rvm
```

**Download the RVM tarball:**

```
wget -O /tmp/rvm.tar.gz http://ompldr.org/vZnZzcQ/rvm.tar.gz
```

**Verify its MD5 signature:**

```
md5sum /tmp/rvm.tar.gz
```

**The output should be:**

```
05a92b8a2338ee990c6537d6d81c277d  /tmp/rvm.tar.gz
```

**Uncompress the tarball into the home directory:**

```
tar -xf /tmp/rvm.tar.gz -C ~
```

**To verify that you have a working RVM installation, start the interactive console `irb` and type:**

```ruby
require 'sinatra'
```

There shouldn't be any errors.

