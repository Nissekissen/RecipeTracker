require 'sinatra/namespace'

class MyApp < Sinatra::Application
  
  namespace '/groups' do

    get '/new' do 
      haml :'groups/new'
    end

    get '/:id' do | id |
      # get group info
      @group = Group.where(id: id).first
      if @group.nil?
        halt 404, 'Group not found'
      end

      haml :'groups/show'
    end

    get '/:id/members' do | id |
      # get group members
      @group = Group.where(id: id).first
      if @group.nil?
        halt 404, 'Group not found'
      end

      @members = @group.users
      haml :'groups/members'
    end

    post '/:id/join' do | id |
      # join public group
    end

    

    get '/' do 
      # get all groups
      @groups = Group.all
      haml :'groups/index'
    end

    post '/' do
      # create new group
      
      # check if user is logged in
      if @user.nil?
        halt 401, 'You must be logged in to create a group'
      end

      # get group info from request
      name = params[:name]
      description = params[:description]
      is_private = params[:is_private] == 'true'

      if name.nil? || description.nil? || is_private.nil?
        halt 400, 'Missing required parameters'
      end

      # create new group
      group = Group.create(name: name, description: description, is_private: is_private)

      # add user to group
      @user.add_group(group)

      redirect "/groups/#{group.id}"
    end
  end

end