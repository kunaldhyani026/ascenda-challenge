require 'hotels_data_merge/supplier_data_loader'

class HotelsController < ApplicationController
  def search
    response = HotelsDataMerge::SupplierDataLoader.new.procure_data
    return render_error(response[:error_body][:type], response[:error_body][:message], response[:error_body][:code]) if response.has_key?(:error_body)
  end

  private

  def render_error(type, message, http_status_code)
    render json: { error: { message: message, type: type } }, status: http_status_code
  end
end

