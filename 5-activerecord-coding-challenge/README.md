## Coding Challenge: ActiveRecord-powered PureTextOverflow

This challenge will test your understanding of Ruby in conjunction with SQL, as well as your ability to test-drive a software development project.

Starting from a very basic Ruby skeleton, your challenge is to use TDD to create a pure-text implementation of stackoverflow.com's basic features (users asking questions, providing answers and upvoting / downvoting other users' questions and answers).

Below is the starting point for your challenge.

```ruby
class PureTextOverflow
  def self.start
    banner_text = "Hello there!"
    keyboard_input = ""
    prompt_with = "Say something:"
    loop do
      system("clear")
      puts banner_text
      puts keyboard_input
      puts
      puts prompt_with
      banner_text = "You said:"
      keyboard_input = gets.chomp
      prompt_with = "Say something else:"
    end
  end
end

PureTextOverflow.start
```

Save the above code in a file called `PureTextOverflow.rb` and run the command below at the terminal:

```
ruby PureTextOverflow.rb
```

**Fast-forward a few hours.**

When the new application is fully developed, we would like the user experience to look like this - when first started, it should display a welcome screen:

```
Hello there! Choose a nickname:
```

After choosing the nickname `WebDevStudent` and pressing `Enter` it should display the home screen:

```
Logged in as: WebDevStudent

Main menu

1) Show all questions
2) Ask a question

q) Quit

Select an option:
```

After selecting `2` and pressing `Enter`:

```
Ask a question:
```

After typing in `Why is the sky blue?` and pressing `Enter` it should return to the home screen.

After selecting `1` to show all the questions:

```
Logged in as: WebDevStudent

Showing all questions

1) Iterating Over an Array in Ruby
2) Substituting Variables Into Strings in Ruby
3) Generating Random Numbers in Ruby
4) Validating an Email Address in Ruby
5) Generating Prime Numbers in Ruby
6) Performing Date Arithmetic in Ruby
7) Removing Duplicate Elements from an Array in Ruby
8) Using Symbols as Hash Keys in Ruby
9) Writing an Infinite Loop in Ruby
10) Why is the sky blue?

m) Main menu
q) Quit

Select an option:
```

After selecting `1` to show the first question:

```
Logged in as: WebDevStudent

Showing single question (and its answers, if there are any)

Title:    Iterating Over an Array in Ruby
Body:     How to do it?
Votes:    5
Asked by: WeaponX

10) Answer:
Try this: your_array.each { |x| ... }
Votes: 3 (answer provided by ManOnTheRun)

1) Upvote the question   (not possible if you authored it)
2) Downvote the question (not possible if you authored it)
3) Provide an answer
4) Select an answer to upvote/downvote

m) Main menu
q) Quit

Select an option:
```

As well, providing answers and upvoting / downvoting of questions and answers should work as expected.

You pass the challenge if you develop - within strict adherence to the TDD methodology - a piece of software that:
- is powered by ActiveRecord.
- is modular and robust.
- makes use of `rake db:migrate` to create the database schema.
- makes use of `rake db:seed` to populate the database with initial (seed) data.

**Remember:** your `git log --oneline` needs to show evidence of a thoroughly methodical **RED** - **GREEN** - **REFACTOR** approach.

