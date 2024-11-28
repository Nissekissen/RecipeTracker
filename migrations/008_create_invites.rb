

Sequel.migration do
  change do
    create_table :invites do
      primary_key :id
      foreign_key :group_id, :groups, null: false
      foreign_key :user_id, :users, type: String
      String :token, null: false
      Integer :uses_left, default: 1
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :expires_at, default: Sequel::CURRENT_TIMESTAMP + 7 * 24 * 60 * 60
    end
  end
end