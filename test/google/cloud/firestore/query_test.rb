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

        test '#method_missing' do
          # []
          books = Book.order(:title)
          assert books.respond_to?(:[])
          assert_equal @book_1.id, books[0].id
          assert_equal @book_2.id, books[1].id
          assert_equal @book_3.id, books[2].id
          assert_nil books[3]

          # size/length
          books = Book.where(:page, :>=, 220)
          assert books.respond_to?(:size)
          assert_equal 2, books.size
          assert books.respond_to?(:length)
          assert_equal 2, books.length

          # empty?
          books = Book.where(:page, :>=, 220)
          assert books.respond_to?(:empty?)
          refute books.empty?
          books = Book.where(:page, :>, 230)
          assert books.empty?

          # blank?
          books = Book.where(:page, :>=, 220)
          assert books.respond_to?(:blank?)
          refute books.blank?
          books = Book.where(:page, :>, 230)
          assert books.blank?

          # NoMethodError
          books = Book.order(:title)
          refute books.respond_to?(:hoge)
          assert_raises(NoMethodError) { books.hoge }
        end

        test '#inspect' do
          books = Book.where(:page, :>=, 220).order(:page)
          expected = /\A#<Google::Cloud::Firestore::Query \[#<Book :id=>"\w+", :created_at=>[-\d:. +]+, :updated_at=>[-\d:. +]+, :title=>"My 2nd Book", :published_on=>Fri, 02 Dec 2022, :page=>220>, #<Book :id=>"\w+", :created_at=>[-\d:. +]+, :updated_at=>[-\d:. +]+, :title=>"My 3rd Book", :published_on=>Sat, 03 Dec 2022, :page=>230>\]>\z/
          assert_match expected, books.inspect

          books = Book.where(:page, :>, 230)
          expected = "#<Google::Cloud::Firestore::Query []>"
          assert_equal expected, books.inspect
        end

        test '#pretty_print' do
          books = Book.where(:page, :>=, 220).order(:page)
          expected = /\A\[#<Book :id=>"\w+", :created_at=>[-\d:. +]+, :updated_at=>[-\d:. +]+, :title=>"My 2nd Book", :published_on=>Fri, 02 Dec 2022, :page=>220>,\n #<Book :id=>"\w+", :created_at=>[-\d:. +]+, :updated_at=>[-\d:. +]+, :title=>"My 3rd Book", :published_on=>Sat, 03 Dec 2022, :page=>230>\]\n\z/
          assert_output(expected) { pp books }

          books = Book.where(:page, :>, 230)
          expected = "[]\n"
          assert_output(expected) { pp books }
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

          book = Book.where(:page, :>, 230).first
          assert_nil book

          books = Book.where(:page, :>, 230).first(2)
          assert_empty books
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
