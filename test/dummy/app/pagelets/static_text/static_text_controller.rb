class StaticText::StaticTextController < ::PageletController

  pagelet_resource only: [:show]

  def show
    delay = pagelet_options.sleep

    if delay
      sleep delay
    end
  end
end
