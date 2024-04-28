# frozen_string_literal: true

class Account::Task::List::Finding < Solid::Process
  input do
    attribute :id, :integer
    attribute :account

    validates :id, id: true
    validates :account, instance_of: [Account, Account::Member]
  end

  def call(attributes)
    attributes => {id:, account:}

    task_list = account.task_lists&.find_by(id:)

    return Failure(:task_list_not_found) unless task_list

    return Failure(:inbox_cannot_be_edited) if task_list.inbox?

    Success(:task_list_found, task_list:)
  end
end
