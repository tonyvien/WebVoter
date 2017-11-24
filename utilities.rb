require 'csv'
require 'bcrypt'
require 'sqlite3'

# Opens a connection to the database and returns the reference to it for
# later use. This function first checks if a database (named 'webvoter') - located 
# in the current folder - already exists to prevent creating a new DB each time this
# function is called.
def openDB()
	unless File.exist?('./webvoter.database')
		db = SQLite3::Database.new( "./webvoter.database" )
		# TODO: Add an extra columns for the user's 1st, 2nd, and 3rd vote
		db.execute( "CREATE TABLE Class (id INTEGER PRIMARY KEY, user TEXT, password TEXT, role TEXT);" )
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
				db.execute( "INSERT INTO Class (user, password, role) VALUES ('#{username}', '#{hashed_pw}', '#{role}')")
			end
		end
		return true
	else
		return false
	end
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
