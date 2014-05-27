class Consultant < ActiveRecord::Base
  attr_accessible :name, :user_id, :created_by, :updated_by, :published
  has_many :books
end
