# WebVoter
Peer Review Web App Project for Web Applications. 

# Description
A web site that will allow for students to view and rate (first, second, and third) for their favorite bootstrap website of the various student submitted sites

# Features:
- They instructor/ta is able to view a report of the voting.  The report clearly indicates who voted and how they voted.
- The instructor/ta is be able to download the voting report as a CSV file.
- For the voting, the order of the websites will be randomized when displayed for students.
- Store usernames and passwords in an SQL database.
- The passwords are salted and hashed.
- There are at least 2 roles - one for students allowing them to vote, and one for instructors/tas.
- There is a way to upload a list (CSV) of users, their passwords, and roles.
- Allows each student to vote once and only once.
- The instructor/ta is able to upload as a large zip file the websites for the students.  
- Uses sessions to ensure that users log in.
- Has an option for logging out.
- All input from the client is sanitized and validated on the server. 
- Uses Bootstrap for styling the web app.


# Installation/Setup:
-Install all dependencies in the Gemfile.
-Run "ruby app.rb"
-Go to localhost:4567 in your browser


# Resetting User Logins and Delete Uploaded Websites:
-Delete the "webvoter.database" file
-Delete all folders inside the "public/ws" folder
