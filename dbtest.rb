#!/usr/bin/ruby

require 'sqlite3'

begin
    
    db = SQLite3::Database.open "db/development.sqlite3"
    id =51
    body = "test reply"
    from_bot = 1
    time = Time.now
    uid = 2
    db.execute "INSERT INTO messages VALUES('#{id}','#{body}','#{from_bot}','#{uid}','#{Time.now}','#{Time.now}')"
    #stm.bind_params id, body, from_bot, uid
    #stm.execute

=begin
    db.results_as_hash = true
    id = 25
    #stm = db.prepare "SELECT * FROM messages LIMIT 20" 
    stm = db.prepare "SELECT * FROM messages WHERE Id>?" 
    stm.bind_param 1, id
    
    rs = stm.execute 
    rs.each do |row| 
        #printf "%s %s %s %s\n", row['id'], row['body'], row['from_bot'], row['user_id']
        #puts row['body'].class
        puts row
    end
    #row = rs.next
    #puts row.join "\s"
=end
rescue SQLite3::Exception => e 
    
    puts "Exception occurred"
    puts e
    
ensure
    db.close if db
end