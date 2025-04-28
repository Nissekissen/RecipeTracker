require 'sinatra/content_for'
require 'sinatra/cookies'

class MyApp < Sinatra::Application
  # enable :sessions

  # @!group Routes
  # Route for the landing page.
  #
  # @return [Haml] Rendered home page.
  get '/' do
    halt 401 if @user.nil?
    @recipe_rows = []
    landing_page = generate_landing_page(@user.id)
    landing_page.each do |row|
      recipe_ids = row.get_recipes
      p recipe_ids
      next if recipe_ids.empty?

      @recipe_rows << { :name => row.name, :recipes => [] }

      # Converts recipe ids to Recipe objects.
      recipe_ids.each do |recipe_id|
        recipe = Recipe[recipe_id]
        @recipe_rows.last[:recipes] << recipe unless recipe.nil?
      end
    end
    haml :home
  end

  # Route for handling 404 errors (page not found).
  #
  # @return [Haml] Rendered not_found error page.
  not_found do
    haml :'errors/not_found'
  end
  # @!endgroup
end