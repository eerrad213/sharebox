require 'open-uri'

class AssetsController < ApplicationController
  # before_action :set_asset, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!  #authenticate for users before any methods is called

  respond_to :html

  def index
    @assets = current_user.assets.all
    respond_with(@assets)
  end

  def show
    @asset = current_user.assets.find(params[:id])
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
  end

  def update
    @asset = current_user.assets.find(params[:id])
    if @asset.update_attributes(asset_params)
      redirect_to @asset, :notice  => "Successfully updated asset."
    else
      render :action => 'edit'
    end
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
  end

  #this action will let the users download the files (after a simple authorization check)
  def get
    #first find the asset within own assets
    asset = current_user.assets.find_by_id(params[:id])

    #if not found in own assets, check if the current_user has share access to the parent folder of the File
    asset ||= Asset.find(params[:id]) if current_user.has_share_access?(Asset.find_by_id(params[:id]).folder)

    if asset
      send_file asset.uploaded_file.path, :type => asset.uploaded_file_content_type

      # Parse the URL for special characters first before downloading
      # data = open(URI.parse(URI.encode(asset.uploaded_file.url)))
      # data = open("#{URI.parse(URI.encode(asset.uploaded_file.url))}")
      # data = open(Asset.find(params[:id]).uploaded_file.url)
      # data = open(asset.uploaded_file.url)

      # use the send_data method to send the above bindary "data" as a file
      # send_data data, :filename => asset.uploaded_file_file_name

      #redirect to amazon S3 url which will let the user download the file automatically
      # redirect_to asset.uploaded_file.url, :type => asset.uploaded_file_content_type
    else
      flash[:error] = "Don't be cheeky! Mind your own assets!"
      redirect_to root_url
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
