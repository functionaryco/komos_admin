defmodule KaffyWeb.OrderView do
  @moduledoc false

  use Phoenix.View,
    root: "lib/kaffy_web/templates",
    namespace: KaffyWeb

  # import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]
  use Phoenix.HTML

  def variant_name(variant) do
    "#{variant.product.name} - #{variant.sku}"
  end

  def item_name(item) do
    "#{item.variant.product.name} - #{item.variant.sku}"
  end

  def item_price(item) do
    "#{item.variant.price.amount}"
  end

  def total_price(item) do
    item.price * item.quantity
  end

  def line_total(item) do
    total_price(item) |> Decimal.from_float()
  end

  def item_total(items) do
    Enum.reduce(items, 0.0, fn x, acc -> acc + total_price(x) end) |> Decimal.from_float()
  end

  def address_text(address) do
    "#{address.firstname} #{address.lastname} Addr: #{address.address1} #{address.address2} City: #{
      address.city
    }-#{address.zipcode}"
  end

  def adjustment_name(conn, context, resource, adjustment) do
    resource = Kaffy.Utils.get_resource(conn, context, resource)
    Kaffy.ResourceCallbacks.adjustment_label(conn, resource, adjustment)
  end
end
