defmodule EbisuWeb.PageLive do
  use EbisuWeb, :live_view

  alias Ebisu.Bitbay
  alias Ebisu.Bitbay.Ticker, as: BitbayTicker
  alias Ebisu.Exchange
  alias Ebisu.Exchange.Ticker, as: ExchangeTicker

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Ebisu.PubSub, "bitbay_ticker")
      Phoenix.PubSub.subscribe(Ebisu.PubSub, "exchange_ticker")
    end

    {:ok,
     assign(socket,
       tickers: %{
         bitbay: format(Bitbay.tickers()),
         exchange: format(Exchange.tickers())
       }
     )}
  end

  @impl true
  def handle_info(%ExchangeTicker{} = ticker, socket) do
    exchange_tickers =
      socket.assigns.tickers.exchange
      |> add(ticker)
      |> window()

    tickers = %{socket.assigns.tickers | exchange: exchange_tickers}

    socket = assign(socket, tickers: tickers)

    {:noreply, push_event(socket, "tickers", %{tickers: tickers})}
  end

  @impl true
  def handle_info(%BitbayTicker{} = ticker, socket) do
    bitbay_tickers =
      socket.assigns.tickers.bitbay
      |> add(ticker)
      |> window()

    tickers = %{socket.assigns.tickers | bitbay: bitbay_tickers}

    socket = assign(socket, tickers: tickers)

    {:noreply, push_event(socket, "tickers", %{tickers: tickers})}
  end

  defp add(tickers, ticker) do
    tickers ++ [format(ticker)]
  end

  defp format(tickers) when is_list(tickers) do
    Enum.map(tickers, fn ticker -> format(ticker) end)
  end

  defp format(%BitbayTicker{} = ticker) do
    %{x: DateTime.to_time(ticker.updated_at), y: ticker.last / ticker.rate}
  end

  defp format(ticker) do
    %{x: DateTime.to_time(ticker.updated_at), y: ticker.last}
  end

  defp window(tickers) do
    Enum.take(tickers, -20)
  end
end
