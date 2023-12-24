## Next
- Rails 7.1 support

## v0.0.10 - 2022-12-28
- Implement `inspect` and `pretty_print` for Google::Cloud::Firestore::Query.
## v0.0.9 - 2022-12-27
- Remove `get_records` method. Now records can be retrieved without it.
- Delegate to Array on method missing for Google::Cloud::Firestore::Query. You can call `query.size`, `query.empty?` and so on.
- Add `count` method to model class. (e.g. `Book.count`)

## v0.0.8 - 2022-11-24
- `all` returns `Google::Cloud::Firestore::CollectionReference` object. `get_records` is required to fetch data from Firestore.

## v0.0.7 - 2022-11-23

- Add authorization = 'Bearer owner' for Firestore Emulator

## v0.0.6 - 2022-10-29

- Use custom error classes

## v0.0.5 - 2022-10-23

- Fix default value bug

## v0.0.4 - 2022-10-23

- Use firestore_attribute instead of firestore_attributes

## v0.0.3 - 2022-10-23

- Run destroy_all in batch
- Override inspect method 

## v0.0.2 - 2022-10-23

- Organize query methods 

## v0.0.1 - 2022-10-22

- Initial release
