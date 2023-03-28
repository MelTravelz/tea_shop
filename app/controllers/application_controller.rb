class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response
  # 404 error -> not found

  # we add this "call back" to rescue the error and call on the method below
  # so the error message is customized

  rescue_from ActiveRecord::RecordInvalid, with: :render_missing_info_response
  # 400 error -> bad request

  def render_not_found_response(exception)
    render json: { message: exception.message }, status: :not_found
  end

  def render_missing_info_response(exception)
    render json: { message: exception.message }, status: :bad_request
  end

end
