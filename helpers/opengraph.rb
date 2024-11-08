require 'rest-client'
require 'nokogiri'

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

    metatags.each do |tag|
      if tag['name'] == 'og:title' || tag['property'] == 'og:title'
        title = tag['content']
      end

      if tag['name'] == 'og:image' || tag['property'] == 'og:image'
        image = tag['content']
      end

      if tag['name'] == 'og:description' || tag['property'] == 'og:description'
        description = tag['content']
      end
    end

    return title, image, description
  end
end