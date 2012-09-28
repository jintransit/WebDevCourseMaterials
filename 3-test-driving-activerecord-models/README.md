## Test-driving ActiveRecord models

This tutorial assumes a good knowledge of the ActiveRecord API and some familiarity with the software development methodology called **TDD** (**T**est-**D**riven **D**evelopment).

We are going to combine those skills and learn how to efficiently develop robust ActiveRecord models in quick iterations.

Before we begin writing tests for our models, we need to understand what validations are and how they work.

### Let's start coding!

In the same location as before (directory `webdevmodels`) create a new file called `tdd.rb` with the following contents:

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
#  has_many :countries
end

class Country < ActiveRecord::Base
#  has_many   :cities
#  belongs_to :continent
end

class City < ActiveRecord::Base
#  belongs_to :country
end

class AugmentedCity < ActiveRecord::Base
end

class ContinentStatistic < ActiveRecord::Base
end

class User < ActiveRecord::Base
#  has_many :contributorships
#  has_many :projects, :through => :contributorships
end

class Project < ActiveRecord::Base
#  has_many :contributorships
#  has_many :users, :through => :contributorships
end

class Contributorship < ActiveRecord::Base
#  belongs_to :user
#  belongs_to :project
end

class AugmentedContributorship < ActiveRecord::Base
end

class Person < ActiveRecord::Base
  validates :first_name, :last_name, :presence => true
end
```

Notice a few differences between this `tdd.rb` and the file we have been working with so far, `app.rb`.

First of all, we commented out all the custom code we had inside our models. We did this specifically because we are going to write the tests first, and we need those tests to fail. Once test failure has been demonstrated, we are going to uncomment those lines of code to make the tests green.

There is also a new line of code we haven't seen before. It is included inside the definition of the `Person` model and it looks like this:

```ruby
  validates :first_name, :last_name, :presence => true
```

This line of code almost reads itself, no explanations are needed for what it does, but I needed to point out its existence in order to introduce the following terminology: we call a validation rule any line of code that begins with `validate` or `validates`, inside of a model.

Let's start the interactive Ruby console. Run this command at the terminal:

```
irb -r ./tdd.rb
```

At the Ruby prompt, type:

```
p = Person.new
p.valid?
```

The output you should see is:

```
1.9.3-p125 :001 > p = Person.new
 => #<Person id: nil, first_name: nil, last_name: nil, year_of_birth: nil, planet_of_birth: nil>
1.9.3-p125 :002 > p.valid?
 => false
```

What this tells us is that a newly created empty `Person` model cannot be saved because the constraints we specified in the validation rule aren't satisfied (no values have been supplied for `first_name` and `last_name`). Indeed, attempting `p.save` at this point will return `false`, and nothing gets written to the database.

Running `p.valid?` not only returns a boolean value, but also has another interesting side effect, which we are going to leverage in order to write meaningful, effective tests.

Try this:

```
1.9.3-p125 :004 > p.errors.messages.has_key?(:first_name)
 => true
```

`p.errors.messages` is the place where ActiveRecord silently complains about everything that went wrong during the validation. `p.errors.messages` is a hash that gets populated as a side effect of running `p.valid?`.

Let's examine what the hash looks like:

```
1.9.3-p125 :005 > p.errors.messages
 => {:first_name=>["can't be blank"], :last_name=>["can't be blank"]}
```

Let's give our model what it wants, and then run the validation again and check for an error condition:

```
p.first_name = "John"
p.last_name = "Doe"
p.valid?
p.errors.messages.has_key?(:first_name)
```

This time we get `true` as a result of calling `p.valid?`, and `p.errors.messages` is an empty hash now.

### Writing our first ActiveRecord test

Quit the interactive Ruby console (with Ctrl-D).

Open `tdd.rb` in a text editor and comment out the validation rule in the `Person` model.

```ruby
class Person < ActiveRecord::Base
#  validates :first_name, :last_name, :presence => true
end
```

To start testing, create a new empty file in the same location as `tdd.rb` and initialize the git repository:

```
touch activerecord_test.rb
git init
git add activerecord_test.rb
git commit -m "Initial commit"
```

Paste the following code into `activerecord_test.rb`:

```ruby
require 'test/unit'
require './tdd.rb'

class TestPersonModel < Test::Unit::TestCase
  def test_that_it_checks_for_presence_of_first_name
    p = Person.new
    p.valid?
    assert( p.errors.messages.has_key?(:first_name), failure_message = "It does not check for the presence of attribute first_name." )
  end
end
```

Save the file and run the test:

```
ruby activerecord_test.rb
```

The output you should see:

```
Run options: 

# Running tests:

F

Finished tests in 0.115625s, 8.6487 tests/s, 8.6487 assertions/s.

  1) Failure:
test_that_it_checks_for_presence_of_first_name(TestPersonModel) [activerecord_test.rb:8]:
It does not check for the presence of attribute first_name.

1 tests, 1 assertions, 1 failures, 0 errors, 0 skips
```

If you're not seeing this output, it means you forgot to comment out the validation rule as described above.

So this is our first failing test.

You can commit now, and make sure you start your commit message with `RED`:

```
git commit -am "RED: test_that_it_checks_for_presence_of_first_name"
```

To make the test pass, all we need to do now is go back into `tdd.rb` and uncomment the validation rule, right?

**WRONG.**

This would violate the fundamental tenet of TDD which says that you need to write the **absolute minimum amount** of code which makes the test pass.

Inside `tdd.rb`, make a copy of the commented line and make sure it validates **only** the presence of `first_name`, like this:

```ruby
class Person < ActiveRecord::Base
#  validates :first_name, :last_name, :presence => true
  validates :first_name, :presence => true
end
```

Run the test, see it pass, commit:

```
git commit -am "GREEN: test_that_it_checks_for_presence_of_first_name"
```

The next thing we need to do is to write a similar test for the `last_name` attribute.

However, the trap we need to be careful not to fall into is copying/pasting the test method we wrote previously, then swapping out `first_name` in favor of `last_name`.

What we need to do instead is to build an array of attributes and iterate over it, like this:

```ruby
require 'test/unit'
require './tdd.rb'

class TestPersonModel < Test::Unit::TestCase
  def test_that_it_checks_for_presence_of_required_attributes
    p = Person.new
    p.valid?
    [:first_name, :last_name].each do |attr|
      assert( p.errors.messages.has_key?(attr), failure_message = "It does not check for the presence of attribute #{attr}." )
    end
  end
end
```

Run the test and see it fail with the message:
`It does not check for the presence of attribute last_name`.

Commit:

```
git commit -am "RED: test_that_it_checks_for_presence_of_required_attributes"
```

To make the test pass, reset the `Person` model to what it was initially:

```ruby
class Person < ActiveRecord::Base
  validates :first_name, :last_name, :presence => true
end
```

Run the test, see it pass, and commit:

```
git commit -am "GREEN: test_that_it_checks_for_presence_of_required_attributes"
```

Our next test is going to check whether or not an attribute has been assigned a numerical value.

Our `Person` model has an attribute called `year_of_birth`, which is defined as an integer in the database.

Let's see what happens if we give it something that is not a number. Type the following commands at the Ruby prompt:

```ruby
p = Person.new :first_name => "John", :last_name => "Doe", :year_of_birth => "abc"
p.valid?
```

Unfortunately, the output shows ActiveRecord not complaining at all, the model is considered valid.

We take this opportunity to write a failing test.

Inside `activerecord_test.rb`, create a new test method, like this:

```ruby
  def test_that_it_checks_for_numericality_of_year_of_birth
    p = Person.new :first_name => "John", :last_name => "Doe", :year_of_birth => "abc"
    p.valid?
    assert( p.errors.messages.has_key?(:year_of_birth), failure_message = "It does not check for numericality of the attribute year_of_birth." )
  end
```

Run the test, see it fail, commit:

```
git commit -am "RED: test_that_it_checks_for_numericality_of_year_of_birth"
```

To make the test pass, add a new validation rule to the `Person` model, like this:

```ruby
class Person < ActiveRecord::Base
  validates :first_name, :last_name, :presence => true
  validates :year_of_birth, :numericality => true
end
```

Run the test, see it pass, commit:

```
git commit -am "GREEN: test_that_it_checks_for_numericality_of_year_of_birth"
```

**Exercise:**

We want to make sure that `year_of_birth` is a plausible numeric value for a person who is alive today. Ensuring that our `Person` model only allows **integer** values which are **greater than or equal to 1900** is left as an exercise to the reader. The validation rules you are going to need look like this:

```ruby
  validates :year_of_birth, :numericality => { :only_integer => true }
  validates :year_of_birth, :numericality => { :greater_than_or_equal_to => 1900 }
```

To clarify, since we are introducing two new validations, we are going to need two distinct test methods, and we are therefore going to commit four times.

### ActiveRecord callbacks

Callbacks are hooks into the lifecycle of an ActiveRecord object that allow us to trigger logic before or after an alteration of the object state.

Our `Person` model contains an attribute called `planet_of_birth`, which we are going to use to showcase ActiveRecord's `before_save` callback. `before_save` allows us to specify a fragment of Ruby code which will always run after all validations have completed successfully, but before the SQL statement to store the data is executed against the database.

In our case, we want to leverage `before_save` to make sure `planet_of_birth` defaults to a value of "Earth" if no other value has been supplied explicitly.

Let's write the failing test first. Add this test method to `activerecord_test.rb`:

```ruby
  def test_that_it_gives_a_default_value_to_planet_of_birth
    p = Person.new :first_name => "John", :last_name => "Doe", :year_of_birth => 1992
    assert( p.save, failure_message = "Could not save a new Person object." )
    pob = p.planet_of_birth
    p.destroy
    assert( pob == "Earth", failure_message = "It does not give planet_of_birth a default value when saving." )
  end
```

Run the test, see it fail, commit:

```
git commit -am "RED: test_that_it_gives_a_default_value_to_planet_of_birth"
```

To make the test pass, add a `before_save` block to the `Person` model, like this:

```ruby
class Person < ActiveRecord::Base
  validates :first_name, :last_name, :presence => true
  validates :year_of_birth, :numericality => true
  validates :year_of_birth, :numericality => { :only_integer => true }
  validates :year_of_birth, :numericality => { :greater_than_or_equal_to => 1900 }
  before_save { |person| person.planet_of_birth = "Earth" if person.planet_of_birth.blank? }
end
```

Run the test, see it pass, commit:

```
git commit -am "GREEN: test_that_it_gives_a_default_value_to_planet_of_birth"
```

### Named scopes

A named scope is a special syntactic sugar to describe a subset of models. A good example is fuzzy search. We want to find all records in a database in which either the first name begins with "John" or the last name begins with "John".

The specific use case is going to look like this:

```ruby
Person.fuzzy_search("John")
```

which is going to return an array containing both "Johnny Brown" and "Peter Johnson" (for example).

To start test-driving our scope, we are first going to check whether an instance of the `Person` model responds to `fuzzy_search`.

Let's write the failing test first. Add this test method to `activerecord_test.rb`:

```ruby
  def test_that_it_responds_to_fuzzy_search
    assert_respond_to( Person, :fuzzy_search, failure_message = "It does not respond to fuzzy_search." )
  end
```

Run the test, see it fail, commit:

```
git commit -am "RED: test_that_it_responds_to_fuzzy_search"
```

Add an empty `scope` declaration to the `Person` model. This one line is the minimum amount of code that will make the test pass.

```ruby
class Person < ActiveRecord::Base
  validates :first_name, :last_name, :presence => true
  validates :year_of_birth, :numericality => true
  validates :year_of_birth, :numericality => { :only_integer => true }
  validates :year_of_birth, :numericality => { :greater_than_or_equal_to => 1900 }
  before_save { |person| person.planet_of_birth = "Earth" if person.planet_of_birth.blank? }
  scope :fuzzy_search
end
```

Run the test, see it pass, commit:

```
git commit -am "GREEN: test_that_it_responds_to_fuzzy_search"
```

In our next failing test, we are going to create three new `Person` records, two of which satisfy the fuzzy search we just mentioned. We then verify that our scope captures them, but doesn't capture the third one.

Add this test method to `activerecord_test.rb`:

```ruby
  def test_that_its_fuzzy_search_captures_records_correctly
    before_count = Person.fuzzy_search("John").count
    p1 = Person.new :first_name => "Johnny", :last_name => "Brown", :year_of_birth => 1992
    assert( p1.save, failure_message = "Could not save a new Person object." )
    p2 = Person.new :first_name => "Peter", :last_name => "Johnson", :year_of_birth => 1993
    assert( p2.save, failure_message = "Could not save a new Person object." )
    p3 = Person.new :first_name => "Laura", :last_name => "Miller", :year_of_birth => 1994
    assert( p3.save, failure_message = "Could not save a new Person object." )
    after_count = Person.fuzzy_search("John").count
    p1.destroy
    p2.destroy
    p3.destroy
    difference = after_count - before_count
    assert( difference == 2, failure_message = "Its fuzzy search does not capture records correctly." )
  end
```

Run the test, see it fail, commit:

```
git commit -am "RED: test_that_its_fuzzy_search_captures_records_correctly"
```

To make the test green, we are going to fully implement the scope, like this:

```ruby
class Person < ActiveRecord::Base
  validates :first_name, :last_name, :presence => true
  validates :year_of_birth, :numericality => true
  validates :year_of_birth, :numericality => { :only_integer => true }
  validates :year_of_birth, :numericality => { :greater_than_or_equal_to => 1900 }
  before_save { |person| person.planet_of_birth = "Earth" if person.planet_of_birth.blank? }
  scope :fuzzy_search, lambda { |term| where("UPPER(first_name) LIKE ? OR UPPER(last_name) LIKE ?", term.upcase + "%", term.upcase + "%") }
end
```

Run the test, see it pass, commit:

```
git commit -am "GREEN: test_that_its_fuzzy_search_captures_records_correctly"
```

### Advanced validation rules

We are now going to stop developing the `Person` model and focus our attention on `Presidency`, which presents to us some opportunities for learning how to perform validations at a more advanced level.

We assume the `Presidency` model has already been developed in a test-driven manner up to a point where it contains the following basic validations:

```ruby
class Presidency < ActiveRecord::Base
  validates :first_name, :other_names, :year_from, :year_to, :presence => true
  validates :year_from, :year_to, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1789 }
end
```

There are a few constraints which are specific to the entity we are modeling (a presidency term):
- year_to must be after year_from
- the length of a term cannot exceed 4 years
- presidency terms must not overlap

**Exercise:** write a failing test for the first constraint.

**Solution:**

To do this, we are going to add a new test class to `activerecord_test.rb`, like this:

```ruby
require 'test/unit'
require './tdd.rb'

class TestPersonModel < Test::Unit::TestCase
  # the tests we wrote for the Person model
end

class TestPresidencyModel < Test::Unit::TestCase
  def test_that_it_checks_year_to_must_be_after_year_from
    p = Presidency.new :first_name => "John", :other_names => "Doe", :year_from => 2024, :year_to => 2021
    p.valid?
    assert( p.errors.messages.has_key?(:yt_after_yf), failure_message = "It does not check that year_to must be after year_from." )
  end
end
```

Run the test, see it fail, commit:

```
git commit -am "RED: test_that_it_checks_year_to_must_be_after_year_from"
```

To make the test pass, we are going to need a custom validation rule, since the logic now involves more than one attribute of the `Presidency` model.

We create a custom validation rule by creating a `validate` block, like this:

```ruby
class Presidency < ActiveRecord::Base
  validates :first_name, :other_names, :year_from, :year_to, :presence => true
  validates :year_from, :year_to, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1789 }
  validate do |presidency|
    yf = presidency.year_from.to_i
    yt = presidency.year_to.to_i
    if yt < yf
      self.errors.messages[:yt_after_yf] = ["year_to must be after year_from"]
    end
  end
end
```

Run the test, see it pass, commit:

```
git commit -am "GREEN: test_that_it_checks_year_to_must_be_after_year_from"
```

**Exercise:**

Writing the failing test for whether it checks that the length of a term cannot exceed 4 years is left as an exercise to the reader, the corresponding piece of code inside of the `validate` block in `tdd.rb` is going to be:

```ruby
    if (yt - yf) > 3
      self.errors.messages[:term_length] = ["the length of a term cannot exceed 4 years"]
    end
```

**Next exercise:** write a failing test for whether it checks that presidency terms must not overlap.

**Solution:**

Add this test method to the `TestPresidencyModel` class inside `activerecord_test.rb`:

```ruby
  def test_that_it_checks_for_overlapping_presidency_terms
    2021.upto(2022) do |year|
      Presidency.where("? BETWEEN year_from AND year_to", year).first.destroy rescue NoMethodError
    end
    p1 = Presidency.new :first_name => "John", :other_names => "Doe", :year_from => 2021, :year_to => 2022
    assert( p1.save, failure_message = "Could not save a new Presidency object." )
    p2 = Presidency.new :first_name => "R.", :other_names => "Smith", :year_from => 2022, :year_to => 2023
    p2.valid?
    p2errmsg = p2.errors.messages
    p1.destroy
    assert( p2errmsg.has_key?(:overlap), failure_message = "It does not check that presidency terms must not overlap." )
  end
```

What we did here is we first of all made sure that nothing else occupies the space 2021-2022. The `destroy` command in that first block may fail if no record was found, hence the `rescue` clause.

Following that we created two presidency terms that overlap at the year 2022.

Run the test, see it fail, commit:

```
git commit -am "RED: test_that_it_checks_for_overlapping_presidency_terms"
```

**Exercise:** implement the validation rule that makes this test pass.

**Solution:**

```ruby
  validate do |presidency|
    yf = presidency.year_from.to_i
    yt = presidency.year_to.to_i
    ok_to_validate_overlap = true
    if yt < yf
      self.errors.messages[:yt_after_yf] = ["year_to must be after year_from"]
      ok_to_validate_overlap = false
    end
    if (yt - yf) > 3
      self.errors.messages[:term_length] = ["the length of a term cannot exceed 4 years"]
      ok_to_validate_overlap = false
    end
    if yf != 0 && yt != 0 && ok_to_validate_overlap
      how_many_overlaps = 0
      yf.upto(yt) do |year|
        how_many_overlaps += self.class.where("? BETWEEN year_from AND year_to", year).count
      end
      if how_many_overlaps != 0
        self.errors.messages[:overlap] = ["presidency terms must not overlap"]
      end
    end
  end
```

Run the test, see it pass, commit:

```
git commit -am "GREEN: test_that_it_checks_for_overlapping_presidency_terms"
```

**Exercise:** Refactor the frequently used snippet of code `where("? BETWEEN year_from AND year_to", year).first` into a named scope called `which_one_includes_year`.

### Test-driving foreign key relationships

When we explored the ActiveRecord API, we saw how adding foreign key declarations (`has_many` and `belongs_to`) to our models makes a few interesting relationship traversal methods available to us.

The first few basic tests we are going to write will check whether new instances of our models respond to those relationship traversal methods.

First, let's test whether a new instance of the `Continent` model responds to `countries`:

```ruby
class TestContinentModel < Test::Unit::TestCase
  def test_that_it_responds_to_countries
    assert_respond_to( Continent.new, :countries, failure_message = "It does not traverse the foreign key relationship." )
  end
end
```

Run the test, see it fail, commit:

```
git commit -am "RED: test_that_it_responds_to_countries"
```

Uncomment the `has_many` declaration in the `Continent` model, like this:

```ruby
class Continent < ActiveRecord::Base
  has_many :countries
end
```

Run the test, see it pass, commit:

```
git commit -am "GREEN: test_that_it_responds_to_countries"
```

**Exercise:** Test-drive all the other foreign key relationships.

One thing we haven't tested so far are uniqueness constraints.

Let's start by testing the obvious reality that two different countries cannot have the same name.

```ruby
class TestCountryModel < Test::Unit::TestCase
  def test_that_it_enforces_the_uniqueness_of_country_name
    random_continent = Continent.new :continent_name => SecureRandom.hex(8)
    assert( random_continent.save, failure_message = "Could not save a new Continent object." )
    randomly_generated_string = SecureRandom.hex(8)
    c1 = Country.new :continent => random_continent, :country_name => randomly_generated_string
    assert( c1.save, failure_message = "Could not save a new Country object." )
    c2 = Country.new :continent => random_continent, :country_name => randomly_generated_string
    c2.valid?
    c2errmsg = c2.errors.messages
    c1.destroy
    random_continent.destroy
    assert( c2errmsg.has_key?(:country_name), failure_message = "It does not enforce the uniqueness of country_name." )
  end
end
```

Notice how we used a random hex string generator in order to ensure that we do not accidentally attempt to store an already existing `Country` object.

Run the test, see it fail, commit:

```
git commit -am "RED: test_that_it_enforces_the_uniqueness_of_country_name"
```

To make the test pass, we are going to add to the `Country` model a validation rule which enforces uniqueness, like this:

```ruby
class Country < ActiveRecord::Base
  validates  :country_name, :presence => true, :uniqueness => true
  has_many   :cities
  belongs_to :continent
end
```

From a performance perspective our new uniqueness constraint is supported by the index we created on table `countries`, column `country_name`.

### Named scopes that cross model boundaries

Suppose we have a `Continent` object (e.g. Europe) and we want a named scope that captures all countries which belong to that continent and the names of which begin with a certain sequence of characters (e.g. "Sw"), something that works like this in the interactive Ruby console:

```ruby
1.9.3-p125 :001 > europe = Continent.find_by_continent_name("Europe")
 => #<Continent id: 3, continent_name: "Europe"> 
1.9.3-p125 :002 > europe.countries.which_begin_with("Sw").map(&:country_name)
 => ["Sweden", "Switzerland"] 
```

In the code snippet above, the method `which_begin_with` is effectively a named scope that operates one degree of separation away from the `Continent` model.

Let's write some failing tests, then implement that method.

First, we check that the `countries` array of a new instance of the `Continent` model responds to `which_begin_with`.

Inside class `TestContinentModel`, add the following test method:

```ruby
  def test_that_its_countries_array_responds_to_which_begin_with
    assert_respond_to( Continent.new.countries, :which_begin_with, failure_message = "Its countries array does not respond to which_begin_with." )
  end
```

Run the test, see it fail, commit:

```
git commit -am "RED: test_that_its_countries_array_responds_to_which_begin_with"
```

To make the test pass, we are going to supply to the `has_many` declaration of the `Continent` model a block with an empty `which_begin_with` method inside of it, like this:

```ruby
class Continent < ActiveRecord::Base
  has_many :countries do
    def which_begin_with
    end
  end
end
```

Run the test, see it pass, commit:

```
git commit -am "GREEN: test_that_its_countries_array_responds_to_which_begin_with"
```

To finish up, we now write the failing test for the desired behavior of the proxy named scope.

Inside class `TestContinentModel`, add the following test method:

```ruby
  def test_that_countries_which_begin_with_captures_records_correctly
    random_continent = Continent.new :continent_name => SecureRandom.hex(8)
    assert( random_continent.save, failure_message = "Could not save a new Continent object." )
    before_count = random_continent.countries.which_begin_with("Sw").count
    c1 = Country.new :continent => random_continent, :country_name => "Sw" + SecureRandom.hex(8)
    assert( c1.save, failure_message = "Could not save a new Country object." )
    c2 = Country.new :continent => random_continent, :country_name => "Ab" + SecureRandom.hex(8)
    assert( c2.save, failure_message = "Could not save a new Country object." )
    after_count = random_continent.countries.which_begin_with("Sw").count
    c1.destroy
    c2.destroy
    random_continent.destroy
    difference = after_count - before_count
    assert( difference == 1, failure_message = "The which_begin_with of its countries array does not capture records correctly." )
  end
```

Run the test, see it fail, commit:

```
git commit -am "RED: test_that_countries_which_begin_with_captures_records_correctly"
```

To make the test pass, we are going to write the actual implementation of `which_begin_with`, like this:

```ruby
class Continent < ActiveRecord::Base
  has_many :countries do
    def which_begin_with(leading_string)
      where("country_name LIKE ?", leading_string + "%")
    end
  end
end
```

Run the test, see it pass, commit:

```
git commit -am "GREEN: test_that_countries_which_begin_with_captures_records_correctly"
```

### Closing words

If you followed this tutorial as part of a ROSEdu WebDev workshop, please mark your name followed by "(TDD-AR)" [here](http://doodle.com/cayn4byuz3d9czgw).

