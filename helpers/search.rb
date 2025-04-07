require 'sequel'

module Search

  def get_recipes_from_query(query)
    keywords_dict = get_keywords_from_query(query)

    keywords = keywords_dict.values.flatten.uniq
    keywords = keywords.map { |keyword| keyword.downcase.strip }

    p keywords

    # search the tags and ingredients for the keywords.
    # Score the recipes based on how many tags and ingredients match the keywords.
    # Search the title for the keywords as well. Add that to the score if it matches.
    # Return the recipes in descending order of score. 
    # Do not use recipe_search table.

    # find matching ingredients
    ingredient_matches = Ingredient.where(name: keywords).all

    # find matching tags
    tag_matches = Tag.where(name: keywords).all

    p tag_matches

    weights = {
      :ingredient => 4,
      :tag => 2,
      :title => 5
    }

    # score the recipes based on the number of matches
    recipe_scores = {}
    ingredient_matches.each do |ingredient|
      recipe_id = ingredient.recipe_id
      recipe_scores[recipe_id] ||= 0
      recipe_scores[recipe_id] += weights[:ingredient]
    end

    tag_matches.each do |tag|
      recipe_id = tag.recipe_id
      recipe_scores[recipe_id] ||= 0
      recipe_scores[recipe_id] += weights[:tag]
    end

    # find matching recipes based on title
    title_matches = Recipe.where(Sequel.ilike(:title, "%#{query}%")).all
    title_matches.each do |recipe|
      recipe_id = recipe.id
      recipe_scores[recipe_id] ||= 0
      recipe_scores[recipe_id] += weights[:title]
    end

    # sort the recipes based on score
    @recipes = Recipe.where(id: recipe_scores.keys).all

    # remove recipes with score < 3
    # @recipes = @recipes.select { |recipe| recipe_scores[recipe.id] >= 3 }

    @recipes = @recipes.sort_by { |recipe| -recipe_scores[recipe.id] }
    
  end


end