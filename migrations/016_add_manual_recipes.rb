
Sequel.migration do
  change do
    alter_table :recipes do
      add_column :is_manual, TrueClass, default: false
      add_column :instructions, String, text: true
    end
  end
end
