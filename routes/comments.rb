require 'sinatra/namespace'
require 'json'

class MyApp < Sinatra::Application
  namespace '/api/v1' do

    error 404 do
      content_type :json
      { error: 'not found' }.to_json
    end

    get '/recipes/:recipe_id/comments' do |recipe_id|
      group_id = params[:group_id]
      if group_id.nil? || group_id == 'public'
        group_id = nil
      end

      # If group_id is private, make sure the user is logged in and return haml :'comments/_notes', layout: false
      if group_id == 'private'
        halt 401 if @user.nil?
        @recipe = Recipe.where(id: recipe_id).first
        note = Comment.where(recipe_id: recipe_id, owner_id: @user.id, is_note: true).first
        content = note.nil? ? '' : note.content
        halt haml :'comments/_notes', layout: false, locals: { content: content }
        
      end

      # make sure the user is in the group
      if !group_id.nil?
        group = Group[group_id]
        p group_id
        halt 404 if group.nil?
        halt 403 if !group.users.include?(@user)
      end

      comments = Comment.where(recipe_id: recipe_id, group_id: group_id, is_note: false).all

      comments_by_parent = comments.group_by{ |comment| comment.parent_id }

      def build_comment_tree(parent_id, comments_by_parent)
        return [] unless comments_by_parent[parent_id]

        comments_by_parent[parent_id].map do |comment|
          
          comment[:children] = build_comment_tree(comment.id, comments_by_parent)
          comment
        end
      end

      root_comments = build_comment_tree(nil, comments_by_parent)

      haml :'comments/index', locals: { comments: root_comments }, layout: false
    end

    post '/recipes/:recipe_id/comments' do |recipe_id|
      # make sure user is logged in
      halt 401 if @user.nil?

      body = JSON.parse(request.body.read)

      group_id = body['group_id']
      p group_id
      if group_id.nil? || group_id == 'public'
        group_id = nil
      end


      parent_id = body['parent_id']

      content = body['content']
      halt 400, 'content is required' if content.nil?

      if group_id == "private"

        comment = Comment.where(recipe_id: recipe_id, group_id: nil, owner_id: @user.id, is_note: true).first



        if comment.nil?
        
          Comment.create(
            recipe_id: recipe_id,
            owner_id: @user.id,
            content: content,
            is_note: 1
          )
        else

          if content == ""
            comment.delete
            halt 200
          end

          comment.update(
            content: content
          )
          
        end

        halt 200
      end

      comment = Comment.create(
        recipe_id: recipe_id,
        owner_id: @user.id,
        parent_id: parent_id,
        group_id: group_id,
        content: content
      )

      p get_comment_depth(comment.id)

      # return the comment as html
      haml :'comments/_comment', locals: { comment: comment }, layout: false
    end

    delete '/recipes/:recipe_id/comments/:comment_id' do |recipe_id, comment_id|
      # make sure user is logged in
      halt 401 if @user.nil?

      comment = Comment.where(id: comment_id, owner_id: @user.id).first
      halt 404 if comment.nil?

      comment.delete

      200
    end
    
  end

  post '/comments' do
    # make sure user is logged in
    halt 401 if @user.nil?

    group_id = params[:group_id]
    if group_id.nil? || group_id == 'public'
      group_id = nil
    end

    recipe_id = params[:recipe_id]
    halt 400, 'recipe id is required' if recipe_id.nil?

    parent_id = params[:parent_id]

    content = params[:content]
    halt 400, 'content is required' if content.nil?

    Comment.create(
      recipe_id: recipe_id,
      owner_id: @user.id,
      parent_id: parent_id,
      group_id: group_id,
      content: content
    )

    redirect "/recipes/#{recipe_id}"
  end
end