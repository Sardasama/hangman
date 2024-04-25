class Game 

  attr_accessor :secret_word, :guess, :tried_arr, :nb_letters, :word_found

  def initialize()
    @@MAX_ERRORS = 10
    @nb_letters = 0
    @word_found = false
    @tried_arr = Array.new
  end

  def select_word(max_letters)
    word_list = File.readlines('google-10000-english-no-swears.txt')
    filtered_list = word_list.select { |w| w.strip.length.between?(5, max_letters) }
    filtered_list.sample.chomp
  end

  def start
    initialize
    if File.exist?("saves/current_save.txt")
      puts "A save file has been found, do you want to load it ? (Y/N)"
      gets.chomp.upcase == "Y" ? load_game : play_new_game   
    else
      play_new_game
    end
  end

  def play_new_game
    puts "Ready to play some Hangman?"
    puts "Please enter the max length for the secret word :"
    max_letters = gets.chomp.to_i
    @secret_word = select_word(max_letters)
    #puts @secret_word
    @guess = @secret_word.gsub(/\S/, '*')
    play_loop
  end

  def play_loop

    while !@word_found && @nb_letters <= @@MAX_ERRORS
      @nb_letters += 1
      puts "Turn (#{@nb_letters} on #{@@MAX_ERRORS})"
      puts "Secret word : #{@guess}"
      
      input = ""
      while input != 'G' && input != 'A'
        puts "You already asked for these letters : #{@tried_arr}"
        puts "Do you want to try a (G)uess or (A)sk for a letter ? (or type 'save' to save and quit the game)"
        input = gets.chomp.upcase
        if input == "SAVE"
          save_game
        end
      end
    
      input == 'G' ? try_guess : ask_letter
    end

    if !@word_found && @nb_letters >= @@MAX_ERRORS
      puts "Sorry, you lose :-("
    else
        puts "Congratulations, you won !"
        savefile = "saves/current_save.txt"
        File.delete(savefile)  if File.exist?(savefile)
    end
  end

  def try_guess
    puts "Enter you solution :"
    solution = gets.chomp.downcase
    #puts "solution : >#{solution}< vs secret word : >#{@secret_word}<"
    @word_found = true if solution == @secret_word
    puts word_found
  end

  def ask_letter

    puts "Please try a new letter"
    new_letter = gets.chomp.downcase
    @tried_arr << new_letter.upcase

    if @secret_word.include? (new_letter.downcase) 
      puts "Lucky ! You found a letter !"
    else
      "Nope !" 
    end

    for i in 0..@secret_word.length
      if @secret_word[i] == new_letter
        @guess[i] = new_letter
      end
    end

    puts "Secret word : #{@guess}"

  end

  def save_game
    Dir.mkdir("saves") if !Dir.exist?("saves")
    
    savefile = "saves/current_save.txt"

    File.delete(savefile)  if File.exist?(savefile)

    File.open(savefile, 'w') do |file|
      file.puts @nb_letters
      file.puts @secret_word
      file.puts @guess
      file.puts @tried_arr
    end
  end

  def load_game
    savefile = "saves/current_save.txt"
    infos = File.readlines(savefile)
    #print infos
    @nb_letters = infos[0].chomp.to_i
    @secret_word = infos[1].chomp
    @guess = infos[2].chomp
    @tried_arr = infos[3].chomp
    play_loop
  end

end

new_game = Game.new
new_game.start
