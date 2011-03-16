require File.dirname(__FILE__) + '/../cleanordirty'
gem 'rspec'
require 'rspec'
gem 'rack-test'
require 'rack/test'

set :environment, :test
#Test::Unit::TestCase.send :include, Rack::Test::Methods

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Sinatra::Application
end

describe "service" do
  before(:each) do
    Dishwasher.delete_all
  end

  describe "GET on /api/v1/dishwashers/:code" do
    before(:each) do
      Dishwasher.create(
        :code => "ABCDEF",
        :name => "Apna Dishwasher",
        :status => "dirty"
      )
    end

    it "should return a dishwasher by code" do
      get '/api/v1/dishwashers/ABCDEF'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["dishwasher"]
      attributes["code"].should == "ABCDEF"
    end

    it "should return a dishwasher with a status" do
      get '/api/v1/dishwashers/ABCDEF'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["dishwasher"]
      attributes["status"].should_not be_blank
    end


    it "should return a 404 for a dishwasher that doesn't exist" do
      get '/api/v1/dishwashers/foo'
      last_response.status.should == 404
    end
  end

#   describe "POST on /api/v1/dishwashers" do
#     it "should create a dishwasher" do
#       post '/api/v1/dishwashers', {
#         :name  => "Apna Dishwasher"
#       }.to_json
#       last_response.should be_ok
# 
#       # On creating a dishwasher, return a random code
#       attributes = JSON.parse(last_response.body)["dishwasher"]
#       code = attributes["code"]
#       
#       # TODO code should be 6 characters long
#       code.length.should == 6
#       
#       get "/api/v1/dishwashers/#{code}"
#       attributes = JSON.parse(last_response.body)["dishwasher"]
#       attributes["code"].should  == "#{code}"
#       attributes["name"].should == "Apna Dishwasher"
#       attributes["status"].should   == "dirty"
#     end
#   end
# 
#   describe "PUT on /api/v1/dishwashers/:code" do
#     it "should update a dishwasher" do
#       Dishwasher.create(
#         :code => "ABCDEF",
#         :name => "Apna Dishwasher",
#         :status => "dirty"
#       )
#       put '/api/v1/dishwashers/ABCDEF', {
#         :status => "clean"}.to_json
#       last_response.should be_ok
#       get '/api/v1/dishwashers/ABCDEF'
#       attributes = JSON.parse(last_response.body)["dishwasher"]
#       attributes["status"].should == "clean"
#     end
#   end
# 
#   describe "DELETE on /api/v1/dishwashers/:id" do
#     it "should delete a dishwasher" do
#       Dishwasher.create(
#         :code => "ABCDEF",
#         :name => "Apna Dishwasher",
#         :status => "dirty"
#       )
#       delete '/api/v1/dishwashers/ABCDEF'
#       last_response.should be_ok
#       get '/api/v1/dishwashers/ABCDEF'
#       last_response.status.should == 404
#     end
#   end


end
