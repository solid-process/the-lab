::ActiveAdmin.register ::Solid::Process::EventLogs::Record do
  actions :index, :show, :destroy

  scope :all
  scope :success, group: :status
  scope :failure, group: :status
  scope :error, group: :status

  filter :root_name
  filter :created_at
  filter :duration
  filter :trace_id
  filter :id

  index do
    selectable_column
    id_column
    column :category do |record|
      case record.category
      when "error" then status_tag("Error", class: "error")
      when "failure" then status_tag("Failure", class: "failure")
      else status_tag("Success", class: "success")
      end
    end
    column :root_name
    column :created_at
    column :duration
    column :trace_id
    actions
  end

  show do
    panel "Event Log" do
      attributes_table_for(resource) do
        row :category do |record|
          case record.category
          when "error" then status_tag("Error", class: "error")
          when "failure" then status_tag("Failure", class: "failure")
          else status_tag("Success", class: "success")
          end
        end
        row :root_name
        row :created_at
        row :duration
        row :trace_id
      end
    end

    if resource.error?
      panel "Exception" do
        attributes_table_for(resource) do
          row "class" do |record|
            record.exception_class
          end
          row "message" do |record|
            record.exception_message
          end
          row "backtrace" do |record|
            record.exception_backtrace.to_s.split(";").join("<br>").html_safe
          end
        end
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
