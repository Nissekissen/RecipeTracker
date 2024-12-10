
Sequel.migration do
  change do
    create_table :saved_recipes do
      primary_key :id
      foreign_key :user_id, :users, null: false, type: String
      foreign_key :recipe_id, :recipes, null: false
      foreign_key :group_id, :groups
      Integer :rating
      foreign_key :collection_id, :collections
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP

      # index [:user_id, :recipe_id], unique: true
    end
  end
end