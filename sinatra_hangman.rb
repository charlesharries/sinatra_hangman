require 'sinatra'
require 'sinatra/reloader' if development?

enable :sessions
set :session_secret, '(*Yjijiwefnweewwef94523'

get '/' do
  game_setup
  @answer = session[:answer]
  @correct_indices = session[:correct_indices]
  @incorrect_characters = session[:incorrect_characters]
  @tries = session[:tries]
  message = nil
  erb :index, :locals => {:message => message}
end

post '/' do
  @answer = session[:answer]
  @correct_indices = session[:correct_indices]
  @incorrect_characters = session[:incorrect_characters]
  @tries = session[:tries]
  letter = params['guess'].downcase.nil? ? "" : params['guess']
  if good_guess?(letter)
    update_game(letter)
  else
    message = "That's not a good flippin guess. Try that one again."
  end
  erb :index, :locals => {:message => message}
end

get '/win' do
  erb :win
end

get '/lose' do
  erb :lose
end

helpers do

  def game_setup
    session[:answer] = generate_word
    session[:correct_indices] = []
    session[:incorrect_characters] = []
    session[:tries] = 10
  end

  def generate_word
    @lines = File.readlines("5desk.txt")
    answer = ""
    loop do
      answer = @lines[Random.rand(@lines.length)].strip # The file is full of secret whitespace!
      break if answer.length >= 5 && answer.length <= 12
    end
    answer
  end

  def good_guess?(letter)
    if letter?(letter) && !already_guessed?(letter)
      true
    else
      false
    end
  end

  def letter?(letter)
    return letter =~ /[A-Za-z]/ && letter.length == 1 ? true : false
  end

  def already_guessed?(letter)
    return @incorrect_characters.include?(letter) ? true : false
  end

  def get_correct_indices(letter)
    if letter.empty?
      []
    elsif @answer.downcase.include?(letter)
      # answer.downcase[i] here to handle if one of the letters in answer is a capital
      @answer.size.times.select { |i| @answer.downcase[i] == letter }
    else
      []
    end
  end

  def update_game(guess)
    session[:correct_indices] += get_correct_indices(guess)
    session[:correct_indices].uniq! # So you don't get [0, 5, 2, 2, 2] or something
    if get_correct_indices(guess).empty?
      session[:tries] -= 1
      session[:incorrect_characters] << guess
    end
    if winner?
      redirect '/win'
    end
    if session[:tries] == 0
      redirect '/lose'
    end
  end

  def winner?
    # Crude but it works
    if session[:correct_indices].length == @answer.length
      true
    else
      false
    end
  end

end
