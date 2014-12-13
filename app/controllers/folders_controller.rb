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
    respond_with(@folder)
  end

  def edit
    @folder = current_user.folders.find(params[:id]) 
  end

  def create
    @folder = current_user.folders.new(folder_params)
    @folder.save
    respond_with(@folder)
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
