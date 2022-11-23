class Book
  include ActAsFireRecordBeta

  firestore_attribute :title, :string
  firestore_attribute :published_on, :date
  firestore_attribute :page, :integer

  validates :title, presence: true

  before_validation :titleize_title

  private

  def titleize_title
    self.title = title.to_s.titleize
  end
end
