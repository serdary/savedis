class TagsController < ApplicationController
  skip_before_filter :authorize, :only => [:index, :show]

  # GET /tags
  # GET /tags.json
  def index
    @tags = Tag.n_count(0)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.json
  def show
    @tag = Tag.find(params[:id])
    
    @bookmarks = @tag.bookmarks
    @notes = @tag.notes.public_notes

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tag }
    end
  end
end
