defmodule ElixirAnki.Factory do
  use ExMachina.Ecto, repo: ElixirAnki.Repo
  @dialyzer {:no_return, fields_for: 1}

  alias ElixirAnki.User

  def user_factory do
    %User{
      username: Faker.Internet.user_name(),
      email: Faker.Internet.email(),
      password_hash: Faker.String.base64(10)
    }
  end
end
