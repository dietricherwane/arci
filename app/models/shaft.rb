class Shaft < ActiveRecord::Base
  attr_accessible :name, :user_id, :published, :created_by, :updated_by
  has_many :blocks
end
