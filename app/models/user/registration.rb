# frozen_string_literal: true

class User::Registration < Solid::Process
  deps do
    attribute :mailer, default: UserMailer
    attribute :token_creation, default: User::AccessToken::Creation
    attribute :task_list_creation, default: Account::Tasks::List::Creation
  end

  input do
    attribute :email, :string
    attribute :password, :string
    attribute :password_confirmation, :string

    before_validation do
      self.email = User::Email::NORMALIZATION[email]
    end

    validates :email, email: true
    validates :password, User::Password::VALIDATIONS_WITH_CONFIRMATION
  end

  def call(attributes)
    rollback_on_failure {
      Given(attributes)
        .and_then(:check_if_email_is_taken)
        .and_then(:create_user)
        .and_then(:create_user_account)
        .and_then(:create_user_inbox)
        .and_then(:create_user_token)
    }
      .and_then(:send_email_confirmation)
      .and_expose(:user_registered, [:user])
  end

  private

  def check_if_email_is_taken(email:, **)
    input.errors.add(:email, "has already been taken") if User.exists?(email:)

    input.errors.any? ? Failure(:invalid_input, input:) : Continue()
  end

  def create_user(email:, password:, password_confirmation:, **)
    user = User.create(email:, password:, password_confirmation:)

    return Continue(user:) if user.persisted?

    input.errors.merge!(user.errors)

    Failure(:invalid_input, input:)
  end

  def create_user_account(user:, **)
    account = Account.create!(uuid: SecureRandom.uuid)

    account.memberships.create!(user:, role: :owner)

    Continue(account:)
  end

  def create_user_inbox(account:, **)
    case deps.task_list_creation.call(account:, inbox: true)
    in Solid::Success(task_list:) then Continue()
    end
  end

  def create_user_token(user:, **)
    case deps.token_creation.call(user:)
    in Solid::Success(token:) then Continue()
    end
  end

  def send_email_confirmation(user:, **)
    deps.mailer.with(
      user:,
      token: user.generate_token_for(:email_confirmation)
    ).email_confirmation.deliver_later

    Continue()
  end
end
