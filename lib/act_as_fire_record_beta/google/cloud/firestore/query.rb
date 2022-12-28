module Google
  module Cloud
    module Firestore
      class Query
        include Enumerable

        def method_missing(sym, *args)
          if respond_to_missing?(sym, false)
            self.to_a.send(sym, *args)
          else
            super
          end
        end

        def respond_to_missing?(sym, _include_private)
          [].respond_to?(sym) ? true : super
        end

        def each(&b)
          records = get.map do |data|
            record = fire_record_class.to_instance(data)
            b.call(record) if b
            record
          end
          b ? records : records.each
        end

        def inspect
          entries = self.to_a.map(&:inspect)
          "#<#{self.class.name} [#{entries.join(', ')}]>"
        end

        def pretty_print(q)
          q.pp(self.to_a)
        end

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
