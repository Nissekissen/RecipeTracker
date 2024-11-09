

Sequel.migration do
  change do
    create_table :ingredients do
      primary_key :id
      foreign_key :recipe_id, :recipes, null: false, on_delete: :cascade
      String :name, null: false
    end
  end
end