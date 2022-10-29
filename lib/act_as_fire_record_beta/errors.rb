module ActAsFireRecordBeta
  class FireRecordError < StandardError; end

  class RecordNotFound < FireRecordError; end

  class RecordNotSaved < FireRecordError; end

  class OperationNotSupported < FireRecordError; end
end
