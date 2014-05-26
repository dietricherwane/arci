class CreateQualifications < ActiveRecord::Migration
  def change
    create_table :qualifications do |t|
      t.string :label
      t.integer :department_id
      t.boolean :published

      t.timestamps
    end
  end
end
