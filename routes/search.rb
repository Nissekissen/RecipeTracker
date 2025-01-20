

class MyApp < Sinatra::Application

  get '/search' do
    

    p is_valid_recipe_with_ai('https://www.arla.se/recept/pizza/')
    redirect '/recipes'

    # make sure user is logged in
    if @user.nil?
      halt 401, 'You must be logged in to search'
    end

    query = params[:q]

    if query.nil?
      halt 400, 'query is required'
    end

    # @recipes = DB[:recipe_search]
    #   .join(:recipes, id: :rowid) # Join recipe_search with recipes on rowid
    #   .where(Sequel.lit("recipe_search MATCH ?", query)) # Perform FTS search
    #   .select(
    #     Sequel[:recipes][:id].as(:recipe_id),             # Qualify columns
    #     Sequel[:recipes][:title].as(:recipe_title),       # Recipe title
    #     Sequel[:recipes][:description].as(:recipe_description), # Recipe description
    #     Sequel[:recipes][:image_url],                    # Add any other fields as needed
    #     Sequel[:recipes][:site_name]
    #   )
    #   .order(Sequel.lit("rank")) # Order by relevance (adjust based on FTS5 rank or other criteria)
    #   .all   # Fetch all results     

    # p @recipes



    haml :'search/results'
  end

end