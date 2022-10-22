module Google
  module Cloud
    module Firestore
      class Query
        def find_one(&block)
          find_many(limit: 1, &block)[0]
        end

        def find_one!(&block)
          find_one(&block) || raise(ActiveRecord::RecordNotFound)
        end

        def find_many(limit: nil, &block)
          scope = limit ? limit(limit) : self
          scope.get.map do |data|
            model_lass = ActAsFireRecordBeta.class_mapping[query.from[0].collection_id]
            record = model_lass.to_instance(data)
            block.call(record) if block
            record
          end
        end

        def destroy_all
          find_many.each(&:destroy)
        end

        def exists?
          !!find_one
        end

        def first(limit = 1)
          records = find_many(limit: limit)
          limit == 1 ? records[0] : records
        end
      end
    end
  end
end
