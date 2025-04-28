module Recipes
  
  # Shortens a description to a maximum length.
  #
  # @param text [String] The description to shorten.
  # @param max_length [Integer] The maximum length of the shortened description.
  # @return [String] The shortened description.
  def shorten_description(text, max_length)
    if text.length > max_length
      text[0..max_length] + '...'
    else
      text
    end
  end

  # Checks if a recipe is saved by the user or by a group the user is in.
  #
  # @param recipe_id [Integer] The ID of the recipe.
  # @return [Boolean] True if the recipe is saved, false otherwise.
  def is_saved?(recipe_id)
    # if the recipe is saved directly by the user, or if the user is in a group where the recipe is saved.

    return false if @user.nil?  

    # for the user
    saved_recipe = SavedRecipe.where(user_id: @user.id, recipe_id: recipe_id).first

    return true if !saved_recipe.nil?

    # for groups
    groups = @user.groups

    groups.each do |group|
      saved_recipe = SavedRecipe.where(group_id: group.id, recipe_id: recipe_id).first
      return true if !saved_recipe.nil?
    end

    return false
    
  end

  # Displays the difficulty of a recipe in Swedish.
  #
  # @param difficulty [String] The difficulty of the recipe (easy, medium, or hard).
  # @return [String] The difficulty of the recipe in Swedish.
  def difficulty_display(difficulty)
    return 'Lätt' if difficulty == 'easy'
    return 'Medel' if difficulty == 'medium'
    return 'Svår' if difficulty == 'hard'
  end

  # Calculates the time ago in words from a datetime.
  #
  # @param datetime [DateTime] The datetime to calculate the time ago from.
  # @return [String] The time ago in words.
  def time_ago_in_words(datetime)
    time_ago = Time.now - datetime
  
    if time_ago < 60
      return 'mindre än en minut sedan'
    elsif time_ago < 3600
      minutes = (time_ago / 60).to_i
      return "#{minutes} minuter sedan"
    elsif time_ago < 86400
      hours = (time_ago / 3600).to_i
      return "#{hours} timmar sedan"
    elsif time_ago < 2592000
      days = (time_ago / 86400).to_i
      return "#{days} dagar sedan"
    elsif time_ago < 31536000
      months = (time_ago / 2592000).to_i
      return "#{months} månader sedan"
    else
      years = (time_ago / 31536000).to_i
      return "#{years} år sedan"
    end
  end

  # Gets the comment depth for a comment.
  #
  # @param comment_id [Integer] The ID of the comment.
  # @return [Integer] The comment depth.
  def get_comment_depth(comment_id)
    comment = Comment.find(comment_id)
    depth = 0
    while comment.parent_id
      comment = Comment.find(comment.parent_id)
      depth += 1
    end
    depth
  end
end