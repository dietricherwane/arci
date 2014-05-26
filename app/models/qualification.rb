class Qualification < ActiveRecord::Base
  belongs_to :department
  has_many :users
  
  attr_accessible :id, :user_id, :label, :department_id, :created_by, :updated_by
end
