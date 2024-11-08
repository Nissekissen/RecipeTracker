
Sequel.migration do
  change do
    create_table :users do
      String primary_key :id
      String :name, null: false
      String :email, null: false
      String :avatar_url
    end
  end
end