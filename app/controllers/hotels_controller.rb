require 'hotels_data_merge/supplier_data_loader'

class HotelsController < ApplicationController
  before_action :validate_params, only: [:search]

  # Search method searches the hotels based on input parameter hotels and destination
  # If both hotels and destination params are provided then results are returned based off hotels ids
  # else the result is either based off hotels ids or destination param.
  # In case of any types of bad request inputs, the method validate_params handles that before actual search method is called.
  def search
    response = HotelsDataMerge::SupplierDataLoader.new.procure_data
    return render_error(response[:error_body][:code], response[:error_body][:type], response[:error_body][:message], response[:error_body][:code]) if response.has_key?(:error_body)

    if params[:hotels].present?
      find_hotels_by_id
    elsif params[:destination].present?
      find_hotels_by_destination
    end
  end

  private

  # Find the hotels as per the hotels ids parameter requested by the user.
  def find_hotels_by_id
    @hotels = []
    params[:hotels].each do |id|
      hotel = Rails.cache.read('hotels')[id]
      @hotels << hotel if hotel.present?
    end
  end

  # Find the hotels as per the destination parameter requested by the user.
  def find_hotels_by_destination
    @hotels = []
    Rails.cache.read('hotels').each do |_hotel_id, hotel|
      @hotels << hotel if hotel.destination_id == params[:destination]
    end
  end

  # Validate the input params - hotels and destination provided by the user.
  # Raises 400 bad request if both neither hotels nor destination parameter is specified.
  # Raises 400 bad request if hotels params is not an Array of all string ids.
  # Raises 400 bad request if destination param is not an Integer.
  def validate_params
    hotels = params[:hotels]
    destination = params[:destination]
    return render_error('invalid_request', 'invalid_request_error', 'Either hotels or destination parameters are required', 400) if !hotels.present? && !destination.present?
    return render_error('invalid_request', 'invalid_request_error', 'hotels parameter should be an array with all string ids', 400) if hotels.present? && (!hotels.is_a?(Array) || !hotels.all? { |id| id.is_a?(String) })

    render_error('invalid_request', 'invalid_request_error', 'destination should be a integer', 400) if destination.present? && !destination.is_a?(Integer)
  end

  # Helper method renders errors with the specified message, type and status code
  def render_error(code, type, message, http_status_code)
    render json: { error: { code: code, message: message, type: type } }, status: http_status_code
  end
end

