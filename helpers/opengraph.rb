require 'rest-client'
require 'nokogiri'
require 'dotenv/load'

module OGParser
  def parse_recipe_opengraph(url)
    html = RestClient.get(url).body
    doc = Nokogiri::HTML(html)

    og_data = {}

    doc.css('meta[property^="og:"]').each do |meta|
      property = meta['property'].sub('og:', '')
      content = meta['content']
      og_data[property] = content
    end

    recipe = {
      title: og_data['title'],
      description: og_data['description'],
      image: og_data['image'],
      site: og_data['site_name'],
      url: og_data['url'] || url
    }

    p recipe

    recipe
  end
end