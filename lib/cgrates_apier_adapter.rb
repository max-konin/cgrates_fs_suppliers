require 'json'
require 'faraday'
require 'faraday_middleware'

require_relative 'config'

class CgratesApierAdapter
  def execute(method:, params: [])
    connection.post '/jsonrpc', {
        method: method,
        params: params
    }
  end

  def connection
    @connection ||= Faraday.new(config.cgrates_url, headers: headers,
                                                     ssl: { verify: false }) do |conn|
      conn.use Faraday::Response::ParseJson
      conn.use FaradayMiddleware::EncodeJson
      conn.use Faraday::Request::UrlEncoded
      conn.use Faraday::Request::BasicAuthentication, config.cgrates_user, config.cgrates_token if need_base_auth?
      conn.adapter Faraday.default_adapter
    end
  end

  private
  def config
    Config.instance
  end

  def need_base_auth?
    !(config.cgrates_user.nil? || config.cgrates_user != '')
  end

  def headers
    {
      'Content-Type': 'application/json',
    }
  end
end
