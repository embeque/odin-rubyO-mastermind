# frozen_string_literal: false

require './lib/mastermind'
# require 'pry-byebug'

game = Game.new
game.play(debug: true)
print 'do you want computer to play the same game? (\'yes\') : '
computer = Game.new
computer.play(game.answer, solve: true, debug: true) if gets.chomp == 'yes'
# binding.pry
