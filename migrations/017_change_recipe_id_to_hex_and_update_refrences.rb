require 'securerandom'

# Generate a unique hex ID
def generate_unique_hex_id(table)
  loop do
    hex_id = SecureRandom.hex(3).upcase # 6-digit hex
    break hex_id unless self[table].where(id: hex_id).any?
  end
end

Sequel.migration do 
    
  up do
    # Create a new recipes table with hex ID
    create_table(:recipes_new) do
      String :id, primary_key: true, size: 6
      String :title, null: false
      String :description, null: false
      String :image_url
      String :site_name
      String :url, null: false
      String :time
      String :servings
      String :difficulty
      TrueClass :is_manual, default: false
      String :instructions, text: true
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      Integer :old_id
    end

    # Migrate existing data and update references
    self[:recipes].each do |recipe|
      new_id = generate_unique_hex_id(:recipes_new)

      # Insert into the new recipes table
      self[:recipes_new].insert(
        id: new_id,
        title: recipe[:title],
        description: recipe[:description],
        image_url: recipe[:image_url],
        site_name: recipe[:site_name],
        url: recipe[:url],
        time: recipe[:time],
        servings: recipe[:servings],
        difficulty: recipe[:difficulty],
        is_manual: recipe[:is_manual],
        instructions: recipe[:instructions],
        created_at: recipe[:created_at],
        old_id: recipe[:id]
      )

      # Update references in saved_recipes
      self[:saved_recipes].where(recipe_id: recipe[:id]).update(recipe_id: new_id)

      # Update references in ingredients
      self[:ingredients].where(recipe_id: recipe[:id]).update(recipe_id: new_id)

      # Update references in tags
      self[:tags].where(recipe_id: recipe[:id]).update(recipe_id: new_id)

      # Update references in comments
      self[:comments].where(recipe_id: recipe[:id]).update(recipe_id: new_id)
    end

    # Update foreign key references in saved_recipes
    alter_table(:saved_recipes) do
      add_foreign_key :new_recipe_id, :recipes_new, type: String, size: 6
    end

    self[:saved_recipes].each do |saved_recipe|
      new_recipe_id = self[:recipes_new].where(old_id: saved_recipe[:recipe_id]).get(:id)
      self[:saved_recipes].where(id: saved_recipe[:id]).update(new_recipe_id: new_recipe_id)
    end

    alter_table(:saved_recipes) do
      drop_foreign_key :recipe_id
      rename_column :new_recipe_id, :recipe_id
    end

    # Update foreign key references in ingredients
    alter_table(:ingredients) do
      add_foreign_key :new_recipe_id, :recipes_new, type: String, size: 6
    end

    self[:ingredients].each do |ingredient|
      new_recipe_id = self[:recipes_new].where(old_id: ingredient[:recipe_id]).get(:id)
      self[:ingredients].where(id: ingredient[:id]).update(new_recipe_id: new_recipe_id)
    end

    alter_table(:ingredients) do
      drop_foreign_key :recipe_id
      rename_column :new_recipe_id, :recipe_id
    end

    # Update foreign key references in tags
    alter_table(:tags) do
      add_foreign_key :new_recipe_id, :recipes_new, type: String, size: 6
    end

    self[:tags].each do |tag|
      new_recipe_id = self[:recipes_new].where(old_id: tag[:recipe_id]).get(:id)
      self[:tags].where(id: tag[:id]).update(new_recipe_id: new_recipe_id)
    end

    alter_table(:tags) do
      drop_foreign_key :recipe_id
      rename_column :new_recipe_id, :recipe_id
    end

    # Update foreign key references in comments
    alter_table(:comments) do
      add_foreign_key :new_recipe_id, :recipes_new, type: String, size: 6
    end

    self[:comments].each do |comment|
      new_recipe_id = self[:recipes_new].where(old_id: comment[:recipe_id]).get(:id)
      self[:comments].where(id: comment[:id]).update(new_recipe_id: new_recipe_id)
    end

    alter_table(:comments) do
      drop_foreign_key :recipe_id
      rename_column :new_recipe_id, :recipe_id
    end


    
    # Drop the old table and rename the new one
    drop_table(:recipes)
    rename_table(:recipes_new, :recipes)
  end

  down do
    # Roll back: Restore original recipes table with integer ID
    create_table(:recipes_old) do
      primary_key :id
      String :title, null: false
      String :description, null: false
      String :image_url
      String :site_name
      String :url, null: false
      String :time
      String :servings
      String :difficulty
      TrueClass :is_manual, default: false
      String :instructions, text: true
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end

    # Copy data back, converting hex ID to an integer
    self[:recipes].each do |recipe|
      old_id = recipe[:id].hex

      self[:recipes_old].insert(
        id: old_id,
        title: recipe[:title],
        description: recipe[:description],
        image_url: recipe[:image_url],
        site_name: recipe[:site_name],
        url: recipe[:url],
        time: recipe[:time],
        servings: recipe[:servings],
        difficulty: recipe[:difficulty],
        is_manual: recipe[:is_manual],
        instructions: recipe[:instructions],
        created_at: recipe[:created_at],
        hex_id: recipe[:id]
      )

      
    end

    # Update references in saved_recipes

    alter_table(:saved_recipes) do
      add_foreign_key :new_recipe_id, :recipes_old
    end

    self[:saved_recipes].each do |saved_recipe|
      old_recipe_id = self[:recipes_old].where(hex_id: saved_recipe[:recipe_id]).get(:id)
      self[:saved_recipes].where(id: saved_recipe[:id]).update(new_recipe_id: old_recipe_id)
    end

    alter_table(:saved_recipes) do
      drop_foreign_key :recipe_id
      rename_column :new_recipe_id, :recipe_id
    end

    # Update references in ingredients
    alter_table(:ingredients) do
      add_foreign_key :new_recipe_id, :recipes_old
    end

    self[:ingredients].each do |ingredient|
      old_recipe_id = self[:recipes_old].where(hex_id: ingredient[:recipe_id]).get(:id)
      self[:ingredients].where(id: ingredient[:id]).update(new_recipe_id: old_recipe_id)
    end

    alter_table(:ingredients) do
      drop_foreign_key :recipe_id
      rename_column :new_recipe_id, :recipe_id
    end

    # Update references in tags
    alter_table(:tags) do
      add_foreign_key :new_recipe_id, :recipes_old
    end

    self[:tags].each do |tag|
      old_recipe_id = self[:recipes_old].where(hex_id: tag[:recipe_id]).get(:id)
      self[:tags].where(id: tag[:id]).update(new_recipe_id: old_recipe_id)
    end

    alter_table(:tags) do
      drop_foreign_key :recipe_id
      rename_column :new_recipe_id, :recipe_id
    end

    # Update references in comments
    alter_table(:comments) do
      add_foreign_key :new_recipe_id, :recipes_old
    end

    self[:comments].each do |comment|
      old_recipe_id = self[:recipes_old].where(hex_id: comment[:recipe_id]).get(:id)
      self[:comments].where(id: comment[:id]).update(new_recipe_id: old_recipe_id)
    end

    alter_table(:comments) do
      drop_foreign_key :recipe_id
      rename_column :new_recipe_id, :recipe_id
    end


    drop_table(:recipes)
    rename_table(:recipes_old, :recipes)
  end


end
