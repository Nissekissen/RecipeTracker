require 'sinatra/namespace'

class MyApp < Sinatra::Application

  namespace '/api/v1' do

    get '/collections' do
      content_type :json

      user_id = params['user_id']

      if @user.nil?
        halt 401, { error: 'You must be logged in to view your collections' }.to_json
      end


      collections = []

      if user_id.nil?
        # current user
        collections = Collection.where(owner_id: @user.id).or(
          group_id: @user.groups.map(&:id)
        ).all
      else
        # other user
        collections = Collection.where(owner_id: user_id, is_private: false, group_id: nil).all
      end

      groups = []

      collections.each do |collection|
        group = collection.group
        arr_group = groups.select { |g| g[:id] == (group.nil? ? nil : group.id) }.first

        if arr_group.nil?
          arr_group = { id: group.nil? ? nil : group.id, name: group.nil? ? 'Mina Samlingar' : group.name, collections: [] }
          groups << arr_group
        end

        arr_group[:collections] << {
          id: collection.id,
          name: collection.name,
          recipes: collection.saved_recipes.map { |r| { id: r.id, saved_by: r.user_id } }
        }
      end

      groups.to_json


    end

    post '/collections' do

      if @user.nil?
        halt 401
      end

      body = JSON.parse(request.body.read)

      if params['name'].nil? && body['name'].nil?
        halt 400
      end

      name = params['name']
      name = body['name'] if name.nil?

      group_id = params['group_id']

      if group_id.nil? || group_id == 'null'
        group_id = nil
      end

      is_private = body['is_private']
      is_private = false if is_private.nil?

      collection = Collection.create(name: name, owner_id: @user.id, group_id: group_id, is_private: is_private)

      status 201
      body({ :id => collection.id, :name => collection.name, :group_id => group_id, :recipes => []}.to_json)

    end

    put '/collections/:id' do | id |
      halt 401 if @user.nil?

      body = JSON.parse(request.body.read)

      p body

      collection = Collection[id]
      if collection.nil?
        halt 404
      end

      if collection.owner_id != @user.id
        halt 403
      end

      if !body['name'].nil?
        collection.name = body['name']
      end

      if !body['is_private'].nil?
        collection.is_private = body['is_private']
      end

      collection.save

      status 204
    end

    delete '/collections/:id' do | id |
      halt 401 if @user.nil?

      collection = Collection[id]
      if collection.nil?
        halt 404
      end



      if collection.owner_id != @user.id || ( collection.group_id != nil && !@user.groups.map(&:id).include?(collection.group_id) )
        halt 403
      end

      collection.destroy

      status 204
    end

  end

end