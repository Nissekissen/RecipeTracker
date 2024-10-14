require 'json'

class MyApp < Sinatra::Application

  get '/recipes/new' do
    haml :'recipes/new'
  end

  get '/recipes/:id' do | id |
    @recipe = Recipe.find(db, id)
    if !@recipe
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
    title, image = get_title_and_image(params['url'])

    if !title || !image
      halt 400, 'url does not contain og:title and og:image'
    end

    # create a new recipe
    @recipe = Recipe.new(title, image, params['url'])

    # save the recipe
    @recipe.save(db)

    # redirect to recipes
    redirect "/recipes"

  end

  get '/recipes' do
    @recipes = Recipe.all(db)
    haml :'recipes/index'
  end

  get '/recipes/:id/delete' do | id |
    Recipe.find(db, id).delete(db)
    redirect '/recipes'
  end

end