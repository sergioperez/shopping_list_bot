require 'telegram/bot'

token = File.read("token.conf").chomp

timestamp = Time.now		

def protect_time(timestamp)
	if ((Time.now - timestamp) < 0.01)
		sleep 0.03
	end
end

def send_list(bot, user_id)
	if File.exist?("./data/#{user_id}")
		productos = Array.new
		File.readlines("./data/#{user_id}").each do |line|
			 productos << line
		end
		bot.api.send_message(chat_id: user_id, text: productos.join)
	else
		bot.api.send_message(chat_id: user_id, text: "La lista está vacía")
	end
end

def clear_list(bot, user_id)
	if File.exist?("./data/#{user_id}")
		File.delete("./data/#{user_id}")
	end
	bot.api.send_message(chat_id: user_id, text: "Lista limpiada!")
end

Telegram::Bot::Client.run(token) do |bot|
	begin
	bot.listen do |message|
		protect_time(timestamp)

		case message.text
		when '/start'
			bot.api.send_message(chat_id: message.chat.id, text: "Hola, #{message.from.first_name}")
		when '/stop'
			bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
		when '/lista'
			send_list(bot, message.from.id)
		when '/limpiar'
			clear_list(bot, message.from.id)
		else
			File.open("./data/#{message.from.id}","a+") { |f| f.puts(message) }
			bot.api.send_message(chat_id: message.chat.id, text: "#{message} añadido a la /lista")
		end
	end
	rescue Telegram::Bot::Exceptions::ResponseError => e
		puts "samatao"
		retry
	end
end
