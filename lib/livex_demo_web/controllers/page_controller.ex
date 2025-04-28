defmodule LivexDemoWeb.PageController do
  use LivexDemoWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
