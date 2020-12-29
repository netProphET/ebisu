defmodule Ebisu.Bitbay do
  alias Ebisu.Bitbay.Clients.Http
  alias Ebisu.Bitbay.Ticker

  alias Ebisu.Repo

  import Ecto.Query

  def add_ticker do
    rate = Http.get_rate()

    Http.get_ticker()
    |> Map.put("rate", rate)
    |> Ticker.changeset()
    |> Repo.insert()
  end

  def tickers() do
    Ticker
    |> order_by(desc: :updated_at)
    |> limit(20)
    |> Repo.all()
  end
end
