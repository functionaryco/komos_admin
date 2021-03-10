defmodule KaffyWeb.ProductController do
  use Phoenix.Controller, namespace: KaffyWeb
  use Phoenix.HTML
  alias Kaffy.Pagination

  def index(
        conn,
        %{"context" => context, "product_id" => id, "resource" => "stock_item" = resource} =
          params
      ) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    params = Map.delete(params, "product_id")

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        fields = Kaffy.ResourceAdmin.index(my_resource)
        {filtered_count, entries} = Kaffy.ResourceQuery.list_resource(conn, my_resource, params)
        items_per_page = Map.get(params, "limit", "100") |> String.to_integer()
        page = Map.get(params, "page", "1") |> String.to_integer()
        has_next = round(filtered_count / items_per_page) > page
        next_class = if has_next, do: "", else: " disabled"
        has_prev = page >= 2
        prev_class = if has_prev, do: "", else: " disabled"
        list_pages = Pagination.get_pages(page, ceil(filtered_count / items_per_page))

        render(conn, "stock_index.html",
          layout: {KaffyWeb.LayoutView, "app.html"},
          context: context,
          resource: resource,
          fields: fields,
          my_resource: my_resource,
          filtered_count: filtered_count,
          page: page,
          has_next_page: has_next,
          next_class: next_class,
          has_prev_page: has_prev,
          prev_class: prev_class,
          list_pages: list_pages,
          entries: entries,
          params: params,
          product_id: id
        )
    end
  end

  def index(
        conn,
        %{"context" => context, "resource" => "stock_item" = resource} = params
      ) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        fields = Kaffy.ResourceAdmin.index(my_resource)
        {filtered_count, entries} = Kaffy.ResourceQuery.list_resource(conn, my_resource, params)
        items_per_page = Map.get(params, "limit", "100") |> String.to_integer()
        page = Map.get(params, "page", "1") |> String.to_integer()
        has_next = round(filtered_count / items_per_page) > page
        next_class = if has_next, do: "", else: " disabled"
        has_prev = page >= 2
        prev_class = if has_prev, do: "", else: " disabled"
        list_pages = Pagination.get_pages(page, ceil(filtered_count / items_per_page))

        render(conn, "stock_index.html",
          layout: {KaffyWeb.LayoutView, "app.html"},
          context: context,
          resource: resource,
          fields: fields,
          my_resource: my_resource,
          filtered_count: filtered_count,
          page: page,
          has_next_page: has_next,
          next_class: next_class,
          has_prev_page: has_prev,
          prev_class: prev_class,
          list_pages: list_pages,
          entries: entries,
          params: params
        )
    end
  end

  def index(
        conn,
        %{"context" => context, "product_id" => id, "resource" => "variant" = resource} = params
      ) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    params = Map.delete(params, "product_id")

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        fields = Kaffy.ResourceAdmin.index(my_resource)
        {filtered_count, entries} = Kaffy.ResourceQuery.list_resource(conn, my_resource, params)
        items_per_page = Map.get(params, "limit", "100") |> String.to_integer()
        page = Map.get(params, "page", "1") |> String.to_integer()
        has_next = round(filtered_count / items_per_page) > page
        next_class = if has_next, do: "", else: " disabled"
        has_prev = page >= 2
        prev_class = if has_prev, do: "", else: " disabled"
        list_pages = Pagination.get_pages(page, ceil(filtered_count / items_per_page))

        if entries |> length() < 2 do
          product_resource = Kaffy.Utils.get_resource(conn, context, "product")
          entry = Kaffy.ResourceQuery.fetch_resource(conn, product_resource, id)

          if entry.option_types |> length() < 1 do
            render(conn, "empty_type.html",
              layout: {KaffyWeb.LayoutView, "app.html"},
              context: context,
              resource: resource,
              product_id: id
            )
          else
            render(conn, "empty_variant.html",
              layout: {KaffyWeb.LayoutView, "app.html"},
              context: context,
              resource: resource,
              product_id: id
            )
          end
        else
          render(conn, "child_index.html",
            layout: {KaffyWeb.LayoutView, "app.html"},
            context: context,
            resource: resource,
            fields: fields,
            my_resource: my_resource,
            filtered_count: filtered_count,
            page: page,
            has_next_page: has_next,
            next_class: next_class,
            has_prev_page: has_prev,
            prev_class: prev_class,
            list_pages: list_pages,
            entries: entries,
            params: params,
            product_id: id
          )
        end
    end
  end

  def index(conn, %{"context" => context, "product_id" => id, "resource" => resource} = params) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    params = Map.delete(params, "product_id")

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        fields = Kaffy.ResourceAdmin.index(my_resource)
        {filtered_count, entries} = Kaffy.ResourceQuery.list_resource(conn, my_resource, params)
        items_per_page = Map.get(params, "limit", "100") |> String.to_integer()
        page = Map.get(params, "page", "1") |> String.to_integer()
        has_next = round(filtered_count / items_per_page) > page
        next_class = if has_next, do: "", else: " disabled"
        has_prev = page >= 2
        prev_class = if has_prev, do: "", else: " disabled"
        list_pages = Pagination.get_pages(page, ceil(filtered_count / items_per_page))

        render(conn, "child_index.html",
          layout: {KaffyWeb.LayoutView, "app.html"},
          context: context,
          resource: resource,
          fields: fields,
          my_resource: my_resource,
          filtered_count: filtered_count,
          page: page,
          has_next_page: has_next,
          next_class: next_class,
          has_prev_page: has_prev,
          prev_class: prev_class,
          list_pages: list_pages,
          entries: entries,
          params: params,
          product_id: id
        )
    end
  end

  def new(conn, %{"context" => context, "id" => product_id, "resource" => "variant" = resource}) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    resource_name = Kaffy.ResourceAdmin.singular_name(my_resource)

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        changeset = Kaffy.ResourceAdmin.create_changeset(my_resource, %{}) |> Map.put(:errors, [])

        render(conn, "variant_new.html",
          layout: {KaffyWeb.LayoutView, "app.html"},
          changeset: changeset,
          context: context,
          resource: resource,
          resource_name: resource_name,
          my_resource: my_resource,
          product_id: product_id
        )
    end
  end

  def create(
        conn,
        %{"context" => context, "id" => product_id, "resource" => "price" = resource} = params
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
          {:ok, entry} ->
            case Map.get(params, "submit", "Save") do
              "Save" ->
                put_flash(conn, :success, "Created a new #{resource_name} successfully")
                |> redirect(
                  to:
                    Kaffy.Utils.router().kaffy_product_path(
                      conn,
                      :index,
                      context,
                      product_id,
                      resource
                    )
                )

              "Save and add another" ->
                conn
                |> put_flash(:success, "#{resource_name} saved successfully")
                |> redirect(
                  to:
                    Kaffy.Utils.router().kaffy_product_path(
                      conn,
                      :new,
                      context,
                      product_id,
                      resource
                    )
                )

              "Save and continue editing" ->
                put_flash(conn, :success, "Created a new #{resource_name} successfully")
                |> redirect_to_resource(context, resource, entry)
            end

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "child_new.html",
              layout: {KaffyWeb.LayoutView, "app.html"},
              changeset: changeset,
              context: context,
              resource: resource,
              resource_name: resource_name,
              my_resource: my_resource
            )

          {:error, {entry, error}} when is_binary(error) ->
            changeset = Ecto.Changeset.change(entry)

            conn
            |> put_flash(:error, error)
            |> render("child_new.html",
              layout: {KaffyWeb.LayoutView, "app.html"},
              changeset: changeset,
              context: context,
              resource: resource,
              resource_name: resource_name,
              my_resource: my_resource
            )
        end
    end
  end

  def create(
        conn,
        %{"context" => context, "id" => product_id, "resource" => "product_property" = resource} =
          params
      ) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)

    product_property_params = Map.put(params["product_property"], "product_id", product_id)
    params = Map.put(params, "product_property", product_property_params)
    params = Kaffy.ResourceParams.decode_map_fields(resource, my_resource[:schema], params)
    changes = Map.get(params, resource, %{})
    resource_name = Kaffy.ResourceAdmin.singular_name(my_resource)

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        case Kaffy.ResourceCallbacks.create_callbacks(conn, my_resource, changes) do
          {:ok, entry} ->
            case Map.get(params, "submit", "Save") do
              "Save" ->
                put_flash(conn, :success, "Created a new #{resource_name} successfully")
                |> redirect(
                  to:
                    Kaffy.Utils.router().kaffy_product_path(
                      conn,
                      :index,
                      context,
                      product_id,
                      resource
                    )
                )

              "Save and add another" ->
                conn
                |> put_flash(:success, "#{resource_name} saved successfully")
                |> redirect(
                  to:
                    Kaffy.Utils.router().kaffy_product_path(
                      conn,
                      :new,
                      context,
                      product_id,
                      resource
                    )
                )

              "Save and continue editing" ->
                put_flash(conn, :success, "Created a new #{resource_name} successfully")
                |> redirect_to_resource(context, resource, entry)
            end

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "child_new.html",
              layout: {KaffyWeb.LayoutView, "app.html"},
              changeset: changeset,
              context: context,
              resource: resource,
              resource_name: resource_name,
              my_resource: my_resource
            )

          {:error, {entry, error}} when is_binary(error) ->
            changeset = Ecto.Changeset.change(entry)

            conn
            |> put_flash(:error, error)
            |> render("child_new.html",
              layout: {KaffyWeb.LayoutView, "app.html"},
              changeset: changeset,
              context: context,
              resource: resource,
              resource_name: resource_name,
              my_resource: my_resource
            )
        end
    end
  end

  def create(
        conn,
        %{"context" => context, "id" => product_id, "resource" => "variant" = resource} = params
      ) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)

    variant_params = Map.put(params["variant"], "product_id", product_id)
    params = Map.put(params, "variant", variant_params)
    params = Kaffy.ResourceParams.decode_map_fields(resource, my_resource[:schema], params)
    changes = Map.get(params, resource, %{})

    resource_name = Kaffy.ResourceAdmin.singular_name(my_resource)

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        case Kaffy.ResourceCallbacks.create_callbacks(conn, my_resource, changes) do
          {:ok, entry} ->
            case Map.get(params, "submit", "Save") do
              "Save" ->
                put_flash(conn, :success, "Created a new #{resource_name} successfully")
                |> redirect(
                  to:
                    Kaffy.Utils.router().kaffy_product_path(
                      conn,
                      :index,
                      context,
                      product_id,
                      resource
                    )
                )

              "Save and add another" ->
                conn
                |> put_flash(:success, "#{resource_name} saved successfully")
                |> redirect(
                  to:
                    Kaffy.Utils.router().kaffy_product_path(
                      conn,
                      :new,
                      context,
                      product_id,
                      resource
                    )
                )

              "Save and continue editing" ->
                put_flash(conn, :success, "Created a new #{resource_name} successfully")
                |> redirect_to_resource(context, resource, entry)
            end

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "variant_new.html",
              layout: {KaffyWeb.LayoutView, "app.html"},
              changeset: changeset,
              context: context,
              resource: resource,
              resource_name: resource_name,
              my_resource: my_resource,
              product_id: product_id
            )

          {:error, {entry, error}} when is_binary(error) ->
            changeset = Ecto.Changeset.change(entry)

            conn
            |> put_flash(:error, error)
            |> render("variant_new.html",
              layout: {KaffyWeb.LayoutView, "app.html"},
              changeset: changeset,
              context: context,
              resource: resource,
              resource_name: resource_name,
              my_resource: my_resource,
              product_id: product_id
            )
        end
    end
  end

  def create(conn, %{"context" => context, "resource" => resource} = params) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    params = Kaffy.ResourceParams.decode_map_fields(resource, my_resource[:schema], params)
    changes = Map.get(params, resource, %{})
    resource_name = Kaffy.ResourceAdmin.singular_name(my_resource)

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        case Kaffy.ResourceCallbacks.create_callbacks(conn, my_resource, changes) do
          {:ok, entry} ->
            case Map.get(params, "submit", "Save") do
              "Save" ->
                put_flash(conn, :success, "Created a new #{resource_name} successfully")
                |> redirect(
                  to: Kaffy.Utils.router().kaffy_resource_path(conn, :index, context, resource)
                )

              "Save and add another" ->
                conn
                |> put_flash(:success, "#{resource_name} saved successfully")
                |> redirect(
                  to: Kaffy.Utils.router().kaffy_resource_path(conn, :new, context, resource)
                )

              "Save and continue editing" ->
                put_flash(conn, :success, "Created a new #{resource_name} successfully")
                |> redirect_to_resource(context, resource, entry)
            end

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html",
              layout: {KaffyWeb.LayoutView, "app.html"},
              changeset: changeset,
              context: context,
              resource: resource,
              resource_name: resource_name,
              my_resource: my_resource
            )

          {:error, {entry, error}} when is_binary(error) ->
            changeset = Ecto.Changeset.change(entry)

            conn
            |> put_flash(:error, error)
            |> render("new.html",
              layout: {KaffyWeb.LayoutView, "app.html"},
              changeset: changeset,
              context: context,
              resource: resource,
              resource_name: resource_name,
              my_resource: my_resource
            )
        end
    end
  end

  def new(
        conn,
        %{
          "context" => context,
          "id" => product_id,
          "resource" => "image" = resource
        } = params
      ) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    resource_name = Kaffy.ResourceAdmin.singular_name(my_resource)

    params = Map.delete(params, "id")

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        changeset = Kaffy.ResourceAdmin.create_changeset(my_resource, %{}) |> Map.put(:errors, [])
        fields = Kaffy.ResourceAdmin.index(my_resource)
        {filtered_count, entries} = Kaffy.ResourceQuery.list_resource(conn, my_resource, params)
        items_per_page = Map.get(params, "limit", "100") |> String.to_integer()
        page = Map.get(params, "page", "1") |> String.to_integer()
        has_next = round(filtered_count / items_per_page) > page
        next_class = if has_next, do: "", else: " disabled"
        has_prev = page >= 2
        prev_class = if has_prev, do: "", else: " disabled"
        list_pages = Pagination.get_pages(page, ceil(filtered_count / items_per_page))

        render(conn, "new_product_image.html",
          layout: {KaffyWeb.LayoutView, "app.html"},
          changeset: changeset,
          resource_name: resource_name,
          context: context,
          resource: resource,
          fields: fields,
          my_resource: my_resource,
          filtered_count: filtered_count,
          page: page,
          has_next_page: has_next,
          next_class: next_class,
          has_prev_page: has_prev,
          prev_class: prev_class,
          list_pages: list_pages,
          entries: entries,
          params: params,
          product_id: product_id
        )
    end

    # case can_proceed?(my_resource, conn) do
    #   false ->
    #     unauthorized_access(conn)

    #   true ->
    # changeset = Kaffy.ResourceAdmin.create_changeset(my_resource, %{}) |> Map.put(:errors, [])

    #     render(conn, "new_product_image.html",
    #       layout: {KaffyWeb.LayoutView, "app.html"},
    #       changeset: changeset,
    #       context: context,
    #       resource: resource,
    #       resource_name: resource_name,
    #       my_resource: my_resource,
    #       product_id: product_id
    #     )
    # end
  end

  def new(
        conn,
        %{
          "context" => context,
          "id" => product_id,
          "resource" => "price" = resource
        } = params
      ) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    resource_name = Kaffy.ResourceAdmin.singular_name(my_resource)

    params = Map.delete(params, "id")

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        changeset = Kaffy.ResourceAdmin.create_changeset(my_resource, %{}) |> Map.put(:errors, [])
        fields = Kaffy.ResourceAdmin.index(my_resource)
        {filtered_count, entries} = Kaffy.ResourceQuery.list_resource(conn, my_resource, params)
        items_per_page = Map.get(params, "limit", "100") |> String.to_integer()
        page = Map.get(params, "page", "1") |> String.to_integer()
        has_next = round(filtered_count / items_per_page) > page
        next_class = if has_next, do: "", else: " disabled"
        has_prev = page >= 2
        prev_class = if has_prev, do: "", else: " disabled"
        list_pages = Pagination.get_pages(page, ceil(filtered_count / items_per_page))

        render(conn, "child_new.html",
          layout: {KaffyWeb.LayoutView, "app.html"},
          changeset: changeset,
          resource_name: resource_name,
          context: context,
          resource: resource,
          fields: fields,
          my_resource: my_resource,
          filtered_count: filtered_count,
          page: page,
          has_next_page: has_next,
          next_class: next_class,
          has_prev_page: has_prev,
          prev_class: prev_class,
          list_pages: list_pages,
          entries: entries,
          params: params,
          product_id: product_id
        )
    end
  end

  def new(conn, %{
        "context" => context,
        "id" => product_id,
        "resource" => "product_property" = resource
      }) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    resource_name = Kaffy.ResourceAdmin.singular_name(my_resource)

    case can_proceed?(my_resource, conn) do
      false ->
        unauthorized_access(conn)

      true ->
        changeset = Kaffy.ResourceAdmin.create_changeset(my_resource, %{}) |> Map.put(:errors, [])

        render(conn, "child_new.html",
          layout: {KaffyWeb.LayoutView, "app.html"},
          changeset: changeset,
          context: context,
          resource: resource,
          resource_name: resource_name,
          my_resource: my_resource,
          product_id: product_id
        )
    end
  end

  def update(
        conn,
        %{
          "context" => context,
          "product_id" => product_id,
          "resource" => "stock_item" = resource,
          "id" => id
        } = params
      ) do
    my_resource = Kaffy.Utils.get_resource(conn, context, resource)
    schema = my_resource[:schema]
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
                    Kaffy.Utils.router().kaffy_product_path(
                      conn,
                      :index,
                      context,
                      product_id,
                      resource
                    )
                )

              "Save and add another" ->
                conn
                |> put_flash(:success, "#{resource_name} saved successfully")
                |> redirect(
                  to: Kaffy.Utils.router().kaffy_product_path(conn, :new, context, resource)
                )

              "Save and continue editing" ->
                conn
                |> put_flash(:success, "#{resource_name} saved successfully")
                |> redirect_to_resource(context, resource, entry)
            end

          {:error, %Ecto.Changeset{}} ->
            conn =
              put_flash(
                conn,
                :error,
                "A problem occurred while trying to save this #{resource}"
              )

            redirect(conn,
              to:
                Kaffy.Utils.router().kaffy_product_path(
                  conn,
                  :index,
                  context,
                  product_id,
                  resource
                )
            )

          {:error, {_entry, error}} when is_binary(error) ->
            conn = put_flash(conn, :error, error)
            # changeset = Ecto.Changeset.change(entry)

            redirect(conn,
              to:
                Kaffy.Utils.router().kaffy_product_path(
                  conn,
                  :index,
                  context,
                  product_id,
                  resource
                )
            )
        end
    end
  end

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
