
class Recipe
  attr_accessor :id, :name, :image_url, :url, :instructions

  def initialize(name, image_url, url, id = nil)
    @name = name
    @image_url = image_url
    @url = url
    @id = id
  end

  def self.from_hash(row)
    Recipe.new(row['name'], row['image_url'], row['url'], row['id'])
  end

  def self.all db
    db.execute('SELECT * FROM recipes').map do |row|
      Recipe.from_hash(row)  
    end
  end

  def self.find_by_name(db, name)
    db.execute('SELECT * FROM recipes WHERE name = ?', name).map do |row|
      Recipe.from_hash(row)  
    end
  end

  def self.find(db, id)
    row = db.execute('SELECT * FROM recipes WHERE id = ?', id).first
    if row
      Recipe.from_hash(row)
    else
      nil
    end
  end

  def save db
    if @id
      db.execute('UPDATE recipes SET name = ?, image_url = ?, url = ?, WHERE id = ?', @name, @image_url, @url, @id)
    else
      db.execute('INSERT INTO recipes (name, image_url, url) VALUES (?, ?, ?)', @name, @image_url, @url)
      @id = db.execute('SELECT last_insert_rowid()').first['last_insert_rowid()']
    end
  end

  def delete db
    db.execute('DELETE FROM recipes WHERE id = ?', @id)
  end
end