# frozen_string_literal: true

module Web::Guest
  class RegistrationsController < BaseController
    def new
      render("web/guest/registrations/new", locals: {user: User::Registration::Input.new})
    end
  end
end
