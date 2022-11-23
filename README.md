# ActAsFireRecordBeta

- Provides Rails applications with an ActiveRecord-like interface to manipulate Firestore.
- Works as a wrapper for the [google-cloud-firestore](https://rubygems.org/gems/google-cloud-firestore) gem.

CRUD example:

```ruby 
# Create
book = Book.new(title: 'An Awesome Book', published_on: '2022-12-01'.to_date, page: 200)
book.save
book.title #=> 'An Awesome Book'

# Update
book.update(page: 210)

# Delete
book.destroy

# Read
id = 'IdG0ZWT0I5DucEQuRgoP'
book = Book.find(id)
```

Finder examples:

```ruby
id = 'IdG0ZWT0I5DucEQuRgoP'
book = Book.find(id)

book = Book.find_by(title: 'An Awesome Book')

books = Book.all 

books = Book.order(:title).get_records
books = Book.order(:title, :desc).get_records

books = Book.where(:page, :>=, 200).get_records
books = Book.where(:page, :>=, 200).order(:page).get_records
```

Please refer test codes for other APIs.

- https://github.com/JunichiIto/act_as_fire_record_beta/blob/main/test/act_as_fire_record_beta_test.rb
- https://github.com/JunichiIto/act_as_fire_record_beta/blob/main/test/google/cloud/firestore/query_test.rb

## Installation
Add this line to your application's Gemfile:

```ruby
gem "act_as_fire_record_beta"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install act_as_fire_record_beta
```

## Setup, usage and etc.

As of now, Japanese document is only available.

[README-ja.md](https://github.com/JunichiIto/act_as_fire_record_beta/blob/main/CHANGELOG-ja.md)

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
