class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response
  # we add this "call back" to rescue the error and call on the method below
  # so the error message is customized

  def render_not_found_response(exception)
    render json: { message: exception.message }, status: :not_found
  end
end
