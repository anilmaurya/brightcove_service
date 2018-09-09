# frozen_string_literal: true

require 'brightcove_service/ingest'
require 'brightcove_service/video'
require 'singleton'
require 'http'

module BrightcoveService
  class Api
    include Singleton

    OAUTH_ENDPOINT = 'https://oauth.brightcove.com/v4/access_token'
    API_ROOT = 'https://cms.api.brightcove.com/v1/accounts'
    PER_PAGE = 100

    def initialize
      @client_id = ENV['BRIGHTCOVE_CLIENT_ID']
      @client_secret = ENV['BRIGHTCOVE_CLIENT_SECRET']
      @base_url = "#{API_ROOT}/#{ENV['BRIGHTCOVE_ACCOUNT_ID']}"
      if [@client_id, @client_secret].any? { |c| c.to_s.empty? }
        raise AuthenticationError, 'Missing Brightcove API credentials'
      end
      set_token
    end

    def create_video(params)
      perform_action('post', 'videos', params.to_json)
    end

    def get_s3_url(video_id, filename)
      perform_action('get', "videos/#{video_id}/upload-urls/#{filename}")
    end

    def ingest_video_and_assets(video_id, params)
      perform_action('post', "videos/#{video_id}/ingest-requests", params)
    end

    def perform_action(request_type, url, params = {})
      set_token if @token_expires < Time.now
      @request_type = request_type
      @url = "#{@base_url}/#{url}"
      @params = params
      response = make_request
      return response.parse if response.code.in? [200, 201]
      raise StandardError, response.to_s
    end

    def make_request
      case @request_type
      when 'post'
        http.post(@url, body: @params)
      when 'get'
        http.get(@url)
      end
    end

    def http
      HTTP.headers(Authorization: "Bearer #{@token}", 'Content-Type': 'application/json')
    end

    private

    def set_token
      response = auth_request
      token_response = auth_request.parse
      return update_token(token_response) if response.status == 200
      raise AuthenticationError, token_response.fetch('error_description')
    end

    def update_token(token_response)
      @token = token_response.fetch('access_token')
      @token_expires = Time.now + token_response.fetch('expires_in')
    end

    def auth_request
      HTTP.basic_auth(user: @client_id, pass: @client_secret)
          .post(OAUTH_ENDPOINT,
                form: { grant_type: 'client_credentials' })
    end

    def raise_account_error
      raise AuthenticationError, 'Token valid but not for the given account_id'
    end
  end
end
