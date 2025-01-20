require_relative '../helpers/search'

Sequel.migration do
  change do
    create_table :ingredients do
      primary_key :id
      foreign_key :recipe_id, :recipes, null: false, on_delete: :cascade
      String :name, null: false
    end

    # create the full text search table
    Search.setup_search_table
  end
end