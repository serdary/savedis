class ApplicationController < ActionController::Base
  before_filter :current_user
  before_filter :authorize
  
  protect_from_forgery
  
  protected
  
  def authorize
    unless current_user
      redirect_to login_url, :notice => 'Please login to access this page'
    end
  end
  
  private
  
  def current_user
    begin
      @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
    rescue ActiveRecord::RecordNotFound
      logger.error "Attempt to get user by id for session: #{session[:user_id]}"
      session[:user_id] = nil
      redirect_to root_url
    end
  end
  
  def render_404
      #render :template => 'error_pages/404', :layout => false, :status => :not_found
      #TODO: make prettier 404!
      raise ActionController::RoutingError.new('Not Found')
  end
end
