defmodule Kaffy.Routes do
  @moduledoc """
  Kaffy.Routes must be "used" in your phoenix routes:

  ```elixir
  use Kaffy.Routes, scope: "/admin", pipe_through: [:browser, :authenticate]
  ```

  `:scope` defaults to `"/admin"`

  `:pipe_through` defaults to kaffy's `[:kaffy_browser]`
  """

  # use Phoenix.Router

  defmacro __using__(options \\ []) do
    scoped = Keyword.get(options, :scope, "/admin")
    custom_pipes = Keyword.get(options, :pipe_through, [])
    pipes = [:kaffy_browser] ++ custom_pipes

    quote do
      pipeline :kaffy_browser do
        plug(:accepts, ["html", "json"])
        plug(:fetch_session)
        plug(:fetch_flash)
        plug(:protect_from_forgery)
        plug(:put_secure_browser_headers)
      end

      scope unquote(scoped), KaffyWeb do
        pipe_through(unquote(pipes))

        get("/", HomeController, :index, as: :kaffy_home)
        get("/dashboard", HomeController, :dashboard, as: :kaffy_dashboard)
        get("/tasks", TaskController, :index, as: :kaffy_task)
        get("/p/:slug", PageController, :index, as: :kaffy_page)
        get("/:context/:resource", ResourceController, :index, as: :kaffy_resource)
        post("/:context/:resource", ResourceController, :create, as: :kaffy_resource)

        post("/:context/:resource/:id/action/:action_key", ResourceController, :single_action,
          as: :kaffy_resource
        )

        post("/:context/:resource/action/:action_key", ResourceController, :list_action,
          as: :kaffy_resource
        )

        get("/:context/:resource/new", ResourceController, :new, as: :kaffy_resource)

        get("/:context/:resource/:id", ResourceController, :show, as: :kaffy_resource)
        get("/:context/:product_id/:resource/:id", ResourceController, :show, as: :kaffy_resource)
        put("/:context/:resource/:id", ResourceController, :update, as: :kaffy_resource)
        delete("/:context/:resource/:id", ResourceController, :delete, as: :kaffy_resource)

        get("/kaffy/api/:context/:resource", ResourceController, :api, as: :kaffy_api_resource)

        # Product routes
        get("/:context/:product_id/:resource/index", ResourceController, :index,
          as: :kaffy_resource
        )

        get("products/:context/:product_id/:resource/index", ProductController, :index,
          as: :kaffy_product
        )

        get("products/:context/:id/:resource/new", ProductController, :new, as: :kaffy_product)
        post("products/:context/:id/:resource", ProductController, :create, as: :kaffy_product)
        # get("/orders/:context/:resource/new", OrderController, :new, as: :kaffy_order)

        put("products/:context/:product_id/:resource/:id", ProductController, :update,
          as: :kaffy_product
        )

        post("/:context/:id/:resource", ResourceController, :create, as: :kaffy_resource)
        post("orders/:context/:id/:resource", OrderController, :add_to_cart, as: :kaffy_order)
        get("/:context/:id/:resource/new", ResourceController, :new, as: :kaffy_resource)
        put("/orders/:context/:id/:resource", OrderController, :clear_cart, as: :kaffy_order)

        # get("/orders/customers/:context/:order_id/:resource", OrderController, :customer,
        #   as: :kaffy_order
        # )

        get("/orders/customers/:context/:resource/:order_id", OrderController, :order_customer,
          as: :kaffy_order
        )

        get("/orders/cart/:context/:resource/:order_id", OrderController, :cart, as: :kaffy_order)

        get("/orders/address/:context/:resource/:order_id", OrderController, :new_address,
          as: :kaffy_order
        )

        post("/orders/address/:context/:resource/:order_id", OrderController, :create_address,
          as: :kaffy_order
        )

        put("orders/customers/:context/:resource/:order_id", OrderController, :update_customer,
          as: :kaffy_order
        )
      end
    end
  end
end
