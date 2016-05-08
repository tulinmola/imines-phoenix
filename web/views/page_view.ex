defmodule Imines.PageView do
  use Imines.Web, :view

  def last_seen() do
    case Imines.Status.last_seen() do
      {x, y, time} -> "#{x},#{y},#{time}"
      _ -> ""
    end
  end
end
