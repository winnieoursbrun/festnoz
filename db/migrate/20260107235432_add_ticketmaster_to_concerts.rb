class AddTicketmasterToConcerts < ActiveRecord::Migration[8.1]
  def change
    add_column :concerts, :ticketmaster_id, :string
    add_index :concerts, :ticketmaster_id, unique: true
    add_column :concerts, :ticketmaster_url, :string
  end
end
