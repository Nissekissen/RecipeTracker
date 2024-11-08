 

Sequel.migration do
  change do
    create_table :recipes do
      primary_key :id
      String :title, null: false
      String :description, null: false
      String :image_url
      String :url, null: false
      Integer :created_at, null: false
    end
  end
end