require "test_helper"

class ActAsFireRecordBetaTest < ActiveSupport::TestCase
  setup do
    Book.destroy_all
  end

  test "it has a version number" do
    assert ActAsFireRecordBeta::VERSION
  end

  test '.col' do
    assert_instance_of Google::Cloud::Firestore::CollectionReference, Book.col
  end

  test '.doc' do
    book = Book.create!(title: 'An Awesome Book', published_on: '2022-12-01'.to_date, page: 200)
    assert_instance_of Google::Cloud::Firestore::DocumentReference, Book.doc(book.id)
  end

  test '.all' do
    book_1 = Book.create!(title: 'ABC', published_on: '2022-12-01'.to_date, page: 200)
    book_2 = Book.create!(title: 'XYZ', published_on: '2022-12-01'.to_date, page: 200)

    books = Book.all.sort_by(&:title)
    assert_equal 2, books.size
    assert_equal book_1.id, books[0].id
    assert_equal book_2.id, books[1].id
  end

  test '.find' do
    book = Book.create!(title: 'An Awesome Book', published_on: '2022-12-01'.to_date, page: 200)

    found_book = Book.find(book.id)
    assert_equal book.id, found_book.id
  end

  test '.find_by' do
    book_1 = Book.create!(title: 'ABC', published_on: '2022-12-01'.to_date, page: 200)
    book_2 = Book.create!(title: 'XYZ', published_on: '2022-12-02'.to_date, page: 210)

    found_book = Book.find_by(title: 'ABC')
    assert_equal book_1.id, found_book.id

    found_book = Book.find_by(published_on: '2022-12-02'.to_date)
    assert_equal book_2.id, found_book.id

    found_book = Book.find_by(page: 200)
    assert_equal book_1.id, found_book.id

    assert_nil Book.find_by(title: 'Not found')
  end

  test '.find_by!' do
    book_1 = Book.create!(title: 'ABC', published_on: '2022-12-01'.to_date, page: 200)
    book_2 = Book.create!(title: 'XYZ', published_on: '2022-12-02'.to_date, page: 210)

    found_book = Book.find_by!(title: 'ABC')
    assert_equal book_1.id, found_book.id

    assert_raises ActAsFireRecordBeta::RecordNotFound do
      Book.find_by!(title: 'Not found')
    end
  end

  test '.where' do
    book_1 = Book.create!(title: 'ABC', published_on: '2022-12-01'.to_date, page: 200)
    book_2 = Book.create!(title: 'XYZ', published_on: '2022-12-02'.to_date, page: 210)

    books = Book.where(:title, :==, 'ABC').get_records
    assert_equal 1, books.size
    assert_equal book_1.id, books[0].id

    books = Book.where(:page, :<=, 210).get_records.sort_by(&:title)
    assert_equal 2, books.size
    assert_equal book_1.id, books[0].id
    assert_equal book_2.id, books[1].id

    books = Book.where(:page, :<, 210).get_records
    assert_equal 1, books.size
    assert_equal book_1.id, books[0].id
  end

  test '.order' do
    book_1 = Book.create!(title: 'ABC', published_on: '2022-12-01'.to_date, page: 200)
    book_2 = Book.create!(title: 'XYZ', published_on: '2022-12-02'.to_date, page: 210)

    books = Book.order(:title).get_records
    assert_equal 2, books.size
    assert_equal book_1.id, books[0].id
    assert_equal book_2.id, books[1].id

    books = Book.order(:title, :desc).get_records
    assert_equal 2, books.size
    assert_equal book_2.id, books[0].id
    assert_equal book_1.id, books[1].id
  end

  test '.first' do
    book = Book.create!(title: 'ABC', published_on: '2022-12-01'.to_date, page: 200)

    found_book = Book.first
    assert_equal book.id, found_book.id
  end

  test '.create' do
    book = Book.create(title: 'An Awesome Book', published_on: '2022-12-01'.to_date, page: 200)
    assert book.persisted?

    book = Book.create(title: nil, published_on: '2022-12-01'.to_date, page: 200)
    assert_not book.persisted?
    assert_equal ["Title can't be blank"], book.errors.full_messages
  end

  test '.create!' do
    book = Book.create!(title: 'An Awesome Book', published_on: '2022-12-01'.to_date, page: 200)
    assert book.persisted?

    assert_raises ActAsFireRecordBeta::RecordNotSaved do
      Book.create!(title: nil, published_on: '2022-12-01'.to_date, page: 200)
    end
  end

  test '.destroy_all' do
    Book.create!(title: 'ABC', published_on: '2022-12-01'.to_date, page: 200)
    Book.create!(title: 'XYZ', published_on: '2022-12-02'.to_date, page: 210)
    assert_equal 2, Book.all.count

    Book.destroy_all
    assert_equal 0, Book.all.count
  end

  test '.logger' do
    assert_instance_of ActiveSupport::Logger, Book.logger
  end

  test 'default attributes' do
    book = Book.create!(title: 'ABC', published_on: '2022-12-01'.to_date, page: 200)

    assert_instance_of String, book.id
    assert_nil book.created_at
    assert_nil book.updated_at
    assert_nil book.doc_ref

    found_book = Book.find_by(title: 'ABC')
    assert_equal book.id, found_book.id
    assert_instance_of Time, found_book.created_at
    assert_instance_of Time, found_book.updated_at
    assert_instance_of Google::Cloud::Firestore::DocumentSnapshot, found_book.doc_ref
  end

  test '#new_record?' do
    book = Book.new(title: 'An Awesome Book', published_on: '2022-12-01'.to_date, page: 200)
    assert book.new_record?
    assert book.save
    assert_not book.new_record?
  end

  test '#persisted?' do
    book = Book.new(title: 'An Awesome Book', published_on: '2022-12-01'.to_date, page: 200)
    assert_not book.persisted?
    assert book.save
    assert book.persisted?
  end

  test '#save' do
    book_1 = Book.new(title: 'An Awesome Book', published_on: '2022-12-01'.to_date, page: 200)
    assert book_1.save

    found_book = Book.find_by(title: 'An Awesome Book')
    assert_equal book_1.id, found_book.id
    assert_equal 'An Awesome Book', found_book.title
    assert_equal '2022-12-01'.to_date, found_book.published_on
    assert_equal 200, found_book.page

    book_2 = Book.new(title: nil, published_on: '2022-12-01'.to_date, page: 200)
    assert_not book_2.save
    assert_equal ["Title can't be blank"], book_2.errors.full_messages
  end

  test '#save!' do
    book_1 = Book.new(title: 'An Awesome Book', published_on: '2022-12-01'.to_date, page: 200)
    assert book_1.save!

    found_book = Book.find_by(title: 'An Awesome Book')
    assert_equal book_1.id, found_book.id
    assert_equal 'An Awesome Book', found_book.title
    assert_equal '2022-12-01'.to_date, found_book.published_on
    assert_equal 200, found_book.page

    book_2 = Book.new(title: nil, published_on: '2022-12-01'.to_date, page: 200)
    assert_raises ActAsFireRecordBeta::RecordNotSaved do
      book_2.save!
    end
  end

  test '#update' do
    book = Book.create!(title: 'An Awesome Book', published_on: '2022-12-01'.to_date, page: 200)

    assert book.update(title: 'My Awesome Book', page: 210)

    found_book = Book.find_by(title: 'My Awesome Book')
    assert_equal book.id, found_book.id
    assert_equal 'My Awesome Book', found_book.title
    assert_equal '2022-12-01'.to_date, found_book.published_on
    assert_equal 210, found_book.page

    assert_not found_book.update(title: nil)
    assert_equal ["Title can't be blank"], found_book.errors.full_messages
  end

  test '#update!' do
    book = Book.create!(title: 'An Awesome Book', published_on: '2022-12-01'.to_date, page: 200)

    assert book.update!(title: 'My Awesome Book', page: 210)

    found_book = Book.find_by(title: 'My Awesome Book')
    assert_equal book.id, found_book.id
    assert_equal 'My Awesome Book', found_book.title
    assert_equal '2022-12-01'.to_date, found_book.published_on
    assert_equal 210, found_book.page

    assert_raises ActAsFireRecordBeta::RecordNotSaved do
      found_book.update!(title: nil)
    end
  end

  test '#destroy' do
    book = Book.create!(title: 'An Awesome Book', published_on: '2022-12-01'.to_date, page: 200)

    assert_equal 1, Book.all.count

    book.destroy

    assert_equal 0, Book.all.count
  end

  test '#logger' do
    assert_instance_of ActiveSupport::Logger, Book.new.logger
  end
end
