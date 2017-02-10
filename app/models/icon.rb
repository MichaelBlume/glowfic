class Icon < ActiveRecord::Base
  include Presentable

  belongs_to :user
  belongs_to :template
  has_many :replies
  has_and_belongs_to_many :galleries

  validates_presence_of :url, :user, :keyword
  validate :url_is_url
  validate :uploaded_url_not_in_use
  nilify_blanks

  after_destroy :clear_icon_ids
  before_destroy :delete_from_s3

  attr_accessible :user, :user_id, :url, :keyword, :credit

  def uploaded?
    url.to_s.starts_with?('https://d1anwqy6ci9o1i.cloudfront.net/')
  end

  def s3_key
    return unless uploaded?
    url[url.index('net/')+4..-1]
  end

  private

  def url_is_url
    return true if url.to_s.starts_with?('http://') || url.to_s.starts_with?('https://')
    self.url = url_was unless new_record?
    errors.add(:url, "must be an actual fully qualified url (http://www.example.com)")
  end

  def delete_from_s3
    return unless uploaded?
    resp = S3_BUCKET.delete_objects(delete: {objects: [{key: s3_key}], quiet: true})
  end

  def uploaded_url_not_in_use
    return unless uploaded?
    check = Icon.where(url: url)
    check = check.where('id != ?', id) unless new_record?
    return unless check.exists?
    self.url = url_was
    errors.add(:url, 'has already been taken')
  end

  def clear_icon_ids
    Reply.where(icon_id: id).update_all(icon_id: nil)
    Post.where(icon_id: id).update_all(icon_id: nil)
  end

  class UploadError < Exception
  end
end
