defmodule Pleroma.Web.OStatus.ActivityRepresenterTest do
  use Pleroma.DataCase

  alias Pleroma.Web.OStatus.ActivityRepresenter
  alias Pleroma.{User, Activity, Object}
  alias Pleroma.Web.ActivityPub.ActivityPub

  import Pleroma.Factory

  test "a note activity" do
    note_activity = insert(:note_activity)

    user = User.get_cached_by_ap_id(note_activity.data["actor"])

    expected = """
    <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
    <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
    <id>#{note_activity.data["object"]["id"]}</id>
    <title>New note by #{user.nickname}</title>
    <content type="html">#{note_activity.data["object"]["content"]}</content>
    <published>#{note_activity.data["object"]["published"]}</published>
    <updated>#{note_activity.data["object"]["published"]}</updated>
    <ostatus:conversation>#{note_activity.data["context"]}</ostatus:conversation>
    <link ref="#{note_activity.data["context"]}" rel="ostatus:conversation" />
    <link type="application/atom+xml" href="#{note_activity.data["object"]["id"]}" rel="self" />
    <link type="text/html" href="#{note_activity.data["object"]["id"]}" rel="alternate" />
    <category term="2hu"/>
    <link rel="mentioned" ostatus:object-type="http://activitystrea.ms/schema/1.0/collection" href="http://activityschema.org/collection/public"/>
    """

    tuple = ActivityRepresenter.to_simple_form(note_activity, user)

    res = :xmerl.export_simple_content(tuple, :xmerl_xml) |> IO.iodata_to_binary

    assert clean(res) == clean(expected)
  end

  test "a reply note" do
    note = insert(:note_activity)
    answer = insert(:note_activity)
    object = answer.data["object"]
    object = Map.put(object, "inReplyTo", note.data["object"]["id"])

    data = %{answer.data | "object" => object}
    answer = %{answer | data: data}

    user = User.get_cached_by_ap_id(answer.data["actor"])

    expected = """
    <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
    <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
    <id>#{answer.data["object"]["id"]}</id>
    <title>New note by #{user.nickname}</title>
    <content type="html">#{answer.data["object"]["content"]}</content>
    <published>#{answer.data["object"]["published"]}</published>
    <updated>#{answer.data["object"]["published"]}</updated>
    <ostatus:conversation>#{answer.data["context"]}</ostatus:conversation>
    <link ref="#{answer.data["context"]}" rel="ostatus:conversation" />
    <link type="application/atom+xml" href="#{answer.data["object"]["id"]}" rel="self" />
    <link type="text/html" href="#{answer.data["object"]["id"]}" rel="alternate" />
    <category term="2hu"/>
    <thr:in-reply-to ref="#{note.data["object"]["id"]}" />
    <link rel="mentioned" ostatus:object-type="http://activitystrea.ms/schema/1.0/collection" href="http://activityschema.org/collection/public"/>
    """

    tuple = ActivityRepresenter.to_simple_form(answer, user)

    res = :xmerl.export_simple_content(tuple, :xmerl_xml) |> IO.iodata_to_binary

    assert clean(res) == clean(expected)
  end

  test "an announce activity" do
    note = insert(:note_activity)
    user = insert(:user)
    object = Object.get_cached_by_ap_id(note.data["object"]["id"])

    {:ok, announce, object} = ActivityPub.announce(user, object)

    announce = Repo.get(Activity, announce.id)

    note_user = User.get_cached_by_ap_id(note.data["actor"])
    note = Repo.get(Activity, note.id)
    note_xml = ActivityRepresenter.to_simple_form(note, note_user, true)
    |> :xmerl.export_simple_content(:xmerl_xml)
    |> to_string

    expected = """
    <activity:object-type>http://activitystrea.ms/schema/1.0/activity</activity:object-type>
    <activity:verb>http://activitystrea.ms/schema/1.0/share</activity:verb>
    <id>#{announce.data["id"]}</id>
    <title>#{user.nickname} repeated a notice</title>
    <content type="html">RT #{note.data["object"]["content"]}</content>
    <published>#{announce.data["published"]}</published>
    <updated>#{announce.data["published"]}</updated>
    <ostatus:conversation>#{announce.data["context"]}</ostatus:conversation>
    <link ref="#{announce.data["context"]}" rel="ostatus:conversation" />
    <link rel="self" type="application/atom+xml" href="#{announce.data["id"]}"/>
    <activity:object>
      #{note_xml}
    </activity:object>
    <link rel="mentioned" ostatus:object-type="http://activitystrea.ms/schema/1.0/person" href="#{note.data["actor"]}"/>
    """

    announce_xml = ActivityRepresenter.to_simple_form(announce, user)
    |> :xmerl.export_simple_content(:xmerl_xml)
    |> to_string

    assert clean(expected) == clean(announce_xml)
  end

  test "a like activity" do
    note = insert(:note)
    user = insert(:user)
    {:ok, like, _note} = ActivityPub.like(user, note)

    tuple = ActivityRepresenter.to_simple_form(like, user)
    refute is_nil(tuple)

    res = :xmerl.export_simple_content(tuple, :xmerl_xml) |> IO.iodata_to_binary

    expected = """
    <activity:verb>http://activitystrea.ms/schema/1.0/favorite</activity:verb>
    <id>#{like.data["id"]}</id>
    <title>New favorite by #{user.nickname}</title>
    <content type="html">#{user.nickname} favorited something</content>
    <published>#{like.data["published"]}</published>
    <updated>#{like.data["published"]}</updated>
    <activity:object>
      <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
      <id>#{note.data["id"]}</id>
    </activity:object>
    <ostatus:conversation>#{like.data["context"]}</ostatus:conversation>
    <link ref="#{like.data["context"]}" rel="ostatus:conversation" />
    <link rel="self" type="application/atom+xml" href="#{like.data["id"]}"/>
    <thr:in-reply-to ref="#{note.data["id"]}" />
    <link rel="mentioned" ostatus:object-type="http://activitystrea.ms/schema/1.0/person" href="#{note.data["actor"]}"/>
    """

    assert clean(res) == clean(expected)
  end

  test "a follow activity" do
    follower = insert(:user)
    followed = insert(:user)
    {:ok, activity} = ActivityPub.insert(%{
          "type" => "Follow",
          "actor" => follower.ap_id,
          "object" => followed.ap_id,
          "to" => [followed.ap_id]
    })

    tuple = ActivityRepresenter.to_simple_form(activity, follower)

    refute is_nil(tuple)

    res = :xmerl.export_simple_content(tuple, :xmerl_xml) |> IO.iodata_to_binary

    expected = """
    <activity:object-type>http://activitystrea.ms/schema/1.0/activity</activity:object-type>
    <activity:verb>http://activitystrea.ms/schema/1.0/follow</activity:verb>
    <id>#{activity.data["id"]}</id>
    <title>#{follower.nickname} started following #{activity.data["object"]}</title>
    <content type="html"> #{follower.nickname} started following #{activity.data["object"]}</content>
    <published>#{activity.data["published"]}</published>
    <updated>#{activity.data["published"]}</updated>
    <activity:object>
      <activity:object-type>http://activitystrea.ms/schema/1.0/person</activity:object-type>
      <id>#{activity.data["object"]}</id>
      <uri>#{activity.data["object"]}</uri>
    </activity:object>
    <link rel="self" type="application/atom+xml" href="#{activity.data["id"]}"/>
    <link rel="mentioned" ostatus:object-type="http://activitystrea.ms/schema/1.0/person" href="#{activity.data["object"]}"/>
    """

    assert clean(res) == clean(expected)
  end

  test "an unfollow activity" do
    follower = insert(:user)
    followed = insert(:user)
    {:ok, _activity} = ActivityPub.follow(follower, followed)
    {:ok, activity} = ActivityPub.unfollow(follower, followed)

    tuple = ActivityRepresenter.to_simple_form(activity, follower)

    refute is_nil(tuple)

    res = :xmerl.export_simple_content(tuple, :xmerl_xml) |> IO.iodata_to_binary

    expected = """
    <activity:object-type>http://activitystrea.ms/schema/1.0/activity</activity:object-type>
    <activity:verb>http://activitystrea.ms/schema/1.0/unfollow</activity:verb>
    <id>#{activity.data["id"]}</id>
    <title>#{follower.nickname} stopped following #{followed.ap_id}</title>
    <content type="html"> #{follower.nickname} stopped following #{followed.ap_id}</content>
    <published>#{activity.data["published"]}</published>
    <updated>#{activity.data["published"]}</updated>
    <activity:object>
      <activity:object-type>http://activitystrea.ms/schema/1.0/person</activity:object-type>
      <id>#{followed.ap_id}</id>
      <uri>#{followed.ap_id}</uri>
    </activity:object>
    <link rel="self" type="application/atom+xml" href="#{activity.data["id"]}"/>
    <link rel="mentioned" ostatus:object-type="http://activitystrea.ms/schema/1.0/person" href="#{followed.ap_id}"/>
    """

    assert clean(res) == clean(expected)
  end

  test "an unknown activity" do
    tuple = ActivityRepresenter.to_simple_form(%Activity{}, nil)
    assert is_nil(tuple)
  end

  defp clean(string) do
    String.replace(string, ~r/\s/, "")
  end
end
