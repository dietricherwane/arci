class AddUuidAndQualificationIdAndProfileIdAndPublishedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :uuid, :string
    add_column :users, :qualification_id, :integer
    add_column :users, :profile_id, :integer
    add_column :users, :published, :boolean
  end
end
