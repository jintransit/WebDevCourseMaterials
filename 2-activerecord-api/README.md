## Understanding The ActiveRecord API

ActiveRecord is the Ruby persistence layer which is going to power the models in our web apps.
ActiveRecord allows us to retrieve and manipulate database data in an object oriented manner, not just as static rows.
ActiveRecord objects are "smart", they understand the structure of our database tables and know how to interact with them.
ActiveRecord maps:
- database tables to classes (we call these classes models)
- table rows to objects (which are instances of the aforementioned models)
- table columns to attributes of the aforementioned objects

### Let's start coding!

We are going to reuse `dev.db`, the database file you ended up with at the end of the SQL tutorial.
If you haven't yet gone through the SQL tutorial, stop right here, go do that now and when you're done, come back here.
A good understanding of SQL is vital, and it is a non-negotiable prerequisite for understanding ActiveRecord.

Create a new directory called `webdevmodels` and copy `dev.db` to it.

```
mkdir webdevmodels
cd webdevmodels
cp /tmp/dev.db .
```

One more thing before we get started: let's make sure we have all the software components we need.
At the terminal, type:

```
ls /usr/include/sqlite3.h && echo "OK - SQLite development files found"
gem list | grep "^sqlite3 " && echo "OK - SQLite RubyGem found"
gem list | grep "^sinatra-activerecord " && echo "OK - ActiveRecord found"
```

If anything is missing, run one or more of the following commands:

```
sudo apt-get install libsqlite3-dev
gem install sqlite3
gem install sinatra-activerecord
```

In the same location (directory `webdevmodels`) create a new file called `app.rb` with the following contents:

```ruby
require 'sinatra'
require 'sinatra/activerecord'

configure do
  options = { :adapter  => "sqlite3", :database => "dev.db" }
  ActiveRecord::Base.establish_connection(options)
  ActiveRecord::Base.logger = Logger.new(STDERR)
end

class Presidency < ActiveRecord::Base
end

class Continent < ActiveRecord::Base
  has_many :countries
end

class Country < ActiveRecord::Base
  has_many   :cities
  belongs_to :continent
end

class City < ActiveRecord::Base
  belongs_to :country
end

class AugmentedCity < ActiveRecord::Base
end

class ContinentStatistic < ActiveRecord::Base
end

class User < ActiveRecord::Base
  has_many :contributorships
  has_many :projects, :through => :contributorships
end

class Project < ActiveRecord::Base
  has_many :contributorships
  has_many :users, :through => :contributorships
end

class Contributorship < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
end

class AugmentedContributorship < ActiveRecord::Base
end

class Person < ActiveRecord::Base
end
```

The `configure do ... end` block at the top of the file is a standard callback mechanism which the Sinatra framework makes available to us.
Any code that's inside the `configure` block will be executed only once, when the server starts up.
We take advantage of this in order to instruct our application to establish a connection to the database.
One other thing we do inside the `configure` block is to set up a logging mechanism, which instructs ActiveRecord to show us a trace of every SQL statement it is issuing against the database.
This is going to be very useful to us because we get instant insight into how ActiveRecord translates our object-centric API calls into SQL statements.

As you can see from `app.rb`, models are subclasses of `ActiveRecord::Base`, a very useful collection of behaviors for connecting our Ruby code to the database.

Without any further explanations, let's start using our Sinatra application right now. Things will start making more sense as we go along, I promise you.

In a terminal window, make sure you are in the same directory where you placed `dev.db` and `app.rb`, and run this command:

```
irb -r ./app.rb
```

Your new prompt should be:

```
1.9.3-p125 :001 >
```

and there should be no obvious error messages anywhere.

The first model we defined in our `app.rb` is `Presidency`, let's type that class name at the prompt.

```
1.9.3-p125 :001 > Presidency
 => Presidency(id: integer, first_name: string, other_names: string, year_from: integer, year_to: integer, notes: text)
```

The above output is somewhat surprising. Contrast that with the output we get when we ask to see `Object`.

```
1.9.3-p125 :002 > Object
 => Object
```

When we ask to see `Presidency`, we get an extra listing of exactly the fields we defined when we created table `presidencies` during the SQL tutorial.
The explanation is simple - this is standard behavior we get for free when we extend `ActiveRecord::Base`.
ActiveRecord takes our model name, converts it from camel-case to snake-case and pluralizes it.
Then it looks inside the database (`dev.db` in our case) to see whether or not a table by that name exists.

`Presidency` `->` conversion to snake-case `->` `presidency` `->` pluralization `->` `presidencies`

- `dev.db`, do you contain a table called `presidencies`?
- Yes.
- `dev.db`, please give me a list of its fields, along with their types. Someone has asked to see them.

This is our first exposure to the fundamental principles which underpin the philosophy of ActiveRecord:
**Convention Over Configuration**
We only need to rely on our knowledge of how the table name - by convention - is being inferred from the model name; it spares us the effort of configuring explicitly in some XML file how the two pieces fit together.
**Don't Repeat Yourself**
Why should we specify any getter/setter methods in the class definition for `Presidency`? Why should we repeat ourselves when those methods are namesakes of columns in table `presidencies`, just one database query away?

### Let's start exploring the API

Type this at the interactive Ruby console:
 
```
Presidency.count
```

The output:

```
D, [] DEBUG -- :    (314.7ms)  SELECT COUNT(*) FROM "presidencies"
 => 30
```

This is our first encounter with a class-level method that performs table-level operations.
Also, notice this is the first time we get to see the logger in action.
Remember we instructed ActiveRecord to tell us what it's doing behind the scenes?
Well, here we just invoked the class method `count` and in response, ActiveRecord executed the SQL statement you see above, extracted the result and showed it to us.

Next, try this:

```
Presidency.first
```

The output you should see is:

```
D, [] DEBUG -- :   Presidency Load (0.9ms)  SELECT "presidencies".* FROM "presidencies" LIMIT 1
 => #<Presidency id: 2, first_name: "Theodore", other_names: "Roosevelt", year_from: 1905, year_to: 1908, notes: "">
```

Notice we are getting an object back.
What if we wanted the answer to be in the form of a hash? Try this:

```
Presidency.first.attributes
```

The output:

```
D, [] DEBUG -- :   Presidency Load (0.9ms)  SELECT "presidencies".* FROM "presidencies" LIMIT 1
 => {"id"=>2, "first_name"=>"Theodore", "other_names"=>"Roosevelt", "year_from"=>1905, "year_to"=>1908, "notes"=>""}
```

In the SQL query above, `LIMIT 1` does what you think it does. It gives back one - randomly picked - table row.
Don't rely on this row being the one with the lowest `id` in the table, however. That may be the case some of the time, but the database engine doesn't guarantee it.

Also, note one other thing - we chained the `attributes` method call onto the back of the `first` method call.
I just wanted to call your attention to this because it's typical of how we do things with ActiveRecord; we are going to do a lot of chaining in subsequent examples.

Next, try this:

```
Presidency.all
```

Expect a wall of text, it's essentially `SELECT * FROM presidencies`, reformatted as an array of objects.
What if we wanted an array with just the values for the `year_from` column, kind of like `SELECT year_from FROM presidencies`?
We can achieve this by chaining a `.map` onto a `.select`, like this:

```
Presidency.select(:year_from).map(&:year_from)
```

The output:

```
D, [] DEBUG -- :    (1.4ms)  SELECT year_from FROM "presidencies"
 => [1905, 1909, 1913, 1917, 1921, 1923, 1925, 1929, 1933, 1937, 1941, 1945, 1949, 1953, 1957, 1961, 1964, 1965, 1969, 1973, 1975, 1977, 1981, 1985, 1989, 1993, 1997, 2001, 2005, 2009]
```

Next, try this:

```
Presidency.find_by_first_name("Franklin")
```

The output:

```
D, [] DEBUG -- :   Presidency Load (0.5ms)  SELECT "presidencies".* FROM "presidencies" WHERE "presidencies"."first_name" = 'Franklin' LIMIT 1
 => #<Presidency id: 10, first_name: "Franklin", other_names: "D. Roosevelt", year_from: 1933, year_to: 1936, notes: "1st term">
```

This is a little strange, right?
We expected the SQL query to be `SELECT * FROM presidencies WHERE first_name = 'Franklin'`, but ActiveRecord has surprisingly appended `LIMIT 1` onto the the back of the SQL statement.
The purpose of `find_by_somecolumnnamehere` class methods is to make life easy for us in situations where we know there is a unique index on a column, and consequently an SQL lookup can only produce either exactly one row or nothing at all.

In our case, no unique constraint has been defined on column `first_name` and we also know that we are going to find more than one row satisfying that condition.
The class method we are looking for is `find_all_by_first_name`.
Try this:

```
Presidency.find_all_by_first_name("Franklin")
```

The output:

```
D, [] DEBUG -- :   Presidency Load (1.0ms)  SELECT "presidencies".* FROM "presidencies" WHERE "presidencies"."first_name" = 'Franklin'
 => [#<Presidency id: 10, first_name: "Franklin", other_names: "D. Roosevelt", year_from: 1933, year_to: 1936, notes: "1st term">, #<Presidency id: 11, first_name: "Franklin", other_names: "D. Roosevelt", year_from: 1937, year_to: 1940, notes: "2nd term; WW 2 begins">, #<Presidency id: 12, first_name: "Franklin", other_names: "D. Roosevelt", year_from: 1941, year_to: 1944, notes: "3rd term">]
```

And this is indeed what we actually had in mind - an array of objects.

As a side note, you should expect substandard performance from any SQL queries which employ `WHERE` clauses involving the `first_name` column, since that column has not been indexed.

There were a few more types of `SELECT` statements we explored during the SQL tutorial.
Let's see what their ActiveRecord equivalents might be.
First of all:

```sql
SELECT DISTINCT first_name || ' ' || other_names AS full_name FROM presidencies;
```

Turns into:

```
Presidency.select("DISTINCT first_name || ' ' || other_names AS full_name").map(&:full_name)
```

Then:

```sql
SELECT COUNT(*) FROM presidencies WHERE year_from BETWEEN 1950 AND 1999;
```

Turns into:

```
Presidency.where("year_from BETWEEN ? AND ?", 1950, 1999).count
```

Notice here we treat the values 1950 and 1999 as unsafe input (input that might originate from a malicious user of our web app).
Replacing potentially unsafe input values with placeholders (question marks) in our `WHERE` clauses is the recommended practice in order to mitigate SQL injection risks.

Then:

```sql
SELECT * FROM presidencies WHERE 1941 BETWEEN year_from AND year_to;
```

Turns into:

```
Presidency.where("? BETWEEN year_from AND year_to", 1941)
```

Then:

```sql
SELECT * FROM presidencies WHERE notes LIKE '% WW %' ORDER BY year_from;
```

Turns into:

```
Presidency.where("notes LIKE ?", "% WW %").order(:year_from)
```

A few words on the dangers of SQL injection.
Let's say you want to implement search functionality in your web application - it's a very common requirement as well as one of the most likely places where a malicious user of your application will attack.
The typical workflow when you respond to a search request would be to first capture the raw input from the search box:

```ruby
raw_input = params[:searchbox].to_s
```

The naive, insecure approach would be to take the raw input and directly plug it into the `WHERE` clause.
If you do that, you are opening up a new option for experienced attackers and sophisticated vulnerability scanning tools to exploit your web app.
Through clever use of punctuation, malicious users may inject extra SQL statements onto the end of your `WHERE` clause and do a lot of damage to your database.
Therefore to protect against such attacks you must be dilligent about sanitizing all input at the application boundary.
One (admittedly radical) option for doing that is:

```ruby
sanitized_input = raw_input.gsub(/[^a-zA-Z0-9 ]/, "")
Presidency.where("notes LIKE ?", "%#{sanitized_input}%").order(:year_from)
```

Notice how we removed all punctuation marks from the raw input before letting it through.
(On a more humorous side note, the pervasiveness of SQL injection vulnerabilities in web applications has given rise to the "Bobby Tables" Internet meme, refer to this XKCD webcomic http://xkcd.com/327/ where the meme originated.)

The next type of `SELECT` statement we explored during the SQL tutorial:

```sql
SELECT
  1 + year_to - year_from AS duration, COUNT(*) AS cnt
FROM
  presidencies
GROUP BY
  duration
ORDER BY cnt DESC;
```

Turns into:

```
Presidency.select("1 + year_to - year_from AS duration, COUNT(*) AS cnt").group(:duration).order(:cnt).reverse_order.map{|dcnt| "Duration: #{dcnt.duration.to_s}, count: #{dcnt.cnt.to_s}"}
```

### Executing raw SQL with ActiveRecord

SQL statements can be very complex and sometimes ActiveRecord does not provide a suitable API for what we want.
Thankfully ActiveRecord lets us execute raw SQL, which is what we are going to do now to create a new table:

```
ActiveRecord::Base.connection.execute("CREATE TABLE people (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, first_name VARCHAR(255), last_name VARCHAR(255))")
```

We can now check the success of the SQL operation above by typing the class name `Person` at the prompt.
Remember, we defined a model called `Person` towards the end of `app.rb`. That's why it works.
We get:

```
 => Person(id: integer, first_name: string, last_name: string)
```

### Inserting rows with ActiveRecord

There are several ways to insert new rows into a table using ActiveRecord.
Probably the simplest one is this:

```ruby
p = Person.new
p.first_name = "John"
p.last_name = "Doe"
if p.save
  "Saved."
else
  "Failed!"
end
```

The output:

```
D, [] DEBUG -- :    (0.2ms)  begin transaction
D, [] DEBUG -- :   SQL (0.6ms)  INSERT INTO "people" ("first_name", "last_name") VALUES (?, ?)  [["first_name", "John"], ["last_name", "Doe"]]
D, [] DEBUG -- :    (438.8ms)  commit transaction
 => "Saved."
```

As you can see, the syntax of the generated `INSERT` statement differs slightly from what were using during the SQL tutorial, but the end-result is the same.

The second method involves the use of a hash with the model's attributes as keys:

```ruby
attrs = { :first_name => "Jane", :last_name => "Doe" }
p = Person.new(attrs)
p.save
```

The third method combines `new` and `save` into a single operation called `create`:

```ruby
attrs = { :first_name => "John", :last_name => "Smith" }
Person.create(attrs)
```

Notice how `save` returns true or false, while `create` returns a copy of the object which we just stored in the database.

### Foreign key relationships: the ONE-TO-MANY case

The fact that in our model definitions a `Continent` `has_many :countries` and a `Country` `belongs_to :continent` brings with it some interesting behavior.
Let's see how we ask the question "Which countries are in the continent called Oceania?"
Try this:

```
Continent.find_by_continent_name("Oceania").countries.map(&:country_name)
```

The output:

```
D, [] DEBUG -- :   Continent Load (0.5ms)  SELECT "continents".* FROM "continents" WHERE "continents"."continent_name" = 'Oceania' LIMIT 1
D, [] DEBUG -- :   Country Load (0.5ms)  SELECT "countries".* FROM "countries" WHERE "countries"."continent_id" = 6
 => ["Australia", "New Zealand"]
```

Conversely, how would we ask the question "Which continent does the country of Argentina belong to?"
Try this:

```
Country.find_by_country_name("Argentina").continent.continent_name
```

The output:

```
D, [2012-08-14T14:26:19.721626 #834] DEBUG -- :   Country Load (0.5ms)  SELECT "countries".* FROM "countries" WHERE "countries"."country_name" = 'Argentina' LIMIT 1
D, [2012-08-14T14:26:19.724695 #834] DEBUG -- :   Continent Load (0.4ms)  SELECT "continents".* FROM "continents" WHERE "continents"."id" = 2 LIMIT 1
 => "South America"
```

A similar strategy would be applicable for the bidirectional traversal of the foreign key relationship between `Country` and `City`.

But how would we ask the question "Which cities are in the continent called Oceania?"
The first thing that comes to mind is this:

```
Continent.find_by_continent_name("Oceania").countries.map(&:cities)
```

And this is what you get in response:

```
D, [] DEBUG -- :   Continent Load (0.4ms)  SELECT "continents".* FROM "continents" WHERE "continents"."continent_name" = 'Oceania' LIMIT 1
D, [] DEBUG -- :   Country Load (0.5ms)  SELECT "countries".* FROM "countries" WHERE "countries"."continent_id" = 6
D, [] DEBUG -- :   City Load (0.5ms)  SELECT "cities".* FROM "cities" WHERE "cities"."country_id" = 78
D, [] DEBUG -- :   City Load (0.5ms)  SELECT "cities".* FROM "cities" WHERE "cities"."country_id" = 79
 => [[#<City id: 30, country_id: 78, city_name: "Canberra">], [#<City id: 120, country_id: 79, city_name: "Wellington">]]
```

But notice the output isn't very usable. It's a list of lists of objects, not what we had in mind.
Surely there must be a better solution.
There is. During the SQL tutorial we defined a join view called `augmented_cities`, and in our `app.rb` we defined a model called `AugmentedCity`.
Let's take advantage of that. Try this:

```
AugmentedCity.find_all_by_continent_name("Oceania").map(&:city_name)
```

The output:

```
D, [] DEBUG -- :   AugmentedCity Load (1.1ms)  SELECT "augmented_cities".* FROM "augmented_cities" WHERE "augmented_cities"."continent_name" = 'Oceania'
 => ["Canberra", "Wellington"]
```

There was also this SQL query we tried during the SQL tutorial:

```sql
SELECT * FROM augmented_cities WHERE city_name = 'London';
```

To accomplish the same thing with ActiveRecord, we would do:

```
AugmentedCity.find_by_city_name("London")
```

The output:

```
D, [] DEBUG -- :   AugmentedCity Load (1.0ms)  SELECT "augmented_cities".* FROM "augmented_cities" WHERE "augmented_cities"."city_name" = 'London' LIMIT 1
 => #<AugmentedCity city_name: "London", country_name: "United Kingdom", continent_name: "Europe">
```

Another view we defined during the SQL tutorial was `continent_statistics`.
Let's put it to good use:

```
ContinentStatistic.all.each{|cs| puts "#{cs.continent_name} has #{cs.how_many_countries} countries."}
```

The output:

```
D, [] DEBUG -- :   ContinentStatistic Load (0.9ms)  SELECT "continent_statistics".* FROM "continent_statistics"
North America has 4 countries.
South America has 9 countries.
Europe has 32 countries.
Africa has 15 countries.
Asia has 17 countries.
Oceania has 2 countries.
```

Having a one-to-many relationship between two models brings with it slight changes to how we insert records into one of the tables (the one which holds the foreign key).
Let's say there is a country called "East Timor" in Oceania and we want to add it to our database.
Attempting this will fail:

```
Country.create :country_name => "East Timor"
```

The error message we get is:

```
SQLite3::ConstraintException: countries.continent_id may not be NULL
```

The correct way to do what we want is:

```ruby
east_timor = Country.new :country_name => "East Timor"
Continent.find_by_continent_name("Oceania").countries << east_timor
```

### Foreign key relationships: the MANY-TO-MANY case

To go back and forth from both sides of a many-to-many relationship, the API is very similar to what we saw previously, in the one-to-many case.

Let's determine all projects for a given user:

```
User.find_by_user_name("gvoicu").projects.map(&:project_name)
```

The output:

```
D, [] DEBUG -- :   User Load (0.8ms)  SELECT "users".* FROM "users" WHERE "users"."user_name" = 'gvoicu' LIMIT 1
D, [] DEBUG -- :   Project Load (0.6ms)  SELECT "projects".* FROM "projects" INNER JOIN "contributorships" ON "projects"."id" = "contributorships"."project_id" WHERE "contributorships"."user_id" = 2
 => ["rosedu/WebDev", "gvoicu/miniflow", "rails/rails", "sinatra/sinatra"]
```

Let's list all people who contribute to a given project:

```
Project.find_by_project_name("rosedu/WebDev").users.map(&:user_name)
```

The output:

```
D, [] DEBUG -- :   Project Load (0.5ms)  SELECT "projects".* FROM "projects" WHERE "projects"."project_name" = 'rosedu/WebDev' LIMIT 1
D, [] DEBUG -- :   User Load (0.5ms)  SELECT "users".* FROM "users" INNER JOIN "contributorships" ON "users"."id" = "contributorships"."user_id" WHERE "contributorships"."project_id" = 2
 => ["alex-morega", "gvoicu", "igstan", "dserban"]
```

A new contributorship is created in a similar way to how we inserted a new record in the one-to-many case:

```ruby
project_flask = Project.find_by_project_name("mitsuhiko/flask")
User.find_by_user_name("dserban").projects << project_flask
```

To conclude, let's list all contributorships in human readable format:

```
AugmentedContributorship.all.each{|ac| puts "#{ac.user_name} contributes to #{ac.project_name}"}
```

The output:

```
D, [] DEBUG -- :   AugmentedContributorship Load (0.9ms)  SELECT "augmented_contributorships".* FROM "augmented_contributorships"
alex-morega contributes to rosedu/WebDev
alex-morega contributes to rosedu/wouso
alex-morega contributes to mitsuhiko/flask
gvoicu contributes to rosedu/WebDev
gvoicu contributes to gvoicu/miniflow
gvoicu contributes to rails/rails
gvoicu contributes to sinatra/sinatra
igstan contributes to rosedu/WebDev
igstan contributes to gvoicu/miniflow
dserban contributes to torvalds/linux
dserban contributes to rosedu/WebDev
dserban contributes to rosedu/wouso
dserban contributes to rosedu/techblog
dserban contributes to rosedu/StartTheDark
dserban contributes to gvoicu/miniflow
dserban contributes to rails/rails
dserban contributes to sinatra/sinatra
torvalds contributes to torvalds/linux
```

### Closing words

This short overview of ActiveRecord ends here.

If you followed this tutorial as part of a ROSEdu WebDev workshop, please mark your name followed by "(AR)" here (TODO: make a doodle).

