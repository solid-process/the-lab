# frozen_string_literal: true

module Web::Guest
  class SessionsController < BaseController
    def new
      render("web/guest/sessions/new", locals: {user: User::Authentication::Input.new})
    end
  end
end
