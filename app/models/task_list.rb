# frozen_string_literal: true

class TaskList < ApplicationRecord
  belongs_to :account

  has_many :task_items, dependent: :destroy, class_name: "TaskItem"

  scope :inbox, -> { where(inbox: true) }
end
