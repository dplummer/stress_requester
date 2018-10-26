defmodule Mix.Tasks.Stress do
  use Mix.Task

  @shortdoc "Makes 10,000 requests to a url"
  def run([token | urls]) do
    HTTPoison.start
    headers = ["Authorization": "Bearer #{token}", "Accept": "application/json"]
    :ok = :hackney_pool.start_pool(:pool, [timeout: 9999999, max_connections: 30])

    Stream.cycle(urls)
    |> Stream.map(fn url ->
      Task.async(fn ->
        start = get_time()
        case HTTPoison.get(url, headers, hackney: [pool: :pool, checkout_timeout: 9999999, recv_timeout: 9999999]) do
          {:ok, %{status_code: 200}} ->
            now = get_time()
            IO.puts "Complete after #{round(now - start)}ms"
            #IO.write(".")
          {:error, %HTTPoison.Error{id: nil, reason: :timeout}} ->
            now = get_time()
            #IO.write "\n"
            IO.puts "Timeout after #{round(now - start)}ms"
          error ->
            IO.inspect(error)
            #IO.write "e"
        end
      end)
    end)
    |> Enum.take(1000)
    |> Task.yield_many(:infinity)
    #IO.write "\n"
    IO.puts "Done!"
  end

  defp get_time do
    :os.system_time(:millisecond)
  end
end
