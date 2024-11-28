
Sequel.migration do
  change do
    create_table :saved_recipes do
      primary_key :id
      foreign_key :user_id, :users, null: false, type: String
      foreign_key :recipe_id, :recipes, null: false
      Integer :created_at, null: false
      Integer :rating

      index [:user_id, :recipe_id], unique: true
    end
  end
end