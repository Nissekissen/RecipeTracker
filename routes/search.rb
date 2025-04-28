class MyApp < Sinatra::Application

  # @!group Routes

  # Performs a search for recipes based on a query.
  #
  # @param q [String] The search query.
  # @return [Haml] Rendered search results page.
  get '/search' do
    @query = params[:q]

    if @query.nil? || @query.empty?
      redirect '/'
    end

    @recipes = get_recipes_from_query(@query)

    haml :'search/results'
  end
  # @!endgroup
end