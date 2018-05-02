class App < Sinatra::Base
	
	enable :sessions

	get '/' do
		db = SQLite3::Database::new("todo.sqlite")
		black = db.execute("SELECT * FROM shirts WHERE name IS (?)", ["Black shirt"])[0]
		blue = db.execute("SELECT * FROM shirts WHERE name IS (?)", ["Blue shirt"])[0]
		green = db.execute("SELECT * FROM shirts WHERE name IS (?)", ["Green shirt"])[0]
		red = db.execute("SELECT * FROM shirts WHERE name IS (?)", ["Red shirt"])[0]
		slim(:index, locals:{black:black, blue:blue, green:green, red:red})
	end
	post '/login' do
		db = SQLite3::Database::new("todo.sqlite")
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
			redirect '/'
		else
			redirect '/wrong_password'
		end
	end
	post '/register' do
		db = SQLite3::Database::new("todo.sqlite")
		username = params[:username]
		password = params[:password]
		re_password = params[:re_password]
		exist = db.execute("SELECT * FROM users WHERE username=?", [username])
		if exist.empty? == false 
			redirect '/username_exist'
		elsif re_password == password
			password_digest = BCrypt::Password.create(password)
			db.execute("INSERT INTO users (username, password) VALUES (?,?)",[username, password_digest])
			redirect '/login'
		else
			redirect '/no_match'
		end
	end
	post '/account' do
		db = SQLite3::Database::new("todo.sqlite")
		name = params[:name]
		adress = params[:adress]
		zip = params[:zip]
		number = params[:number]
		mail = params[:mail]
		state = params[:state]
		db.execute("UPDATE users SET name=?, zip=?, adress=?, mail=?, number=?, state=? WHERE id=?", [name, zip, adress, mail, number, state, session[:user]])
		redirect '/account'
	end
	get '/searched' do
		db = SQLite3::Database::new("todo.sqlite")
		search = params[:search]
		result = db.execute("SELECT * FROM shirts WHERE name LIKE (?)", [search])[0]
		black = db.execute("SELECT * FROM shirts WHERE name IS (?)", ["Black shirt"])[0]
		blue = db.execute("SELECT * FROM shirts WHERE name IS (?)", ["Blue shirt"])[0]
		green = db.execute("SELECT * FROM shirts WHERE name IS (?)", ["Green shirt"])[0]
		red = db.execute("SELECT * FROM shirts WHERE name IS (?)", ["Red shirt"])[0]
		slim(:search, locals:{result:result, black:black, blue:blue, green:green, red:red})
	end
	post '/logout' do
		session[:user] = nil
		redirect '/'
	end
	get '/login' do
		slim(:login)
	end
	get '/no_match' do
		slim(:no_match)
	end
	get '/wrong_password' do
		slim(:wrong_password)
	end
	get '/wrong_username' do
		slim(:wrong_username)
	end
	get '/username_exist' do
		slim(:username_exist)
	end
	get '/product/black' do
		db = SQLite3::Database::new("todo.sqlite")
		black = db.execute("SELECT * FROM shirts WHERE name IS (?)", ["Black shirt"])[0]
		session[:black] = true
		session[:red] = nil
		session[:blue] = nil
		session[:green] = nil
		slim(:product_black, locals:{black:black})
	end
	get '/product/red' do
		db = SQLite3::Database::new("todo.sqlite")
		red = db.execute("SELECT * FROM shirts WHERE name IS (?)", ["Red shirt"])[0]
		session[:red] = true
		session[:blue] = nil
		session[:black] = nil
		session[:green] = nil
		slim(:product_red, locals:{red:red})
	end
	get '/product/green' do
		db = SQLite3::Database::new("todo.sqlite")
		green = db.execute("SELECT * FROM shirts WHERE name IS (?)", ["Green shirt"])[0]
		session[:green] = true
		session[:blue] = nil
		session[:black] = nil
		session[:red] = nil
		slim(:product_green, locals:{green:green})
	end
	get '/product/blue' do
		db = SQLite3::Database::new("todo.sqlite")
		blue = db.execute("SELECT * FROM shirts WHERE name IS (?)", ["Blue shirt"])[0]
		session[:blue] = true
		session[:green] = nil
		session[:black] = nil
		session[:red] = nil
		slim(:product_blue, locals:{blue:blue})
	end
	get '/checkout' do
		db = SQLite3::Database::new("todo.sqlite")
		user_info = db.execute("SELECT * FROM users WHERE id=?", [session[:user]])[0]
		black = db.execute("SELECT * FROM shirts WHERE name IS (?)", ["Black shirt"])[0]
		blue = db.execute("SELECT * FROM shirts WHERE name IS (?)", ["Blue shirt"])[0]
		green = db.execute("SELECT * FROM shirts WHERE name IS (?)", ["Green shirt"])[0]
		red = db.execute("SELECT * FROM shirts WHERE name IS (?)", ["Red shirt"])[0]
		slim(:checkout, locals:{black:black, blue:blue, green:green, red:red, user_info:user_info})
	end
	get '/account' do
		db = SQLite3::Database::new("todo.sqlite")
		user_info = db.execute("SELECT * FROM users WHERE id=?", [session[:user]])[0]
		slim(:account, locals:{user_info:user_info})
	end
	get '/purchased' do
		db = SQLite3::Database::new("todo.sqlite")
		user_info = db.execute("SELECT * FROM users WHERE id=?", [session[:user]])[0]
		slim(:purchased, locals:{user_info:user_info})
	end
end