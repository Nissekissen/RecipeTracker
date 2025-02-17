
Sequel.migration do
  change do
    alter_table :comments do
      add_column :is_note, TrueClass, default: false
    end
  end
end