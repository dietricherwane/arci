class AddValidatedByAndTakenByAndReturnedByToDemands < ActiveRecord::Migration
  def change
    add_column :demands, :validated_by, :integer
    add_column :demands, :taken_by, :integer
    add_column :demands, :returned_by, :integer
  end
end
