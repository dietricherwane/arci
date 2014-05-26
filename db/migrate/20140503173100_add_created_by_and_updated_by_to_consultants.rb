class AddCreatedByAndUpdatedByToConsultants < ActiveRecord::Migration
  def change
    add_column :consultants, :created_by, :integer
    add_column :consultants, :update_by, :integer
  end
end
