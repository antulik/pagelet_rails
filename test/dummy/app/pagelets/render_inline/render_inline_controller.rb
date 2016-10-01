class RenderInline::RenderInlineController < ::PageletController

  pagelet_resource only: [:show]

  def show
    render body: 'Inline render text'
  end
end
