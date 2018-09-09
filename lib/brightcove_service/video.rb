# frozen_string_literal: true
require 'brightcove_service/base'
require 'aws-sdk-s3'

module BrightcoveService
  class Video < Base
    attr_reader :result, :params, :brightcove_video
    validate :long_form_video

    def initialize(params)
      @params = params
    end

    def call
      valid? &&
        create_videos_on_brightcove &&
        set_result
    rescue StandardError => e
      add_error(e)
    end

    private

    def long_form_video
      return true if params['assets']&.values&.any? do |a|
        a['type'] == 'long_form_video'
      end
      errors.add(:base, 'long_form_video required')
      @result = { error: 'long_form_video required' }
    end

    def create_videos_on_brightcove
      @brightcove_video = BrightcoveService::Api.instance.create_video(brightcove_video_params)
    end

    def brightcove_video_params
      video_params = { name: asset_title,
                       reference_id: params[:brightcove_reference_id] }
      video_params[:geo] = geo_params if params[:restricted] == 'true'
      video_params[:schedule] = schedule_params if date_params?
      video_params
    end

    def asset_title
      params[:title_en] || params[:title_id]
    end

    def date_params?
      params[:start_date].present? || params[:end_date].present?
    end

    def geo_params
      {
        restricted: params[:restricted] == 'true',
        exclude_countries: params[:exclude_countries] == 'true',
        countries: params[:countries].reject(&:blank?).map(&:downcase)
      }
    end

    def schedule_params
      {
        starts_at: parsed_time(params[:start_date]),
        ends_at: parsed_time(params[:end_date])
      }
    end

    def parsed_time(time)
      time && Time.parse(time).in_time_zone.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
    end

    def set_result
      @result = s3_urls
    end

    # rubocop:disable Metrics/AbcSize
    def s3_urls
      urls = []
      params[:assets].each do |filename, values|
        next if values['name'].blank?
        result = BrightcoveService::Api.instance.get_s3_url(brightcove_video['id'], filename)
        urls.push(video_id: brightcove_video['id'],
                  presigned_url: signed_url(filename, result),
                  request_url: result['api_request_url'],
                  filename: filename)
      end
      urls
    end
    # rubocop:enable Metrics/AbcSize

    def signed_url(_filename, result)
      signer = Aws::S3::Presigner.new(client: s3_client(result))
      signer.presigned_url(
        :put_object,
        bucket: result['bucket'],
        key: result['object_key']
      )
    end

    def s3_client(result)
      Aws::S3::Client.new(
        region:               'us-east-1',
        access_key_id:        result['access_key_id'],
        secret_access_key:    result['secret_access_key'],
        session_token:        result['session_token']
      )
    end
  end
end
