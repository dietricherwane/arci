class Category < ActiveRecord::Base
  has_many :books
  
  attr_accessible :id, :user_id, :name, :short_code, :published, :created_by, :updated_by
end
