

module Recommendation

  class RecommendationRow
    
    attr_accessor :name, :recipes_method
    attr_reader :recipes

    def initialize(name)
      @name = name

      self
    end

    def set_method method
      @recipes_method = method

      self
    end

    def get_recipes
      return nil if @recipes_method.nil?
      @recipes = @recipes_method.call
    end
  end
  
  def recommended_recipes(user_id)
    user_interactions = RecipeInteraction
      .where(user_id: user_id)
      .group_and_count(:recipe_id, :interaction_type)
      .all

    weights = { "save" => 3, "view" => 1, "comment" => 2 }
    recipe_scores = Hash.new(0)

    user_interactions.each do |interaction|
      recipe_scores[interaction[:recipe_id]] += weights[interaction[:interaction_type]] * interaction[:count]
    end

    similar_users = RecipeInteraction
      .where(recipe_id: recipe_scores.keys)
      .exclude(user_id: user_id)
      .select_map(:user_id)
      .uniq
    
    recommended_recipe_ids = []

    if similar_users.any?
      # Get recipes from similar users
      recommended_recipe_ids = RecipeInteraction
        .where(user_id: similar_users)
        .exclude(recipe_id: recipe_scores.keys)
        .group_by(:recipe_id)
        .order(Sequel.desc(Sequel.function(:COUNT, :id)))
        .limit(10)
        .select_map(:recipe_id)
    
    else
      # Fallback: Get trending recipes if no similar users exist
      recommended_recipe_ids = RecipeInteraction
        .group_by(:recipe_id)
        .order(Sequel.desc(Sequel.function(:COUNT, :id)))
        .limit(10)
        .select_map(:recipe_id)
    end

    top_user_recipes = recipe_scores.keys.take(5)
    similar_recipe_ids = []

    unless top_user_recipes.empty?
      similar_recipe_ids = Recipe
        .join(:tags, recipe_id: :id)
        .where(name: MyApp::DB[:tags].where(recipe_id: top_user_recipes).select(:name))
        .exclude(Sequel[:recipes][:id] => top_user_recipes)
        .group_by(Sequel[:recipes][:id])
        .order(Sequel.desc(Sequel.function(:COUNT, Sequel[:tags][:name])))
        .limit(10)
        .select_map(Sequel[:recipes][:id])
    end

    # if still empty, fallback to random recipes
    if recommended_recipe_ids.empty? && similar_recipe_ids.empty?
      recommended_recipe_ids = Recipe
        .order(Sequel.lit('RANDOM()'))
        .limit(10)
        .select_map(:id)
    end

    (recommended_recipe_ids + similar_recipe_ids).uniq.first(5)
  end

  def previously_saved_recipes(user_id)
    SavedRecipe
      .join(:recipes, id: :recipe_id)
      .where(user_id: user_id)
      .order(Sequel.desc(Sequel[:saved_recipes][:created_at]))
      .limit(5)
      .distinct
      .select_map(:recipe_id)
  end

  def recipes_from_groups(user_id)
    
  end

  def group_recommendations(user_id)
    
  end

  def trending_recipes
    
  end

  def seasonal_recipes
    
  end
  
  def time_based_variation
    hour = Time.now.hour
    if hour < 9
      RecommendationRow.new("Frukostar").set_method(-> { breakfast_recipes })
    elsif hour < 12
      RecommendationRow.new("Lyxiga bruncher").set_method(-> { brunch_recipes })
    elsif hour < 16
      RecommendationRow.new("Lyxiga luncher").set_method(-> { lunch_recipes })
    else
      RecommendationRow.new("Lyxiga middagar").set_method(-> { dinner_recipes })
    end
  end

  def breakfast_recipes
    
    breakfast_recipe_ids = Tag
      .join(:recipes, id: :recipe_id)
      .where(name: "breakfast")
      .limit(10)
      .select_map(:recipe_id)

    return [] if breakfast_recipe_ids.count < 5

    breakfast_recipe_ids
  end

  def brunch_recipes

    brunch_recipe_ids = Tag
      .join(:recipes, id: :recipe_id)
      .where(name: "brunch")
      .limit(10)
      .select_map(:recipe_id)

    return [] if brunch_recipe_ids.count < 5

    brunch_recipe_ids
  end

  def lunch_recipes
    
    lunch_recipe_ids = Tag
      .join(:recipes, id: :recipe_id)
      .where(name: "lunch")
      .limit(10)
      .select_map(:recipe_id)

    return [] if lunch_recipe_ids.count < 5

    lunch_recipe_ids
  end

  def dinner_recipes
    
    dinner_recipe_ids = Tag
      .join(:recipes, id: :recipe_id)
      .where(name: "dinner")
      .select(:recipe_id)
      .limit(10)
      .all

    return [] if dinner_recipe_ids.count < 5

    dinner_recipe_ids
  end
  
  def generate_landing_page(user_id)
    selected_recipes = Set.new

    available_rows = [
      RecommendationRow.new("Rekommenderade recept").set_method(-> { recommended_recipes(user_id) }),
      RecommendationRow.new("Dina senaste sparade").set_method(-> { previously_saved_recipes(user_id) }),
      # RecommendationRow.new("Recept från grupper").set_method(-> { recipes_from_groups(user_id) }),
      # RecommendationRow.new("Rekommenderade grupper").set_method(-> { group_recommendations(user_id) }),
      # RecommendationRow.new("Trendande recept").set_method(-> { trending_recipes }),
      # RecommendationRow.new("I säsong").set_method(-> { seasonal_recipes }),
    ]

    # Select 3 random rows
    selected_rows = available_rows.sample(3)
    
    # Add time-based variation
    selected_rows << time_based_variation


    # random order
    selected_rows.shuffle
  end
end