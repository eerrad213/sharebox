class Asset < ActiveRecord::Base

  belongs_to :user
  belongs_to :folder

  #set up "uploaded_file" field as attached_file (using Paperclip)
  has_attached_file :uploaded_file,
    :url => "/assets/get/:id",
    :path => ":Rails_root/assets/:id/:basename.:extension"

  validates_with AttachmentSizeValidator, :attributes => :uploaded_file, :less_than => 10.megabytes
  validates_with AttachmentPresenceValidator, :attributes => :uploaded_file
  do_not_validate_attachment_file_type :uploaded_file

  def file_name
    uploaded_file_file_name
  end

  def file_size
    uploaded_file_file_size
  end
end
