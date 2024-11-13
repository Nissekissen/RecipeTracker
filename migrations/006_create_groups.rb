
Sequel.migration do
  change do
    create_table :groups do
      primary_key :id
      String :name, null: false
      String :description, null: false
      Boolean :is_private, null: false, default: false
      String :image_url
    end
  end
end