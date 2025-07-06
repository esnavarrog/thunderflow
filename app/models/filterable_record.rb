class FilterableRecord < ApplicationRecord
  self.abstract_class = true

  # == Constants
  PAGINATION_LIMIT = 30

  # == Fetcher
  def self.fetch(params = {})
    collection = pagination_filter(self, params)
    collection = date_filter(collection, params)
    order_filter(collection, params)
  end

  def self.get_limit(params = {})
    params[:limit].present? ? params[:limit].to_i : PAGINATION_LIMIT
  end

  def self.pagination_filter(klass, params = {})
    params[:no_limit].present? ? klass.all : klass.page(params[:page]).per(get_limit(params))
  end

  def self.attribute_filter(collection, key, params = {})
    params[key.to_sym].present? && params[key.to_sym] != 'nothing' ? collection.where(key.to_s => params[key.to_sym]) : collection
  end

  def self.es_entero?(param)
    Integer(param)
    true
  rescue ArgumentError, TypeError
    false
  end

  def self.search_filter(collection, keys, params = {})
    if params[:query].present? && keys.present? && !keys.empty?
      if params[:query].include?('ñ') || params[:query].include?('Ñ')
        query = "#{keys[0]} ILIKE '%#{params[:query]}%'"

        if keys.size > 1
          (1..keys.size - 1).each do |i|
            query += " or #{keys[i]} ILIKE '%#{params[:query]}%'"
          end
        end
      elsif es_entero?(params[:query])
        query = "id = #{params[:query].to_i}"
      else
        query = "#{keys[0]} ILIKE unaccent('%#{params[:query]}%')"

        if keys.size > 1
          (1..keys.size - 1).each do |i|
            query += " or #{keys[i]} ILIKE unaccent('%#{params[:query]}%')"
          end
        end
      end
      collection.where(query)
    else
      collection
    end
  end

  def self.date_filter(collection, params = {})
    return collection unless params[:start_date].present? || params[:end_date].present?

    table_name = collection.klass.table_name

    if params[:start_date].present?
      start_date = Utilities::DateService.parse_datetime(params[:start_date])

      if start_date
        start_date = start_date.beginning_of_day
        collection = collection.where(table_name + '.created_at >= ?', start_date)
      end
    end

    if params[:end_date].present?
      end_date = Utilities::DateService.parse_datetime(params[:end_date])

      if end_date
        end_date = end_date.end_of_day
        collection = collection.where(table_name + '.created_at <= ?', end_date)
      end
    end

    collection
  end

  def self.boolean_filter(collection, key, params = {})
    return collection if params[key.to_s.to_sym].nil?
    return collection if params[key.to_s.to_sym].to_s.eql?('')

    collection.where(key.to_s => params[key.to_s.to_sym].to_s.eql?('true'))
  end

  def self.order_filter(collection, params = {})
    return collection unless collection.klass.attribute_names.include?(params[:order])

    table_name = collection.klass.table_name

    direction = params[:dir].present? ? params[:dir] : default_sort_dir
    if params[:order].present?
      collection.order("#{table_name}.#{params[:order]} #{direction}")
    else
      collection.order(default_sort_order.to_s => direction.to_sym)
    end
  end

  def self.default_sort_order
    'created_at'
  end

  def self.default_sort_dir
    'desc'
  end
end
