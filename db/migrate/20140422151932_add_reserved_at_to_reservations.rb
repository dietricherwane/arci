class AddReservedAtToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :reserved_at, :datetime
  end
end
