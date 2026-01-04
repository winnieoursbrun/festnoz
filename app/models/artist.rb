# frozen_string_literal: true

class Artist < ApplicationRecord
  ENRICHMENT_CACHE_DURATION = 30.days

  # Associations
  has_many :concerts, dependent: :destroy
  has_many :user_artists, dependent: :destroy
  has_many :followers, through: :user_artists, source: :user

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :genre, presence: true

  # Callbacks
  after_create_commit :schedule_enrichment, if: :should_enrich?
  after_update_commit :schedule_enrichment_on_name_change, if: :saved_change_to_name?

  # Scopes
  scope :by_genre, ->(genre) { where(genre: genre) }
  scope :search, ->(query) { where("name ILIKE ?", "%#{sanitize_sql_like(query)}%") }
  scope :needs_enrichment, -> { where(audiodb_status: [nil, "pending"]) }
  scope :enriched, -> { where(audiodb_status: "enriched") }
  scope :not_found_in_audiodb, -> { where(audiodb_status: "not_found") }

  # Instance methods
  def upcoming_concerts
    concerts.where("starts_at >= ?", Time.current).order(:starts_at)
  end

  def past_concerts
    concerts.where("starts_at < ?", Time.current).order(starts_at: :desc)
  end

  def follower_count
    followers.count
  end

  def on_tour?
    upcoming_concerts.where("starts_at <= ?", 6.months.from_now).exists?
  end

  # Enrichment methods
  def enriched?
    audiodb_status == "enriched"
  end

  def enrichment_pending?
    audiodb_status.nil? || audiodb_status == "pending"
  end

  def schedule_enrichment
    update_column(:audiodb_status, "pending")
    ArtistEnrichmentJob.perform_later(id)
  end

  def force_enrich!
    update_column(:audiodb_status, "pending")
    update_column(:audiodb_enriched_at, nil)
    AudiodbService.new.enrich_artist(self)
  end

  def social_links
    links = {}
    links[:website] = website if website.present?
    links[:facebook] = facebook_url if facebook_url.present?
    links[:twitter] = "https://twitter.com/#{twitter_handle}" if twitter_handle.present?
    links
  end

  def has_social_links?
    website.present? || facebook_url.present? || twitter_handle.present?
  end

  def needs_re_enrichment?
    return true if audiodb_enriched_at.nil?
    return true if audiodb_status == "failed" && audiodb_enriched_at < 1.day.ago
    audiodb_enriched_at < ENRICHMENT_CACHE_DURATION.ago
  end

  def primary_image_url
    thumbnail_url || image_url
  end

  private

  def should_enrich?
    audiodb_status.nil? || audiodb_status == "pending"
  end

  def schedule_enrichment_on_name_change
    schedule_enrichment
  end
end
