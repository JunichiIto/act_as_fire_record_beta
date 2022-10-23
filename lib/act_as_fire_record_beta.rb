require "google/cloud/firestore"
require "act_as_fire_record_beta/version"
require "act_as_fire_record_beta/railtie"

module ActAsFireRecordBeta
  extend ActiveSupport::Concern
  extend Forwardable

  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  delegate :logger => Rails

  @class_mapping = {}
  def self.class_mapping
    @class_mapping
  end

  included do
    attribute :id, :string
    attribute :created_at, :time
    attribute :updated_at, :time

    attr_accessor :doc_ref

    ActAsFireRecordBeta.class_mapping[collection_name_with_env] = self
  end

  class_methods do
    extend Forwardable
    delegate :logger => Rails

    def firestore_attributes(*names)
      @_firestore_attributes ||= []
      @_firestore_attributes += names.map(&:to_sym)
    end

    def col
      @_col ||= client.col(collection_name_with_env)
    end

    def doc(id)
      client.doc("#{collection_name_with_env}/#{id}")
    end

    def all
      col.get_records
    end

    def find(id)
      data = doc(id).get
      raise ActiveRecord::RecordNotFound if data.missing?

      to_instance(data)
    end

    def find_by(param)
      raise ArgumentError, "param size should be 1: #{param}" unless param.size == 1
      field, value = param.to_a.flatten

      where(field, :==, value).first
    end

    def find_by!(param)
      find_by(param) || raise(ActiveRecord::RecordNotFound)
    end

    def where(field, operator, value)
      col.where(field, operator, value)
    end

    def order(field, direction = :asc)
      col.order(field, direction)
    end

    def first(limit = 1)
      records = col.get_records(limit: limit)
      limit == 1 ? records[0] : records
    end

    def create(params)
      record = new(params)
      record.save
      record
    end

    def create!(params)
      record = new(params)
      record.save!
      record
    end

    def destroy_all
      delete_in_batch(col.list_documents)
    end

    def delete_in_batch(doc_refs)
      max_batch_size = 500
      nested_doc_refs = doc_refs.each_slice(max_batch_size)
      firestore = Google::Cloud::Firestore.new
      nested_doc_refs.each do |doc_refs|
        firestore.batch do |b|
          doc_refs.each do |doc_ref|
            b.delete(doc_ref)
          end
        end
      end
    end

    def save_params(record)
      @_firestore_attributes.to_h { |key| [key, record.send(key)] }
    end

    def to_instance(data)
      params = {
        id: data.document_id,
        created_at: data.created_at,
        updated_at: data.updated_at,
      }
      @_firestore_attributes.each do |key|
        params[key] = data[key]
      end
      new(params).tap { |record| record.doc_ref = data }
    end

    private

    def collection_name
      self.to_s.tableize
    end

    def client
      @_client ||= Google::Cloud::Firestore.new
    end

    def collection_name_with_env
      "#{collection_name}-#{Rails.env}".freeze
    end
  end # ClassMethods

  def new_record?
    id.blank?
  end

  def persisted?
    !new_record?
  end

  def save
    raise "insert only." unless new_record?
    return false if invalid?

    ref = col.add(save_params)
    self.id = ref.document_id

    true
  end

  def save!
    save || raise(ActiveRecord::RecordNotSaved.new("Failed to save the record", self))
  end

  def update(params)
    raise "update only" if new_record?
    self.attributes = params
    return false if invalid?

    doc.set(save_params, merge: true)
    true
  end

  def update!(params)
    update(params) || raise(ActiveRecord::RecordNotSaved.new("Failed to save the record", self))
  end

  def destroy
    doc.delete
    true
  end

  # Override
  def inspect
    hash = attributes.transform_keys(&:to_sym)
    hash_text = hash.to_s[1..-2]
    "#<#{self.class} #{hash_text}>"
  end

  private

  def save_params
    self.class.save_params(self)
  end

  def col
    self.class.col
  end

  def doc
    self.class.doc(id)
  end
end
