::ActiveAdmin.register ::Solid::Process::EventLogs::Record do
  actions :index, :show, :destroy

  permit_params :root_name, :trace_id, :version, :duration, :ids, :records

  actions :all, except: []

  filter :id
  filter :root_name
  filter :trace_id
  filter :duration
  filter :created_at

  index do
    selectable_column
    id_column
    column :root_name
    column :trace_id
    column :duration
    column :created_at
    actions
  end

  show do
    attributes_table_for(resource) do
      row :id
      row :root_name
      row :trace_id
      row :version
      row :duration
      row :ids
      row :records
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :root_name
      f.input :trace_id
      f.input :version
      f.input :duration
      f.input :ids
      f.input :records
    end
    f.actions
  end
end
