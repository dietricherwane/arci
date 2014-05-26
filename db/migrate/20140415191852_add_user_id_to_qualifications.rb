class AddUserIdToQualifications < ActiveRecord::Migration
  def change
    add_column :qualifications, :user_id, :integer
  end
end
