require 'sinatra/content_for'
require 'sinatra/cookies'

class MyApp < Sinatra::Application
  # enable :sessions

  get '/' do
    @recipes = Recipe.all
    @header_name = "Alla recept"
    if !@user.nil?
      @header_name = "Dina recept"
      @recipes = SavedRecipe.where(user_id: @user.id).all.map(&:recipe)
      # append recipes that are saved in a group that the user is a member of
      @user.groups.each do |group|
        new_arr = SavedRecipe.where(group_id: group.id).all.map(&:recipe)
        p @recipes
        @recipes = @recipes + new_arr
      end
      @recipes = @recipes.uniq
    end
    haml :home
  end

  not_found do
    haml :'errors/not_found'
  end
end