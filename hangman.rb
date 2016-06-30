require 'date'
require 'yaml'

class String
	def letters?(value)
		value.split("").each do |char|
  			char =~ /[[:alpha:]]/
  		end
	end
end

class Hangman
	def initialize
		puts "Hangman initialized!"
		start_menu
	end

	def start_menu
		puts "1. New Game"
		puts "2. Load Game"
		puts "3. Exit"
		puts
		input = gets.chomp.to_s
		if input == "1"
			new_game
		elsif input == "2"
			load_game
		elsif input == "3"
			quit_game
		else
			clear_screen
			start_menu
		end
	end

	def new_game
		choose_word
		play
	end

	def save_game
		file_count = Dir.glob(File.join('saved_games', '**', '*')).select { |file| File.file?(file) }.count # count files in saved_games
		if file_count > 3
			puts "Please select a save to overwrite: "
			list_saved_games #show files
			index = gets.chomp
			game_files = Dir.entries("saved_games").select { |f| f.include?(".sav") }
			game_file = "saved_games/#{game_files[index.to_i]}"
			File.delete(game_file) #delete file
		end
		yaml = YAML::dump(self)
		Dir.mkdir("saved_games") unless Dir.exists? "saved_games"
		filename = "saved_games/#{(file_count.to_i)+1}.sav"
		save_file = File.new(filename, 'w')
		save_file.write(yaml)
	end

	def delete_file
		File.delete("game_file")
	end

	def load_game
		list_saved_games
		index = gets.chomp
		game_file = "saved_games/#{game_files[index.to_i]}"
		yaml = File.open(game_file).read
		YAML::load(yaml)
		play
	end

	def list_saved_games
		puts
		game_files = Dir.entries("saved_games").select { |f| f.include?(".sav") }
		game_files.each_with_index do |file,index|
			puts "#{index+1}. #{file}"
		end
	end

	#choose a word
	def choose_word
		dictionary = File.open ('5desk.txt')
		selection = Array.new
		dictionary.each do |word|
			if word.length >= 5 && word.length <= 12
				selection << word
			end
		end
		@word = selection.sample.split("")
		@word = @word[0..-2]
		puts "Word: " + @word.inspect #debug
		@progress = Array.new
		@word[0..-1].length.times do
			@progress << "_"
		end
	end

	def play
		@misses = Array.new
		game_over = false
		until game_over == true
			clear_screen
			puts "1. Start Menu | 2. Save Game | 3. Quit Game"
			puts "(DEBUG) Word: #{@word.join("")}" #debug
			print @progress.join(" ") + "\r\n"
			print "Misses: #{@misses.join(" ").upcase} \r\n"
			puts "Guess a letter or full word"
			guess = gets.chomp.downcase
			if guess.length == 1
				if guess == "1" # Start Menu
					clear_screen
					start_menu
				elsif guess == "2" # Save Game
					save_game
				elsif guess == "3" # Quit Game
					quit_game
				elsif (@word.include? guess.downcase) || (@word.include? guess.upcase)
					@word.each_with_index do |letter,index|
						if guess == letter.downcase
							@progress[index] = guess
						end
					end
				else
					@misses << guess unless @misses.include? guess
				end
			elsif guess.length > 1
				if guess == @word.join("").downcase
					@word.each_with_index do |letter,index|
						@progress[index] = @word[index]
					end
					puts "Correct! The word was '#{@word.join("")}'."
				else
					puts "Incorrect! The word was '#{@word.join("")}'."
				end
				play_again
			else
				puts "Error: no input"
			end
			game_over = true if (@progress.none? {|space| space == "_"}) || (@misses.length == 6)
		end
		puts @word.join(" ")
		puts "The word was '#{@word.join("")}'"
		play_again
	end

	def clear_screen
		system "clear" or system "cls"
	end

	def quit_game
		abort("Exiting Hangman")
	end

	def play_again
		puts
		puts "Play again?"
		puts "1. New Game | 2. Start Menu | 3. Quit"
		input = gets.chomp
		if input == "1"
			new_game
		elsif input == "2"
			clear_screen
			start_menu
		elsif input == "3"
			quit_game
		else
			start_menu
		end
	end

end

game = Hangman.new