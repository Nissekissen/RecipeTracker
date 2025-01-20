

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

end