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
    item.variant.price.amount * item.quantity
  end

  def line_total(item) do
    total_price(item) |> Decimal.from_float()
  end

  def item_total(items) do
    Enum.reduce(items, 0.0, fn x, acc -> acc + total_price(x) end) |> Decimal.from_float()
  end
end
