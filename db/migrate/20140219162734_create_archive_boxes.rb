class CreateArchiveBoxes < ActiveRecord::Migration
  def change
    create_table :archive_boxes do |t|
      t.string :name
      t.boolean :published

      t.timestamps
    end
  end
end
