class AssetsController < ApplicationController
  before_action :set_asset, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!  #authenticate for users before any methods is called

  respond_to :html

  def index
    @assets = current_user.assets.all
    respond_with(@assets)
  end

  def show
    respond_with(@asset)
  end

  def new
    @asset = current_user.assets.build
    if params[:folder_id] #if we want to upload a file inside another folder
      @current_folder = current_user.folders.find(params[:folder_id])
      @asset.folder_id = @current_folder.id
    end
    respond_with(@asset)
  end

  def edit
    @asset = current_user.assets.find(params[:id])
  end

  def create
    @asset = current_user.assets.build(asset_params)
    if @asset.save
      flash[:notice] = "Successfully uploaded the file."

      if @asset.folder #checking if we have a parent folder for this file
        redirect_to browse_path(@asset.folder)  #then we redirect to the parent folder
      else
        redirect_to root_url
      end
    else
      render :action => 'new'
    end
    # respond_with(@asset), this line is from original generate in rails 4
    # ** This was causing this error (AbstractController::DoubleRenderError in AssetsController#create)
  end

  def update
    @asset = current_user.assets.find(params[:id])
    @asset.update(asset_params)
    respond_with(@asset)
  end

  def destroy
    @asset = current_user.assets.find(params[:id])
    @parent_folder = @asset.folder #grabbing the parent folder before deleting the record
    @asset.destroy
    flash[:notice] = "Successfully deleted the file."

    #redirect to a relevant path depending on the parent folder
    if @parent_folder
      redirect_to browse_path(@parent_folder)
    else
      redirect_to root_url
    end
    # respond_with(@asset), this line is from original generate in rails 4
    # ** This was causing this error (AbstractController::DoubleRenderError in AssetsController#destroy)
  end

  #this action will let the users download the files (after a simple authorization check)
  def get
    asset = current_user.assets.find_by_id(params[:id])
    if asset
      send_file asset.uploaded_file.path, :type => asset.uploaded_file_content_type
    else
      flash[:error] = "Don't be cheeky! Mind your own assets!"
      redirect_to assets_path
    end
  end
  private
  def set_asset
    @asset = Asset.find(params[:id])
  end

  def asset_params
    params.require(:asset).permit(:user_id, :uploaded_file, :folder_id) if params[:asset]
  end
end
