# reference: http://blog.livedoor.jp/xaicron/archives/54466736.html

require 'net/http'
require 'uri'
require 'json'
require 'dotenv'

class Ginger

  def self.check(text)
    Dotenv.load

    text.freeze

    url = ENV["API_URL"]
    api_key  = ENV["API_KEY"]

    params = Hash.new
    params.store("lang", "US")
    params.store("clientVersion", "2.0")
    params.store("apiKey", api_key)
    params.store("text", text)

    uri = URI.parse url
    uri.query = URI.encode_www_form(params)
    req = Net::HTTP::Get.new uri
    res = Net::HTTP.start(uri.host, uri.port) {|http| http.request req }

    unless res.code == '200'
      return "Error!! #{res.code} #{res.message}"
    else
      result = JSON.parse(res.body)
      if result["LightGingerTheTextResult"] == []
        return "Good English"
      else
        fixed_text = text.dup
        gap = 0
        puts result
        result["LightGingerTheTextResult"].each do |rs|
          from    = rs["From"]
          to      = rs["To"]
          if rs["Suggestions"][0]
            suggest = rs["Suggestions"][0]["Text"]
            fixed_text[from..to] = suggest
          end
        end

        # Suggestionsが返ってこない場合があるため
        if text == fixed_text
          return "Good English"
        else
          return fixed_text
        end

      end

    end

  end

end
