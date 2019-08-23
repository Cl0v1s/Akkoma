# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Workers.Subscriber do
  alias Pleroma.Repo
  alias Pleroma.Web.Federator
  alias Pleroma.Web.Websub.WebsubClientSubscription

  # Note: `max_attempts` is intended to be overridden in `new/1` call
  use Oban.Worker,
    queue: "federator_outgoing",
    max_attempts: 1

  @impl Oban.Worker
  def perform(%{"op" => "refresh_subscriptions"}, _job) do
    Federator.perform(:refresh_subscriptions)
  end

  def perform(%{"op" => "request_subscription", "websub_id" => websub_id}, _job) do
    websub = Repo.get(WebsubClientSubscription, websub_id)
    Federator.perform(:request_subscription, websub)
  end

  def perform(%{"op" => "verify_websub", "websub_id" => websub_id}, _job) do
    websub = Repo.get(WebsubClientSubscription, websub_id)
    Federator.perform(:verify_websub, websub)
  end
end
