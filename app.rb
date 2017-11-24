require 'sinatra'
require 'sinatra/reloader' if development?
load './utilities.rb'
# Required for login sessions
enable :sessions



before do
	# Save routes in arrays
	@publicRoutes = ['/', '/student-login', '/instructor-login']
	@userRoutes = ['/student-dashboard', '/instructor-dashboard']
	# get the current page route for page privileges
	@currentRoute = request.path_info 

	@uid = nil || session[:uid]
	@username = nil || session[:username]
	@role = nil || session[:role]

	# Call helper functions for authentication checks
	authenticateUser()
	userRedirect()
end



helpers do
	# Checks if user is logged in for certain pages
	def authenticateUser()
		if @userRoutes.include? @currentRoute
			if @uid.nil?
				redirect '/'
			end
		end
	end

	# Redirects user from non-user pages (home, login, etc.)
	def userRedirect()
		if @publicRoutes.include? @currentRoute
			if @role == "student"
				redirect '/student-dashboard'
			elsif @role == "instructor"
				redirect '/instructor-dashboard'
			end
		end
	end

	# Create a user session
	def createSession(uid, username, role)
		session[:uid] = uid
		session[:username] = username
		session[:role] = role # Save role for page privileges
	end


end



get '/' do
	erb :index, :layout => :main_layout
end



post '/' do
	file = File.new(params[:file][:tempfile], 'r')
	# isSuccessful will be a boolean. true if everything 
	# was successfully added in csv function, false otherwise...
	isSuccessful = importCSV(file.path);
	return isSuccessful.to_s
end


=begin
	######################################################
	######################################################
	############### Student Route handlers ###############
	######################################################
	######################################################
=end


get '/student-login' do
	erb :student_login, :layout => :main_layout, :locals => {err: ""}
end



post '/student-login' do
	username = params[:username].chomp
	password = params[:password].chomp
	role = "student"

	# uid holds user's id if found, else it will be false
	uid = verifyUser(username, password, role)

	# If user was found, create a session with uid, username, and role
	if(uid)
		createSession(uid, username, role)
		redirect '/student-dashboard'
	else
		erb :student_login, :layout => :main_layout, :locals => {err: "Invalid Credentials"}
	end
end



get '/student-dashboard' do
	erb :student_dashboard, :layout => :main_layout
end


=begin
	######################################################
	######################################################
	############ Instructor/TA Route handlers ############
	######################################################
	######################################################
=end


get '/instructor-login' do
	erb :instructor_login, :layout => :main_layout, :locals => {err: ""}
end



post '/instructor-login' do
	username = params[:username].chomp
	password = params[:password].chomp
	role = "instructor"

	# uid holds user's id if found, else it will be false
	uid = verifyUser(username, password, role)

	# If user was found, create a session with uid, username, and role
	if(uid)
		createSession(uid, username, role)
		redirect '/instructor-dashboard'
	else
		erb :instructor_login, :layout => :main_layout, :locals => {err: "Invalid Credentials"}
	end
end



get '/instructor-dashboard' do
	erb :instructor_dashboard, :layout => :main_layout
end



get '/logout' do
	session.clear
	redirect '/'
end