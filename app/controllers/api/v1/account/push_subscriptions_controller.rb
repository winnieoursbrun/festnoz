# frozen_string_literal: true

module Api
  module V1
    module Account
      class PushSubscriptionsController < BaseController
        # GET /api/v1/account/push_subscriptions/public_key
        def public_key
          key = vapid_public_key
          if key.blank?
            render json: { error: "Web push is not configured" }, status: :service_unavailable
            return
          end

          render json: { public_key: key }, status: :ok
        end

        # GET /api/v1/account/push_subscriptions
        def index
          subscriptions = current_user.push_subscriptions.active.order(last_seen_at: :desc)

          render json: {
            push_subscriptions: subscriptions.map do |subscription|
              subscription_payload(subscription)
            end
          }, status: :ok
        end

        # POST /api/v1/account/push_subscriptions
        def create
          keys = push_subscription_keys
          if keys[:p256dh].blank? || keys[:auth].blank?
            render json: { error: "Missing push subscription keys" }, status: :unprocessable_entity
            return
          end

          subscription = PushSubscription.find_or_initialize_by(endpoint: push_subscription_params[:endpoint])
          newly_created = subscription.new_record?

          subscription.assign_attributes(
            user: current_user,
            p256dh_key: keys[:p256dh],
            auth_key: keys[:auth],
            expiration_time: push_subscription_params[:expiration_time],
            user_agent: request.user_agent,
            last_seen_at: Time.current,
            revoked_at: nil
          )

          if subscription.save
            render json: {
              message: newly_created ? "Push subscription created" : "Push subscription updated",
              push_subscription: subscription_payload(subscription)
            }, status: newly_created ? :created : :ok
          else
            render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
          end
        end

        # DELETE /api/v1/account/push_subscriptions/:id
        def destroy
          subscription = current_user.push_subscriptions.find(params[:id])
          subscription.destroy

          render json: { message: "Push subscription removed" }, status: :ok
        end

        # POST /api/v1/account/push_subscriptions/test
        def test
          PushNotificationJob.perform_later(current_user.id, {
            title: "FestNoz test notification",
            body: "Push notifications are enabled.",
            url: "/dashboard"
          })

          render json: { message: "Test notification queued" }, status: :accepted
        end

        private

        def vapid_public_key
          Rails.application.credentials.dig(:web_push, :public_key) ||
            Rails.application.credentials.vapid_public_key
        end

        def push_subscription_params
          params.require(:push_subscription).permit(:endpoint, :expiration_time, keys: [ :p256dh, :auth ])
        end

        def push_subscription_keys
          keys = push_subscription_params[:keys]
          return {} unless keys.respond_to?(:to_h)

          keys.to_h.symbolize_keys
        end

        def subscription_payload(subscription)
          {
            id: subscription.id,
            endpoint: subscription.endpoint,
            created_at: subscription.created_at,
            last_seen_at: subscription.last_seen_at
          }
        end
      end
    end
  end
end
