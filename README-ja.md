# ActAsFireRecordBeta
- Firestoreを操作するActiveRecord風のインタフェースをRailsアプリケーションに提供します。
- [google-cloud-firestore](https://rubygems.org/gems/google-cloud-firestore) gemのラッパーとして動作します。

このgemを使う前に、以下の点に注意してください。

- このgemはあくまでActiveRecord風のAPIを提供しているだけであり、ActiveRecordと完全な互換性があるわけではありません。そのため、ActiveStorageやDeviseなど、ActiveRecordの使用を前提としたgemやフレームワークをFirestoreに置き換えることはできません。
- FirestoreはいわゆるNoSQLであるため、RDBMSとは根本的に異なるデータ設計を考える必要があります。このgemを使ってActiveRecord風のAPIを手に入れたとしても、根本的なデータ設計についてはNoSQLのベストプラクティスに従う必要があります。

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

## Setup 

### Firebase Emulatorを使う場合 (development or test)

- [Firebase Emulatorをインストール](https://firebase.google.com/docs/emulator-suite/install_and_configure)します。
- `firebase init`でプロジェクト用のFirestoreをセットアップします。
- [このWikiページ](https://github.com/JunichiIto/act_as_fire_record_beta/wiki/.gitignore-example)を参考にして`.gitignore`の設定を追加します。
- 環境変数`FIRESTORE_EMULATOR_HOST`にEmulatorのhost情報を設定します。（`export FIRESTORE_EMULATOR_HOST=127.0.0.1:8080`など）
- `firebase emulator:start`でEmulatorを起動し、それからRailsを起動します。
  - `firebase emulators:start --import=./firebase-local --export-on-exit` のように `--import` オプションと `--export-on-exit` オプションを付けると、作成したデータをローカルに保存できます。
  - データを保存するディレクトリは`.gitignore`に追加しておきましょう。
- `firebase emulators:exec 'bundle exec rspec' --only firestore` のようなコマンドを入力すると、Emulatorの起動、テストの実行、Emulatorの終了が一度に行えます。

### 本物のFirestoreを使う場合

- Firebaseプロジェクトを作成し、 プロジェクト内にFirestoreを追加します。
- 「https://console.cloud.google.com/ > 左サイドメニュー > APIとサービス > 認証情報 > サービスアカウント > 名前=App Engine default service account のアカウントの鉛筆マークをクリック > キータブ > 鍵を追加 > 新しい鍵を作成 > JSON形式」でCredentialをダウンロードします。
- CredentialをRailsプロジェクト内の任意のディレクトリに配置します。
  - CredentialがGitHubにpushされないよう、必ず`.gitignore`にCredentialのパスを追加してください。
- （ローカルで実行する場合）環境変数`GOOGLE_APPLICATION_CREDENTIALS`にCredentialへのパスを追加します。（`export GOOGLE_APPLICATION_CREDENTIALS=path/to/your-key.json`など）
- （サーバーで実行する場合）環境変数`FIRESTORE_CREDENTIALS`にCredentialの内容（JSON文字列）を書き込みます。
- `config/initializers/firestore.rb` に`project_id`を設定します。

```ruby 
require "google/cloud/firestore"

Google::Cloud::Firestore.configure do |config|
  config.project_id = "your-awesome-project"
end
```

- 作成したデータ（ドキュメント）は「(モデル名)-(実行環境)」という名前のコレクションに保存されます（例：`books-development`、`blog_comments-production`）

### モデルの設定

モデルの設定例です。

```ruby
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
```

- クラスはPORO(Plain Old Ruby Object)として定義します。
  - `ApplicationRecord`は継承しないでください。
- `ActAsFireRecordBeta`をincludeします。
- Firestoreで管理したい属性と型を`firestore_attribute`で指定します。
  - このメソッドに指定可能な引数は[`ActiveModel::Attributes::ClassMethods#attribute`](https://api.rubyonrails.org/classes/ActiveModel/Attributes/ClassMethods.html#method-i-attribute)と同じです。
- （オプション）必要に応じてバリデーションを追加します。
  - バリデーションには[`ActiveModel::Validations::ClassMethods`](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html)が使われます。
- （オプション）必要に応じてバリデーションコールバックを追加します。
  - コールバックには[`ActiveModel::Validations::Callbacks::ClassMethods`](https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html)が使われます。
- `belongs_to`や`has_many`のようなモデルの関連は使えません。

## APIの使用例

### CRUD
単純なCRUDの例です。

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

### Finder methods 
検索メソッドの使用例です。

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

上記以外のAPIの使用例はテストコードを参照してください。

- https://github.com/JunichiIto/act_as_fire_record_beta/blob/main/test/act_as_fire_record_beta_test.rb
- https://github.com/JunichiIto/act_as_fire_record_beta/blob/main/test/google/cloud/firestore/query_test.rb

## 注意点・制約事項

- `order`メソッドや`where`メソッドは[`Google::Cloud::Firestore::Query`](https://www.rubydoc.info/gems/google-cloud-firestore/2.7.2/Google/Cloud/Firestore/Query)をそのまま使っているため、引数の指定方法がActiveRecordと異なります。
- ActiveRecordとは異なり、`where`や`order`を指定した場合は最後に`get_records`メソッドを呼ばないとデータを取得できません。
- 指定可能な検索条件には制約があります。具体的にはFirestoreや[google-cloud-firestore](https://rubygems.org/gems/google-cloud-firestore)の制約がそのまま当てはまります。

## テストコードを書く場合の注意点

RDBMSを使ったテストとは異なり、テストで使用したデータは自動的に削除されません。必要に応じてデータを削除してください。

```ruby 
require "test_helper"

class ActAsFireRecordBetaTest < ActiveSupport::TestCase
  setup do
    Book.destroy_all
  end

  test "create" do
    Book.create(title: 'An Awesome Book', published_on: '2022-12-01'.to_date, page: 200)
    assert_equal 1, Book.all.count
  end
end
```

```ruby 
require "rails_helper"

RSpec.describe Book, type: :model do 
  before do
    Book.destroy_all
  end
  
  it "creates new record" do
    Book.create(title: 'An Awesome Book', published_on: '2022-12-01'.to_date, page: 200)
    expect(Book.all.count).to eq 1
  end
end
```

## CIでテストを動かす場合の設定例

GitHub Actions上でFirebase Emulatorを使用する設定例を[こちらのWikiページ](https://github.com/JunichiIto/act_as_fire_record_beta/wiki/GitHub-Actions-example)にまとめてあります。

## TODOs 

[Issues](https://github.com/JunichiIto/act_as_fire_record_beta/issues)をご覧ください。

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
