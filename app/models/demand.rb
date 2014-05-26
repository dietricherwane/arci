class Demand < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :books
  
  attr_accessible :id, :user_id, :book_damaged_by_at, :returned_by_at, :book_damaged_at, :returned_at, :taken_by_at, :book_left_at, :validated_at, :unavailable_by_at, :validated_by_at, :validated_by, :taken_by, :returned_by, :damaged_by, :unavailable_by, :book_damaged_by, :expires_on, :on_hold, :in_progress, :validated, :book_left, :returned, :book_damaged, :troubles_in, :unavailable, :taken, :created_at
end
