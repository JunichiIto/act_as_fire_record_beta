module ActAsFireRecordBeta
  class Railtie < ::Rails::Railtie
    initializer "act_as_fire_record_beta" do
      require "act_as_fire_record_beta/google/cloud/firestore/query"

      ActionDispatch::ExceptionWrapper.rescue_responses["ActAsFireRecordBeta::RecordNotFound"] = :not_found

      if Google::Cloud.configure.firestore.emulator_host
        Google::Cloud::Firestore::V1::Firestore::Client.configure do |config|
          config.rpcs.list_documents.metadata ||= {}
          config.rpcs.list_documents.metadata['authorization'] = 'Bearer owner'
        end

        Google::Cloud::Firestore::Service.prepend(
          Module.new do
            protected

            def default_headers parent = nil
              headers = super
              headers['authorization'] = 'Bearer owner'
              headers
            end
          end
        )
      end
    end
  end
end
