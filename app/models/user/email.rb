# frozen_string_literal: true

module User::Email
  NORMALIZATION = -> { _1.downcase.strip }
end
