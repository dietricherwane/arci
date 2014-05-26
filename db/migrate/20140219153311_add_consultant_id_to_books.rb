class AddConsultantIdToBooks < ActiveRecord::Migration
  def change
    add_column :books, :consultant_id, :integer
  end
end
