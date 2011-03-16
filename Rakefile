require 'rubygems'
gem 'activerecord'
require 'active_record'
require 'yaml'
require 'logger'
gem 'sqlite3'
require 'sqlite3'

desc "Load the environment"
task :environment do
  dbconfig = {
      :adapter    => "sqlite3",
      :database   => "my.db",
      :pool       => 5,
      :timeout    => 5000
    }
  ActiveRecord::Base.establish_connection(dbconfig)
end

namespace :db do
  desc "Migrate the database"
  task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end
end
