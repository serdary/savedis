class AjaxController < ApplicationController
skip_before_filter :authorize, :only => [:notes]
  def notes
    if params[:s]
      notes = Note.where("content like ?", "%#{params[:s]}%")
    else
      notes = Note.all
    end
    
    list = notes.map { |n| Hash[ id: n.id, title: n.title, content: n.content] }
    render json: list
  end
end
