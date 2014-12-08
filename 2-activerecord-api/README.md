## Understanding The ActiveRecord API

ActiveRecord is the Ruby persistence layer which is going to power the models in our Rails web apps.

ActiveRecord allows us to retrieve and manipulate database data in an object oriented manner, not just as static rows.

ActiveRecord objects are "smart", they understand the structure of our database tables and know how to interact with them.

ActiveRecord maps:
- database tables to classes (we call these classes models)
- table rows to objects (which are instances of said models)
- table columns to attributes of said objects

### Preparatory steps

Make a new Rails project inside the `/tmp` directory:
```
cd /tmp
rails new LearningActiveRecord
cd LearningActiveRecord
```
We are going to reuse `dev.db`, the database file we ended up with at the end of the SQL tutorial.  
If for any reason you cannot locate the file `dev.db`, please follow these steps:

**Download `dev.db`:**

First make sure you are in the right directory:
```
pwd
```
The output should be:
```
/tmp/LearningActiveRecord
```
Then run:
```
wget -O db/development.sqlite3 http://dserban.github.io/introduction-to-sql/dev.db
```

**Verify the MD5 signature of the database file:**

```
md5sum db/development.sqlite3
```
**The output should be:**
```
fc566111e2973d9eeaa3285b4a21b89d  db/development.sqlite3
```
**Very important:** If you're new to SQL and you haven't yet gone through the SQL tutorial, stop right here, go do that now and when you're done, come back here. A good understanding of SQL is vital, and it is a non-negotiable prerequisite for understanding ActiveRecord.

The SQLite database `db/development.sqlite3` is full of database tables, views and indexes that were created while following the instructions in the SQL tutorial. We are going to leverage the fact that they are now readily available to us, and write some Ruby code ("the ActiveRecord models") that will serve as a proxy when interacting with the aforementioned tables, views and indexes.  
Run the following command at the Linux prompt:
```
sqlite3 db/development.sqlite3
```
The SQLite interactive console should start, and the output should be:
```
Enter ".help" for instructions
Enter SQL statements terminated with a ";"
sqlite>
```
At the `sqlite>` prompt, run this command:
```
.schema
```
The output should consist of several definitions for tables, views and indexes, like this:
```
CREATE TABLE cities (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  country_id INTEGER NOT NULL,
  city_name VARCHAR(255)
);
CREATE TABLE continents (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  continent_name VARCHAR(255)
);
CREATE TABLE contributorships (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  user_id INTEGER NOT NULL,
  project_id INTEGER NOT NULL
);
CREATE TABLE countries (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  continent_id INTEGER NOT NULL,
  country_name VARCHAR(255)
);
CREATE TABLE presidencies (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  first_name VARCHAR(255),
  other_names VARCHAR(255),
  year_from INTEGER,
  year_to INTEGER,
  notes TEXT
);
CREATE TABLE projects (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  project_name VARCHAR(255)
);
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  user_name VARCHAR(255)
);
CREATE VIEW augmented_cities AS
SELECT
  city_name, country_name, continent_name
FROM
  cities, countries, continents
WHERE
  cities.country_id = countries.id
  AND
  countries.continent_id = continents.id;
CREATE VIEW augmented_contributorships AS
SELECT
  user_name, project_name
FROM
  contributorships,
  users,
  projects
WHERE
  users.id = contributorships.user_id
  AND
  projects.id = contributorships.project_id;
CREATE VIEW continent_statistics AS
SELECT
  continent_name, how_many_countries
FROM
  continents,
  (SELECT continent_id, COUNT(*) AS how_many_countries FROM countries GROUP BY continent_id) AS breakdows
WHERE
  continents.id = breakdows.continent_id;
CREATE INDEX index_on_city_name    ON cities    (city_name);
CREATE INDEX index_on_continent_id ON countries (continent_id);
CREATE INDEX index_on_country_id   ON cities    (country_id);
CREATE INDEX index_on_country_name ON countries (country_name);
CREATE INDEX index_on_project_id ON contributorships (project_id);
CREATE INDEX index_on_project_name ON projects (project_name);
CREATE INDEX index_on_user_id    ON contributorships (user_id);
CREATE INDEX index_on_user_name    ON users    (user_name);
CREATE INDEX index_on_year_from ON presidencies (year_from);
CREATE INDEX index_on_year_to   ON presidencies (year_to);
CREATE UNIQUE INDEX unique_index_on_user_id_and_project_id ON contributorships (user_id,project_id);
```
Take a brief moment to review the definitions above, and specifically take note of the fact that all table definitions, always and without exception, begin with a column called `id`, which always looks like this:
```
id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
```
This is an important detail to remember as we progress through this tutorial.

When you're done reviewing the database schema, use Ctrl-D to exit SQLite and go back to the Linux shell.

The next preparatory step is to save the Bash script listed below in a file called `makemodels.sh` in the current directory:
```
cat << EOF > app/models/presidency.rb
class Presidency < ActiveRecord::Base
end
EOF

cat << EOF > app/models/continent.rb
class Continent < ActiveRecord::Base
  has_many :countries
end
EOF

cat << EOF > app/models/country.rb
class Country < ActiveRecord::Base
  has_many   :cities
  belongs_to :continent
end
EOF

cat << EOF > app/models/city.rb
class City < ActiveRecord::Base
  belongs_to :country
end
EOF

cat << EOF > app/models/augmented_city.rb
class AugmentedCity < ActiveRecord::Base
end
EOF

cat << EOF > app/models/continent_statistic.rb
class ContinentStatistic < ActiveRecord::Base
end
EOF

cat << EOF > app/models/user.rb
class User < ActiveRecord::Base
  has_many :contributorships
  has_many :projects, :through => :contributorships
end
EOF

cat << EOF > app/models/project.rb
class Project < ActiveRecord::Base
  has_many :contributorships
  has_many :users, :through => :contributorships
end
EOF

cat << EOF > app/models/contributorship.rb
class Contributorship < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
end
EOF

cat << EOF > app/models/augmented_contributorship.rb
class AugmentedContributorship < ActiveRecord::Base
end
EOF

cat << EOF > app/models/person.rb
class Person < ActiveRecord::Base
end
EOF
```
Assuming you are still in the `/tmp/LearningActiveRecord` directory, run the script like this:
```
bash makemodels.sh
```
The above command should execute very quickly and it should not output anything (meaning it ran succesfully).  
To verify that the files have been created correctly, run:
```
ls -1 app/models/*.rb
```
The output should be:
```
app/models/augmented_city.rb
app/models/augmented_contributorship.rb
app/models/city.rb
app/models/continent.rb
app/models/continent_statistic.rb
app/models/contributorship.rb
app/models/country.rb
app/models/person.rb
app/models/presidency.rb
app/models/project.rb
app/models/user.rb
```
As you can see by looking at the contents of these files, models are subclasses of `ActiveRecord::Base`, a very useful collection of behaviors for connecting our Ruby code to the database.

In your terminal window, make sure you are still in the `/tmp/LearningActiveRecord` directory (just as before), and run this command:
```
rails c
```
The output should be similar to this:
```
Loading development environment (Rails 4.1.6)
2.1.2 :001 > 
```
and there should be no obvious error messages anywhere.

The final preparatory step is to instruct our console environment to establish a connection to the database. Run the following command:
```
ActiveRecord::Base.connection
```
The output should be a wall of text that ends with `:database=>"/tmp/LearningActiveRecord/db/development.sqlite3"`.

We are done with all preparatory steps.  
Without any further explanations, let's start exploring the ActiveRecord API. Things will start to make more sense as we go along.

### The ActiveRecord API

The first model we defined above is `Presidency`, let's type that class name at the prompt.
```
001 > Presidency
 => Presidency(id: integer, first_name: string, other_names: string, year_from: integer, year_to: integer, notes: text)
```
The above output is somewhat surprising. Contrast that with the output we get when we ask to see `Object`.
```
002 > Object
 => Object
```
When we ask to see `Presidency`, we get an extra listing of exactly the fields we defined when we created table `presidencies` during the SQL tutorial.  
The explanation is simple - this is standard behavior we get for free when we extend `ActiveRecord::Base`.  
ActiveRecord takes our model name, converts it from `CamelCase` to `snake_case` and pluralizes it.  
Then it looks inside the database (`db/development.sqlite3`) to see whether or not a table by that name exists.  
`Presidency` `->` conversion to snake-case `->` `presidency` `->` pluralization `->` `presidencies`
- `db/development.sqlite3`, do you contain a table called `presidencies`?
- Yes.
- `db/development.sqlite3`, please give me a list of its fields, along with their types. Someone has asked to see them.

This is our first exposure to the fundamental principles which underpin the philosophy of ActiveRecord:  
**Convention Over Configuration**  
We only need to rely on our knowledge of how the table name - by convention - is being inferred from the model name; it spares us the effort of explicitly configuring (in some XML file somewhere) how the two pieces fit together.  
**Don't Repeat Yourself**  
Why should we specify any getter/setter methods in the class definition for `Presidency`? Why should we repeat ourselves when those methods are namesakes of columns in table `presidencies`, just one database query away?

Type this at the interactive Rails console:
```
Presidency.count
```
The output:
```
   (0.3ms)  SELECT COUNT(*) FROM "presidencies"
 => 30
```
This is our first encounter with a class-level method that performs table-level operations.

Also, notice this is the first time we get to see the SQL trace logger in action. We know exactly what happened in the database (which SQL statement has been issued against the database).  
This is going to be very useful to us for debugging purposes because we get instant insight into how ActiveRecord translates our object-centric API calls into SQL statements.

Next, try this:
```
Presidency.first
```
The output you should see is:
```
  Presidency Load (39.2ms)  SELECT  "presidencies".* FROM "presidencies"   ORDER BY "presidencies"."id" ASC LIMIT 1
 => #<Presidency id: 2, first_name: "Theodore", other_names: "Roosevelt", year_from: 1905, year_to: 1908, notes: "">
```
Notice we are getting an object back.  
But what if we wanted the answer to be in the form of a hash? Try this:
```
Presidency.first.attributes
```
The output:
```
  Presidency Load (0.4ms)  SELECT  "presidencies".* FROM "presidencies"   ORDER BY "presidencies"."id" ASC LIMIT 1
 => {"id"=>2, "first_name"=>"Theodore", "other_names"=>"Roosevelt", "year_from"=>1905, "year_to"=>1908, "notes"=>""}
```
Notice one important detail - we chained the `attributes` method call onto the back of the `first` method call.  
This is worth mentioning because it's typical of how we do things with ActiveRecord; we are going to do a lot of this kind of chaining in subsequent examples below.

Next, try this:
```
Presidency.all
```
Expect a wall of text, it's essentially `SELECT * FROM presidencies`, reformatted as an array of objects.

But what if we wanted an array with just the values for the `year_from` column, kind of like `SELECT year_from FROM presidencies`?  
We can achieve this by chaining a `.map` onto a `.select`, like this:
```
Presidency.select(:year_from).map(&:year_from)
```
The output:
```
  Presidency Load (0.4ms)  SELECT "presidencies"."year_from" FROM "presidencies"
 => [1905, 1909, 1913, 1917, 1921, 1923, 1925, 1929, 1933, 1937, 1941, 1945, 1949, 1953, 1957, 1961, 1964, 1965, 1969, 1973, 1975, 1977, 1981, 1985, 1989, 1993, 1997, 2001, 2005, 2009] 
```
Next, try this:
```
Presidency.find_by(:first_name => "Franklin")
```
The output:
```
  Presidency Load (0.3ms)  SELECT  "presidencies".* FROM "presidencies"  WHERE "presidencies"."first_name" = 'Franklin' LIMIT 1
 => #<Presidency id: 10, first_name: "Franklin", other_names: "D. Roosevelt", year_from: 1933, year_to: 1936, notes: "1st term">
```
This might seem a little strange, especially if you expected the SQL query to be `SELECT * FROM presidencies WHERE first_name = 'Franklin'`, but ActiveRecord has surprisingly appended `LIMIT 1` onto the the back of the SQL statement.

The purpose of `find_by(:some_column_name => some_value)` is to make life easy for us in situations where we know there is a unique index on a column, and where consequently an SQL lookup can only produce either exactly one row or nothing at all.  
In our case, no unique constraint has been defined on column `first_name` and we also know that we are going to find more than one row satisfying that condition, so in order to produce a single value (and not an array), ActiveRecord limits the number of records to 1.

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
raw_input = params[:searchbox]
```
The naive, insecure approach would be to take the raw input and directly plug it into the `WHERE` clause.  
If you do that, you are opening up a new option for experienced attackers and sophisticated vulnerability scanning tools to exploit your web app.  
Through clever use of punctuation, malicious users may inject extra SQL statements onto the end of your `WHERE` clause and do a lot of damage to your database.  
Therefore to protect against such attacks you must be dilligent about sanitizing all input at the application boundary.  
One (admittedly radical) option for doing that is:
```ruby
sanitized_input = raw_input.gsub(/[^a-zA-Z0-9 ]/, "")
Presidency.where("notes LIKE ?", "%" + sanitized_input + "%").order(:year_from)
```
Notice how we removed all punctuation marks from the raw input before letting it through.  
(On a more humorous side note, the pervasiveness of SQL injection vulnerabilities in web applications has given rise to the "Bobby Tables" Internet meme, refer to this XKCD webcomic http://xkcd.com/327/ where the meme originated.)

### Executing raw SQL with ActiveRecord

SQL statements can be very complex and sometimes ActiveRecord does not provide a suitable API for what we want.  
Thankfully ActiveRecord lets us execute raw SQL, which is what we are going to do now to create a new table:
```
ActiveRecord::Base.connection.execute("CREATE TABLE people (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, first_name VARCHAR(255), last_name VARCHAR(255), year_of_birth INTEGER, planet_of_birth VARCHAR(255))")
```
We can now check the success of the SQL operation above by typing the class name `Person` at the prompt.
```
> Person
 => Person(id: integer, first_name: string, last_name: string, year_of_birth: integer, planet_of_birth: string) 
```
Remember, we previously defined a model called `Person` inside of the file `app/models/person.rb`, but the corresponding database table was not there at the very beginning (we have just now created it). And the existence of the `Person` model inside of `app/models/person.rb` is why it works.

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
   (0.2ms)  begin transaction
  SQL (11.8ms)  INSERT INTO "people" ("first_name", "last_name") VALUES (?, ?)  [["first_name", "John"], ["last_name", "Doe"]]
   (0.3ms)  commit transaction
 => "Saved." 
```

As you can see, the syntax of the generated `INSERT` statement differs slightly from what we were using during the SQL tutorial, but the end-result is the same.  
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
Notice how `save` returns true or false, while `create` returns a reference to the object which we just stored in the database.

### Foreign key relationships: the ONE-TO-MANY case

The fact that in our model definitions a `Continent` `has_many :countries` and a `Country` `belongs_to :continent` brings with it some interesting behavior.

Let's look at how we ask the question "Which countries are in the continent called Oceania?"  
Try this:
```
Continent.find_by(:continent_name => "Oceania").countries.map(&:country_name)
```
The output:
```
  Continent Load (0.3ms)  SELECT  "continents".* FROM "continents"  WHERE "continents"."continent_name" = 'Oceania' LIMIT 1
  Country Load (0.2ms)  SELECT "countries".* FROM "countries"  WHERE "countries"."continent_id" = ?  [["continent_id", 6]]
 => ["Australia", "New Zealand"] 
```
Conversely, how would we ask the question "Which continent does the country of Argentina belong to?"  
Try this:
```
Country.find_by(:country_name => "Argentina").continent.continent_name
```
The output:
```
  Country Load (0.4ms)  SELECT  "countries".* FROM "countries"  WHERE "countries"."country_name" = 'Argentina' LIMIT 1
  Continent Load (0.3ms)  SELECT  "continents".* FROM "continents"  WHERE "continents"."id" = ? LIMIT 1  [["id", 2]]
 => "South America" 
```
A similar strategy would be applicable for the bidirectional traversal of the foreign key relationship between `Country` and `City`.

But how would we ask the question "Which cities are in the continent called Oceania?"  
The first thing that comes to mind is this:
```
Continent.find_by(:continent_name => "Oceania").countries.map(&:cities)
```
And this is what you get in response:
```
  Continent Load (0.3ms)  SELECT  "continents".* FROM "continents"  WHERE "continents"."continent_name" = 'Oceania' LIMIT 1
  Country Load (0.3ms)  SELECT "countries".* FROM "countries"  WHERE "countries"."continent_id" = ?  [["continent_id", 6]]
  City Load (0.4ms)  SELECT "cities".* FROM "cities"  WHERE "cities"."country_id" = ?  [["country_id", 78]]
  City Load (0.3ms)  SELECT "cities".* FROM "cities"  WHERE "cities"."country_id" = ?  [["country_id", 79]]
 => [#<ActiveRecord::Associations::CollectionProxy [#<City id: 30, country_id: 78, city_name: "Canberra">]>, #<ActiveRecord::Associations::CollectionProxy [#<City id: 120, country_id: 79, city_name: "Wellington">]>] 
```
But notice the output isn't very usable. It's a slightly obscured array of arrays of objects, not what we had in mind.  
Surely there must be a better solution.  
There is. During the SQL tutorial we defined a join view called `augmented_cities`, and inside of `app/models/augmented_city.rb` we defined a model called `AugmentedCity`.  
Let's take advantage of that. Try this:
```
AugmentedCity.where(:continent_name => "Oceania").map(&:city_name)
```
The output:
```
  AugmentedCity Load (0.3ms)  SELECT "augmented_cities".* FROM "augmented_cities"  WHERE "augmented_cities"."continent_name" = 'Oceania'
 => ["Canberra", "Wellington"] 
```
There was also this SQL query we tried during the SQL tutorial:

```sql
SELECT * FROM augmented_cities WHERE city_name = 'London';
```
To accomplish the same thing with ActiveRecord, we use:
```
AugmentedCity.find_by(:city_name => "London")
```
The output:
```
  AugmentedCity Load (0.4ms)  SELECT  "augmented_cities".* FROM "augmented_cities"  WHERE "augmented_cities"."city_name" = 'London' LIMIT 1
 => #<AugmentedCity city_name: "London", country_name: "United Kingdom", continent_name: "Europe"> 
```
Another view we defined during the SQL tutorial was `continent_statistics`.  
Let's put it to good use:
```
ContinentStatistic.all.each{|cs| puts "#{cs.continent_name} has #{cs.how_many_countries} countries."}
```
The first part of the output looks like this:
```
  ContinentStatistic Load (0.5ms)  SELECT "continent_statistics".* FROM "continent_statistics"
North America has 4 countries.
South America has 9 countries.
Europe has 32 countries.
Africa has 15 countries.
Asia has 17 countries.
Oceania has 2 countries.
```
Having a one-to-many relationship between two models brings with it slight changes to how we insert records into one of the tables (the one which holds the foreign key).  
Let's say there is a new country in Oceania called "East Timor" and we want to add it to our database.  
Attempting this will fail:
```
Country.create(:country_name => "East Timor")
```
The error message we get is:
```
SQLite3::ConstraintException: countries.continent_id may not be NULL
```
The correct way to do what we want is:
```ruby
east_timor = Country.new(:country_name => "East Timor")
Continent.find_by(:continent_name => "Oceania").countries << east_timor
```
### Foreign key relationships: the MANY-TO-MANY case

To go back and forth from both sides of a many-to-many relationship, the API is very similar to what we saw previously, in the one-to-many case.

Let's determine all projects for a given user:
```
User.find_by(:user_name => "gvoicu").projects.map(&:project_name)
```
The output:
```
  User Load (0.3ms)  SELECT  "users".* FROM "users"  WHERE "users"."user_name" = 'gvoicu' LIMIT 1
  Project Load (0.4ms)  SELECT "projects".* FROM "projects" INNER JOIN "contributorships" ON "projects"."id" = "contributorships"."project_id" WHERE "contributorships"."user_id" = ?  [["user_id", 2]]
 => ["rosedu/WebDev", "gvoicu/miniflow", "rails/rails", "sinatra/sinatra"] 
```
Let's list all people who contribute to a given project:
```
Project.find_by(:project_name => "rosedu/WebDev").users.map(&:user_name)
```
The output:
```
  Project Load (0.4ms)  SELECT  "projects".* FROM "projects"  WHERE "projects"."project_name" = 'rosedu/WebDev' LIMIT 1
  User Load (0.4ms)  SELECT "users".* FROM "users" INNER JOIN "contributorships" ON "users"."id" = "contributorships"."user_id" WHERE "contributorships"."project_id" = ?  [["project_id", 2]]
 => ["alex-morega", "gvoicu", "igstan", "dserban"] 
```
A new contributorship is created in a similar way to how we inserted a new record in the one-to-many case:
```ruby
project_flask = Project.find_by(:project_name => "mitsuhiko/flask")
User.find_by(:user_name => "alex-morega").projects << project_flask
```
To conclude, let's list all contributorships in human readable format:
```
AugmentedContributorship.all.each{|ac| puts "#{ac.user_name} contributes to #{ac.project_name}"}
```
The first part of the output looks like this:
```
  AugmentedContributorship Load (0.5ms)  SELECT "augmented_contributorships".* FROM "augmented_contributorships"
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
alex-morega contributes to mitsuhiko/flask
```
This short overview of ActiveRecord ends here.
