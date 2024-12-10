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

      collection = Collection[collection_id]

      if collection.nil?
        halt 404
      end

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
      if @user.nil?
        halt 401
      end

      recipe = Recipe[id]

      if recipe.nil?
        halt 404
      end

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

  end

end