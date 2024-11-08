require 'json'

class MyApp < Sinatra::Application

  get '/recipes/new' do
    haml :'recipes/new'
  end

  get '/recipes/:id' do | id |
    @recipe = Recipe[id]
    if @recipe.nil?
      halt 404, 'Recipe not found'
    end

    # redirect to the recipe url
    redirect @recipe.url
  end


  post '/recipes' do
    # make sure all the headers are there
    if !params['url']
      halt 400, 'url is required'
    end

    # get the title and image from the url
    title, image, description = get_opengraph_data(params['url'])

    if !title || !image || !description
      halt 400, 'url does not contain og:title, og:image and og:description'
    end

    # create a new recipe
    Recipe.create(title: title, image_url: image, url: params['url'], description: description, created_at: Time.now.to_i)

    # redirect to recipes
    redirect "/recipes"

  end

  get '/recipes' do
    @recipes = Recipe.all
    haml :'recipes/index'
  end

  get '/recipes/:id/delete' do | id |
    recipe = Recipe.where(id: id).first
    recipe.delete
    redirect '/recipes'
  end

end