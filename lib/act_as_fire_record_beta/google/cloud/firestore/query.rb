module Google
  module Cloud
    module Firestore
      class Query
        def get_records(limit: nil)
          scope = limit ? limit(limit) : self
          scope.get.map do |data|
            model_lass = ActAsFireRecordBeta.class_mapping[query.from[0].collection_id]
            model_lass.to_instance(data)
          end
        end

        def destroy_all
          get_records.each(&:destroy)
        end

        def first(limit = 1)
          records = get_records(limit: limit)
          limit == 1 ? records[0] : records
        end

        def exists?
          !!first
        end
      end
    end
  end
end
