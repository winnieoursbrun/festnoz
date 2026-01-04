# frozen_string_literal: true

class Concert < ApplicationRecord
  # Geocoding configuration
  geocoded_by :full_address
  after_validation :geocode_if_needed, if: :should_geocode?

  # Associations
  belongs_to :artist

  # Validations
  validates :title, presence: true
  validates :venue_name, :city, :country, presence: true
  validates :starts_at, presence: true
  # Conditional validation: require coordinates OR valid address for geocoding
  validates :latitude, :longitude, presence: true, unless: :will_be_geocoded?
  validates :latitude, numericality: {
    greater_than_or_equal_to: -90,
    less_than_or_equal_to: 90,
    allow_nil: true
  }
  validates :longitude, numericality: {
    greater_than_or_equal_to: -180,
    less_than_or_equal_to: 180,
    allow_nil: true
  }
  validate :ends_at_after_starts_at

  # Scopes
  scope :upcoming, -> { where("starts_at >= ?", Time.current).order(:starts_at) }
  scope :past, -> { where("starts_at < ?", Time.current).order(starts_at: :desc) }
  scope :in_city, ->(city) { where("city ILIKE ?", "%#{sanitize_sql_like(city)}%") }
  scope :by_date_range, ->(start_date, end_date) { where(starts_at: start_date..end_date) }

  # Geocoder method: builds full address for geocoding
  def full_address
    [venue_address, city, country].compact.join(", ")
  end

  # Check if this record should be geocoded
  def should_geocode?
    # Don't geocode if coordinates are manually provided
    return false if latitude.present? && longitude.present?

    # Only geocode if we have enough address info
    venue_name.present? && city.present? && country.present?
  end

  # Check if address fields changed
  def address_changed?
    venue_address_changed? || city_changed? || country_changed?
  end

  # Check if record will be geocoded (for validation purposes)
  def will_be_geocoded?
    latitude.blank? && longitude.blank? && venue_name.present? && city.present? && country.present?
  end

  private

  # Custom geocoding callback with error handling
  def geocode_if_needed
    return unless should_geocode?

    begin
      sleep(1) if Rails.env.production? # Respect Nominatim rate limit
      geocode

      if latitude.blank? || longitude.blank?
        errors.add(:base, "Could not geocode address: #{full_address}. Please provide coordinates manually.")
      end
    rescue Geocoder::Error, Timeout::Error => e
      Rails.logger.error("Geocoding failed for Concert #{id || 'new'}: #{e.message}")
      errors.add(:base, "Geocoding service unavailable. Please provide coordinates manually.")
    end
  end

  def ends_at_after_starts_at
    return unless ends_at && starts_at

    if ends_at < starts_at
      errors.add(:ends_at, "must be after start time")
    end
  end
end
