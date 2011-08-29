require 'mechanize'

class BookmarksController < ApplicationController  
  before_filter :check_ownership
  skip_before_filter :authorize, :only => [:index, :popular, :show, :recent]
  skip_before_filter :check_ownership, :only => [:index, :show, :new, :create, :popular, :recent]
   
  # GET /bookmarks
  # GET /bookmarks.json
  def index
    if params[:username]
      user_bookmarks
    elsif params[:tag_id]
      tag_bookmarks
    end
    
    if !@bookmarks
      redirect_to root_url
      return
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bookmarks }
    end
  end
   
  # GET /popular
  # GET /popular.json
  def popular
    popular_bookmarks

    respond_to do |format|
      format.html # popular.html.erb
      format.json { render json: @bookmarks }
    end
  end
  
  # GET /recent
  # GET /recent.json
  def recent
    recent_bookmarks

    respond_to do |format|
      format.html # recent.html.erb
      format.json { render json: @bookmarks }
    end
  end

  # GET /bookmarks/1
  # GET /bookmarks/1.json
  def show
    @bookmark = Bookmark.get_active_bookmark(params[:id].to_i) || render_404
    
    @private_user_count = 0
    @public_list = Array.new
    @content_owner = false
    
    @title = @bookmark.title
    @description = @bookmark.description
    
		@bookmark.users.each do |user|
		  user_bookmark = user.bookmark_users.find_by_bookmark_id(@bookmark.id)
		  next if user_bookmark.is_deleted
		  
			if current_user and user_bookmark.user_id == current_user.id
				@public_list << user
				@content_owner = true
				@title = user_bookmark.title if !user_bookmark.title.blank?
        @description = user_bookmark.description if !user_bookmark.description.blank?
        @publicly_visible = !user_bookmark.is_private
			elsif !user_bookmark.is_private
				@public_list << user
			else
  			@private_user_count += 1
			end
	  end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bookmark }
    end
  end

  # GET /bookmarks/new
  # GET /bookmarks/new.json
  def new
    if (params[:username] != current_user.username)
      redirect_to root_url
      return
    end
    @bookmark = Bookmark.new    
    @bookmark.bookmark_users.build
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /bookmarks/1/edit
  def edit
    @tags = @bookmark.tags.map { |tag| tag.value }.join(',')
    @edit_action = true
  end

  # POST /bookmarks
  # POST /bookmarks.json
  def create
    @bookmark = Bookmark.new(params[:bookmark])
    if params[:tag_value]
      @bookmark_user = @bookmark.bookmark_users.first
      @bookmark_user.user_id = current_user.id
    else
      @bookmark_user = BookmarkUser.new(:user_id => current_user.id)
      @bookmark.bookmark_users << @bookmark_user
    end

    @tags = params[:tag_value]
    
    if current_user.bookmarks.get_bookmark_by_url(@bookmark.url)
      flash[:notice] = 'You already added this page'
      @has_same_url ||= true
    end
    
    respond_to do |format|
      if !params[:tag_value]
        @check_result = @has_same_url ? false : @bookmark.check_url
        format.js
      else
        if !@has_same_url and @bookmark.add_bookmark_to_user(@bookmark_user)
          Tag.add_tags_to_parent(@bookmark, @tags)
          format.html { redirect_to popular_path, notice: 'Bookmark was successfully created.' }
        else
          format.html { render action: "new" }
        end
      end
    end
  end

  # PUT /bookmarks/1
  # PUT /bookmarks/1.json
  def update
    respond_to do |format|
      if @bookmark.update_attributes(params[:bookmark])
        Tag.update_parent_tags(@bookmark, params[:tag_value])
        
        format.html { redirect_to @bookmark, notice: 'Bookmark was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /bookmarks/1
  # DELETE /bookmarks/1.json
  def destroy
    @bookmark.delete_from_user(current_user)
    Tag.delete_tags_from_parent(@bookmark)

    respond_to do |format|
      format.html { redirect_to(user_bookmarks_path(:username => current_user.username)) }
      format.json { head :ok }
    end
  end
  
  private
  
  def check_ownership
    begin
      @bookmark = current_user.bookmarks.find(params[:id])
      @bookmark_user = current_user.bookmark_users.where("bookmark_id = ?", params[:id]).first
    rescue ActiveRecord::RecordNotFound
      logger.error "Attempt to access someone else's bookmark ID=#{params[:id]}"
      redirect_to root_url, :notice => 'Invalid bookmark'
    end
  end
  
  def popular_bookmarks
    @bookmarks = Bookmark.n_save_count(0).paginate(:page => params[:page], :per_page => configatron.page_size)
  end
  
  def recent_bookmarks
    @bookmarks = Bookmark.recently_added(12).paginate(:page => params[:page], :per_page => configatron.page_size)
  end
  
  def user_bookmarks    
    if (current_user and params[:username] == current_user.username) 
      @bookmarks = current_user.active_bookmarks.paginate(:page => params[:page], :per_page => configatron.page_size)
      @content_owner = true
    else
      @bookmarks = User.find_by_username(params[:username]).public_bookmarks.paginate(:page => params[:page], :per_page => configatron.page_size)
      @content_owner = false
    end
  end
  
  def tag_bookmarks
    @bookmarks = Tag.find_by_id(params[:tag_id]).bookmarks.paginate(:page => params[:page], :per_page => configatron.page_size, :conditions => "save_count > 0")
  end
end
