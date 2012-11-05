class PureTextOverflow
  class User < Struct.new(:nickname)
    @@users = { 1 => User.new("Warrior"),
                2 => User.new("EtherealCereal"),
                3 => User.new("AgentSmith"),
                4 => User.new("WeaponX"),
                5 => User.new("ManOnTheRun"),
                6 => User.new("ButtersFromSouthPark"),
                7 => User.new("Avenger") }

    def self.find_by_id(u_id)
      @@users[u_id]
    end

    def self.create(u_nickname)
      u_id = @@users.count + 1
      @@users[u_id] = User.new(u_nickname)
      u_id
    end
  end

  class Question < Struct.new(:asker_id, :title, :body)
    @@questions = { 1 => Question.new(4, "Iterating Over an Array in Ruby", "How to do it?"),
                    2 => Question.new(7, "Substituting Variables Into Strings in Ruby", "How to do it?"),
                    3 => Question.new(1, "Generating Random Numbers in Ruby", "How to do it?"),
                    4 => Question.new(2, "Validating an Email Address in Ruby", "How to do it?"),
                    5 => Question.new(4, "Generating Prime Numbers in Ruby", "How to do it?"),
                    6 => Question.new(5, "Performing Date Arithmetic in Ruby", "How to do it?"),
                    7 => Question.new(1, "Removing Duplicate Elements from an Array in Ruby", "How to do it?"),
                    8 => Question.new(6, "Using Symbols as Hash Keys in Ruby", "How to do it?"),
                    9 => Question.new(4, "Writing an Infinite Loop in Ruby", "How to do it?") }

    def self.find_by_id(q_id)
      @@questions[q_id]
    end

    def self.create(u_id,q_text)
      @@questions[@@questions.count + 1] = Question.new(u_id, q_text, "Any ideas?")
    end

    def self.all
      @@questions.map { |k,v| "#{k}) #{v.title}" }
    end

    def self.exists?(q_id)
      @@questions.has_key?(q_id)
    end
  end

  class Answer < Struct.new(:question_id, :responder_id, :body)
    @@answers = { 10 => Answer.new(1, 5, "Try this: your_array.each { |x| ... }"),
                  11 => Answer.new(2, 3, "Try this: \#{variable_to_interpolate}"),
                  12 => Answer.new(5, 1, "You need the mathn gem."),
                  14 => Answer.new(9, 7, "Try this: loop do ... end") }

    def self.find_by_id(a_id)
      @@answers[a_id]
    end

    def self.find_by_question_id(q_id)
      @@answers.select { |k,v| v.question_id == q_id }
    end

    def self.create(q_id,user_id,a_text)
      @@answers[@@answers.count + 11] = Answer.new(q_id, user_id, a_text)
    end

    def self.exists?(a_id)
      @@answers.has_key?(a_id)
    end
  end

  class QuestionVote < Struct.new(:user_id, :question_id, :vote)
    @@q_votes = [ QuestionVote.new(1, 1,  1),
                  QuestionVote.new(2, 1,  1),
                  QuestionVote.new(3, 1,  1),
                  QuestionVote.new(5, 1,  1),
                  QuestionVote.new(7, 1,  1),
                  QuestionVote.new(1, 2,  1),
                  QuestionVote.new(2, 2,  1),
                  QuestionVote.new(3, 2,  1),
                  QuestionVote.new(4, 2,  1),
                  QuestionVote.new(2, 3,  1),
                  QuestionVote.new(3, 3,  1),
                  QuestionVote.new(4, 3,  1),
                  QuestionVote.new(5, 3,  1),
                  QuestionVote.new(6, 3,  1),
                  QuestionVote.new(7, 3,  1),
                  QuestionVote.new(1, 9, -1),
                  QuestionVote.new(2, 9, -1),
                  QuestionVote.new(3, 9, -1),
                  QuestionVote.new(5, 9, -1),
                  QuestionVote.new(6, 9, -1),
                  QuestionVote.new(7, 9, -1) ]

    def self.upvote(u_id,q_id)
      vote(u_id, q_id, 1)
    end

    def self.downvote(u_id,q_id)
      vote(u_id, q_id, -1)
    end

    def self.popularity(q_id)
      pop = @@q_votes.select do |qvote|
                        qvote.question_id == q_id
                      end.reduce(0) do |sum,qvote|
                            sum + qvote.vote
                          end
    end

    private

    def self.vote(u_id,q_id,which_way)
      return if Question.find_by_id(q_id).asker_id == u_id

      v = @@q_votes.find do |v|
        v.user_id == u_id and v.question_id == q_id
      end

      if v
        v.vote = which_way
      else
        @@q_votes << QuestionVote.new(u_id, q_id, which_way) 
      end
    end
  end

  class AnswerVote < Struct.new(:user_id, :answer_id, :vote)
    @@a_votes = [ AnswerVote.new(1, 10,  1),
                  AnswerVote.new(2, 10,  1),
                  AnswerVote.new(3, 10,  1),
                  AnswerVote.new(1, 11,  1),
                  AnswerVote.new(4, 11,  1),
                  AnswerVote.new(5, 11,  1),
                  AnswerVote.new(7, 11,  1),
                  AnswerVote.new(2, 12,  1),
                  AnswerVote.new(3, 12,  1),
                  AnswerVote.new(4, 12,  1),
                  AnswerVote.new(5, 12,  1),
                  AnswerVote.new(6, 12,  1),
                  AnswerVote.new(4, 14, -1),
                  AnswerVote.new(5, 14, -1) ]

    def self.upvote(u_id,a_id)
      vote(u_id, a_id, 1)
    end

    def self.downvote(u_id,a_id)
      vote(u_id, a_id, -1)
    end

    def self.popularity(a_id)
      pop = @@a_votes.select do |avote|
                        avote.answer_id == a_id
                      end.reduce(0) do |sum,avote|
                            sum + avote.vote
                          end
    end

    private

    def self.vote(u_id,a_id,which_way)
      return if Answer.find_by_id(a_id).responder_id == u_id

      v = @@a_votes.find do |v|
        v.user_id == u_id and v.answer_id == a_id
      end

      if v
        v.vote = which_way
      else
        @@a_votes << AnswerVote.new(u_id, a_id, which_way) 
      end
    end
  end

  def self.content_for_single_question(q_id)
    c = []
    c << "Title:    #{Question.find_by_id(q_id).title}"
    c << "Body:     #{Question.find_by_id(q_id).body}"
    c << "Votes:    #{QuestionVote.popularity(q_id)}"
    q_author = User.find_by_id(Question.find_by_id(q_id).asker_id).nickname
    c << "Asked by: #{q_author}"
    Answer.find_by_question_id(q_id).each do |k,v|
      c << ""
      c << "#{k}) Answer:"
      c << "#{v.body}"
      a_author = User.find_by_id(Answer.find_by_id(k).responder_id).nickname
      c << "Votes: #{AnswerVote.popularity(k)} (answer provided by #{a_author})"
    end
    c
  end

  @@menu_options = { :main_menu       => ["1) Show all questions",
                                          "2) Ask a question"],
                     :single_question => ["1) Upvote the question   (not possible if you authored it)",
                                          "2) Downvote the question (not possible if you authored it)",
                                          "3) Provide an answer",
                                          "4) Select an answer to upvote/downvote"] }

  def self.get_user_input(prompt)
    puts prompt
    gets.chomp
  end

  def self.start
    system("clear")
    my_nickname = get_user_input("Hello there! Choose a nickname:")
    my_user_id = User.create(my_nickname)
    banner_text = "Main menu"
    navigation_state = :main_menu
    selected_qid = 0
    selected_aid = 0
    loop do
      system("clear")
      puts "Logged in as: #{my_nickname}"
      puts
      puts banner_text
      if navigation_state == :single_question
        puts
        content_for_single_question(selected_qid).each { |line| puts line }
      end
      puts
      @@menu_options[navigation_state].each { |option| puts option }
      puts
      puts "m) Main menu" unless navigation_state == :main_menu
      puts "q) Quit"
      puts
      keyboard_input = get_user_input("Select an option:")

      if navigation_state == :main_menu and keyboard_input == "1"
        banner_text = "Showing all questions"
        navigation_state = :all_questions
        @@menu_options[navigation_state] = Question.all
        next
      end

      if navigation_state == :main_menu and keyboard_input == "2"
        system("clear")
        keyboard_input = get_user_input("Ask a question:")
        Question.create(my_user_id, keyboard_input)
        next
      end

      if navigation_state == :all_questions
        aux_int = keyboard_input.to_i
        if Question.exists?(aux_int)
          selected_qid = aux_int
          banner_text = "Showing single question (and its answers, if there are any)"
          navigation_state = :single_question
          next
        end
      end

      if navigation_state == :single_question and keyboard_input == "1"
        QuestionVote.upvote(my_user_id, selected_qid)
      end

      if navigation_state == :single_question and keyboard_input == "2"
        QuestionVote.downvote(my_user_id, selected_qid)
      end

      if navigation_state == :single_question and keyboard_input == "3"
        keyboard_input = get_user_input("Provide an answer:")
        Answer.create(selected_qid, my_user_id, keyboard_input)
        next
      end

      if navigation_state == :single_question and keyboard_input == "4"
        keyboard_input = get_user_input("Select an answer:")
        aux_int = keyboard_input.to_i
        if Answer.exists?(aux_int)
          selected_aid = aux_int
          puts "1) Upvote the selected answer   (not possible if you authored it)"
          puts "2) Downvote the selected answer (not possible if you authored it)"
          keyboard_input = gets.chomp
          if keyboard_input == "1"
            AnswerVote.upvote(my_user_id, selected_aid)
          end
          if keyboard_input == "2"
            AnswerVote.downvote(my_user_id, selected_aid)
          end
        end
        next
      end

      if keyboard_input == "m"
        banner_text = "Main menu"
        navigation_state = :main_menu
        selected_qid = 0
        selected_aid = 0
        next
      end

      if keyboard_input == "q"
        exit
      end
    end
  end
end

PureTextOverflow.start

