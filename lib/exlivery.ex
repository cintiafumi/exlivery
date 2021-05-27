defmodule Exlivery do
  alias Exlivery.Users.Agent, as: UsersAgent
  alias Exlivery.Users.CreateOrUpdate

  def start_agents do
    UsersAgent.start_link(%{})
  end

  defdelegate create_or_update_user(params), to: CreateOrUpdate, as: :call
end
