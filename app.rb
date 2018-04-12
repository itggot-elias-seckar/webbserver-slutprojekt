class App < Sinatra::Base

	get '/' do
		slim(:index)
	end
	get '/home' do
		slim(:home)
	end
	post '/logout' do
		session[:user] = nil
		redirect '/'
	end
	post '/login' do
		db = SQLite3::Database::new("slutprojekt.sqlite")
		username = params[:username]
		password = params[:password]
		name = db.execute("SELECT * FROM users WHERE username=?", [username])
		if name.empty?
			redirect '/wrong_username'
		end
		data = db.execute("SELECT * FROM users WHERE username IS (?)" ,[username])[0]
		password_digest = BCrypt::Password.new(data[2])
		if password_digest == password
			session[:user] = db.execute("SELECT id FROM users WHERE username=?",[username])
			redirect '/home'
		else
			redirect '/wrong_password'
		end
	end
	post '/register' do
		db = SQLite3::Database::new("slutprojekt.sqlite")
		username = params[:username]
		password = params[:password]
		re_password = params[:re_password]
		exist = db.execute("SELECT * FROM users WHERE username=?", [username])
		if exist.empty? == false 
			redirect '/username_exist'
		elsif re_password == password
			password_digest = BCrypt::Password.create(password)
			db.execute("INSERT INTO users (username, password) VALUES (?,?)",[username, password_digest])
			redirect '/'
		else
			redirect '/no_match'
		end
	end

end           
