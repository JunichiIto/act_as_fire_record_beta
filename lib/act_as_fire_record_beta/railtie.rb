module ActAsFireRecordBeta
  class Railtie < ::Rails::Railtie
    initializer "act_as_fire_record_beta" do
      require "act_as_fire_record_beta/google/cloud/firestore/query"
    end
  end
end
