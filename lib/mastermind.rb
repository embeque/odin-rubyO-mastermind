# frozen_string_literal: true

# require 'pry-byebug'

# class to create game instances
class Game
  attr_accessor :colors, :digits, :tries
  attr_reader :answer

  def initialize(defaults: { colors: 5, digits: 4, tries: 12 }, ask: false)
    ask_defaults if ask == true

    self.colors = defaults[:colors]
    self.digits = defaults[:digits]
    self.tries = defaults[:tries]
  end

  def play(code = random_answer, solve: false, debug: false)
    puts "Game Started\n" if debug
    info if debug
    @answer = correct(code)
    if solve == true
      puts "started searching for code #{answer}" if debug
      computer_solve(debug: debug)
    else
      human_solve
      # for_computer = Game.new(defaults: { colors: colors, digits: digits, tries: tries })
      # for_computer.play(answer, solve: true, debug: false)
      # puts "\n\nYou Solved the code in #{get_elapsed_tries} and computer solved it in #{for_computer.get_elapsed_tries}\n"
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

  def computer_solve(set: universal_set, guess: 1122, debug: false)
    result = nil
    loop do
      groups = Hash.new { |hash, key| hash[key] = [] }
      set.each do |code|
        score = find_score(code, guess)
        groups[score.to_s.to_sym].append code
      end

      actual_score = evaluate(guess, debug: debug)
      if actual_score.nil?
        puts 'Game End' if debug
        break
      end
      set = groups[actual_score.to_s.to_sym]

      if set.length <= 1
        result = set[0]
        puts "\n---------------------------------------------" if debug
        puts "Answer Found: #{result} after #{get_elapsed_tries} tries." if debug
        puts "---------------------------------------------\n" if debug
        break
      end

      # set has been adjusted
      guess = set[0] # lowest literal in the set

      # computer_solve(next_set, next_set[0]) # can take best choice which is smaller integer literal
    end
    result
  end

  def ask_defaults
    print 'How many colors do you want?  : '
    (self.colors = gets.chomp.to_i) until colors.is_a? Integer
    puts nil, nil

    print 'How many digits you wnat? - (More digits higher the difficulty more time it will take to solve)\n'
    (self.digits = gets.chomp.to_i) until digits.is_a? Integer
    puts nil, nil

    print 'How many tries you want should take to solve this problem?  : '
    (self.tries = gets.chomp.to_i) until tries.is_a? Integer
    puts nil, nil
  end

  def random_answer
    rand(0..max_value)
  end

  def info
    puts "\nRed Peg   : Correct Color on Correct Position"
    puts 'White Peg : Correct Color on Wrong Position'
    puts nil
  end

  def get_elapsed_tries
    12 - tries
  end

  def evaluate(guess, debug: true)
    # returns the score if uses the tries and nil if there is no tries left
    if tries.positive?
      result = find_score(guess, answer)
      self.tries = tries - 1
      puts "Try: #{get_elapsed_tries}, Guess #{guess} score: #{result[0]} Red Pegs, #{result[1]} White Pegs" if debug
      puts "Remaining Tries #{tries}" if debug
      puts nil if debug
      result
    else
      # you don't have tries left
      puts 'You don\'t have any tries left!!! Try again by relaunching the game' if debug
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
