require 'sinatra'
require 'sinatra/reloader' if development?

load './utilities.rb'


get '/' do
	erb :index, :layout => :main_layout
end

post '/' do
	file = File.new(params[:file][:tempfile], 'r')
	file_path = file.path
	# isSuccessful will be a boolean. true if everything 
	# was successfully added, false otherwise...
	isSuccessful = csvToDB(file_path);

	return isSuccessful.to_s
end

get '/student-login' do
	erb :student_login, :layout => :main_layout
end

get '/instructor-login' do
	erb :instructor_login, :layout => :main_layout
end

