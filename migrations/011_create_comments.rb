
Sequel.migration do
  change do
    create_table :comments do
      primary_key :id
      foreign_key :recipe_id, :recipes, null: false
      foreign_key :owner_id, :users, null: false, type: String
      foreign_key :parent_id, :comments, on_delete: :cascade
      foreign_key :group_id, :groups
      String :content, null: false, text: true
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      Integer :is_note, default: 0
    end
  end
end
