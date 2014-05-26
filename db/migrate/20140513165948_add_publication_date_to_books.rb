class AddPublicationDateToBooks < ActiveRecord::Migration
  def change
    add_column :books, :publication_date, :date
  end
end
