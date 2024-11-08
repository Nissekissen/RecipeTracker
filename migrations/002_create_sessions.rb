
Sequel.migration do
  up do
    create_table :sessions do
      primary_key :id
      foreign_key :user_id, :users, null: false
      String :token, null: false
      Integer :expires_at, null: false
    end
  end
end