# Exlivery

## Criando o projeto

Criar novo projeto pelo bash:

```bash
mix new exlivery
```

Adicionar dependência do Credo:

```elixir
def deps do
  [
    {:credo, "~> 1.5", only: [:dev, :test], runtime: false}
  ]
end
```

Configurando Credo:

```bash
mix credo gen.config
```

E no arquivo `.credo.exs`, trocar essa regra para false:

```elixir
{Credo.Check.Readability.ModuleDoc, false},
```

## Construindo a struct do Usuário

Criar uma [struct](https://elixir-lang.org/getting-started/structs.html) no arquivo `lib/users/user.ex`:

```elixir
defmodule Exlivery.Users.User do
  defstruct [:name, :email]
end
```

Rodar o `iex` no terminal:

```bash
iex -S mix
```

```elixir
iex> %Exlivery.Users.User{}
#..> %Exlivery.Users.User{email: nil, name: nil}
```

Structs é basicamente: um mapa com um nome.

Podemos fazer um `alias`:

```elixir
iex> alias Exlivery.Users.User
iex> %User{}
#..> %Exlivery.Users.User{email: nil, name: nil}
iex> %User{email: "cintiafumi@gmail.com", name: "Cintia Fumi"}
#..> %Exlivery.Users.User{email: "cintiafumi@gmail.com", name: "Cintia Fumi"}
iex> user = %User{email: "cintiafumi@gmail.com", name: "Cintia Fumi"}
#..> %Exlivery.Users.User{email: "cintiafumi@gmail.com", name: "Cintia Fumi"}
iex> is_map(user)
#..> true
```

Usaremos `struct` quando quisermos envelopar dados, transmitir dados de um lado para outro e dar mais significado para esse dado. Ao invés de um map puro, queremos bater o olho no código e saber que é um usuário, que é um pedido, que é um carro.

Vamos deixar nossa `struct` completa:

```elixir
defmodule Exlivery.Users.User do
  defstruct [:name, :email, :cpf, :age]
end
```

Ao recompilar o código, vamos criar novamente `user`:

```elixir
iex> user = %User{email: "cintiafumi@gmail.com", name: "Cintia Fumi"}
#..> %Exlivery.Users.User{
#..>   age: nil,
#..>   cpf: nil,
#..>   email: "cintiafumi@gmail.com",
#..>   name: "Cintia Fumi"
#..> }
iex> Map.put(user, :age, 36)
#..> %Exlivery.Users.User{
#..>   age: 36,
#..>   cpf: nil,
#..>   email: "cintiafumi@gmail.com",
#..>   name: "Cintia Fumi"
#..> }
iex> %{user | cpf: "123456789"}
#..> %Exlivery.Users.User{
#..>   age: nil,
#..>   cpf: "123456789",
#..>   email: "cintiafumi@gmail.com",
#..>   name: "Cintia Fumi"
#..> }
```

A partir de agora, sempre que formos transitar dados de usuário, iremos buildar uma struct e passar essa struct para nossas funções como argumento.

Também podemos fazer pattern matching:

```elixir
iex> %User{email: valor} = user
#..> %Exlivery.Users.User{
#..>   age: nil,
#..>   cpf: nil,
#..>   email: "cintiafumi@gmail.com",
#..>   name: "Cintia Fumi"
#..> }
iex> valor
#..> "cintiafumi@gmail.com"
```

Agora temos um novo contexto `user` que vai ter várias funcionalidades ao redor de `user`. E com isso, seguiremos com separação de código por contexto (Domain Driven Design). Definindo os contextos da aplicação como boa prática, isolando os comportamentos, os códigos e os módulos da aplicação.
