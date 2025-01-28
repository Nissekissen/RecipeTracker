require 'rest-client'
require 'nokogiri'
require 'dotenv/load'

module OGParser
  def get_property(tag, name)
    if tag['name'] == name || tag['property'] == name
      return tag['content']
    end

    return nil
  end

  def get_description(url)
    # omagah bullshit api doesn't give the original description
    # enter opengraph

    response = RestClient::Request.execute(
      {
        method: :get,
        url: url,
        timeout: 5
      }
    )

    parsed_data = Nokogiri::HTML.parse(response.body)

    metatags = parsed_data.css('meta')

    description = nil

    metatags.each do |tag|
      description = get_property(tag, 'description') unless get_property(tag, 'description').nil?
    end

    return description
  end

  def get_all_tags(data)
    # the data is json parsed api response
    # get the tags from 'cuisines', maybe we expand later

    data['cuisines']
  end

  def get_recipe_data(url)
    response = RestClient::Request.execute(
      {
        method: :get,
        url: 'https://api.spoonacular.com/recipes/extract?url=' + url + '&apiKey=' + ENV['SPOONACULAR_TOKEN'] + '&analyze=true',
        timeout: 5
      }
    )

    parsed_data = JSON.parse(response.body)

    title = parsed_data['title']
    image = parsed_data['image']
    time = parsed_data['readyInMinutes']
    servings = parsed_data['servings']
    ingredients = parsed_data['extendedIngredients'].map { |i| i['original'] }
    description = get_description(url)
    tags = get_all_tags(parsed_data)
    site = parsed_data['sourceName']

    return {
      title: title,
      image: image,
      time: time,
      servings: servings,
      ingredients: ingredients,
      description: description,
      tags: tags,
      site: site
    }

  end
end