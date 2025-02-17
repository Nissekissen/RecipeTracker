

Sequel.migration do
  change do
    create_table :collections do
      primary_key :id
      foreign_key :owner_id, :users, null: false, type: String
      foreign_key :group_id, :groups
      String :name, null: false
    end
  end
end