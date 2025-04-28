require 'sinatra/namespace'

class MyApp < Sinatra::Application
  
  namespace '/groups' do

    # Route for displaying the form to create a new group.
    get '/new' do 

      @part = 1

      haml :'groups/new'
    end

    # Route for viewing a specific group.
    # @param id [Integer] the id of the group
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

      @admin_hash = {}

      @members.each do | member |
        # update admin hash
        @admin_hash[member.id] = is_admin(member, @group)
      end

      p @admin_hash

      @collections = Collection.where(group_id: @group.id).all

      # p @collections

      @member_amount = @members.length
      @is_member = @user.nil? ? false : @user.groups.include?(@group)
      @is_admin = is_admin(@user, @group)
      @is_owner = @user.id == @group.owner_id

      @invite_token = params["invite_token"]

      @is_invited = false

      if !@invite_token.nil?
        @invite = Invite.where(token: @invite_token).first
        if !@invite.nil?
          @is_invited = true
        end
      end

      if @tab == "recipes"
        haml :'groups/show'
      elsif @tab == "members"
        haml :'groups/members'
      end

    end

    # Try to join a group.
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
    
    # get all groups
    get '/' do 
      @groups = Group.all
      haml :'groups/index'
    end

    # create new group. Multi-part form.
    post '/' do

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

        # make user group admin
        set_admin(@user, @group, true)

        @part = 3

        haml :'groups/new'
      end
    end
  end


end