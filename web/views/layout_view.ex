defmodule Imines.LayoutView do
  use Imines.Web, :view

  def encoded_image(path, attrs \\ []) do
    {:ok, body} = File.read("web/static/assets/images/#{path}")
    src = "data:image/png;base64,#{Base.encode64(body)}"
    attrs = [src: src] ++ attrs
    tag(:img, attrs)
  end
end
