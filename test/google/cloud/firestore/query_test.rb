require "test_helper"

module Google
  module Cloud
    module Firestore
      class QueryTest < ActiveSupport::TestCase
        setup do
          Book.destroy_all
          @book_1 = Book.create!(title: 'My 1st book', published_on: '2022-12-01'.to_date, page: 210)
          @book_2 = Book.create!(title: 'My 2nd book', published_on: '2022-12-02'.to_date, page: 220)
          @book_3 = Book.create!(title: 'My 3rd book', published_on: '2022-12-03'.to_date, page: 230)
        end

        test '#[]' do
          books = Book.order(:title)
          assert_equal @book_1.id, books[0].id
          assert_equal @book_2.id, books[1].id
          assert_equal @book_3.id, books[2].id
          assert_nil books[3]
        end

        test '#size' do
          books = Book.where(:page, :>=, 220)
          assert_equal 2, books.size
          assert_equal 2, books.length
        end

        test '#destroy_all' do
          Book.where(:page, :>=, 220).destroy_all

          books = Book.all
          assert_equal [@book_1.id], books.map(&:id)
        end

        test '#first' do
          book = Book.where(:page, :>=, 220).order(:page).first
          assert_equal @book_2.id, book.id

          books = Book.where(:page, :>=, 220).order(:page).first(2)
          book_ids = [@book_2, @book_3].map(&:id)
          found_ids = books.map(&:id)
          assert_equal book_ids, found_ids
        end

        test '#exists?' do
          assert Book.where(:page, :>=, 230).exists?
          assert_not Book.where(:page, :>=, 231).exists?
        end

        test '#fire_record_class' do
          query = Book.where(:page, :>=, 220)
          assert_equal Book, query.fire_record_class
        end
      end
    end
  end
end
