require 'json'
require 'sinatra/namespace'

class MyApp < Sinatra::Application

  get '/recipes/not-found' do
    haml :'recipes/not_found'
  end

  get '/recipes/new' do
    haml :'recipes/new'
  end

  get '/recipes/:id' do | id |
    @recipe = Recipe[id]
    if @recipe.nil?
      status 404
      redirect '/recipes/not-found'
    end

    haml :'recipes/show'
  end

  post '/recipes' do

    # make sure user is logged in
    if @user.nil?
      halt 401, 'You must be logged in to save a recipe'
    end

    # make sure all the headers are there
    if !params['url']
      halt 400, 'url is required'
    end

    # make sure the recipe doesn't already exist
    if Recipe.where(url: params['url']).first
      halt 400, 'Recipe already exists'
    end

    # get the title and image from the url
    recipe_data = get_recipe_data(params['url'])

    title = recipe_data[:title]
    image = recipe_data[:image]
    description = recipe_data[:description]
    time = recipe_data[:time]
    servings = recipe_data[:servings]
    ingredients = recipe_data[:ingredients]
    site = recipe_data[:site]

    # create a new recipe
    Recipe.create(
      title: title,
      description: description,
      image_url: image,
      site_name: site,
      url: params['url'],
      time: time,
      servings: servings,
    )

    # get the user collections
    collection = Collection.where(owner_id: @user.id, name: "Favoriter").first

    if collection.nil?
      collection = Collection.first(owner_id: @user.id).first
    end

    # Save the recipe for the user

    recipe = Recipe.where(url: params['url']).first
    saved_recipe = SavedRecipe.create(user_id: @user.id, recipe_id: recipe.id, created_at: Time.now.to_i, collection_id: collection.id)

    # redirect to recipes
    redirect "/recipes"

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

      # If the saved recipe exists, delete it. Otherwise, create it
      saved_recipe = SavedRecipe.where(recipe_id: recipe.id, user_id: @user.id, collection_id: collection.id).first

      group_id = nil
      if saved_recipe.nil?
        # if the collection has a group_id, make sure the user is a member of the group
        if !collection.group_id.nil? && !@user.groups.any? { |group| group.id == collection.group_id }
          halt 403
        end

        saved_recipe = SavedRecipe.create(recipe_id: recipe.id, user_id: @user.id, collection_id: collection.id, created_at: Time.now.to_i, group_id: collection.group_id)
      else
        saved_recipe.delete
      end
      status 200
    end

    get '/recipes/:id/saved' do | id |
      
      halt 401 if @user.nil?
      
      recipe = Recipe[id]
      
      halt 404 if recipe.nil?

      saved_recipes = SavedRecipe.where(user_id: @user.id, recipe_id: recipe.id)

      # get all collections
      collections = Collection.where(owner_id: @user.id).or(
        group_id: @user.groups.map(&:id)
      ).all

      result = collections.map do |collection|
        {
          collection_id: collection.id,
          saved: collection.saved_recipes.any? { |saved_recipe| saved_recipe.recipe_id == recipe.id }
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
        halt 401
      end

      url = params['url']
      verified = params['alreadyVerified']

      if url.nil?
        halt 400
      end

      # if the recipe already exists, save it for the user
      recipe = Recipe.where(url: url).first

      p recipe

      if !recipe.nil?
        # get the user collections
        collection = Collection.where(owner_id: @user.id, name: "Favoriter").first
        
        collection = Collection.first(owner_id: @user.id).first if collection.nil?

        # Save the recipe for the user
        saved_recipe = SavedRecipe.create(user_id: @user.id, recipe_id: recipe.id, created_at: Time.now.to_i, collection_id: collection.id)

        status 200
        halt
      end

      if verified.nil? || verified == false
        if !is_valid_recipe_with_ai(url)
          halt 400
        end
      end

      recipe_data = get_recipe_data_with_ai(url)

      p recipe_data

      title = recipe_data["title"]
      image = recipe_data["image_url"]
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

      # get the user collections
      collection = Collection.where(owner_id: @user.id, name: "Favoriter").first

      if collection.nil?
        collection = Collection.first(owner_id: @user.id).first
      end

      # Save the recipe for the user
      saved_recipe = SavedRecipe.create(user_id: @user.id, recipe_id: recipe.id, created_at: Time.now.to_i, collection_id: collection.id)

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
      
      haml :'recipes/_list', locals: { recipes: recipes }, layout: false
    end

  end

end