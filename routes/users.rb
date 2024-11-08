
class MyApp < Sinatra::Application

  get '/profile/:id' do | id |
    @profile = User[id]
    if !@profile
      halt 404, 'Profile not found'
    end

    if !@user.nil? && @profile.id == @user.id
      @is_owner = true
    end

    @saved_recipes = Recipe.join(:saved_recipes, recipe_id: :id).select(Sequel[:recipes][:id], :title, :description, :image_url, :url).where(user_id: @profile.id).all

    p Recipe.join(:saved_recipes, recipe_id: :id).select(:"recipe.id", :title, :description, :image_url, :url).where(user_id: @profile.id).sql

    p @saved_recipes

    haml :'profile/show'
  end
end