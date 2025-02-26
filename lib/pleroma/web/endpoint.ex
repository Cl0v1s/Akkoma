# Pleroma: A lightweight social networking server
# Copyright © 2017-2021 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :pleroma

  require Pleroma.Constants

  alias Pleroma.Config

  socket("/live", Phoenix.LiveView.Socket)

  plug(Pleroma.Web.Plugs.SetLocalePlug)
  plug(CORSPlug)
  plug(Pleroma.Web.Plugs.CSPNoncePlug)
  plug(Pleroma.Web.Plugs.HTTPSecurityPlug)
  plug(Pleroma.Web.Plugs.UploadedMedia)

  @static_cache_control "public, no-cache"

  # InstanceStatic needs to be before Plug.Static to be able to override shipped-static files
  # If you're adding new paths to `only:` you'll need to configure them in InstanceStatic as well
  # Cache-control headers are duplicated in case we turn off etags in the future
  plug(
    Pleroma.Web.Plugs.InstanceStatic,
    at: "/",
    from: :pleroma,
    only: ["emoji", "images"],
    gzip: true,
    cache_control_for_etags: "public, max-age=1209600",
    headers: %{
      "cache-control" => "public, max-age=1209600"
    }
  )

  plug(Pleroma.Web.Plugs.InstanceStatic,
    at: "/",
    gzip: true,
    cache_control_for_etags: @static_cache_control,
    headers: %{
      "cache-control" => @static_cache_control
    }
  )

  # Careful! No `only` restriction here, as we don't know what frontends contain.
  plug(Pleroma.Web.Plugs.FrontendStatic,
    at: "/",
    frontend_type: :primary,
    gzip: true,
    cache_control_for_etags: @static_cache_control,
    headers: %{
      "cache-control" => @static_cache_control
    }
  )

  plug(Plug.Static.IndexHtml, at: "/pleroma/admin/")

  plug(Pleroma.Web.Plugs.FrontendStatic,
    at: "/pleroma/admin",
    frontend_type: :admin,
    gzip: true,
    cache_control_for_etags: @static_cache_control,
    headers: %{
      "cache-control" => @static_cache_control
    }
  )

  plug(Plug.Static.IndexHtml, at: "/pleroma/swaggerui/")

  plug(Pleroma.Web.Plugs.FrontendStatic,
    at: "/pleroma/swaggerui",
    frontend_type: :swagger,
    gzip: true,
    if: &Pleroma.Web.Swagger.ui_enabled?/0,
    cache_control_for_etags: @static_cache_control,
    headers: %{
      "cache-control" => @static_cache_control
    }
  )

  plug(Pleroma.Web.Plugs.FrontendStatic,
    at: "/",
    frontend_type: :mastodon,
    gzip: true,
    cache_control_for_etags: @static_cache_control,
    headers: %{
      "cache-control" => @static_cache_control
    }
  )

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug(
    Plug.Static,
    at: "/",
    from: :pleroma,
    only: Pleroma.Web.static_paths(),
    # JSON-LD is accepted by some servers for AP objects and activities,
    # thus only enable it here instead of a global extension mapping
    # (it's our only *.jsonld file anyway)
    content_types: %{"litepub-0.1.jsonld" => "application/ld+json"},
    # credo:disable-for-previous-line Credo.Check.Readability.MaxLineLength
    gzip: true,
    cache_control_for_etags: @static_cache_control,
    headers: %{
      "cache-control" => @static_cache_control
    }
  )

  plug(Plug.Static,
    at: "/pleroma/admin/",
    from: {:pleroma, "priv/static/adminfe/"}
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug(Phoenix.CodeReloader)
  end

  plug(Pleroma.Web.Plugs.TrailingFormatPlug)
  plug(Plug.RequestId)
  plug(Plug.Logger, log: :debug)

  plug(Plug.Parsers,
    parsers: [
      :urlencoded,
      Pleroma.Web.Plugs.Parsers.Multipart,
      :json
    ],
    pass: ["*/*"],
    json_decoder: Jason,
    length: Config.get([:instance, :upload_limit]),
    body_reader: {Pleroma.Web.Plugs.DigestPlug, :read_body, []}
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  secure_cookies = Config.get([__MODULE__, :secure_cookie_flag])

  cookie_name =
    if secure_cookies,
      do: "__Host-pleroma_key",
      else: "pleroma_key"

  extra =
    Config.get([__MODULE__, :extra_cookie_attrs])
    |> Enum.join(";")

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(
    Plug.Session,
    store: :cookie,
    key: cookie_name,
    signing_salt: Config.get([__MODULE__, :signing_salt], "CqaoopA2"),
    http_only: true,
    secure: secure_cookies,
    extra: extra
  )

  plug(Pleroma.Web.Plugs.RemoteIp)

  plug(Pleroma.Web.Router)

  @doc """
  Dynamically loads configuration from the system environment
  on startup.

  It receives the endpoint configuration from the config files
  and must return the updated configuration.
  """
  def load_from_system_env(config) do
    port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
    {:ok, Keyword.put(config, :http, [:inet6, port: port])}
  end

  def websocket_url do
    String.replace_leading(url(), "http", "ws")
  end
end
