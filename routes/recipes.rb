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

    # redirect to the recipe url
    redirect @recipe.url
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

    # get the title and image from the url
    title, image, description, site = get_opengraph_data(params['url'])


    if title.nil? || image.nil? || description.nil?
      halt 400
    end

    # create a new recipe
    Recipe.create(title: title, image_url: image, url: params['url'], description: description, created_at: Time.now.to_i, site_name: site)

    get_ingredients(params['url']).each do |ingredient|
      Ingredient.create(name: ingredient, recipe_id: Recipe.where(url: params['url']).first.id)
    end

    # get the user collections
    collection = UserCollection.where(user_id: @user.id, name: "Favoriter").first

    if collection.nil?
      collection = UserCollection.first(user_id: @user.id).first
    end

    # Save the recipe for the user

    recipe = Recipe.where(url: params['url']).first
    SavedRecipe.create(user_id: @user.id, recipe_id: recipe.id, created_at: Time.now.to_i, collection_id: collection.id)

    # redirect to recipes
    redirect "/recipes"

  end

  get '/recipes' do
    @recipes = Recipe.all

    # get the user collections and saved recipes
    if @user.nil?
      halt haml :'recipes/index'
      p "pluh"
    end


    db_collections = UserCollection.where(user_id: @user.id)
    @collections = []

    @saved_recipes = SavedRecipe.where(user_id: @user.id)



    # create an array of collections with the recipes in them
    db_collections.each do |collection|
      @collections << {collection: collection, recipes: []}
    end

    @saved_recipes.each do |saved_recipe|
      @collections.each do |collection|
        if collection[:collection].id == saved_recipe.collection_id
          collection[:recipes] << Recipe[saved_recipe.recipe_id]
        end
      end
    end

    haml :'recipes/index'
  end
  

  # before '/api/v1/*' do
  #   if @user.nil?
  #     halt 401, 'Not logged in'
  #   end
  # end

  namespace '/api/v1' do

    get '/recipes/:id/save' do | id |

      if @user.nil?
        halt 401
      end
      
      # make sure the recipe exists
      recipe = Recipe[id]
      if recipe.nil?
        halt 404
      end
      
      collection_id = params['collection_id']

      if collection_id.nil?
        halt 400
      end

      # make sure the collection exists

      collection = UserCollection[collection_id]

      if collection.nil?
        halt 404
      end

      # If the recipe is already saved in this collection, remove it completely.
      # If the recipe is saved in another collection, update the collection_id to the new one
      # If the recipe is not saved, save it

      saved_recipe = SavedRecipe.where(user_id: @user.id, recipe_id: recipe.id).first

      if saved_recipe.nil?
        # recipe is not saved, save it
        SavedRecipe.create(user_id: @user.id, recipe_id: recipe.id, collection_id: collection.id, created_at: Time.now.to_i)
      elsif saved_recipe.collection_id == collection.id
        # recipe is already saved in this collection, remove it
        SavedRecipe.where(user_id: @user.id, recipe_id: recipe.id).delete
      else
        # recipe is saved in another collection, update the collection_id
        SavedRecipe.where(user_id: @user.id, recipe_id: recipe.id).update(collection_id: collection.id)
      end

      status 200
    end

    get '/recipes/:id/saved' do | id |
      if @user.nil?
        halt 401
      end

      recipe = Recipe[id]

      if recipe.nil?
        halt 404
      end

      saved_recipes = SavedRecipe.where(user_id: @user.id, recipe_id: recipe.id)

      # get all collections
      collections = UserCollection.where(user_id: @user.id)

      result = collections.map do |collection|
        {
          collection_id: collection.id,
          saved: saved_recipes.any? { |saved_recipe| saved_recipe.collection_id == collection.id }
        }
      end

      status 200
      body result.to_json

      
    end

    post '/collections' do

      if @user.nil?
        halt 401
      end

      if params['name'].nil?
        halt 400
      end

      collection = UserCollection.create(name: params['name'], user_id: @user.id)

      status 201
      body({ :id => collection.id, :name => collection.name, :recipes => []}.to_json)

    end

  end

end