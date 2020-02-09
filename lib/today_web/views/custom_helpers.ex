defmodule TodayWeb.CustomHelpers do
  use Phoenix.HTML

  def string_to_html(text) do
    text
    |> Earmark.as_html!
    |> raw
  end

  def posted_datetime(date_time) do
    Timex.format!(date_time, "%B %d, %Y at %H:%M", :strftime)
  end
end
