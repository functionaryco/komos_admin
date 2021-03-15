defmodule KaffyWeb.ResourceView do
  @moduledoc false

  use Phoenix.View,
    root: "lib/kaffy_web/templates",
    namespace: KaffyWeb

  # import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]
  use Phoenix.HTML

  def shipment_name(conn, context, resource, shipment) do
    resource = Kaffy.Utils.get_resource(conn, context, resource)
    Kaffy.ResourceCallbacks.shipment_name(conn, resource, shipment)
  end
end
