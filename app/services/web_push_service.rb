# frozen_string_literal: true

class WebPushService
  DEFAULT_SUBJECT = "mailto:admin@festnoz.link"

  def initialize(push_subscription)
    @push_subscription = push_subscription
  end

  def deliver(payload)
    credentials = vapid_credentials

    WebPush.payload_send(
      message: payload.to_json,
      endpoint: @push_subscription.endpoint,
      p256dh: @push_subscription.p256dh_key,
      auth: @push_subscription.auth_key,
      vapid: credentials
    )
  end

  private

  def vapid_credentials
    public_key = Rails.application.credentials.dig(:web_push, :public_key) ||
                 Rails.application.credentials.vapid_public_key
    private_key = Rails.application.credentials.dig(:web_push, :private_key) ||
                  Rails.application.credentials.vapid_private_key

    if public_key.blank? || private_key.blank?
      raise ArgumentError, "Missing VAPID keys"
    end

    {
      subject: Rails.application.credentials.dig(:web_push, :subject) || DEFAULT_SUBJECT,
      public_key: public_key,
      private_key: private_key
    }
  end
end
