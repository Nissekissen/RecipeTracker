require 'json'

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

  post '/recipes/:id/bookmark' do | id |
    # make sure user is logged in
    if @user.nil?
      halt 401, { :message => 'You must be logged in to save a recipe' }.to_json
    end

    recipe = Recipe.where(id: id).first
    if recipe.nil?
      halt 404, { :message => 'Recipe not found' }.to_json
    end

    # check if the recipe is already saved
    saved_recipe = SavedRecipe.where(user_id: @user.id, recipe_id: recipe.id).first
    if saved_recipe.nil?
      # create a new saved recipe
      saved_recipe = SavedRecipe.create(user_id: @user.id, recipe_id: recipe.id, created_at: Time.now.to_i)
    end

    redirect '/recipes'
  end

  get '/recipes/:id/bookmark' do | id |
    # make sure user is logged in
    if @user.nil?
      halt 401, 'You must be logged in to save a recipe'
    end

    recipe = Recipe.where(id: id).first
    if recipe.nil?
      halt 404, 'Recipe not found'
    end

    saved_recipe = SavedRecipe.where(user_id: @user.id, recipe_id: recipe.id).first
    return { bookmarked: !saved_recipe.nil? }.to_json
  end

  delete '/recipes/:id/bookmark' do | id |
    # make sure user is logged in
    if @user.nil?
      halt 401, 'You must be logged in to unsave a recipe'
    end

    recipe = Recipe.where(id: id).first
    if recipe.nil?
      halt 404, 'Recipe not found'
    end

    # check if the recipe is already saved
    saved_recipe = SavedRecipe.where(user_id: @user.id, recipe_id: recipe.id).first
    if !saved_recipe.nil?
      # delete the saved recipe
      saved_recipe.delete
    end

    redirect '/recipes'
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

    # Save the recipe for the user

    recipe = Recipe.where(url: params['url']).first
    SavedRecipe.create(user_id: @user.id, recipe_id: recipe.id, created_at: Time.now.to_i)

    # redirect to recipes
    redirect "/recipes"

  end

  get '/recipes' do
    @recipes = Recipe.all

    haml :'recipes/index'
  end

end