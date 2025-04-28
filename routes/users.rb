class MyApp < Sinatra::Application

  # @!group Routes

  # Shows a user profile.
  #
  # @param id [String] The ID of the user profile to show.
  # @return [Haml] Rendered user profile page.
  get '/profile/:id' do | id |
    @profile = User[id]

    if !@profile
      halt 404, 'Profile not found'
    end

    if !@user.nil? && @profile.id == @user.id
      @is_owner = true
    end

    @tab = params["tab"] || "bookmarks"

    # If tab = collections, show only if it is the owner of the profile
    if @tab == "collections" && !@is_owner
      @tab = "bookmarks"
    end

    if @tab == "bookmarks"
      is_private = [false]
      is_private << true if @is_owner
      
      # chatgpt clutch
      @bookmarks = Recipe.join(:saved_recipes, recipe_id: :id)
               .join(:collections, id: Sequel[:saved_recipes][:collection_id])
               .where(Sequel[:saved_recipes][:user_id] => @profile.id)
               .where(Sequel[:collections][:group_id] => nil)

      @bookmarks = @bookmarks.where(Sequel[:collections][:is_private] => false) unless @is_owner
      @bookmarks = @bookmarks.select_all(:recipes).all

      @collections = Collection.where(owner_id: @profile.id, group_id: nil, is_private: is_private).all
    elsif @tab == "groups"
      @groups = @profile.groups.filter { |group| !group.is_private || group.users.include?(@user) }
    elsif @tab == "collections"
      @collections = Collection.where(owner_id: @profile.id, group_id: nil).all
    end

    haml :'profile/show'
  end

  # Redirects to the user's bookmarks tab.
  #
  # @param id [String] The ID of the user.
  # @return [Haml] Redirects to the bookmarks tab on the user's profile.
  get '/profile/:id/bookmarks' do | id |
    redirect "/profile/#{id}?tab=bookmarks"
  end

  # Redirects to the user's groups tab.
  #
  # @param id [String] The ID of the user.
  # @return [Haml] Redirects to the groups tab on the user's profile.
  get '/profile/:id/groups' do | id |
    redirect "/profile/#{id}?tab=groups"
  end

  # Redirects to the user's collections tab.
  #
  # @param id [String] The ID of the user.
  # @return [Haml] Redirects to the collections tab on the user's profile.
  get '/profile/:id/collections' do | id |
    redirect "/profile/#{id}?tab=collections"
  end
  # @!endgroup
end