# frozen_string_literal: true

# require 'pry-byebug'

# class to create game instances
class Game
  attr_accessor :colors, :digits, :tries
  attr_reader :answer

  def initialize
    self.colors = 5
    self.digits = 4
    self.tries = 12

    # play
  end

  def get_input(message)
    puts message
    gets.chomp
  end

  # remove computer solve and human solve functionality, make one game pipeline only
  def play
    give_code = get_input "\nDo you have someone to Enter the code ? (yes/no) - if 'no' random code will be selected"
    if give_code == 'yes'

      puts 'Okay, now pass the device to the someone (so he can enter the code)'
      puts 'Don\t dare to look at the code or continue yourself'
      puts nil
      puts 'If the device has been passed to someone, hit \'RETURN\' to continue'
      gets
      system 'clear' # works only on Linux

      puts "\nOkay ..."
      puts 'You can Enter the code keeping in view these condition:'
      puts "  1. for each digit, you can select between numbers 0 - #{colors}"
      puts "  2. number of digits of the code must be #{digits}"

      new_code = get_input("\nnow, enter the number according to these conditions, otherwise the game will restart !!!").to_i
      if valid? new_code
        @answer = new_code
      else
        system 'clear'
        puts 'Wrong code entered. do it all again !!!'
        play
        return
      end
    else
      @answer = random_correct_answer
    end
    system 'clear'
    play_started
  end

  def play_started
    puts "Game Started\n"
    info
    solve = get_input "\nDo you want to computer to solve the problem instead of you (yes/no)"
    if solve.downcase == 'yes'
      puts "started searching for code #{answer}"
      computer_solve
    else
      human_solve
    end
  end

  def valid?(code)
    if code.digits.length == digits && correct(code) == code
      true
    else
      false
    end
  end

  def human_solve
    guess = nil
    tries.times do
      guess = get_guess
      score = evaluate(guess)
      next unless score == [digits, 0]

      puts "\n-------------------------"
      puts "Congratulations! Your guess is right: #{guess}"
      puts "You won in #{get_elapsed_tries} tries"
      puts "-------------------------\n"
      return
    end
    puts "You Failed - answer was #{answer}"
  end

  def get_guess
    guess = nil
    loop do
      print 'Enter an Integer: '
      guess = gets.chomp.to_i

      break if guess.is_a?(Integer)

      puts 'Invalid Input! Try Again!'
    end
    guess
  end

  def computer_solve(set: universal_set, guess: 1122)
    result = nil
    loop do
      groups = Hash.new { |hash, key| hash[key] = [] }
      set.each do |code|
        score = find_score(code, guess)
        groups[score.to_s.to_sym].append code
      end

      actual_score = evaluate(guess)
      if actual_score.nil?
        puts 'Game End'
        break
      end
      set = groups[actual_score.to_s.to_sym]

      if set.length <= 1
        result = set[0]
        puts "\n---------------------------------------------"
        puts "Answer Found: #{result} after #{get_elapsed_tries} tries."
        puts "---------------------------------------------\n"
        break
      end

      # set has been adjusted
      guess = set[0] # lowest literal in the set

      # computer_solve(next_set, next_set[0]) # can take best choice which is smaller integer literal
    end
    result
  end

  def random_correct_answer
    correct(rand(0..max_value))
  end

  def info
    puts "\nRed Peg   : Correct Color on Correct Position"
    puts 'White Peg : Correct Color on Wrong Position'
    puts nil
  end

  def get_elapsed_tries
    12 - tries
  end

  def evaluate(guess)
    # returns the score if uses the tries and nil if there is no tries left
    if tries.positive?
      result = find_score(guess, answer)
      self.tries = tries - 1
      puts "Try: #{get_elapsed_tries}, Guess #{guess} score: #{result[0]} Red Pegs, #{result[1]} White Pegs"
      puts "Remaining Tries #{tries}"
      puts nil
      result
    else
      # you don't have tries left
      puts 'You don\'t have any tries left!!! Try again by relaunching the game'
      nil
    end
  end

  def find_score(code, guess)
    #
    # arrays
    code  = format(code).chars
    guess = format(guess).chars

    red = 0 # correct color on correct postition

    code.each_index do |i|
      next unless code[i] == guess[i]

      red += 1
      code[i] = nil
      guess[i] = nil
    end

    white = 0 # correct color on wrong position

    guess.compact.each do |digit|
      if idx = code.index(digit)
        white += 1
        code[idx] = nil
      end
    end

    [red, white]
  end

  def format(value)
    # return string of full length of digits
    value_arr = value.to_s.chars
    append_val = Array.new(digits - value_arr.length, '0')
    value_arr = append_val + value_arr
    value_arr.join
  end

  def universal_set
    result = []
    max_check_value = max_value # so don't have to call and calculate value each time on comparison
    value = 0
    loop do
      result.append value
      value = correct(value + 1)
      break if value > max_check_value
    end
    # binding.break
    result
  end

  def max_value
    max_str = colors.to_s
    (max_str * digits).to_i
  end

  def remove_greater(number)
    limit = colors
    remove_number_arr = '0123456789'.scan(/\d/).select { |d| d.to_i > limit }

    num_arr = number.to_s.chars
    num_arr = num_arr.map do |char|
      if remove_number_arr.include?(char)
        limit + 1
      else
        char
      end
    end
    num_arr.join.to_i
  end

  def correct(number)
    number = remove_greater(number)
    # binding.break
    target = colors + 1
    replacement = 10

    result = 0
    multiplier = 1

    while number.positive?
      digit = number % 10
      digit = replacement if digit == target
      result += digit * multiplier

      result_arr = result.to_s.chars
      if result_arr[0] == target.to_s
        result_arr[0] = replacement.to_s
        result = result_arr.join.to_i
      end

      multiplier *= 10
      number /= 10
    end
    # binding.break

    result
  end
end
