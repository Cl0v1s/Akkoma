# Pleroma: A lightweight social networking server
# Copyright © 2017-2021 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.PleromaAPI.EmojiReactionController do
  use Pleroma.Web, :controller

  alias Pleroma.Activity
  alias Pleroma.Object
  alias Pleroma.User
  alias Pleroma.Web.CommonAPI
  alias Pleroma.Web.MastodonAPI.StatusView
  alias Pleroma.Web.Plugs.OAuthScopesPlug

  plug(Pleroma.Web.ApiSpec.CastAndValidate)
  plug(OAuthScopesPlug, %{scopes: ["write:statuses"]} when action in [:create, :delete])

  plug(
    OAuthScopesPlug,
    %{scopes: ["read:statuses"], fallback: :proceed_unauthenticated}
    when action == :index
  )

  defdelegate open_api_operation(action), to: Pleroma.Web.ApiSpec.EmojiReactionOperation

  action_fallback(Pleroma.Web.MastodonAPI.FallbackController)

  def index(%{assigns: %{user: user}} = conn, %{id: activity_id} = params) do
    with true <- Pleroma.Config.get([:instance, :show_reactions]),
         %Activity{} = activity <- Activity.get_by_id_with_object(activity_id),
         %Object{data: %{"reactions" => reactions}} when is_list(reactions) <-
           Object.normalize(activity, fetch: false) do
      reactions =
        reactions
        |> filter(params)
        |> filter_allowed_users(user, Map.get(params, :with_muted, false))

      render(conn, "index.json", emoji_reactions: reactions, user: user)
    else
      _e -> json(conn, [])
    end
  end

  defp filter_allowed_user_by_ap_id(ap_ids, excluded_ap_ids) do
    Enum.reject(ap_ids, fn ap_id ->
      with false <- ap_id in excluded_ap_ids,
           %{is_active: true} <- User.get_cached_by_ap_id(ap_id) do
        false
      else
        _ -> true
      end
    end)
  end

  defp filter_allowed_users_by_domain(ap_ids, %User{} = for_user) do
    Enum.reject(ap_ids, fn ap_id ->
      User.blocks_domain?(for_user, ap_id)
    end)
  end

  defp filter_allowed_users_by_domain(ap_ids, nil), do: ap_ids

  def filter_allowed_users(reactions, user, with_muted) do
    exclude_ap_ids =
      if is_nil(user) do
        []
      else
        User.cached_blocked_users_ap_ids(user) ++
          if not with_muted, do: User.cached_muted_users_ap_ids(user), else: []
      end

    filter_emoji = fn emoji, users, url ->
      users
      |> filter_allowed_user_by_ap_id(exclude_ap_ids)
      |> filter_allowed_users_by_domain(user)
      |> case do
        [] -> nil
        users -> {emoji, users, url}
      end
    end

    reactions
    |> Stream.map(fn
      [emoji, users, url] when is_list(users) -> filter_emoji.(emoji, users, url)
      {emoji, users, url} when is_list(users) -> filter_emoji.(emoji, users, url)
      {emoji, users} when is_list(users) -> filter_emoji.(emoji, users, nil)
      _ -> nil
    end)
    |> Stream.reject(&is_nil/1)
  end

  defp filter(reactions, %{emoji: emoji}) when is_binary(emoji) do
    Enum.filter(reactions, fn [e, _, _] -> e == emoji end)
  end

  defp filter(reactions, _), do: reactions

  def create(%{assigns: %{user: user}} = conn, %{id: activity_id, emoji: emoji}) do
    emoji =
      emoji
      |> Pleroma.Emoji.fully_qualify_emoji()
      |> Pleroma.Emoji.maybe_quote()

    with {:ok, _activity} <- CommonAPI.react_with_emoji(activity_id, user, emoji) do
      activity = Activity.get_by_id(activity_id)

      conn
      |> put_view(StatusView)
      |> render("show.json", activity: activity, for: user, as: :activity)
    end
  end

  def delete(%{assigns: %{user: user}} = conn, %{id: activity_id, emoji: emoji}) do
    emoji =
      emoji
      |> Pleroma.Emoji.fully_qualify_emoji()
      |> Pleroma.Emoji.maybe_quote()

    with {:ok, _activity} <- CommonAPI.unreact_with_emoji(activity_id, user, emoji) do
      activity = Activity.get_by_id(activity_id)

      conn
      |> put_view(StatusView)
      |> render("show.json", activity: activity, for: user, as: :activity)
    end
  end
end
