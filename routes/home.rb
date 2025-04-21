require 'sinatra/content_for'
require 'sinatra/cookies'

class MyApp < Sinatra::Application
  # enable :sessions

  # A simple landing page. Currently it sends you to a log in page if you are not logged in, but I will probably change that.
  get '/' do
    halt 401 if @user.nil?
    @recipe_rows = []
    landing_page = generate_landing_page(@user.id)
    landing_page.each do |row|
      recipe_ids = row.get_recipes
      p recipe_ids
      next if recipe_ids.empty?

      @recipe_rows << { :name => row.name, :recipes => [] }

      # row.get_recipes returns an array of recipe ids. We need to convert them to Recipe objects
      recipe_ids.each do |recipe_id|
        recipe = Recipe[recipe_id]
        @recipe_rows.last[:recipes] << recipe unless recipe.nil?
      end
    end
    haml :home
  end

  not_found do
    haml :'errors/not_found'
  end
end