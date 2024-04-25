class CreateSolidProcessEventLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_process_event_logs do |t|
      t.string :root_name, null: false, index: true
      t.string :trace_id, index: true
      t.integer :version, null: false
      t.integer :duration, null: false, index: true
      t.json :ids, null: false, default: {}
      t.json :records, null: false, default: []
      t.datetime :created_at, null: false, index: true
    end
  end
end
