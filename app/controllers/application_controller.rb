class ApplicationController < ActionController::API
  # we add this "call back" to rescue the error and call on the method below:
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response
  rescue_from ActiveRecord::RecordInvalid, with: :render_bad_request_response

  def render_not_found_response(exception)
    render json: { message: exception.message }, status: 404
    # add <errors[ error: exception.class, message: .... ]> to hash above as extention?? (then update all tests)
    # or make a serializer? 
  end

  def render_bad_request_response(exception)
    render json: { message: exception.message }, status: 400
  end
end
