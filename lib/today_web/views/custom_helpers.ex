defmodule TodayWeb.CustomHelpers do
  use Phoenix.HTML
  alias Today.Content

  def string_to_html(text) do
    text
    |> Earmark.as_html!
    |> raw
  end

  def posted_datetime(date_time) do
    Timex.format!(date_time, "%B %d, %Y at %H:%M", :strftime)
  end

  def posted_date(date_time) do
    date_time
    |> NaiveDateTime.to_date
    |> Date.to_string
  end

  def tags_for_select do
    Enum.map(Content.list_tags, &{&1.name, &1.name})
  end
end
