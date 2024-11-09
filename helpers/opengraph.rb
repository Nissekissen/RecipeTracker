require 'rest-client'
require 'nokogiri'
require 'dotenv/load'

module OGParser
  def get_opengraph_data(url)
    response = RestClient::Request.execute(
      {
        method: :get,
        url: url,
        timeout: 5
      }
    )
    
    parsed_data = Nokogiri::HTML.parse(response.body)

    metatags = parsed_data.css('meta')
    
    title = nil
    image = nil
    description = nil
    site = nil

    metatags.each do |tag|
      title = get_property(tag, 'og:title') unless get_property(tag, 'og:title').nil?
      image = get_property(tag, 'og:image') unless get_property(tag, 'og:image').nil?
      description = get_property(tag, 'og:description') unless get_property(tag, 'og:description').nil?
      site = get_property(tag, 'og:site_name') unless get_property(tag, 'og:site_name').nil?
    end

    return title, image, description, site
  end

  def get_property(tag, name)
    if tag['name'] == name || tag['property'] == name
      return tag['content']
    end

    return nil
  end

  def get_ingredients(url)
    response = RestClient::Request.execute(
      {
        method: :get,
        url: 'https://api.spoonacular.com/recipes/extract?url=' + url + '&apiKey=' + ENV['SPOONACULAR_TOKEN'],
        timeout: 5
      }
    )


    return JSON.parse(response.body)['extendedIngredients'].map { |ingredient| ingredient['original']}

  end
end