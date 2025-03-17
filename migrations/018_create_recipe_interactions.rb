
Sequel.migration do
  change do
    create_table :recipe_interactions do
      primary_key :id
      foreign_key :user_id, :users, null: false, type: String
      foreign_key :recipe_id, :recipes, null: false, type: String
      String :interaction_type, null: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
