class DynoController < ApplicationController

  def show
    render pagelet_params[:id]
  end

  private

    def pagelet_params
      params.permit(:id)
    end

end
