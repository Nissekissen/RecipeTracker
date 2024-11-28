
Sequel.migration do
  change do
    create_table :users do
      String :id, primary_key: true
      String :name, null: false
      String :email, null: false
      String :avatar_url
    end
  end
end