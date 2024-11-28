

Sequel.migration do
  change do
    create_table(:group_recipes) do
      primary_key :id
      foreign_key :group_id, :groups, null: false
      foreign_key :recipe_id, :recipes, null: false
      foreign_key :user_id, :users, null: false, type: String

      index [:group_id, :recipe_id], unique: true
    end
  end
end