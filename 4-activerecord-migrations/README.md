## ActiveRecord migrations

ActiveRecord migrations are the Ruby developers' preferred approach for managing changes to the definitions of database objects.

Migrations can manage the evolution of a schema used by several physical databases. They are a solution to the common problem of adding a table to make a new feature work in your local database, but being unsure of how to push that change to other developers.

In order to build an intuition for what ActiveRecord migrations are, compare both sides of the code snippet below. Describe all the similarities and differences you can spot.

```
$ cat u.sql                                       |  $ cat db/migrate/1_create_subscribers.rb
                                                  |  class CreateSubscribers < ActiveRecord::Migration
                                                  |    def self.up
CREATE TABLE subscribers (                        |      create_table :subscribers do |t|
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,  |
  email varchar(255),                             |        t.string :email
  first_name varchar(255),                        |        t.string :first_name
  middle_initial varchar(255),                    |        t.string :middle_initial
  last_name varchar(255),                         |        t.string :last_name
);                                                |      end
CREATE UNIQUE INDEX usr_em_indx                   |      add_index :subscribers, :email, :unique => true
                 ON subscribers (email);          |
                                                  |    end
                                                  |  end
```

**Difference:** On the left hand side we have regular SQL, while on the right hand side we have Ruby code.

**Similarity:** Both code snippets do the same thing to a database. A table called `subscribers` is involved.

**Difference:** The file containing the Ruby code is located inside of the directory path `db/migrate`. (This will be important in a moment.)

**Difference:** The name of the SQL file (`u.sql`) does not follow any conventions. The name of the Ruby file contains a reference to the Ruby class inside of it: `create_subscribers` is the snake-case version of the camel-cased `CreateSubscribers`. Also, the name of the Ruby file begins with a number. The importance of this number will become obvious later on.

**Difference:** The SQL `CREATE TABLE` snippet declares the `id` column as the first column of table `subscribers`, while the equivalent Ruby code doesn't. The explanation is simple: by default and unless instructed otherwise, ActiveRecord will assume we want a primary key for our table, and it will make `id` the primary key just like that, without asking.

### What is an ActiveRecord migration?

A migration:
- is a set of database instructions ...
- ... written in Ruby ...
- ... to allow us to "migrate" our database from one state to another.

A migration describes the changes that should take place in our database, for instance when we:
- create a table
- add a column to a table
- create an index

A migration may contain instructions for two distinct cases:
- for moving up to a new state
- for moving back down to a previous state

### Why use a migration?

**Because it keeps our database schema definition in the same place as the application code.**

Our application depends on the database being a certain way. Since they are so closely coupled together, we want to make sure that the structure of the database is stored and version-controlled in the same location as our application code.

**Because migrations are repeatable.**

When we move our project to a new computer, we want to have the database there too. With migrations, all it takes is one command and we go from nothing to a database that is in the same state as on the original computer.

**Because migrations allow us to share schema changes with other developers.**

... and ...

**Because migrations are database engine agnostic.**

### Let's start coding!

In a terminal, change directory to the same location as before (directory `webdevmodels`) and run the following commands:

```
mkdir -p db/migrate
touch db/migrate/1_create_subscribers.rb
```

Paste the following code into the file `db/migrate/1_create_subscribers.rb` you have just created:

```ruby
class CreateSubscribers < ActiveRecord::Migration
  def self.up
    create_table :subscribers do |t|
      t.string :email
      t.string :first_name
      t.string :middle_initial
      t.string :last_name
    end
    add_index :subscribers, :email, :unique => true
  end
end
```

In order to execute this migration against the database we are going to use a helper program called `rake` (the Ruby counterpart to `make`).

At this point we need to create the `Rakefile`, just like we need a `Makefile` before we can start using `make`.

In the same location as before (directory `webdevmodels`), create a new file called `Rakefile` and paste the code below into it:

```ruby
require './app.rb'
require 'sinatra'
require 'sinatra/activerecord/rake'
```

You are now ready to run the migration. While you're in the same location with the `Rakefile`, issue the following command at the terminal:

```
rake db:migrate
```

After a few seconds, there is **a lot** of output. The most interesting bits are:

```
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL) 
SELECT "schema_migrations"."version" FROM "schema_migrations" 
Migrating to CreateSubscribers (1)
==  CreateSubscribers: migrating ==============================================
-- create_table(:subscribers)
CREATE TABLE "subscribers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "email" varchar(255), "first_name" varchar(255), "middle_initial" varchar(255), "last_name" varchar(255)) 
CREATE UNIQUE INDEX "index_subscribers_on_email" ON "subscribers" ("email")
==  CreateSubscribers: migrated (0.0093s) =====================================
INSERT INTO "schema_migrations" ("version") VALUES ('1')
```

Predictably, our table and index have been created according to our specifications.

But we did not give any instructions to create that other table, the one called `schema_migrations`.

This table is for ActiveRecord's internal use, and it is where the current state (migration version) is stored. As you can see from the `INSERT` statement, right now the current version is `1`. Remember how we named our migration file? It started with the number `1`. It's the same number.

The number `1` has been used here for illustrative purposes. In most professional-grade Ruby applications, this version number consists of a **YYYYMMDDhhmmss**-formatted timestamp, e.g. `20121025145959`.

**Data types**

In our example above, table `subscribers` has a few fields, all of which are strings. However, we may also define other types, including:
- `text`
- `integer`
- `decimal`
- `date`
- `time`
- `datetime`
- `timestamp`
- `boolean`

(Note: Migrations also support the data type `float`, but its use in Ruby applications is highly discouraged due to rounding issues.)

**Foreign key relationships**

Imagine we had a one-to-many relationship between a publication and its subscribers.

Using `t.integer :publication_id` to declare that relationship makes the foreign key naming obvious and explicit, but you can abstract away this implementation detail by using `t.references :publication` instead.

This is what our migration might look like if there was a foreign key relationship involved.

```ruby
class CreateSubscribers < ActiveRecord::Migration
  def self.up
    create_table :subscribers do |t|
      t.string     :email
      t.string     :first_name
      t.string     :middle_initial
      t.string     :last_name
      t.references :publication
      t.decimal    :monthly_fee
    end
    add_index :subscribers, :email, :unique => true
  end
end
```

### Custom `rake` tasks

When working on a new application as a member of a team, there are several one-time operations a developer may need to perform after moving the application to a new computer. So far we looked at migrating the database, but another common operation is seeding the database with an initial set of table entries for testing purposes.

We can automate this too by leveraging the flexibility of `rake`.

Let's examine our `Rakefile` in its current state. It looks like this:

```ruby
require './app.rb'
require 'sinatra'
require 'sinatra/activerecord/rake'
```

To create a new `rake` task of our own design, we append the following snippet of code to the bottom of our `Rakefile`:

```ruby
namespace :db do
  task :seed do
    seed_file = "./db/seeds.rb"
    puts "Seeding database from: #{seed_file}"
    load(seed_file) if File.exist?(seed_file)
  end
end
```

As you can see above, there are three meaningful lines of Ruby code, wrapped in a task called `seed`, wrapped in a namespace called `db`. This will allow us to execute the command `rake db:seed` at the terminal, which will trigger the execution of those lines of code.

Of course, we are going to need a file called `seeds.rb` inside of the `db` directory. Let's create it:

```
touch db/seeds.rb
```

Let's paste the following code into it:

```ruby
subscribers = [
  {:email => 'jack@clark.com', :first_name => 'Jack', :middle_initial => 'T.', :last_name => 'Clark'},
  {:email => 'KevinT@wang.com', :first_name => 'Kevin', :middle_initial => 'M.', :last_name => 'Thomas'},
  {:email => 'liz@green.com', :first_name => 'Liz', :middle_initial => 'V.', :last_name => 'Martinez'}
]

subscribers.each do |s|
  Subscriber.create(s)
end
```

We now have all the pieces of the puzzle in place, except for one. We have not yet defined a model to go with our `subscribers` table. Open `app.rb` in an editor and add the `Subscriber` model, like this:

```ruby
class Subscriber < ActiveRecord::Base
end
```

Finally, run the command below at the terminal:

```
rake db:seed
```

The output shows three `INSERT` SQL statements, as expected.
