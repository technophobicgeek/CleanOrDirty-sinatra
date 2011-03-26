#require 'rubygems'
#require 'bundler/setup'
require 'time'

require 'datamapper'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-serializer'

require 'sinatra'
require 'bitly'


# set up database using datamapper

class Dishwasher
  include DataMapper::Resource

  # fields
  property :id,             Serial
  property :name,           String
  property :status,         String
  property :code,           String
  property :last_updated,   Integer
  # validations
  validates_uniqueness_of :code
end

DataMapper.finalize

# Set up database logs
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/project.db")

Dishwasher.auto_migrate! unless Dishwasher.storage_exists?

Bitly.use_api_version_3
$bitly = Bitly.new("plusbzz", "R_18b965b49460efd206c595f066f43370")



before do
  content_type 'application/json'
end

# the HTTP entry points to our service

get '/api/v1/dishwashers/:code' do
  dishwasher = Dishwasher.first(:code => params[:code])
  if dishwasher
    dishwasher.to_json
  else
    error 404, "dishwasher not found".to_json
  end
end

post '/api/v1/dishwashers' do
  begin
    body = JSON.parse(request.body.read)
    dishwasher = Dishwasher.create(body)
    
    if dishwasher
      # TODO Generate and update a code for the dishwasher
      u = $bitly.shorten("http://cleanordirty.heroku.com/api/v1/dishwashers/#{dishwasher.id}")

      dishwasher.code = u.user_hash
      dishwasher.status = "dirty"
      dishwasher.last_updated = Time.now.utc.to_i
      dishwasher.save
      dishwasher.to_json
    else
      error 400, "error creating dishwasher".to_json
    end
    
  rescue => e
    error 400, e.message.to_json
  end
end

put '/api/v1/dishwashers/:code' do
  update_dishwasher(params[:code])
end

post '/api/v1/dishwashers/update/:code' do
  update_dishwasher(params[:code])
end

delete '/api/v1/dishwashers/:code' do
  delete_dishwasher(params[:code])
end

post '/api/v1/dishwashers/delete/:code' do
  delete_dishwasher(params[:code])
end

private

  # TODO validate updates
  #     cannot update code
  #     status should be clean or dirty
  #     name should be bounded

  def update_dishwasher(code)
    dishwasher = Dishwasher.first(:code => code)
    if dishwasher
      begin
        body = JSON.parse(request.body.read)
        body.delete("code") # can't update code
        body["last_updated"] = Time.now.utc.to_i
        dishwasher.update(body)
        # TODO we don't have any validations right now. we'll cover later
        dishwasher.to_json
      rescue => e
        error 400, e.message.to_json
      end
    else
      error 404, "dishwasher not found".to_json
    end
  end

  def delete_dishwasher(code)
    dishwasher = Dishwasher.first(:code => code)
    if dishwasher
      dishwasher.destroy
      dishwasher.to_json
    else
      error 404, "dishwasher not found".to_json
    end
  end
