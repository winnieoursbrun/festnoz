class AddTicketmasterToArtists < ActiveRecord::Migration[8.1]
  def change
    add_column :artists, :ticketmaster_id, :string
    add_index :artists, :ticketmaster_id, unique: true
    add_column :artists, :ticketmaster_url, :string
    add_column :artists, :ticketmaster_name, :string
  end
end
