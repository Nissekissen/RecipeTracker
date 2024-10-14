require 'sqlite3'

class Seeder

  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.migrate!
    create_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS recipes')
  end

  def self.create_tables
    db.execute('CREATE TABLE IF NOT EXISTS recipes (
                id INTEGER PRIMARY KEY,
                name TEXT,
                image_url TEXT,
                url TEXT,
                created_by TEXT FOREIGN KEY,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)')
    db.execute('CREATE TABLE IF NOT EXISTS users (
                id TEXT PRIMARY KEY,
                name TEXT,
                email TEXT)')
  end

  def self.populate_tables

  end

  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/recipes.sqlite')
    @db.results_as_hash = true
    @db
  end
end