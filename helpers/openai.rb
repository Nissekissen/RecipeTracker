require 'openai'
require 'open-uri'


module OpenAI

  def client
    return @client if !@client.nil?

    @client = OpenAI::Client.new(
      access_token: ENV['OPENAI_API_KEY'],
      log_errors: true
    )

    return @client
  end

  def get_recipe_data_with_ai(url)

    # get raw html from url
    data = URI(url).open(&:read)

    # split the data into head and body


    data_body = data.split("</head>")[1]

    response = client.chat(
      parameters: {
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'developer', 
            content: 'You are a recipe bot. 
            To the following partial HTML data, please provide me with the recipe data in the current JSON format. Answer in the same language as the recipe.
            {
              "title": "string",
              "description": "string",
              "image_url": "string",
              "time": "string" (number of minutes, no unit),
              "site": "string" (arla.se, koket.se, etc),
              "servings": "string",
              "ingredients": ["string"],
              "difficulty": "string" (answer with easy, medium or hard in english),
              "tags": ["string"] (at least 5 keywords that help to identify the recipe. Might be cousine, diet, priceclass, main ingredient etc.)
            }'
          },
          {role: 'user', content: data_body}
        ]
      }
    )

    raw_data = response.dig("choices", 0, "message", "content")

    # remove the ```json from the beginning and ``` from end of the string
    raw_data = raw_data[7..-4]

    json_data = JSON.parse(raw_data)

    return json_data
  end

  def is_valid_recipe_with_ai(url)

    data = URI(url).open(&:read)

    # get the head of the html data without parsing.
    data_head = data.split("</head>")[0]

    response = client.chat(
      parameters: {
        model: 'gpt-4o-mini',
        messages: [
          {role: 'developer', content: 'You are a recipe bot. To the following partial HTML data, please tell me if this is a valid recipe or not. You will response with either true or false.'},
          {role: 'user', content: data_head}
        ]
      }
    )

    raw_data = response.dig("choices", 0, "message", "content")

    # p raw_data

    return raw_data == "true"
  end

  def get_keywords_from_query(query)
    # Get the keywords from a search query

    response = client.chat(
      parameters: {
        model: 'gpt-4o-mini',
        messages: [
          {role: 'developer', content: '
          You are a recipe bot that helps users find recipes.
          To the following query, please provide me with keywords that can be used to find recipes.
          Keywords should be in the following json format:
          {
            "keywords": ["string"]
          }
          Respond only with the keywords.'},
          {role: 'user', content: query}
        ]
      }
    )

    raw_data = response.dig("choices", 0, "message", "content")

    # remove the ```json from the beginning and ``` from end of the string

    raw_data = raw_data[7..-4]

    return JSON.parse(raw_data)
  end
end