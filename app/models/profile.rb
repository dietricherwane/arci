class Profile < ActiveRecord::Base
  has_many :users
  
  attr_accessible :id, :name, :shortcut
end
