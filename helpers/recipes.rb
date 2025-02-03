

module Recipes
  
  def shorten_description(text, max_length)
    if text.length > max_length
      text[0..max_length] + '...'
    else
      text
    end
  end

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

  def difficulty_display(difficulty)
    return 'Lätt' if difficulty == 'easy'
    return 'Medel' if difficulty == 'medium'
    return 'Svår' if difficulty == 'hard'
  end

  def time_ago_in_words(datetime)
    now = Time.now
    difference = now - datetime.to_time

    case difference
    when 0..60
      "just nu"
    when 61..3600
      minutes = (difference / 60).round
      "#{minutes} #{minutes == 1 ? 'minut' : 'minuter'} sedan"
    when 3601..86400
      hours = (difference / 3600).round
      "#{hours} #{hours == 1 ? 'timme' : 'timmar'} sedan"
    when 86401..604800
      days = (difference / 86400).round
      "#{days} #{days == 1 ? 'dag' : 'dagar'} sedan"
    when 604801..2592000
      weeks = (difference / 604800).round
      "#{weeks} #{weeks == 1 ? 'vecka' : 'veckor'} sedan"
    when 2592001..31536000
      months = (difference / 2592000).round
      "#{months} #{months == 1 ? 'månad' : 'månader'} sedan"
    else
      years = (difference / 31536000).round
      "#{years} #{years == 1 ? 'år' : 'år'} sedan"
    end
  end

  def get_comment_depth(comment_id)
    comment = Comment.where(id: comment_id).first
    return 0 if comment.nil?
    return 1 + get_comment_depth(comment.parent_id)
  end

end