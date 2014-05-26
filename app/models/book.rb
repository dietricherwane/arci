class Book < ActiveRecord::Base
  has_and_belongs_to_many :demands
  has_many :reservations
  belongs_to :category
  belongs_to :block
  belongs_to :consultant
  belongs_to :archive_box
  attr_accessible :id, :user_id, :archive_box_id, :publication_date, :created_by, :updated_by, :code, :title, :description, :geographic_position, :total_quantity, :quantity_in_stock, :published, :category_id, :block_id, :consultant_id, :created_at
end
