defmodule Exlivery.Users.UserTest do
  use ExUnit.Case

  alias Exlivery.Users.User

  describe "build/5" do
    test "when all params are valid, returns the user" do
      response =
        User.build("Rua das bananeiras", "Cintia", "cintia@banana.com", "12345678900", 36)

      expected_response =
        {:ok,
         %User{
           address: "Rua das bananeiras",
           age: 36,
           cpf: "12345678900",
           email: "cintia@banana.com",
           name: "Cintia"
         }}

      assert response == expected_response
    end

    test "when there are invalid params, returns an error" do
      response =
        User.build("Rua das bananeiras", "Cintiazita", "cintia@banana.com", "12345678900", 15)

      expected_response = {:error, "Invalid parameters."}

      assert response == expected_response
    end
  end
end
