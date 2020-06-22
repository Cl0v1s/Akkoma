# Pleroma: A lightweight social networking server
# Copyright © 2017-2020 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.MigrationHelper.NotificationBackfill do
  alias Pleroma.Notification
  alias Pleroma.Object
  alias Pleroma.Repo
  alias Pleroma.User

  import Ecto.Query

  def fill_in_notification_types do
    query =
      from(n in Pleroma.Notification,
        where: is_nil(n.type),
        preload: :activity
      )

    query
    |> Repo.chunk_stream(100)
    |> Enum.each(fn notification ->
      type =
        notification.activity
        |> type_from_activity()

      notification
      |> Notification.changeset(%{type: type})
      |> Repo.update()
    end)
  end

  # This is copied over from Notifications to keep this stable.
  defp type_from_activity(%{data: %{"type" => type}} = activity) do
    case type do
      "Follow" ->
        accepted_function = fn activity ->
          with %User{} = follower <- User.get_by_ap_id(activity.data["actor"]),
               %User{} = followed <- User.get_by_ap_id(activity.data["object"]) do
            Pleroma.FollowingRelationship.following?(follower, followed)
          end
        end

        if accepted_function.(activity) do
          "follow"
        else
          "follow_request"
        end

      "Announce" ->
        "reblog"

      "Like" ->
        "favourite"

      "Move" ->
        "move"

      "EmojiReact" ->
        "pleroma:emoji_reaction"

      # Compatibility with old reactions
      "EmojiReaction" ->
        "pleroma:emoji_reaction"

      "Create" ->
        activity
        |> type_from_activity_object()

      t ->
        raise "No notification type for activity type #{t}"
    end
  end

  defp type_from_activity_object(%{data: %{"type" => "Create", "object" => %{}}}), do: "mention"

  defp type_from_activity_object(%{data: %{"type" => "Create"}} = activity) do
    object = Object.get_by_ap_id(activity.data["object"])

    case object && object.data["type"] do
      "ChatMessage" -> "pleroma:chat_mention"
      _ -> "mention"
    end
  end
end