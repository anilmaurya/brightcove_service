module BrightcoveService
  class Base
    include ActiveModel::Validations

    def add_error(e)
      errors.add(:base, e.to_s)
      @result = { error: error_message(e) }
    end

    def error_message(e)
      error = JSON.parse(e.to_s)
      return error unless error.is_a?(Array)
      error.collect { |obj| obj['message'] }.join(', ')
    rescue JSON::ParserError
      return e
    end
  end
end
