require 'yaml'

class Hangman
  attr_accessor :word, :right_letters, :wrong_letters, :attempts
  EMPTY = '_'
  MAX_ATTEMPTS = 10
  SAVE_PATH = 'save.yml'

  RULES = %{
***************************** RULES *****************************
* The computer has chosen a word between 5 and 12 letters long.
* You have #{MAX_ATTEMPTS} tries to guess it.
* Each turn, you may guess a letter. If the word contains it,
* it will be revealed. If it doesn't, you lose an attempt.
*****************************************************************
}

  def initialize
    dictionary = File.open('dictionary.txt', 'r')
    words = dictionary.readlines.map(&:chomp)
    @word = ''
    @word = words.sample until @word.length.between?(5, 12)
    @right_letters = Array.new(word.length, EMPTY)
    @attempts = MAX_ATTEMPTS
    @wrong_letters = []
  end

  def play
    display_rules
    propose_load if File.file?(SAVE_PATH)
    while right_letters.include?(EMPTY) && self.attempts > 0
      play_round
    end
    unless right_letters.include?(EMPTY)
      puts "\nCongradulations! You guessed the word!"
    else
      puts "\nYour last guess:"
      display_letters(right_letters)
      puts "\nBetter luck next time! The word was:"
    end
    puts word
  end

  private

  def propose_load
    puts 'Would you like to load a saved game? y/n'
    answer = ''
    begin
      answer = gets.chomp.downcase
      raise unless answer =~ /[yn]/
    rescue
      puts 'Incorrect input'
      retry
    end
    load if answer == 'y'
  end

  def display_letters(letters)
    str = letters.join(' ')
    puts str.empty? ? 'No letters yet' : str
  end

  def display_rules
    puts RULES
  end

  def display_at_start_of_round
    puts "\nYou have #{attempts} attempt(s) to guess the word."
    puts "\n* Revealed letters:"
    display_letters(right_letters)
    puts "\n* Letters not in the word:"
    display_letters(wrong_letters)
  end

  def letter?(char)
    char =~ /[A-Za-z]/
  end

  def get_guess
    letter = ''
    loop do
      print "\nGuess a letter, or type 'save' to save your game: "
      letter = gets.chomp.downcase
      return 'save' if letter == 'save'
      unless letter?(letter)
        puts "\nPlease enter a valid letter!"
        next
      end
      if right_letters.include?(letter) || wrong_letters.include?(letter)
        puts "\nYou already guessed that one! Try another."
        display_letters(right_letters)
      else
        break
      end
    end
    letter
  end

  def get_game_state
    {
      word: word,
      right_letters: right_letters,
      wrong_letters: wrong_letters,
      attempts: attempts
    }
  end

  def set_game_state(game_state)
    self.word = game_state[:word]
    self.right_letters = game_state[:right_letters]
    self.wrong_letters = game_state[:wrong_letters]
    self.attempts = game_state[:attempts]
  end

  def save
    File.open(SAVE_PATH, 'w') { |file| file.write(get_game_state.to_yaml) }
  end

  def load
    game_state = YAML.load(File.read(SAVE_PATH))
    set_game_state(game_state)
  end

  def play_round
    display_at_start_of_round
    letter = get_guess
    if letter == 'save'
      save
      return
    end
    if word.include?(letter)
      word.each_char.with_index(0) do |char, i|
        right_letters[i] = char if char == letter
      end
      puts "\nGood guess!"
    else
      wrong_letters << letter
      self.attempts -= 1
      puts "\nWhoops, wrong letter!"
    end
  end
end

new_game = Hangman.new
new_game.play