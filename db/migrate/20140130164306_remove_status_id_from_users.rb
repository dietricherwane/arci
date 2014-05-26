class RemoveStatusIdFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :status_id
  end
end
