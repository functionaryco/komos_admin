defmodule KaffyWeb.ShippingController do
  use Phoenix.Controller, namespace: KaffyWeb
  use Phoenix.HTML
  alias Kaffy.Pagination
  alias KaffyWeb.ResourceView

  defp can_proceed?(resource, conn) do
    Kaffy.ResourceAdmin.authorized?(resource, conn)
  end

  defp unauthorized_access(conn) do
    conn
    |> put_flash(:error, "You are not authorized to access that page")
    |> redirect(to: Kaffy.Utils.router().kaffy_home_path(conn, :index))
  end

  defp redirect_to_resource(conn, context, resource, entry) do
    redirect(conn,
      to:
        Kaffy.Utils.router().kaffy_resource_path(
          conn,
          :show,
          context,
          resource,
          entry.id
        )
    )
  end

  # we received actions as map so we actually use strings as keys
  defp get_action_record(actions, action_key) when is_map(actions) and is_binary(action_key) do
    Map.fetch!(actions, action_key)
  end

  # we received actions as Keyword list so action_key needs to be an atom
  defp get_action_record(actions, action_key) when is_list(actions) and is_binary(action_key) do
    action_key = String.to_existing_atom(action_key)
    [action_record] = Keyword.get_values(actions, action_key)
    action_record
  end
end
