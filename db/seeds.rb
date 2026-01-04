# frozen_string_literal: true

# Clear existing data
puts "Clearing existing data..."
Concert.destroy_all if defined?(Concert) && Concert.table_exists?
UserArtist.destroy_all if defined?(UserArtist) && UserArtist.table_exists?
Artist.destroy_all if defined?(Artist) && Artist.table_exists?
User.destroy_all if defined?(User) && User.table_exists?

# Create admin user
puts "Creating admin user..."
admin = User.create!(
  email: 'admin@example.com',
  username: 'admin',
  password: 'password',
  password_confirmation: 'password',
  admin: true
)

# Create test users
puts "Creating test users..."
user1 = User.create!(
  email: 'user@example.com',
  username: 'musiclover',
  password: 'password',
  password_confirmation: 'password'
)

user2 = User.create!(
  email: 'breizh@example.com',
  username: 'breizh_fan',
  password: 'password',
  password_confirmation: 'password'
)

# Create artists
puts "Creating artists..."
artists_data = [
  {
    name: 'Tri Yann',
    description: 'Legendary Breton folk band formed in 1970',
    genre: 'Breton Folk',
    country: 'France',
    image_url: '/images/placeholders/artist-1.svg'
  },
  {
    name: 'Nolwenn Korbell',
    description: 'Singer of traditional Breton songs',
    genre: 'Traditional',
    country: 'France',
    image_url: '/images/placeholders/artist-2.svg'
  },
  {
    name: 'Bagad Kemper',
    description: 'Traditional Breton bagpipe ensemble',
    genre: 'Breton Traditional',
    country: 'France',
    image_url: '/images/placeholders/artist-3.svg'
  },
  {
    name: 'Denez Prigent',
    description: 'Contemporary Breton singer blending tradition and modernity',
    genre: 'World Music',
    country: 'France',
    image_url: '/images/placeholders/artist-4.svg'
  },
  {
    name: 'Red Cardell',
    description: 'Breton rock band with Celtic influences',
    genre: 'Celtic Rock',
    country: 'France',
    image_url: '/images/placeholders/artist-5.svg'
  }
]

artists = artists_data.map { |attrs| Artist.create!(attrs) }

# Create concerts
puts "Creating concerts..."
concerts_data = [
  {
    artist: artists[0],
    title: 'Fest-Noz de Printemps',
    description: 'Traditional Breton dance night with Tri Yann',
    starts_at: 2.weeks.from_now.change(hour: 20, min: 0),
    ends_at: 2.weeks.from_now.change(hour: 23, min: 30),
    venue_name: 'Salle des Fêtes de Quimper',
    venue_address: '10 Rue de la République',
    city: 'Quimper',
    country: 'France',
    latitude: 47.9956,
    longitude: -4.0979,
    price: 15.00,
    ticket_url: 'https://example.com/tickets/1'
  },
  {
    artist: artists[0],
    title: 'Festival Interceltique',
    description: 'Tri Yann at the famous Celtic festival',
    starts_at: 3.months.from_now.change(hour: 21, min: 0),
    venue_name: 'Palais des Congrès',
    venue_address: 'Quai Eric Tabarly',
    city: 'Lorient',
    country: 'France',
    latitude: 47.7482,
    longitude: -3.3631,
    price: 25.00,
    ticket_url: 'https://example.com/tickets/2'
  },
  {
    artist: artists[1],
    title: 'Concert Kan ha Diskan',
    description: 'Traditional Breton singing evening',
    starts_at: 1.month.from_now.change(hour: 19, min: 30),
    venue_name: 'Ti ar Vro',
    venue_address: '5 Place Saint-Corentin',
    city: 'Quimper',
    country: 'France',
    latitude: 47.9960,
    longitude: -4.1026,
    price: 12.00
  },
  {
    artist: artists[2],
    title: 'Défilé et Concert',
    description: 'Bagpipe parade followed by concert',
    starts_at: 3.weeks.from_now.change(hour: 14, min: 0),
    venue_name: 'Place de la Mairie',
    venue_address: 'Place de la Mairie',
    city: 'Brest',
    country: 'France',
    latitude: 48.3905,
    longitude: -4.4860,
    price: 8.00
  },
  {
    artist: artists[2],
    title: 'Championnat des Bagadoù',
    description: 'Bagpipe championship competition',
    starts_at: 4.months.from_now.change(hour: 10, min: 0),
    venue_name: 'Stade de Penvillers',
    venue_address: 'Rue de Penvillers',
    city: 'Quimper',
    country: 'France',
    latitude: 47.9923,
    longitude: -4.0848,
    price: 20.00,
    ticket_url: 'https://example.com/tickets/3'
  },
  {
    artist: artists[3],
    title: 'Concert Électro-Breton',
    description: 'Modern electronic music meets Breton tradition',
    starts_at: 6.weeks.from_now.change(hour: 21, min: 30),
    venue_name: 'Le Vauban',
    venue_address: '17 Av. Clemenceau',
    city: 'Brest',
    country: 'France',
    latitude: 48.3833,
    longitude: -4.4948,
    price: 18.00,
    ticket_url: 'https://example.com/tickets/4'
  },
  {
    artist: artists[4],
    title: 'Rock Celtique',
    description: 'High-energy Celtic rock concert',
    starts_at: 5.weeks.from_now.change(hour: 20, min: 30),
    venue_name: 'Glaz Arena',
    venue_address: 'Boulevard de Plymouth',
    city: 'Brest',
    country: 'France',
    latitude: 48.3987,
    longitude: -4.4753,
    price: 22.00,
    ticket_url: 'https://example.com/tickets/5'
  },
  {
    artist: artists[4],
    title: 'Festival des Vieilles Charrues',
    description: 'Red Cardell at the biggest music festival in France',
    starts_at: 4.months.from_now.change(hour: 22, min: 0),
    venue_name: 'Site de Kerampuilh',
    venue_address: 'Kerampuilh',
    city: 'Carhaix-Plouguer',
    country: 'France',
    latitude: 48.2769,
    longitude: -3.5731,
    price: 45.00,
    ticket_url: 'https://example.com/tickets/6'
  },
  {
    artist: artists[1],
    title: 'Fest-Noz Kemperle',
    description: 'Traditional dance night in Kemperle',
    starts_at: 2.months.from_now.change(hour: 20, min: 0),
    venue_name: 'Salle Condorcet',
    venue_address: 'Rue Condorcet',
    city: 'Quimperlé',
    country: 'France',
    latitude: 47.8722,
    longitude: -3.5486,
    price: 10.00
  },
  {
    artist: artists[3],
    title: 'Concert Intime',
    description: 'Acoustic concert in an intimate setting',
    starts_at: 1.week.from_now.change(hour: 19, min: 0),
    venue_name: 'Chapelle de Ty Mamm Doué',
    venue_address: 'Route de Ty Mamm Doué',
    city: 'Quimper',
    country: 'France',
    latitude: 47.9912,
    longitude: -4.0912,
    price: 14.00
  }
]

concerts = concerts_data.map { |attrs| Concert.create!(attrs) }

# Create some follows
puts "Creating user follows..."
user1.follow(artists[0])
user1.follow(artists[2])
user1.follow(artists[4])

user2.follow(artists[0])
user2.follow(artists[1])
user2.follow(artists[3])

puts "\n✅ Seed data created successfully!"
puts "\nTest Credentials:"
puts "  Admin: admin@example.com / password"
puts "  User 1: user@example.com / password"
puts "  User 2: breizh@example.com / password"
puts "\nStatistics:"
puts "  #{User.count} users created"
puts "  #{Artist.count} artists created"
puts "  #{Concert.count} concerts created"
puts "  #{UserArtist.count} follow relationships created"
