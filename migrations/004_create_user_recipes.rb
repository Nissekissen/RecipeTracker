
Sequel.migration do
  change do
    create_table :saved_recipes do
      primary_key :id
      foreign_key :user_id, :users, null: false, type: String
      foreign_key :recipe_id, :recipes, null: false
      foreign_key :collection_id, :user_collections, null: false
      Integer :created_at, null: false

      index [:user_id, :recipe_id], unique: true
    end
  end
end