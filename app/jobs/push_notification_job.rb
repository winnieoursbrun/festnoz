# frozen_string_literal: true

class PushNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, payload)
    user = User.find_by(id: user_id)
    return unless user

    user.push_subscriptions.active.find_each do |subscription|
      begin
        WebPushService.new(subscription).deliver(payload)
      rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
        subscription.mark_revoked!
      rescue WebPush::ResponseError => e
        subscription.mark_revoked! if invalid_subscription_response?(e)
        raise unless invalid_subscription_response?(e)
      end
    end
  end

  private

  def invalid_subscription_response?(error)
    [ 404, 410 ].include?(error.response.code.to_i)
  end
end
