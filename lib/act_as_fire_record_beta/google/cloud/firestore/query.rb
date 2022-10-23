module Google
  module Cloud
    module Firestore
      class Query
        def get_records(limit: nil)
          scope = limit ? limit(limit) : self
          scope.get.map do |data|
            fire_record_class.to_instance(data)
          end
        end

        def destroy_all
          doc_refs = get_records.map(&:doc_ref)
          fire_record_class.delete_in_batch(doc_refs)
        end

        def first(limit = 1)
          records = get_records(limit: limit)
          limit == 1 ? records[0] : records
        end

        def exists?
          !!first
        end

        def fire_record_class
          @_fire_record_class ||= ActAsFireRecordBeta.class_mapping[query.from[0].collection_id]
        end
      end
    end
  end
end
