
class MyApp < Sinatra::Application

  get '/profile/:id' do | id |
    @profile = User[id]
    if !@profile
      halt 404, 'Profile not found'
    end

    if !@user.nil? && @profile.id == @user.id
      @is_owner = true
    end

    @tab = params["tab"] || "bookmarks"

    if @tab == "bookmarks"
      @bookmarks = Recipe.join(:saved_recipes, recipe_id: :id).select(Sequel[:recipes][:id], :title, :description, :image_url, :url).where(user_id: @profile.id).all
    elsif @tab == "groups"
      @groups = @profile.groups.filter { |group| !group.is_private || group.users.include?(@user) }
    end


    haml :'profile/show'
  end

  get '/profile/:id/bookmarks' do | id |
    redirect "/profile/#{id}?tab=bookmarks"
  end

  get '/profile/:id/groups' do | id |
    redirect "/profile/#{id}?tab=groups"
  end
end