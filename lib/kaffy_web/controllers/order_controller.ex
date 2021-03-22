defmodule KaffyWeb.OrderController do
  use Phoenix.Controller, namespace: KaffyWeb
  use Phoenix.HTML
  alias Kaffy.Pagination

  def new(conn, %{"context" => context, "resource" => resource}) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    resource_name = Kaffy.ResourceAdmin.singular_name(my_resource)

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        changeset = Kaffy.ResourceAdmin.create_changeset(my_resource, %{}) |> Map.put(:errors, [])

        render(conn, "show.html",
          layout: {KaffyWeb.LayoutView, "app.html"},
          changeset: changeset,
          context: context,
          resource: resource,
          resource_name: resource_name,
          my_resource: my_resource
        )
    end
  end

  def add_to_cart(
        conn,
        %{"context" => context, "id" => order_id, "resource" => "order_item" = resource} = params
      ) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    order_item_params = Map.put(params["order_item"], "order_id", order_id)
    params = Map.put(params, "order_item", order_item_params)
    params = Kaffy.ResourceParams.decode_map_fields("order_item", my_resource[:schema], params)
    changes = Map.get(params, "order_item", %{})

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        case Kaffy.ResourceCallbacks.add_to_cart(conn, my_resource, changes) do
          {:ok, _entry} ->
            put_flash(conn, :success, "Item added to cart successfully")
            |> redirect(
              to: Kaffy.Utils.router().kaffy_order_path(conn, :cart, context, "order", order_id)
            )

          {:error, %Ecto.Changeset{} = _changeset} ->
            redirect(conn,
              to: Kaffy.Utils.router().kaffy_order_path(conn, :cart, context, "order", order_id)
            )

            # render(conn, "cart.html",
            #   layout: {KaffyWeb.LayoutView, "app.html"},
            #   cart_changeset: changeset,
            #   context: context,
            #   resource: resource,
            #   resource_name: "order",
            #   my_resource: my_resource
            # )
        end
    end
  end

  def clear_cart(conn, %{"context" => context, "id" => order_id, "resource" => "order" = resource}) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    conn = Plug.Conn.assign(conn, :order_id, order_id)
    Kaffy.ResourceAdmin.clear_cart(conn, my_resource, :ok)

    redirect(conn,
      to: Kaffy.Utils.router().kaffy_resource_path(conn, :new, context, resource)
    )
  end

  def cart(conn, %{
        "context" => context,
        "resource" => "order" = resource,
        "order_id" => id
      }) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    schema = my_resource[:schema]
    resource_name = Kaffy.ResourceAdmin.singular_name(my_resource)
    cart_resource = Kaffy.Utils.get_resource(conn, context, "order_item")
    variant_resource = Kaffy.Utils.get_resource(conn, "product", "variant")
    {_filtered_count, items_list} = Kaffy.ResourceQuery.list_resource(conn, cart_resource, %{})

    cart_changeset =
      Kaffy.ResourceAdmin.create_changeset(cart_resource, %{}) |> Map.put(:errors, [])

    {_filtered_count, variants_list} =
      Kaffy.ResourceQuery.list_resource(conn, variant_resource, %{})

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        if entry = Kaffy.ResourceQuery.fetch_resource(conn, my_resource, id) do
          changeset = Ecto.Changeset.change(entry)

          render(conn, "cart.html",
            layout: {KaffyWeb.LayoutView, "app.html"},
            changeset: changeset,
            context: context,
            resource: resource,
            my_resource: my_resource,
            resource_name: resource_name,
            schema: schema,
            entry: entry,
            cart_resource: cart_resource,
            items: items_list,
            variants: variants_list,
            cart_changeset: cart_changeset
          )
        else
          put_flash(conn, :error, "The resource you are trying to visit does not exist!")
          |> redirect(
            to: Kaffy.Utils.router().kaffy_resource_path(conn, :index, context, resource)
          )
        end
    end
  end

  def new_address(conn, %{"context" => context, "resource" => resource, "order_id" => order_id}) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    resource_name = Kaffy.ResourceAdmin.singular_name(my_resource)

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        changeset = Kaffy.ResourceAdmin.create_changeset(my_resource, %{}) |> Map.put(:errors, [])

        render(conn, "new_address.html",
          layout: {KaffyWeb.LayoutView, "app.html"},
          changeset: changeset,
          context: context,
          resource: resource,
          resource_name: resource_name,
          my_resource: my_resource,
          order_id: order_id
        )
    end
  end

  def create_address(
        conn,
        %{"context" => context, "resource" => resource, "order_id" => order_id} = params
      ) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    params = Kaffy.ResourceParams.decode_map_fields(resource, my_resource[:schema], params)
    changes = Map.get(params, resource, %{})
    resource_name = Kaffy.ResourceAdmin.singular_name(my_resource)

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        case Kaffy.ResourceCallbacks.create_callbacks(conn, my_resource, changes) do
          {:ok, _entry} ->
            case Map.get(params, "submit", "Save") do
              "Save" ->
                put_flash(conn, :success, "Created a new #{resource_name} successfully")
                |> redirect(
                  to:
                    Kaffy.Utils.router().kaffy_order_path(
                      conn,
                      :order_customer,
                      "order",
                      "order",
                      order_id
                    )
                )
            end

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new_address.html",
              layout: {KaffyWeb.LayoutView, "app.html"},
              changeset: changeset,
              context: context,
              resource: resource,
              resource_name: resource_name,
              my_resource: my_resource,
              order_id: order_id
            )

          {:error, {entry, error}} when is_binary(error) ->
            changeset = Ecto.Changeset.change(entry)

            conn
            |> put_flash(:error, error)
            |> render("new_address.html",
              layout: {KaffyWeb.LayoutView, "app.html"},
              changeset: changeset,
              context: context,
              resource: resource,
              resource_name: resource_name,
              my_resource: my_resource,
              order_id: order_id
            )
        end
    end
  end

  def order_customer(conn, %{
        "context" => context,
        "resource" => "order" = resource,
        "order_id" => id
      }) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    schema = my_resource[:schema]
    resource_name = Kaffy.ResourceAdmin.singular_name(my_resource)

    customer_resource = Kaffy.Utils.get_resource(conn, "account", "user")
    address_resource = Kaffy.Utils.get_resource(conn, "account", "address")

    {_filtered_count, customers_list} =
      Kaffy.ResourceQuery.list_resource(conn, customer_resource, %{})

    {_filtered_count, address_list} =
      Kaffy.ResourceQuery.list_resource(conn, address_resource, %{})

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        if entry = Kaffy.ResourceQuery.fetch_resource(conn, my_resource, id) do
          changeset = Ecto.Changeset.change(entry)

          render(conn, "order_customer.html",
            layout: {KaffyWeb.LayoutView, "app.html"},
            changeset: changeset,
            context: context,
            resource: resource,
            my_resource: my_resource,
            resource_name: resource_name,
            customer_resource: customer_resource,
            schema: schema,
            entry: entry,
            users: customers_list,
            address_resource: address_resource,
            address_list: address_list
          )
        else
          put_flash(conn, :error, "The resource you are trying to visit does not exist!")
          |> redirect(
            to: Kaffy.Utils.router().kaffy_resource_path(conn, :index, context, resource)
          )
        end
    end
  end

  def adjustments(conn, %{
        "context" => context,
        "resource" => "order" = resource,
        "order_id" => id
      }) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    schema = my_resource[:schema]
    resource_name = Kaffy.ResourceAdmin.singular_name(my_resource)

    adjustments_resource = Kaffy.Utils.get_resource(conn, "calculation", "adjustment")

    {_filtered_count, adjustments_list} =
      Kaffy.ResourceQuery.list_resource(conn, adjustments_resource, %{})

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        if entry = Kaffy.ResourceQuery.fetch_resource(conn, my_resource, id) do
          render(conn, "adjustments_index.html",
            layout: {KaffyWeb.LayoutView, "app.html"},
            context: context,
            resource: resource,
            my_resource: my_resource,
            resource_name: resource_name,
            schema: schema,
            entry: entry,
            adjustments: adjustments_list,
            order_id: id
          )
        else
          put_flash(conn, :error, "The resource you are trying to visit does not exist!")
          |> redirect(
            to: Kaffy.Utils.router().kaffy_resource_path(conn, :index, context, resource)
          )
        end
    end
  end

  def payments(conn, %{
        "context" => context,
        "resource" => "payment" = resource,
        "order_id" => id
      }) do
    my_resource = Kaffy.Utils.get_resource(conn, context, "order")
    schema = my_resource[:schema]
    resource_name = Kaffy.ResourceAdmin.singular_name(my_resource)

    payment_resource = Kaffy.Utils.get_resource(conn, "payment", "payment")

    {_filtered_count, payments_list} =
      Kaffy.ResourceQuery.list_resource(conn, payment_resource, %{})

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        if entry = Kaffy.ResourceQuery.fetch_resource(conn, my_resource, id) do
          render(conn, "payment_index.html",
            layout: {KaffyWeb.LayoutView, "app.html"},
            context: context,
            resource: resource,
            my_resource: my_resource,
            resource_name: resource_name,
            schema: schema,
            entry: entry,
            adjustments: payments_list,
            order_id: id
          )
        else
          put_flash(conn, :error, "The resource you are trying to visit does not exist!")
          |> redirect(
            to: Kaffy.Utils.router().kaffy_resource_path(conn, :index, context, resource)
          )
        end
    end
  end

  def update_customer(
        conn,
        %{"context" => context, "resource" => resource, "order_id" => id} = params
      ) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    schema = my_resource[:schema]

    params = Kaffy.ResourceAdmin.customer_update_params(params)

    params = Kaffy.ResourceParams.decode_map_fields(resource, schema, params)

    resource_name = Kaffy.ResourceAdmin.singular_name(my_resource) |> String.capitalize()

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        entry = Kaffy.ResourceQuery.fetch_resource(conn, my_resource, id)
        changes = Map.get(params, resource, %{})

        case Kaffy.ResourceCallbacks.update_callbacks(conn, my_resource, entry, changes) do
          {:ok, entry} ->
            conn = put_flash(conn, :success, "#{resource_name} saved successfully")

            save_button = Map.get(params, "submit", "Save")

            case save_button do
              "Save" ->
                conn
                |> put_flash(:success, "#{resource_name} saved successfully")
                |> redirect(
                  to:
                    Kaffy.Utils.router().kaffy_order_path(
                      conn,
                      :order_customer,
                      context,
                      resource,
                      entry.id
                    )
                )
            end

          {:error, %Ecto.Changeset{} = changeset} ->
            conn =
              put_flash(
                conn,
                :error,
                "A problem occurred while trying to save this #{resource} "
              )

            conn
            |> redirect(
              to:
                Kaffy.Utils.router().kaffy_order_path(
                  conn,
                  :order_customer,
                  context,
                  resource,
                  changeset.data.id
                )
            )

          {:error, {_entry, error}} when is_binary(error) ->
            conn = put_flash(conn, :error, error)

            conn
            |> redirect(
              to: Kaffy.Utils.router().kaffy_order_path(conn, :order_customer, context, resource)
            )
        end
    end
  end

  def order_shipment(conn, %{"context" => context, "resource" => resource, "id" => id}) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)

    resource_name = Kaffy.ResourceAdmin.singular_name(my_resource)

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        if entry = Kaffy.ResourceQuery.fetch_resource(conn, my_resource, id) do
          render(conn, "order_shipment.html",
            layout: {KaffyWeb.LayoutView, "app.html"},
            context: context,
            resource: resource,
            my_resource: my_resource,
            resource_name: resource_name,
            entry: entry
          )
        else
          put_flash(conn, :error, "The resource you are trying to visit does not exist!")
          |> redirect(
            to: Kaffy.Utils.router().kaffy_resource_path(conn, :index, context, resource)
          )
        end
    end
  end

  # we received actions as map so we actually use strings as keys
  defp get_action_record(actions, action_key) when is_map(actions) and is_binary(action_key) do
    Map.fetch!(actions, action_key)
  end

  defp unauthorized_access(conn) do
    conn
    |> put_flash(:error, "You are not authorized to access that page")
    |> redirect(to: Kaffy.Utils.router().kaffy_home_path(conn, :index))
  end

  # we received actions as Keyword list so action_key needs to be an atom
  defp get_action_record(actions, action_key) when is_list(actions) and is_binary(action_key) do
    action_key = String.to_existing_atom(action_key)
    [action_record] = Keyword.get_values(actions, action_key)
    action_record
  end

  defp can_proceed?(resource, conn) do
    Kaffy.ResourceAdmin.authorized?(resource, conn)
  end
end
