class Archive < ApplicationRecord
  mount_uploader :file, FileUploader

  belongs_to :archiveable, polymorphic: true
  belongs_to :user

  validates :file, presence: true
  validate :file_size_validation

  private

  def file_size_validation
    if file.size > 10.megabytes
      errors.add(:file, "debe ser menor a 10MB")
    end
  end
end
