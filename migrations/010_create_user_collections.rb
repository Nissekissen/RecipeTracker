

Sequel.migration do
  change do
    create_table :user_collections do
      primary_key :id
      foreign_key :user_id, :users, null: false, type: String
      String :name, null: false
    end
  end
end