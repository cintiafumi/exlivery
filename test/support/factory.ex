defmodule Exlivery.Factory do
  use ExMachina

  alias Exlivery.Users.User

  def user_factory do
    %User{
      name: "Cintia",
      email: "cintia@banana.com",
      cpf: "12345678900",
      age: 36,
      address: "Rua das bananeiras, 35"
    }
  end
end
