require 'sinatra/namespace'

class MyApp < Sinatra::Application

  namespace '/api/v1' do

    get '/collections' do
      content_type :json

      if @user.nil?
        halt 401, { error: 'You must be logged in to view your collections' }.to_json
      end

      collections = Collection.where(owner_id: @user.id).or(
        group_id: @user.groups.map(&:id)
      ).all

      groups = []

      collections.each do |collection|
        group = collection.group
        arr_group = groups.select { |g| g[:id] == (group.nil? ? nil : group.id) }.first

        if arr_group.nil?
          arr_group = { id: group.nil? ? nil : group.id, name: group.nil? ? 'Mina Samlingar' : group.name, collections: [] }
          groups << arr_group
        end

        arr_group[:collections] << { id: collection.id, name: collection.name, recipes: collection.saved_recipes.map { |r| { id: r.id } } }
      end

      groups.to_json


    end

    post '/collections' do

      if @user.nil?
        halt 401
      end

      if params['name'].nil?
        halt 400
      end

      group_id = params['group_id']

      if group_id.nil? || group_id == 'null'
        group_id = nil
      end

      collection = Collection.create(name: params['name'], owner_id: @user.id, group_id: group_id)

      status 201
      body({ :id => collection.id, :name => collection.name, :group_id => group_id, :recipes => []}.to_json)

    end

  end

end