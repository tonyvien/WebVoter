require 'csv'
require 'zip'
require 'bcrypt'
require 'sqlite3'

# Opens a connection to the database and returns the reference to it for
# later use. This function first checks if a database (named 'webvoter') - located 
# in the current folder - already exists to prevent creating a new DB each time this
# function is called.
def openDB()
	unless File.exist?('./webvoter.database')
		db = SQLite3::Database.new( "./webvoter.database" )
		# Set up the base table with uid, username, password, and role
		db.execute( "CREATE TABLE Class (id INTEGER PRIMARY KEY, user TEXT, password TEXT, role TEXT);" )
		# Add an extra columns for the user's vote status, 1st, 2nd, and 3rd vote
		db.execute ("ALTER TABLE Class ADD COLUMN has_voted INTEGER DEFAULT 0; ")
		db.execute ("ALTER TABLE Class ADD COLUMN first_choice TEXT DEFAULT 'n/a'; ")
		db.execute ("ALTER TABLE Class ADD COLUMN second_choice TEXT DEFAULT 'n/a'; ")
		db.execute ("ALTER TABLE Class ADD COLUMN third_choice TEXT DEFAULT 'n/a'; ")
	else
		db = SQLite3::Database.open( "./webvoter.database" )
	end
	return db
end


# Checks if CSV is valid before adding users to db. Each
# row count must be equal to 3 (users, passwords, roles).
def validateCSV(path)
	csv = CSV.read(path)
	csv.each do |row|
		if(row.length != 3)
			return false
		end
	end
	return true
end


# This function adds each student/instructor to the database from
# the user uploaded CSV file. Passwords are hashed when storing
# each user's information and returns true if insertion is 
# successful, false otherwise. Parameter is a string path to
# to uploaded CSV file. 
def importCSV(path)
	if validateCSV(path)
		# Open DB connection
		db = openDB()
		# Add users to DB inside this loop
		CSV.foreach(path) do |col|
			unless (col[0] == "users") # prevent storing any possible headers
				username = col[0].strip
				password = col[1].strip
				role = col[2].strip
				# Hash the current user's password
				hashed_pw = BCrypt::Password.create(password)
				# Store current user into DB
				db.execute( "INSERT INTO Class (user, password, role) VALUES ('#{username}', '#{hashed_pw}', '#{role}')" )
			end
		end
		return true
	else
		return false
	end
end


# This function Imports ZIP files and stores them in the website folder 
# (Found in public folder). Any changes to the desired exporting path can 
# be made by changing 'public/ws'
def importZIP(path)
	dest_folder = File.join(Dir.pwd, 'public/ws')
	Zip::File.open(path) do |zipfile|
	  zipfile.each do |entry|
	  	cur_file = File.join(dest_folder, entry.name)
	    unless File.exist?(cur_file)	
	      FileUtils::mkdir_p(File.dirname('public/ws/'+entry.name)) # Create website dir
	      zipfile.extract(entry, cur_file)	# Extract files into dir
	    end
	  end
	end
	return true
end


# This function first checks if username exists, if it does
# check to see if its password is correct. If username does not 
# exist or password is incorrect, return false. Parameter for the
# role is passed to indicate the where the user is trying to log
# in from. (Either the Student or Instructor Login portal).
def verifyUser(username, password, role)
	db = openDB() # Open DB connection

	# default query string. This will be passed into the db.execute query function below
	qry = "SELECT * FROM Class WHERE user='#{username}'"

	# add a query filter for students or instructors/tas
	if(role=="student")
		qry += " AND role='student'"
	else
		qry += " AND (role='instructor' or role='ta')"
	end

	# user holds an array of user information returned from DB
	# where user[0] holds the id, user[1] the user, user[2] the password, etc.
	user = (db.execute( qry ))[0]

	# If the user was found, move on to validate the password
	if user
		# Compare the user's stored encrypted password with the submitted one
		stored_pw = BCrypt::Password.new(user[2])
		if(stored_pw == password)
			return user[0] # return user's id
		else
			return false
		end
	else # user was not found, return false
		return false
	end
end


# This function loads in the sites by grabbing the html file's
# directory path. It stores the path in a array as a string and
# returns it to the client side to serve the site. The site
# order is also randomized when shown to the user.
def getSites()
	ws = []
	#gets all the html files located in the 'public/ws' folder
	Dir['./public/ws/*/*.html'].each {|x|
		ws.push(x.gsub('./public/', ''))
	}
	return  ws
end


# This function processes a user's vote. The user's id, first,
# second, and third choices are passed in to update the table.
# The function will return true if the update was sucessful,
# and false if the user has already voted.
def processVote(uid, first, second, third)
	db = openDB()
	# Checks if the user has voted. voteStatus should be 0 if user hasn't voted yet
	voteStatus = db.execute("SELECT has_voted FROM Class WHERE id=#{uid}")[0][0]
	# If the user hasn't voted yet, update their choices and flag that they voted.
	if(voteStatus == 0)
		db.execute("UPDATE Class 
					SET has_voted=1, first_choice='#{first}',second_choice='#{second}',third_choice='#{third}'
					WHERE id=#{uid}")
		return true
	else
		# If user has already voted, return false and show error
		return false
	end
end



# This function loads in the the current polls and sends the 
# data back as an array of hashes. The entire array will then
# be transformed into stringified JSON and parsed via client side
def getPolls()
	p_arr = []
	db = openDB()
	current_polls = db.execute('SELECT user, first_choice, second_choice, third_choice FROM Class')

	current_polls.each { |user|
		p_hash = Hash.new
		p_hash[:user] = user[0]
		p_hash[:first] = user[1]
		p_hash[:second] = user[2]
		p_hash[:third] = user[3]

		p_arr.push(p_hash)
	}
	return p_arr
end


# Updates (or creates) the Class CSV file. The default 
# CSV file path is located at "public/ws/class_votes.csv"
def updateCSV()
	db = openDB()
	users = db.execute("SELECT * FROM Class") 

	CSV.open('./public/ws/class_votes.csv', 'wb', :write_headers => true, :headers => ["USER_ID","USERNAME","PASSWORD", "ROLE", "HAS_VOTED", "FIRST_CHOICE", "SECOND_CHOICE", "THIRD_CHOICE"]) { |csv|
		users.each do |user|
			csv << user
		end
	}
end
