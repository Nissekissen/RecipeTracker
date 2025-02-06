
Sequel.migration do
  up do
    # create a temp table, copy the data, drop the old table, rename the temp table
    create_table(:saved_recipes_temp) do
      primary_key :id
      foreign_key :user_id, :users, null: false, type: String, on_delete: :cascade
      foreign_key :recipe_id, :recipes, null: false, on_delete: :cascade
      foreign_key :group_id, :groups, on_delete: :cascade
      Integer :rating
      foreign_key :collection_id, :collections, on_delete: :cascade
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end

    run "INSERT INTO saved_recipes_temp SELECT * FROM saved_recipes"

    drop_table(:saved_recipes)

    rename_table(:saved_recipes_temp, :saved_recipes)
  end

  down do
    # create a temp table, copy the data, drop the old table, rename the temp table
    create_table(:saved_recipes_temp) do
      primary_key :id
      foreign_key :user_id, :users, null: false, type: String
      foreign_key :recipe_id, :recipes, null: false
      foreign_key :group_id, :groups
      Integer :rating
      foreign_key :collection_id, :collections
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end

    run "INSERT INTO saved_recipes_temp SELECT * FROM saved_recipes"

    drop_table(:saved_recipes)

    rename_table(:saved_recipes_temp, :saved_recipes)
  end
end
