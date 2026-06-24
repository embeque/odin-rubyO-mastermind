# frozen_string_literal: false

require_relative '../lib/mastermind'

game = Game.new

result = []
10_000.times do
  result << game.random_answer
end

puts 'The function is working fine' if result.max == 6666 && result.min == 0
