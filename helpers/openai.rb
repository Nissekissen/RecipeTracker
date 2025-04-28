require 'openai'
require 'open-uri'


module OpenAI
  # Returns the OpenAI client.
  #
  # @return [OpenAI::Client] The OpenAI client.
  def client
    return @client if !@client.nil?

    @client = OpenAI::Client.new(
      access_token: ENV['OPENAI_API_KEY'],
      log_errors: true
    )

    return @client
  end

  # Cleans HTML by removing script and style tags, HTML comments, and unnecessary attributes.
  #
  # @param html [String] The HTML to clean.
  # @return [String] The cleaned HTML.
  def clean_html(html)
    # Remove <script> and <style> tags with their contents
    html.gsub!(/<script.*?>.*?<\/script>/m, '')
    html.gsub!(/<style.*?>.*?<\/style>/m, '')
    
    # Remove HTML comments
    html.gsub!(/<!--.*?-->/m, '')

    # Optionally, strip unnecessary attributes (like event handlers or data attributes)
    html.gsub!(/\s(?:id|class|data-[^=]+|onclick|onmouseover)="[^"]*"/, '')

    html
  end

  # Gets recipe data from a URL using OpenAI.
  #
  # @param url [String] The URL of the recipe page.
  # @return [Hash] A hash containing the recipe data.
  def get_recipe_data_with_ai(url)
    # get raw html from url
    data = URI(url).open(&:read)

    # split the data into head and body
    data_body = data.split("</head>")[1]
    data_body = clean_html(data_body)

    opengraph_data = parse_recipe_opengraph(url)

    # Check for missing keys in opengraph_data
    required_keys = %w[description image site]
    missing_keys = required_keys.select { |key| opengraph_data[key].nil? }

    # Prepare the query for OpenAI
    query_content = 'You are a recipe bot. To the following partial HTML data, please provide me with the recipe data in the current JSON format. Answer in the same language as the recipe.
    {
      "title": "string",
      "time": "string" (number of minutes, no unit),
      "servings": "string",
      "ingredients": ["string"],
      "difficulty": "string" (answer with easy, medium or hard in english),
      "tags": ["string"] (One must be the main ingredient of the dish (e.g. chicken, beef, etc.), one must be the type of dish (e.g. soup, salad, etc.), and one must be the cuisine (e.g. italian, mexican, etc.), one must be the diet type (e.g. vegetarian, vegan, etc.), one must be the meal type (e.g. breakfast, lunch, dinner, dessert, etc.), and one must be the occasion (e.g. party, picnic, etc.). Add more tags preferably if you can find them. They should always be in english.),
    }'

    unless missing_keys.empty?
      query_content += "\nOh, it seems like you need to add these keys as well: #{missing_keys.join(', ')}. Please provide the missing values in JSON format (similar to above)."
    end

    p opengraph_data
    p query_content

    response = client.chat(
      parameters: {
        model: 'gpt-4o-mini',
        messages: [
          { role: 'developer', content: query_content },
          { role: 'user', content: data_body }
        ]
      }
    )

    raw_data = response.dig("choices", 0, "message", "content")

    # remove the ```json from the beginning and ``` from end of the string
    raw_data = raw_data[7..-4]

    json_data = JSON.parse(raw_data)

    # merge opengraph_data with json_data
    json_data = json_data.merge(opengraph_data)

    return json_data
  end

  # Checks if a recipe is valid using OpenAI.
  #
  # @param url [String] The URL of the recipe page.
  # @return [Boolean] True if the recipe is valid, false otherwise.
  def is_valid_recipe_with_ai(url)
    # get raw html from url
    # data = URI(url).open(&:read)
    # data_body = data.split("</head>")[1]

    # response = client.chat(
    #   parameters: {
    #     model: 'gpt-4o-mini',
    #     messages: [
    #       { role: 'developer', content: 'Du är en receptbot. Är detta en giltig receptsida? Svara endast med sant eller falskt.' },
    #       { role: 'user', content: data_body }
    #     ]
    #   }
    # )

    # raw_data = response.dig("choices", 0, "message", "content")

    # return raw_data == "sant"
    return true
  end

  # Gets keywords from a search query using OpenAI.
  #
  # @param query [String] The search query.
  # @return [Array] An array of keywords.
  def get_keywords_from_query(query)
    # Get the keywords from a search query

    response = client.chat(
      parameters: {
        model: 'gpt-4o-mini',
        messages: [
          { role: 'developer', content: 'Du är en sökordsbot. Jag kommer att ge dig en sökfråga och du kommer att ge mig en lista med sökord som är relevanta för frågan. Svara endast med en lista med sökord separerade med kommatecken.' },
          { role: 'user', content: query }
        ]
      }
    )

    raw_data = response.dig("choices", 0, "message", "content")

    return raw_data.split(",").map(&:strip)
  end
end