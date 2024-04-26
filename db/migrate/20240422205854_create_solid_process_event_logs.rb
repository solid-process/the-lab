class CreateSolidProcessEventLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_process_event_logs do |t|
      t.string :category, index: true
      t.string :root_name, null: false, index: true
      t.string :trace_id, index: true
      t.integer :version, null: false
      t.integer :duration, null: false, index: true
      t.json :ids, null: false, default: {}
      t.json :records, null: false, default: []
      t.string :exception_class, null: true, index: true
      t.string :exception_message, null: true
      t.string :exception_backtrace, null: true
      t.datetime :created_at, null: false, index: true
    end
  end
end
