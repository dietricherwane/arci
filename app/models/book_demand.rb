class BookDemand < ActiveRecord::Base
  attr_accessible :demand_id, :user_id, :book_damaged_by_at, :returned_by_at, :book_damaged_at, :returned_at, :taken_by_at, :book_left_at, :validated_at, :unavailable_by_at, :validated_by, :taken_by, :returned_by, :damaged_by, :unavailable_by, :book_damaged_by, :book_id, :on_hold, :book_left, :in_progress, :validated, :returned, :book_damaged, :unavailable, :taken, :created_at, :updated_at, :comments
end
