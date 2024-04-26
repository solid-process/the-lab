::ActiveAdmin.register ::Solid::Process::EventLogs::Record do
  actions :index, :show, :destroy

  permit_params :root_name, :trace_id, :version, :duration, :ids, :records

  filter :root_name
  filter :created_at
  filter :duration
  filter :trace_id
  filter :id

  index do
    selectable_column
    id_column
    column :root_name
    column :created_at
    column :duration
    column :trace_id
    actions
  end

  show do
    panel "Event Log" do
      attributes_table_for(resource) do
        row :root_name
        row :created_at
        row :duration
        row :trace_id
      end
    end

    panel "Records" do
      attributes_table_for(resource) do
        row "Serialized" do |record|
          rows = record.raw_records.map.with_index do |raw_record, index|
            "<tr><th>#{index}</th><td>#{raw_record.to_json}</td></tr>"
          end

          "<table>#{rows.join("\n")}</table>".html_safe
        end
        row :ids do |record|
          rows = record.ids.map { |key, value| "<tr><th>#{key}</th><td>#{value.to_json}</td></tr>" }

          "<table>#{rows.join("\n")}</table>".html_safe
        end
        row :version
      end
    end
  end
end
