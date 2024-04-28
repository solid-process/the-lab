# frozen_string_literal: true

module Web::User
  class BaseController < Web::BaseController
    layout "web/application"

    before_action :authenticate_user!
  end
end
