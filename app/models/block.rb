class Block < ActiveRecord::Base
  attr_accessible :name, :shaft_id, :published, :user_id, :created_by, :updated_by
  belongs_to :shaft
  has_many :books
end
