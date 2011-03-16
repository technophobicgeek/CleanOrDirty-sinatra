require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'sinatra'
require 'bitly'

require "#{File.dirname(__FILE__)}/models/dishwasher"

# setting up our environment

dbconfig = {
    :adapter    => "sqlite3",
    #:database   => ENV['DATABASE_URL'] || "#{Dir.pwd}/db/my.db",
    :database   => "#{Dir.pwd}/db/my.db",
    :pool       => 5,
    :timeout    => 5000
  }
ActiveRecord::Base.establish_connection(dbconfig)

# the HTTP entry points to our service

# get a dishwasher by code
get '/api/v1/dishwashers/:code' do
  dishwasher = Dishwasher.find_by_code(params[:code])
  if dishwasher
    dishwasher.to_json
  else
    error 404, "dishwasher not found".to_json
  end
end

# create a new dishwasher, return json response
post '/api/v1/dishwashers' do
  begin
    dishwasher = Dishwasher.create(JSON.parse(request.body.read))
    # TODO Generate and update a code for the dishwasher
    Bitly.use_api_version_3    
    bitly = Bitly.new("plusbzz", "R_18b965b49460efd206c595f066f43370")
    u = bitly.shorten("http://cleanordirty.heroku.com/api/v1/dishwashers/#{dishwasher[:id]}")
    dishwasher.update_attributes({:code => u.user_hash, :status => "dirty"})
    
    if dishwasher
      dishwasher.to_json
    else
      error 400, "error creating dishwasher".to_json  
    end
  rescue => e
    error 400, e.message.to_json
  end
end

# update an existing dishwasher
put '/api/v1/dishwashers/:code' do
  dishwasher = Dishwasher.find_by_code(params[:code])
  if dishwasher
    begin
      dishwasher.update_attributes(JSON.parse(request.body.read))
      # we don't have any validations right now. we'll cover later
      dishwasher.to_json
    rescue => e
      error 400, e.message.to_json
    end
  else
    error 404, "dishwasher not found".to_json
  end
end

# destroy an existing dishwasher
delete '/api/v1/dishwashers/:code' do
  dishwasher = Dishwasher.find_by_code(params[:code])
  if dishwasher
    dishwasher.destroy
    dishwasher.to_json
  else
    error 404, "dishwasher not found".to_json
  end
end
