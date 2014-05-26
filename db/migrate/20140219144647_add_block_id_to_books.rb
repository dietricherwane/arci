class AddBlockIdToBooks < ActiveRecord::Migration
  def change
    add_column :books, :block_id, :integer
  end
end
