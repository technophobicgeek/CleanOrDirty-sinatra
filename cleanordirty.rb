require 'rubygems'
require 'bundler/setup'

require 'dm-core'
require 'dm-migrations'


require 'sinatra'
require 'bitly'


# set up database using datamapper

class Dishwasher
  include DataMapper::Resource

  # fields
  property :id,     Serial
  property :name,   String
  property :status, String
  property :code,   String

  # validations
  validates_uniqueness_of :code
end
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/project.db")
DataMapper.auto_upgrade!


# the HTTP entry points to our service

get '/api/v1/dishwashers/:code' do
  dishwasher = Dishwasher.first(:code => params[:code])
  if dishwasher
    dishwasher.to_json
  else
    error 404, "dishwasher not found".to_json
  end
end
# 
# post '/api/v1/dishwashers' do
#   begin
#     dishwasher = Dishwasher.create(JSON.parse(request.body.read))
#     
#     # TODO Generate and update a code for the dishwasher
#     Bitly.use_api_version_3    
#     bitly = Bitly.new("plusbzz", "R_18b965b49460efd206c595f066f43370")
#     u = bitly.shorten("http://cleanordirty.heroku.com/api/v1/dishwashers/#{dishwasher[:id]}")
#     dishwasher.update_attributes({:code => u.user_hash, :status => "dirty"})
#     
#     if dishwasher
#       dishwasher.to_json
#     else
#       error 400, "error creating dishwasher".to_json  
#     end
#   rescue => e
#     error 400, e.message.to_json
#   end
# end
# 
# put '/api/v1/dishwashers/:code' do
#   dishwasher = Dishwasher.find_by_code(params[:code])
#   if dishwasher
#     begin
#       dishwasher.update_attributes(JSON.parse(request.body.read))
#       # we don't have any validations right now. we'll cover later
#       dishwasher.to_json
#     rescue => e
#       error 400, e.message.to_json
#     end
#   else
#     error 404, "dishwasher not found".to_json
#   end
# end
# 
# delete '/api/v1/dishwashers/:code' do
#   dishwasher = Dishwasher.find_by_code(params[:code])
#   if dishwasher
#     dishwasher.destroy
#     dishwasher.to_json
#   else
#     error 404, "dishwasher not found".to_json
#   end
# end
