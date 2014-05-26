class Department < ActiveRecord::Base
  has_many :qualifications
  
  attr_accessible :id, :user_id, :name, :published, :created_by, :updated_by
end
