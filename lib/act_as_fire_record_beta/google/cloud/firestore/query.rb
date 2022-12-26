module Google
  module Cloud
    module Firestore
      class Query
        include Enumerable

        def each(&b)
          records = get.map do |data|
            fire_record_class.to_instance(data)
          end
          records.each(&b)
        end

        def [](nth)
          self.to_a[nth]
        end

        def size
          self.to_a.size
        end
        alias length size

        def destroy_all
          doc_refs = self.map(&:doc_ref)
          fire_record_class.delete_in_batch(doc_refs)
        end

        def first(limit = 1)
          records = limit(limit)
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
