
Sequel.migration do
  change do
    create_table :tags do
      primary_key :id
      foreign_key :recipe_id, :recipes, null: false
      String :name, null: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end