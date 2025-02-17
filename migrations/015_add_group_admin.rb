
Sequel.migration do
  change do
    alter_table :groups_users do
      add_column :is_admin, TrueClass, default: false
    end
  end
end
