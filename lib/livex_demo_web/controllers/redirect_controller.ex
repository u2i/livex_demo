defmodule LivexDemoWeb.RedirectController do
  use LivexDemoWeb, :controller

  @doc """
  Redirects the root path to the locations page
  """
  def redirect_to_locations(conn, _params) do
    conn
    |> redirect(to: ~p"/locations")
    |> halt()
  end
end
