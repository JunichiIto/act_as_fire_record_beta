class Book
  include ActAsFireRecordBeta

  firestore_attribute :title, :string
  firestore_attribute :published_on, :date
  firestore_attribute :page, :integer

  validates :title, presence: true
end
