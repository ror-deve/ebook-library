class Ebook < ApplicationRecord
  has_one_attached :file
  has_one_attached :cover_image

  validates :title, presence: true
  validates :file, presence: true

  validate :acceptable_file_type
  validate :acceptable_file_size

  scope :search, ->(q) {
    where(
      "title ILIKE :q OR author ILIKE :q OR file_name ILIKE :q",
      q: "%#{sanitize_sql_like(q)}%"
    )
  }

  private

  def acceptable_file_type
    return unless file.attached?
    unless file.content_type.in?(%w[application/pdf application/octet-stream])
      errors.add(:file, "must be a PDF")
    end
  end

  def acceptable_file_size
    return unless file.attached?
    if file.byte_size > 50.megabytes
      errors.add(:file, "size must be less than 50MB")
    end
  end
end
