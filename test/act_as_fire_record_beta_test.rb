require "test_helper"

class ActAsFireRecordBetaTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert ActAsFireRecordBeta::VERSION
  end

  test '.firestore_attributes' do
    assert DummyModel.respond_to?(:firestore_attributes)
  end

  test '.col' do
    assert DummyModel.respond_to?(:col)
  end

  test '.doc' do
    assert DummyModel.respond_to?(:doc)
  end

  test '.all' do
    assert DummyModel.respond_to?(:all)
  end

  test '.find' do
    assert DummyModel.respond_to?(:find)
  end

  test '.find_by' do
    assert DummyModel.respond_to?(:find_by)
  end

  test '.where' do
    assert DummyModel.respond_to?(:where)
  end

  test '.order' do
    assert DummyModel.respond_to?(:order)
  end

  test '.first' do
    assert DummyModel.respond_to?(:first)
  end

  test '.create' do
    assert DummyModel.respond_to?(:create)
  end

  test '.create!' do
    assert DummyModel.respond_to?(:create!)
  end

  test '.destroy_all' do
    assert DummyModel.respond_to?(:destroy_all)
  end

  test '.logger' do
    assert DummyModel.respond_to?(:logger)
  end

  test 'default attributes' do
    model = DummyModel.new
    assert model.respond_to?(:id)
    assert model.respond_to?(:updated_at)
    assert model.respond_to?(:created_at)
  end

  test '#new_record?' do
    assert DummyModel.new.respond_to?(:new_record?)
  end

  test '#persisted?' do
    assert DummyModel.new.respond_to?(:persisted?)
  end

  test '#save' do
    assert DummyModel.new.respond_to?(:save)
  end

  test '#save!' do
    assert DummyModel.new.respond_to?(:save!)
  end

  test '#update' do
    assert DummyModel.new.respond_to?(:update)
  end

  test '#update!' do
    assert DummyModel.new.respond_to?(:update!)
  end

  test '#destroy' do
    assert DummyModel.new.respond_to?(:destroy)
  end

  test '#logger' do
    assert DummyModel.new.respond_to?(:logger)
  end
end
