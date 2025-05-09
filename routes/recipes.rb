require 'json'
require 'sinatra/namespace'

class MyApp < Sinatra::Application

  # @!group Routes

  # Displays a 404 error page for recipes.
  #
  # @return [Haml] Rendered 404 error page.
  get '/recipes/not-found' do
    haml :'recipes/not_found'
  end

  # Displays a form for creating a new recipe.
  #
  # @return [Haml] Rendered form for creating a new recipe.
  get '/recipes/new' do
    halt 401 if @user.nil?
    @collections = Collection.where(owner_id: @user.id).or(
      group_id: @user.groups.map(&:id)
    ).all

    # the users "favoriter" collection
    @default_collection = Collection.where(owner_id: @user.id, name: "Favoriter").first
    if @default_collection.nil?
      @default_collection = Collection.where(owner_id: @user).first
    end

    haml :'recipes/new'
  end
  
  # Displays a form for manually creating a new recipe.
  #
  # @return [Haml] Rendered form for manually creating a new recipe.
  get '/recipes/manual' do
    haml :'recipes/manual'
  end
  
  # Creates a new recipe (manual).
  #
  # @param title [String] The title of the recipe.
  # @param description [String] The description of the recipe.
  # @param image [String] The URL of the recipe image.
  # @param instructions [String] The instructions for the recipe.
  # @param time [String] The preparation time for the recipe.
  # @param servings [String] The number of servings the recipe makes.
  # @param ingredient [Array<String>] The ingredients for the recipe.
  # @param difficulty [String] The difficulty of the recipe (easy, medium, hard).
  # @return [Haml] Redirects to the newly created recipe page.
  post '/recipes' do
    # for manual recipes

    halt 401 if @user.nil?

    p params

    title = params['title']
    description = params['description']
    image = params['image']
    instructions = params['instructions']
    time = params['time']
    servings = params['servings']
    ingredients = params['ingredient']
    difficulty = params['difficulty']


    halt 400 if [title, description, instructions, time, servings, ingredients].any?(&:nil?)
    halt 400 if !['easy', 'medium', 'hard'].include?(difficulty)

    recipe = Recipe.create(
      title: title,
      description: description,
      image_url: image,
      site_name: "Manuellt recept",
      url: "Manuellt recept",
      time: time,
      servings: servings,
      difficulty: difficulty,
      is_manual: true,
      instructions: instructions
    )

    ingredients.each do |ingredient|
      Ingredient.create(recipe_id: recipe.id, name: ingredient)
    end

    collection = Collection.where(owner_id: @user.id, name: "Favoriter").first
    if collection.nil?
      collection = Collection.where(owner_id: @user.id).first
    end

    # create a recipe interaction
    RecipeInteraction.create(
      recipe_id: recipe.id,
      user_id: @user.id,
      interaction_type: 'save'
    )
    
    SavedRecipe.create(user_id: @user.id, recipe_id: recipe.id, created_at: Time.now.to_i, collection_id: collection.id)

    redirect "/recipes/#{recipe.id}"

  end

  # Shows a specific recipe.
  #
  # @param id [String] The ID of the recipe to show.
  # @return [Haml] Rendered recipe page.
  get '/recipes/:id' do | id |
    @recipe = Recipe[id]
    if @recipe.nil?
      status 404
      redirect '/recipes/not-found'
    end

    # create a recipe interaction
    if !@user.nil?
      RecipeInteraction.create(
        recipe_id: @recipe.id,
        user_id: @user.id,
        interaction_type: 'view'
      )
    end

    @comments = []

    haml :'recipes/show'
  end

  # @route GET /recipes/:id/external
  # Redirects the user to the external recipe page.
  #
  # @param id [String] The ID of the recipe.
  # @return [Haml] Redirects to the external recipe URL.
  get'/recipes/:id/external' do | id |
    @recipe = Recipe[id]
    halt 404 if @recipe.nil?

    # create a recipe interaction
    if !@user.nil?
      RecipeInteraction.create(
        recipe_id: @recipe.id,
        user_id: @user.id,
        interaction_type: 'view'
      )
    end

    redirect @recipe.url
  end
  

  namespace '/api/v1' do

    # Saves a recipe in the specified collection.
    #
    # @param id [String] The ID of the recipe to save.
    # @param collection_id [String] The ID of the collection to save the recipe to.
    # @return [JSON] Status 200 on success.
    get '/recipes/:id/save' do | id |

      halt 401 if @user.nil?
      
      # make sure the recipe exists
      recipe = Recipe[id]
      halt 404 if recipe.nil?
      
      collection_id = params['collection_id']

      halt 400 if collection_id.nil?

      # make sure the collection exists
      collection = Collection[collection_id]

      halt 404 if collection.nil?

      group = nil
      # if the collection has a group, save it to group
      if !collection.group_id.nil?
        # make sure the user is a member of the group
        if !@user.groups.any? { |group| group.id == collection.group_id }
          halt 403
        end

        group = Group[collection.group_id]

      end

      # If the saved recipe exists, delete it. Otherwise, create it
      saved_recipe = SavedRecipe.where(recipe_id: recipe.id, collection_id: collection.id).first

      if saved_recipe.nil?

        # create a recipe interaction
        RecipeInteraction.create(
          recipe_id: recipe.id,
          user_id: @user.id,
          interaction_type: 'save'
        )        
        # create a saved recipe
        saved_recipe = SavedRecipe.create(recipe_id: recipe.id, user_id: @user.id, collection_id: collection.id, created_at: Time.now.to_i, group_id: collection.group_id)
      else

        # make sure the user is the owner of the recipe or a group admin
        if !group.nil? && (!is_admin(@user, group) || saved_recipe.user_id != @user.id)
          halt 403
        end

        saved_recipe.delete

      end
      status 200
    end

    # Gets whether a recipe is saved by the user or not.
    #
    # @param id [String] The ID of the recipe.
    # @return [JSON] JSON representation of whether the recipe is saved or not.
    get '/recipes/:id/saved' do | id |
      
      halt 401 if @user.nil?
      
      recipe = Recipe[id]
      
      halt 404 if recipe.nil?

      SavedRecipe.where(user_id: @user.id, recipe_id: recipe.id)

      # get all collections
      collections = Collection.where(owner_id: @user.id).or(
        group_id: @user.groups.map(&:id)
      ).all

      result = collections.map do |collection|

        saved_by_id = collection.saved_recipes.select { |saved_recipe| saved_recipe.recipe_id == recipe.id }.map(&:user_id).first

        if !saved_by_id.nil? && saved_by_id != @user.id
          saved_by = User[saved_by_id]
        end
        {
          collection_id: collection.id,
          saved: collection.saved_recipes.any? { |saved_recipe| saved_recipe.recipe_id == recipe.id },
          savedBy: saved_by.nil? ? nil : saved_by.name
        }
      end

      status 200
      body result.to_json

      
    end

    # Checks if a recipe is valid or not.
    #
    # @param url [String] The URL of the recipe to check.
    # @return [JSON] JSON representation of whether the recipe is valid or not.
    get '/recipes/check' do
      # check if a recipe is valid or not by using the helper function
      url = params['url']
      
      halt 401 if @user.nil?
      halt 400 if url.nil?

      recipe = Recipe.where(url: url).first
      
      return {valid: true}.to_json if !recipe.nil?

      return {valid: is_valid_recipe_with_ai(url)}.to_json
    end

    # Creates a new recipe.
    #
    # @param url [String] The URL of the recipe.
    # @param collection [String] The ID of the collection to save the recipe to.
    # @param alreadyVerified [Boolean] Whether the recipe has already been verified.
    # @return [JSON] Status 200 on success.
    post '/recipes' do


      if @user.nil?
        halt 401, {error: "Du måste vara inloggad för att spara recept"}.to_json
      end

      url = params['url']
      collection = params['collection']
      collection = Collection[collection] if !collection.nil?
      if collection.nil?
        collection = Collection.where(owner_id: @user.id, name: "Favoriter").first
        collection = Collection.first(owner_id: @user.id).first if collection.nil?
      end
      verified = params['alreadyVerified']

      if url.nil?
        halt 400, {error: "URL krävs"}.to_json
      end

      # if the recipe already exists, save it for the user
      recipe = Recipe.where(url: url).first

      if !recipe.nil?

        # Save the recipe for the user
        SavedRecipe.create(user_id: @user.id, recipe_id: recipe.id, created_at: Time.now.to_i, collection_id: collection.id)

        status 200
        halt
      end

      if verified.nil? || verified == false
        if !is_valid_recipe_with_ai(url)
          halt 400, {error: "Ogiltigt recept"}.to_json
        end
      end

      recipe_data = get_recipe_data_with_ai(url)

      title = recipe_data["title"]
      image = recipe_data["image"]
      description = recipe_data["description"]
      time = recipe_data["time"]
      servings = recipe_data["servings"]
      ingredients = recipe_data["ingredients"]
      site = recipe_data["site"]
      tags = recipe_data["tags"]
      difficutly = recipe_data["difficulty"]


      # create a new recipe
      recipe = Recipe.create(
        title: title,
        description: description,
        image_url: image,
        site_name: site,
        url: url,
        time: time,
        servings: servings,
        difficulty: difficutly
      )

      # ingredients
      ingredients.each do |ingredient|
        Ingredient.create(recipe_id: recipe.id, name: ingredient)
      end

      # tags
      tags.each do |tag|
        Tag.create(recipe_id: recipe.id, name: tag)
      end

      # Save the recipe for the user
      SavedRecipe.create(user_id: @user.id, recipe_id: recipe.id, created_at: Time.now.to_i, collection_id: collection.id)

      status 200
    end

    # Filters recipes by collection.
    #
    # @param group_id [String] The ID of the group to filter by.
    # @param collections [Array<String>] The IDs of the collections to filter by.
    # @return [Haml] Rendered list of filtered recipes.
    post '/recipes/filter' do 
      halt 401 if @user.nil?

      group_id = params['group_id']

      collection_ids = JSON.parse(request.body.read)['collections']
      recipes = nil

      if group_id.nil?
        recipes = SavedRecipe.where(collection_id: collection_ids).map(&:recipe)
      else
        recipes = SavedRecipe.where(collection_id: collection_ids, group_id: group_id).map(&:recipe)
      end

      # remove duplicates
      recipes = recipes.uniq
      
      haml :'recipes/_list', locals: { recipes: recipes }, layout: false
    end

  end
  # @!endgroup
end