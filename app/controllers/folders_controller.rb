class FoldersController < ApplicationController
  before_action :set_folder, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!

  respond_to :html

  def index
    @folders = current_user.folders.all
    respond_with(@folders)
  end

  def show
    @folder = current_user.folders.find(params[:id])
    respond_with(@folder)
  end

  def new
    @folder = current_user.folders.new
    #if there is "folder_id" param, we know that we are under a folder, thus, we will essentially create a subfolder
    if params[:folder_id] #if we want to create a folder inside another folder

      #we still need to set the @current_folder to make the buttons working fine
      @current_folder = current_user.folders.find(params[:folder_id])

      #then we make sure the folder we are creating has a parent folder which is the @current_folder
      @folder.parent_id = @current_folder.id
      respond_with(@folder)
    end
  end

  def edit
    @folder = current_user.folders.find(params[:id])
  end

  def create
    @folder = current_user.folders.new(folder_params)
    if @folder.save
      flash[:notice] = "Successfully created folder."

      if @folder.parent #checking if we have a parent folder on this one
        redirect_to browse_path(@folder.parent)  #then we redirect to the parent folder
      else
        redirect_to root_url #if not, redirect back to home page
      end
    else
      render :action => 'new'
    end
    # respond_with(@folder), this line is from original generate in rails 4
    # ** This was causing this error (AbstractController::DoubleRenderError in FoldersController#create)
  end

  def update
    @folder = current_user.folders.find(params[:id])
    @folder.update(folder_params)
    respond_with(@folder)
  end

  def destroy
    @folder = current_user.folders.find(params[:id])
    @folder.destroy
    respond_with(@folder)
  end

  private
  def set_folder
    @folder = Folder.find(params[:id])
  end

  def folder_params
    params.require(:folder).permit(:name, :parent_id, :user_id)
  end
end