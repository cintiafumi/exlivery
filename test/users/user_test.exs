defmodule Exlivery.Users.UserTest do
  use ExUnit.Case

  import Exlivery.Factory

  alias Exlivery.Users.User

  describe "build/5" do
    test "when all params are valid, returns the user" do
      response =
        User.build("Rua das bananeiras, 35", "Cintia", "cintia@banana.com", "12345678900", 36)

      expected_response = {:ok, build(:user)}

      assert response == expected_response
    end

    test "when there are invalid params, returns an error" do
      response =
        User.build("Rua das bananeiras, 35", "Cintia", "cintia@banana.com", "12345678900", 16)

      expected_response = {:error, "Invalid parameters."}

      assert response == expected_response
    end
  end
end
