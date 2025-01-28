 

Sequel.migration do
  change do
    create_table :recipes do
      primary_key :id
      String :title, null: false
      String :description, null: false
      String :image_url
      String :site_name
      String :url, null: false
      String :time
      String :servings
      String :difficulty
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end