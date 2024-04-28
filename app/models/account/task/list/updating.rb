# frozen_string_literal: true

class Account::Task::List::Updating < Solid::Process
  input do
    attribute :id, :integer
    attribute :name, :string
    attribute :account

    before_validation do
      self.name = name&.strip
    end

    validates :id, id: true
    validates :name, presence: true
    validates :account, instance_of: [Account, Account::Member]
  end

  def call(attributes)
    attributes => {id:, account:, name:}

    case Account::Task::List::Finding.call(account:, id:)
    in Solid::Failure(type, value) then Failure(type, **value)
    in Solid::Success(task_list:)
      task_list.update!(name:)

      Success(:task_list_updated, task_list:)
    end
  end
end
