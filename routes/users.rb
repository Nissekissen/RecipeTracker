
class MyApp < Sinatra::Application

  get '/profile/:id' do | id |
    @profile = User[id]
    if !@profile
      halt 404, 'Profile not found'
    end

    if !@user.nil? && @profile.id == @user.id
      @is_owner = true
    end

    @saved_recipes = Recipe.join(:saved_recipes, recipe_id: :id).where(user_id: @profile.id).all

    p @saved_recipes

    haml :'profile/show'
  end
end