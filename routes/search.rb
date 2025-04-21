

class MyApp < Sinatra::Application

  # simple search algorithm.
  get '/search' do
    
    @query = params[:q]

    if @query.nil? || @query.empty?
      redirect '/'
    end

    @recipes = get_recipes_from_query(@query)

    
    



    haml :'search/results'
  end

end