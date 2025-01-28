require 'sinatra/namespace'

class MyApp < Sinatra::Application
  
  namespace '/groups' do

    get '/new' do 

      @part = 1

      haml :'groups/new'
    end

    get '/:id' do | id |
      # get group info
      @group = Group.where(id: id).first

      
      if @group.nil?
        halt 404, 'Group not found'
      end

      @is_member = @user.nil? ? false : @user.groups.include?(@group)
      
      if @group.is_private
        halt 404 if !@is_member
      end


      @tab = params["tab"] || "recipes"
      
      # @recipes = Recipe
      #   .join(:group_recipes, recipe_id: :id)
      #   .select(Sequel[:recipes][:id], :title, :description, :image_url, :url)
      #   .where(group_id: @group.id)
      #   .all
      @recipes = Recipe
        .join(:saved_recipes, recipe_id: :id)
        .select(Sequel[:recipes][:id], :title, :description, :image_url, :url, :site_name, :time, :servings, :difficulty)
        .where(group_id: @group.id)
        .group(:recipe_id).all
      @members = @group.users

      @collections = Collection.where(group_id: @group.id).all

      p @collections

      @member_amount = @members.length
      @is_member = @user.nil? ? false : @user.groups.include?(@group)

      @invites = @group.invites.map do | invite |
        owner_id = invite.owner_id
        owner = User.where(id: owner_id).first
        { :invite => invite, :owner => owner }
      end

      haml :'groups/show'
    end

    post '/:id/recipes' do | id |
      # make sure user is logged in and is a member of the group
      if @user.nil?
        halt 401, 'You must be logged in to add a recipe to a group'
      end

      group = Group.where(id: id).first

      if group.nil?
        halt 404, 'Group not found'
      end

      if !@user.groups.include?(group)
        halt 401, 'You must be a member of the group to add a recipe'
      end

      # get recipe info from request
      recipe_id = params[:recipe_id]

      if recipe_id.nil?
        halt 400, 'Missing required parameters'
      end

      # get recipe
      recipe = Recipe.where(id: recipe_id).first

      if recipe.nil?
        halt 404, 'Recipe not found'
      end

      # add recipe to group
      SavedRecipe.create(recipe_id: recipe.id, user_id: @user.id, group_id: group.id)

      redirect "/groups/#{group.id}"

    end

    get '/:id/members' do | id |
      # get group members
      @group = Group.where(id: id).first
      
      
      if @group.nil?
        halt 404, 'Group not found'
      end
      
      if @group.is_private
        if @user.nil? || !@user.groups.include?(@group)
          halt 401, 'You must be logged in to view this group'
        end
      end
      
      @members = @group.users
      haml :'groups/members'
    end

    post '/:id/join' do | id |
      # join public group

      # make sure user is logged in
      if @user.nil?
        halt 401, 'You must be logged in to join a group'
      end

      # get group
      group = Group.where(id: id).first

      if group.nil? || group.is_private
        halt 404, 'Group not found'
      end

      # add user to group
      @user.add_group(group)

      redirect "/groups/#{group.id}"
    end

    get '/:id/leave' do | id |
      # leave group

      # make sure user is logged in
      if @user.nil?
        halt 401, 'You must be logged in to leave a group'
      end

      # get group
      group = Group.where(id: id).first

      if group.nil?
        halt 404, 'Group not found'
      end

      if !@user.groups.include?(group)
        halt 400, 'You are not a member of this group'
      end

      # remove user from group
      @user.remove_group(group)

      redirect "/groups/#{group.id}"
    end

    get '/' do 
      # get all groups
      @groups = Group.all
      haml :'groups/index'
    end

    post '/' do
      # create new group

      if params[:part].nil?
        halt 400, 'Missing required parameters'
      end

      if params[:part] == "1"
        @name = params[:name]
        @description = params[:description]
        @is_private = params[:is_private] == 'on'

        if @name.nil? || @description.nil? || @is_private.nil?
          redirect '/groups/new'
        end

        @part = 2
        
        haml :'groups/new'
      elsif params[:part] == "2"
        name = params[:name]
        description = params[:description]
        is_private = params[:is_private] == 'on'
        image_url = params[:image]

        if name.nil? || description.nil? || is_private.nil?
          redirect '/groups/new'
        end

        # create new group

        @group = Group.create(name: name, description: description, is_private: is_private, image_url: image_url)

        # create group collection
        group_collection = Collection.create(owner_id: @user.id, group_id: @group.id, name: 'Favoriter')

        @user.add_group(@group)

        @part = 3

        haml :'groups/new'
      end
      
      # # check if user is logged in
      # if @user.nil?
      #   halt 401, 'You must be logged in to create a group'
      # end

      # # get group info from request
      # name = params[:name]
      # description = params[:description]
      # is_private = params[:is_private] == 'on'
      # image_url = params[:image]

      # if name.nil? || description.nil? || is_private.nil?
      #   halt 400, 'Missing required parameters'
      # end

      # # create new group
      # group = Group.create(name: name, description: description, is_private: is_private, image_url: image_url)
      
      # # create group collection
      # group_collection = Collection.create(owner_id: @user.id, group_id: group.id, name: 'Favoriter')

      # @user.add_group(group)
      # redirect "/groups/#{group.id}"
    end
  end


end