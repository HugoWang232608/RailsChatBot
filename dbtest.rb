#!/usr/bin/ruby

require 'sqlite3'

begin
    
    db = SQLite3::Database.open "db/development.sqlite3"

    db.results_as_hash = true
    id = 140
    stm = db.prepare "SELECT * FROM messages WHERE Id>?" 
    stm.bind_param 1, id
    
    rs = stm.execute 


    a = Array.new
    rs.each do |row| 
        m = Hash["id"=> row['id'], 'body' => row['body'], 'from_bot'=> row['from_bot'], 'user_id'=>row['user_id'] ]
        a << m
    end
    stm.close if stm
    db.close if db

    puts a
rescue SQLite3::Exception => e 
    
    puts "Exception occurred"
    puts e
    
ensure
 
end