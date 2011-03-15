class Dishwasher < ActiveRecord::Base
  validates_uniqueness_of :code
  def to_json
    super(:except => :password)
  end
end