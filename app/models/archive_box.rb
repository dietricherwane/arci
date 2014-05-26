class ArchiveBox < ActiveRecord::Base
  attr_accessible :name, :published, :user_id, :created_by, :updated_by
  has_many :books
end
