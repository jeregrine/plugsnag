defmodule Plugsnag do
  defmacro __using__(_env) do
    quote location: :keep do
      @before_compile Plugsnag
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      defoverridable [call: 2]

      def call(conn, opts) do
        try do
          super(conn, opts)
        rescue
          wrapper = %Elixir.Plug.Conn.WrapperError{} ->
            %{kind: kind, reason: reason, stack: stack} = wrapper
            report(Exception.normalize(kind, reason, stack))
          exception ->
            report(exception)
        end
      end
    end
  end

  defp report(exception) do
    stacktrace = System.stacktrace

    exception
    |> Bugsnag.report

    reraise exception, stacktrace
  end
end
