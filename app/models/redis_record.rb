# frozen_string_literal: true

class RedisRecord
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  attr_accessor :persisted

  def initialize(attributes = nil)
    @persisted = false
    super(attributes)
  end

  def self.connection
    @connection ||= ConnectionPool::Wrapper.new do
      Redis.new(url: ENV['REDIS_URL'])
    end
  end

  def connection
    RedisRecord.connection
  end

  def save!
    save
  end

  def save
    valid_record = valid?
    connection.set(redis_key, to_json) if valid_record
    @persisted = true
    valid_record
  end

  def update(params)
    assign_attributes(params)
    save
  end

  def self.find(id)
    new_model = find_by(id)
    raise ActiveRecord::RecordNotFound if new_model.blank?

    new_model
  end

  def self.find_by(id)
    value = connection.get(redis_key(id))
    return nil if value.blank?

    new_model = model_name.human.constantize.new
    new_model.from_json(value)
    new_model.persisted = true
    new_model
  end

  def persisted?
    @persisted
  end

  def destroy
    connection.del(redis_key)
  end

  def self.redis_key(id_to_query)
    "#{Rails.env}_#{model_name.name}_#{id_to_query}"
  end

  def redis_key
    "#{Rails.env}_#{model_name.name}_#{id}"
  end
end
