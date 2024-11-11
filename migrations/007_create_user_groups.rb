
Sequel.migration do
  change do
    create_table :groups_users do
      primary_key :id
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      foreign_key :group_id, :groups, null: false, on_delete: :cascade
    end
  end
end