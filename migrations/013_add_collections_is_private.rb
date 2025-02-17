
Sequel.migration do
  change do
    alter_table :collections do
      add_column :is_private, TrueClass, default: false
    end
  end
end