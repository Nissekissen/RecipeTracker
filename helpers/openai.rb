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

  def is_valid_recipe_with_ai(url)

    data = URI(url).open(&:read)

    # get the head of the html data without parsing.
    data_head = data.split("</head>")[0]
    data_head = clean_html(data_head)

    p data_head
    

    response = client.chat(
      parameters: {
        model: 'gpt-4o-mini',
        messages: [
          {role: 'developer', content: 'You are a recipe bot. To the following partial HTML data, please tell me if the data is from a webpage that displayed a recipe or not. You will response with either true or false. No additional formatting.'},
          {role: 'user', content: data_head}
        ]
      }
    )

    raw_data = response.dig("choices", 0, "message", "content")

    p raw_data

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
Given the following search query, extract relevant keywords that can be used to find recipes. Your goal is to find all relevant recipes. Categorize them into the following types:  
- Main Ingredients (e.g., chicken, beef, tofu)  
- Dish Type (e.g., soup, salad, curry)  
- Cuisine (e.g., Italian, Mexican, Thai)  
- Diet Type (e.g., vegetarian, vegan, keto)  
- Meal Type (e.g., breakfast, lunch, dinner)  
- Occasion (e.g., party, picnic, holiday)  

Always return the response in this JSON format:  
{
  "ingredients": ["string"],
  "dish_types": ["string"],
  "cuisines": ["string"],
  "diet_types": ["string"],
  "meal_types": ["string"],
  "occasions": ["string"]
}

Rules:  
- Extract only the most relevant keywords.  
- Do not include general words like "recipe," "easy," or "delicious."  
- All keywords should be in lowercase English.  
- If a category has no matches, return an empty array.  

Example Query → Response:  
User Query: "Looking for a quick and easy vegan Mexican taco recipe for a family dinner."  
ChatGPT Response:  
{
  "ingredients": ["taco"],
  "dish_types": ["taco"],
  "cuisines": ["mexican"],
  "diet_types": ["vegan"],
  "meal_types": ["dinner"],
  "occasions": ["family"]
}  

Respond only with the JSON. No explanations, no additional text.
'},
          {role: 'user', content: query}
        ]
      }
    )

    raw_data = response.dig("choices", 0, "message", "content")

    p raw_data

    # remove the ```json from the beginning and ``` from end of the string

    # raw_data = raw_data[7..-4]

    return JSON.parse(raw_data)
  end
end