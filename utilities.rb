require 'csv'


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



# Add each user to the DB
def csvToDB(path)
	file_contents = ""
	if validateCSV(path)

		# Add users to DB inside this loop
		CSV.foreach(path) do |col|
			unless (col[0] == "users") # if csv contains headers
				file_contents += col[0] + col[1] + col[2] + "\n"
				# TODO: Add users to DB here (col[0] = user, HASH(col[1]) = password, col[2] = role)
				#
				#
				#
			end
		end
		return true
	else
		return false
	end
end