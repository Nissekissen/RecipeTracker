require 'rest-client'
require 'nokogiri'

module OGParser
  def get_title_and_image(url)
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

    metatags.each do |tag|
      if tag['name'] == 'og:title' || tag['property'] == 'og:title'
        title = tag['content']
      end

      if tag['name'] == 'og:image' || tag['property'] == 'og:image'
        image = tag['content']
      end
    end

    return title, image
  end
end