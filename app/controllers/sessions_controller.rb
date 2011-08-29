class SessionsController < ApplicationController
  skip_before_filter :authorize

  def new
  end

  def create
    if user = User.authenticate(params[:username], params[:password])
      session[:user_id] = user.id
      redirect_to root_url
    else
      redirect_to login_url, :notice => 'Wrong user / password combination.'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => 'Logged out'
  end

end
