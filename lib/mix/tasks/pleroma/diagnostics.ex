# credo:disable-for-this-file
defmodule Mix.Tasks.Pleroma.Diagnostics do
  alias Pleroma.Repo
  alias Pleroma.User

  require Pleroma.Constants

  import Mix.Pleroma
  import Ecto.Query
  use Mix.Task

  def run(["http", url]) do
    start_pleroma()

    Pleroma.HTTP.get(url)
    |> shell_info()
  end

  def run(["fetch_object", url]) do
    start_pleroma()

    Pleroma.Object.Fetcher.fetch_object_from_id(url)
    |> IO.inspect()
  end

  def run(["home_timeline", nickname]) do
    start_pleroma()
    user = Repo.get_by!(User, nickname: nickname)
    shell_info("Home timeline query #{user.nickname}")

    followed_hashtags =
      user
      |> User.followed_hashtags()
      |> Enum.map(& &1.id)

    params =
      %{limit: 20}
      |> Map.put(:type, ["Create", "Announce"])
      |> Map.put(:blocking_user, user)
      |> Map.put(:muting_user, user)
      |> Map.put(:reply_filtering_user, user)
      |> Map.put(:announce_filtering_user, user)
      |> Map.put(:user, user)
      |> Map.put(:followed_hashtags, followed_hashtags)
      |> Map.delete(:local)

    list_memberships = Pleroma.List.memberships(user)
    recipients = [user.ap_id | User.following(user)]

    query =
      Pleroma.Web.ActivityPub.ActivityPub.fetch_activities_query(
        recipients ++ list_memberships,
        params
      )
      |> limit(20)

    Ecto.Adapters.SQL.explain(Repo, :all, query, analyze: true, timeout: :infinity)
    |> shell_info()
  end

  def run(["user_timeline", nickname, reading_nickname]) do
    start_pleroma()
    user = Repo.get_by!(User, nickname: nickname)
    reading_user = Repo.get_by!(User, nickname: reading_nickname)
    shell_info("User timeline query #{user.nickname}")

    params =
      %{limit: 20}
      |> Map.put(:type, ["Create", "Announce"])
      |> Map.put(:user, reading_user)
      |> Map.put(:actor_id, user.ap_id)
      |> Map.put(:pinned_object_ids, Map.keys(user.pinned_objects))

    list_memberships = Pleroma.List.memberships(user)

    recipients =
      %{
        godmode: params[:godmode],
        reading_user: reading_user
      }
      |> Pleroma.Web.ActivityPub.ActivityPub.user_activities_recipients()

    query =
      (recipients ++ list_memberships)
      |> Pleroma.Web.ActivityPub.ActivityPub.fetch_activities_query(params)
      |> limit(20)

    Ecto.Adapters.SQL.explain(Repo, :all, query, analyze: true, timeout: :infinity)
    |> shell_info()
  end

  def run(["notifications", nickname]) do
    start_pleroma()
    user = Repo.get_by!(User, nickname: nickname)
    account_ap_id = user.ap_id
    options = %{account_ap_id: user.ap_id}

    query =
      user
      |> Pleroma.Notification.for_user_query(options)
      |> where([n, a], a.actor == ^account_ap_id)
      |> limit(20)

    Ecto.Adapters.SQL.explain(Repo, :all, query, analyze: true, timeout: :infinity)
    |> shell_info()
  end

  def run(["known_network", nickname]) do
    start_pleroma()
    user = Repo.get_by!(User, nickname: nickname)

    params =
      %{}
      |> Map.put(:type, ["Create"])
      |> Map.put(:local_only, false)
      |> Map.put(:blocking_user, user)
      |> Map.put(:muting_user, user)
      |> Map.put(:reply_filtering_user, user)
      # Restricts unfederated content to authenticated users
      |> Map.put(:includes_local_public, not is_nil(user))
      |> Map.put(:restrict_unlisted, true)

    query =
      Pleroma.Web.ActivityPub.ActivityPub.fetch_activities_query(
        [Pleroma.Constants.as_public()],
        params
      )
      |> limit(20)

    Ecto.Adapters.SQL.explain(Repo, :all, query, analyze: true, timeout: :infinity)
    |> shell_info()
  end
end
