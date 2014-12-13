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
    @asset = current_user.assets.new
    respond_with(@asset)
  end

  def edit
    @asset = current_user.assets.find(params[:id])
  end

  def create
    @asset = current_user.assets.new(asset_params)
    @asset.save
    respond_with(@asset)
  end

  def update
    @asset = current_user.assets.find(params[:id])
    @asset.update(asset_params)
    respond_with(@asset)
  end

  def destroy
    @asset = current_user.assets.find(params[:id])
    @asset.destroy
    respond_with(@asset)
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
