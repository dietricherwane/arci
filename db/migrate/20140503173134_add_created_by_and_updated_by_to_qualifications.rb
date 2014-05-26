class AddCreatedByAndUpdatedByToQualifications < ActiveRecord::Migration
  def change
    add_column :qualifications, :created_by, :integer
    add_column :qualifications, :update_by, :integer
  end
end
