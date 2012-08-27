## Coding Challenge: Unit Tests Are FIRST !!!

This challenge will test your ability to:
- quickly absorb the syntax and idioms of an unfamiliar programming language (Ruby in this particular case);
- discipline your brain to adapt to an unfamiliar (but superior) development methodology.

The development methodology we just mentioned is **TDD**, which stands for **T**est-**D**riven **D**evelopment.

The mechanism of TDD is simple. It consists of iterations of **RED**-**GREEN**-**REFACTOR** where:
- **RED** involves capturing a small piece of system specification in the form of a coded software test which MUST FAIL.
- After demonstrating test failure, you build the **smallest possible amount** of production software that meets this specification. In other words, you write the code that makes the test **GREEN** (and doesn’t break any existing tests).
- You then review the new code in conjunction with the existing system, correcting any deficiencies in its design or the overall system design (this step is known as the **REFACTOR**ing step and it is optional).

If everything goes right, at the end of each iteration your git log will show two or three new commits which are clearly marked **RED**, **GREEN** and **REFACTOR**.

### The Challenge

Someone handed over to you some poorly designed yet functioning legacy code and you must turn it into a modular, robust, thoroughly testable piece of software (within strict adherence to the TDD methodology).

Below is the starting point for your challenge, a legacy Ruby program that simulates a gameplay.

```ruby
class TicTacToe
  BOARD = [:a1, :a2, :a3, :b1, :b2, :b3, :c1, :c2, :c3]
  WINNING_COMBINATIONS = [[:a1, :a2, :a3],
                          [:b1, :b2, :b3],
                          [:c1, :c2, :c3],
                          [:a1, :b1, :c1],
                          [:a2, :b2, :c2],
                          [:a3, :b3, :c3],
                          [:a1, :b2, :c3],
                          [:c1, :b2, :a3]]

  def initialize
    @owned_by_x     = []
    @owned_by_zero  = []
    @who_moves_next = 1
  end

  def play
    9.times do
      if @who_moves_next == 1
        @owned_by_x << (BOARD - @owned_by_x - @owned_by_zero).sample
      else
        @owned_by_zero << (BOARD - @owned_by_x - @owned_by_zero).sample
      end
      WINNING_COMBINATIONS.each do |wcomb|
        return "Game over, X won." if (wcomb - @owned_by_x).empty?
        return "Game over, 0 won." if (wcomb - @owned_by_zero).empty?
      end
      @who_moves_next = 1 - @who_moves_next
    end
    "Game over, nobody won."
  end
end
```

As you can see, the original developer could have wrapped some of the logic in method calls with descriptive names, but didn't bother to do so.

Save the above code in a file called `tictactoe.rb` and run the command below at the terminal:

```
irb -r ./tictactoe.rb
```

At the interactive Ruby prompt, type `TicTacToe.new.play` several times:

```
1.9.3-p125 :001 > TicTacToe.new.play
 => "Game over, X won."
 
1.9.3-p125 :002 > TicTacToe.new.play
 => "Game over, X won."
 
1.9.3-p125 :003 > TicTacToe.new.play
 => "Game over, 0 won."
 
1.9.3-p125 :004 > TicTacToe.new.play
 => "Game over, nobody won."
```

So the program clearly works, but we want a new one which is going to behave a little differently. And - **more importantly** - we want the development process to be test-driven.

When the new program is fully developed, we would like the gameplay to look like this:

```
1.9.3-p125 :001 > player_x = TicTacToePlayer.new "X"
 => #<TicTacToePlayer:0x8dda3bc>

1.9.3-p125 :002 > player_zero = TicTacToePlayer.new "0"
 => #<TicTacToePlayer:0x8dc5c78>

1.9.3-p125 :003 > game_state = player_x.turn {:owned_by_x => [], :owned_by_zero => []}
 => {:owned_by_x=>[:b3], :owned_by_zero=>[]}

1.9.3-p125 :004 > game_state = player_zero.turn game_state
 => {:owned_by_x=>[:b3], :owned_by_zero=>[:a1]}

1.9.3-p125 :005 > game_state = player_x.turn game_state
 => {:owned_by_x=>[:b3, :c3], :owned_by_zero=>[:a1]}

1.9.3-p125 :006 > game_state = player_zero.turn game_state
 => {:owned_by_x=>[:b3, :c3], :owned_by_zero=>[:a1, :a2]}

1.9.3-p125 :007 > game_state = player_x.turn game_state
Game over, X won.
 => nil
```

I will get you started by writing two simple RED-GREEN iterations for you, and then it's game on for you.

Start by creating a new empty file and initializing the git repository:

```
touch tictactoeplayer_test.rb
git init
git add tictactoeplayer_test.rb
git commit -m "Initial commit"
```

Paste the following code into `tictactoeplayer_test.rb`:

```ruby
require 'test/unit'

class TicTacToePlayer
end

class TestPlayer < Test::Unit::TestCase
  def test_truthiness
    functionality_implemented = false
    assert( functionality_implemented, failure_message = "Functionality not implemented" )
  end
end
```

Save the file.

One more thing before we run the test: let's make sure we have the software we need.

At the terminal, type:

```
gem list | grep "^test-unit " && echo "OK - Test::Unit found"
```

If the `test-unit` gem is missing, install it with the following command (you may need to use `sudo`):

```
gem install test-unit
```

Once you have the unit testing framework installed, run the test by typing the command below at the terminal:

```
ruby tictactoeplayer_test.rb
```

The output you should see is this:

```
Run options: 

# Running tests:

F

Finished tests in 0.002765s, 361.6797 tests/s, 361.6797 assertions/s.

  1) Failure:
test_truthiness(TestPlayer) [tictactoeplayer_test.rb:9]:
Functionality not implemented

1 tests, 1 assertions, 1 failures, 0 errors, 0 skips
```

This is our first failing test.
You can commit now, and make sure you start your commit message with `RED`:

```
git commit -am "RED: test_truthiness"
```

You can track the progress of your commits with the command:

```
git log --oneline
```

The output looks like this:

```
0bd3d0f RED: test_truthiness
9394cbc Initial commit
```

Notice how the commit messages are in reverse chronological order. (This will be important in a moment.)

To make the test pass, the fix is easy: set `functionality_implemented` to `true`.

Run the test again and the output you should see is:

```
Run options: 

# Running tests:

.

Finished tests in 0.002294s, 435.9183 tests/s, 435.9183 assertions/s.

1 tests, 1 assertions, 0 failures, 0 errors, 0 skips
```

As expected, the test passed.

You can commit now, and make sure you start your commit message with `GREEN`:

```
git commit -am "GREEN: test_truthiness"
```

Let's track our progress again with `git log --oneline`:

```
4a4bf01 GREEN: test_truthiness
0bd3d0f RED: test_truthiness
9394cbc Initial commit
```

There is one bash trick we can use to get a cleaner, more relevant output. Try this:

```
git log --oneline | grep -Eo 'RED|GREEN|REFACTOR'
```

The output:

```
GREEN
RED
```

So you know you're doing well when you have a nice stack of alternating **RED**s and **GREEN**s, sprinkled with some **REFACTOR**s.

Next, we want to test some very basic behaviors of our class.

Before we implement the method called `turn`, let's first write a failing test for the assertion "an instance of `TicTacToePlayer` should respond to `turn`".

For writing the test, the diff is going to be:

```ruby
     functionality_implemented = true
     assert( functionality_implemented, failure_message = "Functionality not implemented" )
   end
+
+  def test_responds_to_turn
+    tttp = TicTacToePlayer.new
+    assert_respond_to( tttp, :turn, failure_message = "An instance of TicTacToePlayer does not respond to turn" )
+  end
 end
```

When running the test, the output is going to be:

```
Run options: 

# Running tests:

F.

Finished tests in 0.003480s, 574.6925 tests/s, 574.6925 assertions/s.

  1) Failure:
test_responds_to_turn(TestPlayer) [tictactoeplayer_test.rb:14]:
An instance of TicTacToePlayer does not respond to turn.
Expected #<TicTacToePlayer:0x88efbb8> (TicTacToePlayer) to respond to #turn.

2 tests, 2 assertions, 1 failures, 0 errors, 0 skips
```

Log the changes as `RED`:

```
git commit -am "RED: test_responds_to_turn"
```

Write the **absolute minimum amount** of code which makes the test pass, here's the diff:

```ruby
 require 'test/unit'
 
 class TicTacToePlayer
+  def turn
+  end
 end
 
 class TestPlayer < Test::Unit::TestCase
```

Run the test again:

```
Run options: 

# Running tests:

..

Finished tests in 0.002614s, 765.1870 tests/s, 765.1870 assertions/s.

2 tests, 2 assertions, 0 failures, 0 errors, 0 skips
```

Log the changes as `GREEN`:

```
git commit -am "GREEN: test_responds_to_turn"
```

Track your progress:

```
git log --oneline | grep -Eo 'RED|GREEN|REFACTOR'
```

This output below, times ten, is what the results of your work should look like:

```
GREEN
RED
GREEN
RED
```

Remember, if you see one `GREEN` immediately following another `GREEN`, you have failed the challenge because there was no failing test inbetween.

You also fail the challenge for writing more than the **absolute minimum amount** of code needed to pass a test.

### Helpful hints

To get started with the exercise, have a look at the expected output from the gameplay and see if you can break down the functionality of `TicTacToePlayer` into atomic behaviors that you can write individual tests for.

Think of `TicTacToePlayer` as being bound by the terms and conditions of a contract that regulates how it should interact with the outside world. What would that contract look like? How would you go about verifying whether or not `TicTacToePlayer` abides by that contract?

There are two kinds of tests you may want to write:
- Test that the software actually provides the useful functionality it promised;
- Test that the software doesn't break on bad input.

One of the most challenging parts of TDD is the art and science of deciding what is and what isn't a meaningful test.

To help you along, here is an (incomplete) list of what you could potentially test for:
- Test that the `turn` method doesn't raise an exception when given one argument (no matter what kind of argument);
- Test that the `turn` method doesn't raise an exception when given a hash with two randomly generated key-value pairs as the only argument;
- Test that the `turn` method doesn't raise an exception when given the argument `{:owned_by_x => nil, :owned_by_zero => nil}`;
- Test that the `turn` method doesn't raise an exception when given the argument `{:owned_by_x => [], :owned_by_zero => []}`;
- Test that the `turn` method returns a non-nil result when given the argument `{:owned_by_x => [], :owned_by_zero => []}`;
- Test that the `turn` method returns a hash with at least the keys `:owned_by_x` and `:owned_by_zero` when given the argument `{:owned_by_x => [], :owned_by_zero => []}` (you may want to break this one up into two separate tests);
- Test that the `turn` method returns a hash with no more than two keys when given the argument `{:owned_by_x => [], :owned_by_zero => []}`;
- Test that the `turn` method returns `nil` when the input value associated with `:owned_by_x` is not an array;
- Test that the `turn` method returns `nil` when the input value associated with `:owned_by_zero` is not an array;
- Test that the `turn` method returns `nil` when the input value associated with `:owned_by_x` is an array that contains illegal cell identifiers;
- Test that the `turn` method returns `nil` when the input value associated with `:owned_by_zero` is an array that contains illegal cell identifiers;
- Test that the `turn` method returns the same hash it received as input when it's not the player's turn;
- Test that the player who had the first turn can't be behind the other player, in terms of the number of cells he owns;
- Test that the player who had the first turn can't be ahead of the other player by more than one, in terms of the number of cells he owns;
- Test that the `turn` method returns `nil` when one of the players has won.

All `Test::Unit` assertions are documented here:

http://www.ruby-doc.org/stdlib-1.9.3/libdoc/test/unit/rdoc/Test/Unit/Assertions.html

