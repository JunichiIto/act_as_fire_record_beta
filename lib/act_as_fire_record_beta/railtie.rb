module ActAsFireRecordBeta
  class Railtie < ::Rails::Railtie
    initializer "act_as_fire_record_beta" do
      require "act_as_fire_record_beta/google/cloud/firestore/query"

      ActionDispatch::ExceptionWrapper.rescue_responses["ActAsFireRecordBeta::RecordNotFound"] = :not_found
    end
  end
end
