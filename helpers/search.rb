require 'sequel'

module Search

  def self.setup_search_table
    DB.run(<<~SQL)
      CREATE VIRTUAL TABLE IF NOT EXISTS recipe_search USING fts5(
        title,
        description,
        ingredients
      );
    SQL

    DB.run(<<~SQL)
      CREATE TRIGGER after_recipe_insert AFTER INSERT ON recipes
      BEGIN
        INSERT INTO recipe_search (rowid, title, description, ingredients)
        VALUES (NEW.id, NEW.title, NEW.description, '');
      END;
    SQL

    DB.run(<<~SQL)
      CREATE TRIGGER after_ingredient_insert AFTER INSERT ON ingredients
      BEGIN
        UPDATE recipe_search
        SET ingredients = (
          SELECT GROUP_CONCAT(name, ' ') FROM ingredients WHERE recipe_id = NEW.recipe_id
        )
        WHERE rowid = NEW.recipe_id;
      END;
    SQL

  end

  def self.sync_search_table
    DB.run("DELETE FROM recipe_search;")
    DB.run(<<~SQL)
      INSERT INTO recipe_search (rowid, title, description, ingredients)
      SELECT r.id, r.title, r.description, GROUP_CONCAT(i.name, ' ')
      FROM recipes r
      LEFT JOIN ingredients i ON r.id = i.recipe_id
      GROUP BY r.id;
    SQL
  end


end