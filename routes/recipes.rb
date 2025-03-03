require 'json'
require 'sinatra/namespace'

class MyApp < Sinatra::Application

  get '/recipes/not-found' do
    haml :'recipes/not_found'
  end

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

  get '/recipes/manual' do
    haml :'recipes/manual'
  end

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

    SavedRecipe.create(user_id: @user.id, recipe_id: recipe.id, created_at: Time.now.to_i, collection_id: collection.id)

    redirect "/recipes/#{recipe.id}"

  end

  get '/recipes/:id' do | id |
    @recipe = Recipe[id]
    if @recipe.nil?
      status 404
      redirect '/recipes/not-found'
    end

    @comments = []

    haml :'recipes/show'
  end

  get '/recipes' do
    @recipes = Recipe.all

    # get the user collections and saved recipes
    if @user.nil?
      halt haml :'recipes/index'
    end

    # user_groups = @user.groups

    # get all collections where the user is the owner or a member of the group that owns it
    @collections = Collection.where(owner_id: @user.id).or(
      group_id: @user.groups.map(&:id)
    ).all

    p @collections

    haml :'recipes/index'
  end
  

  # before '/api/v1/*' do
  #   if @user.nil?
  #     halt 401, 'Not logged in'
  #   end
  # end

  namespace '/api/v1' do

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

      group_id = nil
      if saved_recipe.nil?

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

    get '/recipes/check' do
      # check if a recipe is valid or not by using the helper function
      url = params['url']
      
      halt 401 if @user.nil?
      halt 400 if url.nil?

      recipe = Recipe.where(url: url).first
      return {valid: true}.to_json if !recipe.nil?

      return {valid: is_valid_recipe_with_ai(url)}.to_json
    end

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

end