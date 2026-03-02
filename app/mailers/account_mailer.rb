# frozen_string_literal: true

class AccountMailer < ApplicationMailer
  def password_changed(user)
    @user = user
    mail(to: @user.email, subject: "Your FestNoz password was changed")
  end

  def account_deletion_confirmation(user, raw_token)
    @user = user
    @confirmation_url = deletion_confirmation_url(raw_token)
    mail(to: @user.email, subject: "Confirm your FestNoz account deletion")
  end

  private

  def deletion_confirmation_url(raw_token)
    base_url = ENV.fetch("URL", "http://127.0.0.1:3000")
    base_url = "http://#{base_url}" unless base_url.start_with?("http")
    "#{base_url}/account/delete/confirm?token=#{CGI.escape(raw_token)}"
  end
end
