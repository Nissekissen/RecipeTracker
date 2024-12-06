

Sequel.migration do
  change do
    create_table :group_collections do
      primary_key :id
      foreign_key :group_id, :groups, null: false
      String :name, null: false
    end
  end
end