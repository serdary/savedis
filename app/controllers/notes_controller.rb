class NotesController < ApplicationController
  before_filter :check_ownership
  skip_before_filter :authorize, :only => [:index, :show, :recent]
  skip_before_filter :check_ownership, :only => [:index, :show, :new, :create, :recent]

  # GET /notes
  # GET /notes.json
  def index
    if params[:username]
      user_notes
    elsif params[:tag_id]
      tag_notes
    end
        
    if !@notes
      redirect_to root_url
      return
    end

    @content_owner = (!current_user.nil? and params[:username] == current_user.username)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @notes }
    end
  end

  # GET /recent
  # GET /recent.json
  def recent
    @notes = Note.recently_added(12).paginate(:page => params[:page], :per_page => configatron.page_size)

    respond_to do |format|
      format.html # recent.html.erb
      format.json { render json: @bookmarks }
    end
  end

  # GET /notes/1
  # GET /notes/1.json
  def show
    @note = Note.active_notes.find_by_id(params[:id])
    
    if !@note or (@note.is_private and (!current_user or @note.user_id != current_user.id))
      render_404
      return
    end
    
    @content_owner = (!current_user.nil? and @note.user_id == current_user.id)
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @note }
    end
  end

  # GET /notes/new
  # GET /notes/new.json
  def new
    @note = Note.new
    if (params[:username] != current_user.username)
      redirect_to new_user_note_path(current_user)
      return
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @note }
    end
  end

  # GET /notes/1/edit
  def edit
    @tags = @note.tags.map { |tag| tag.value }.join(',')
  end

  # POST /notes
  # POST /notes.json
  def create
    @note = Note.new(params[:note])

    respond_to do |format|
      if @note.add_note_to_user(current_user)
        Tag.add_tags_to_parent(@note, params[:tag_value])
        format.html { redirect_to @note, notice: 'Note was successfully created.' }
        format.json { render json: @note, status: :created, location: @note }
      else
        format.html { render action: "new" }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /notes/1
  # PUT /notes/1.json
  def update
    respond_to do |format|
      if @note.update_attributes(params[:note])
        Tag.update_parent_tags(@note, params[:tag_value])
        format.html { redirect_to @note, notice: 'Note was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.json
  def destroy  
    @note.delete_from_user(current_user)
    Tag.delete_tags_from_parent(@note)

    respond_to do |format|
      format.html { redirect_to(user_notes_path(:username => current_user.username)) }
      format.json { head :ok }
    end
  end
  
  private
  
  def check_ownership
    begin
      @note = current_user.notes.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error "Attempt to access someone else's note ID=#{params[:id]}"
      redirect_to recentnotes_url, :notice => 'Invalid note'
    end
  end
  
  def user_notes
    if (current_user and params[:username] == current_user.username)
      @notes = current_user.notes.active_notes.paginate(:page => params[:page], :per_page => configatron.page_size)
    else
      @notes = User.find_by_username(params[:username]).notes.public_notes.paginate(:page => params[:page], :per_page => configatron.page_size)
    end
  end
  
  def tag_notes
    @notes = Tag.find_by_id(params[:tag_id]).notes.paginate(:page => params[:page], :per_page => configatron.page_size, :conditions => "is_private = 0 AND is_deleted = 0")
  end
end
