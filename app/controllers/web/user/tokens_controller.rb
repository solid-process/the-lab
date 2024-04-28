# frozen_string_literal: true

module Web::User
  class TokensController < BaseController
    def update
      result = User::AccessToken::Refreshing.call(user: current_user)

      message = result.success? ? {notice: "Access token updated."} : {alert: "Access token cannot be updated."}

      redirect_to(web_user_settings_api_path, message)
    end
  end
end
