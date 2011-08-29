class UsersController < ApplicationController
  before_filter :check_ownership
  skip_before_filter :authorize, :only => [:index, :show, :create, :new]
  skip_before_filter :check_ownership, :only => [:index, :show, :settings, :new, :create]
  
  # GET /users
  # GET /users.json
  def index
    @users = User.order(:username)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @content_owner = false
    if @user = User.valid.find_by_username(params[:username])
      if current_user and @user.id == current_user.id
        @bookmarks = @user.active_bookmarks.limit(5)
        @notes = @user.notes.active_notes.limit(5)
        @content_owner = true
      else
        @bookmarks = @user.public_bookmarks.limit(5)
        @notes = @user.notes.public_notes.limit(5)
      end
      
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @user }
      end
    else
      render_404
    end
  end
  
  def settings
    if @user = current_user
      respond_to do |format|
        format.html # settings.html.erb
      end
    else
      redirect_to login_path
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new
    @new_action = true

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        Notifier.register_validation(@user).deliver
        session[:user_id] = @user.id
        
        format.html { redirect_to(:action => 'show', :username => @user.username) }
        format.json { render json: @user, status: :created, location: @user }
      else
        @new_action = true
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(settings_url, notice: "#{@user.username} has been successfully updated") }
      else
        format.html { render action: "edit" }
      end
    end
  end
  
  private
  
  def check_ownership
    begin
      @user = User.find(params[:id])
      if @user.id != session[:user_id]
        @user = nil
      end
    rescue ActiveRecord::RecordNotFound  
      @user = nil
    end
    
    if @user == nil
      logger.error "Attempt to access someone else's user settings ID=#{params[:id]}"
      redirect_to root_url, :notice => 'Invalid User'
    end
  end
end
