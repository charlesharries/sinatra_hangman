require 'sinatra'
require 'sinatra/reloader'

def generate_word
  answer = ""
  loop do
    answer = @lines[Random.rand(@lines.length)].strip # The file is full of secret whitespace!
    break if answer.length >= 5 && answer.length <= 12
  end
  answer
end

def get_correct_indices(letter)
  if letter.empty?
    []
  elsif ANSWER.downcase.include?(letter)
    # answer.downcase[i] here to handle if one of the letters in answer is a capital
    ANSWER.size.times.select { |i| ANSWER.downcase[i] == letter }
  else
    []
  end
end

def make_string(correct_indices)
  string = ""
  ANSWER.length.times do |index|
    if correct_indices.include?(index)
      string << ANSWER[index] + " "
    else
      string << "_ "
    end
  end
  string
end

@lines = File.readlines("5desk.txt")
@@tries = 10
@@correct_indices = []
@@incorrect_characters = []
ANSWER = generate_word

get '/' do
  letter = params['guess'].nil? ? "" : params['guess']
  @@correct_indices += get_correct_indices(letter)
  word_string = make_string(@@correct_indices)
  erb :index, :locals => {:answer => ANSWER, :tries => @@tries, :letter => letter, :indices => @@correct_indices, :string => word_string}
end
