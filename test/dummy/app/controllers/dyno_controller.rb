class DynoController < ApplicationController

  def show
    render params[:id]
  end

end
