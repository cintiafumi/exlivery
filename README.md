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
%Exlivery.Users.User{email: nil, name: nil}
```

Structs é basicamente: um mapa com um nome.

Podemos fazer um `alias`:

```elixir
iex> alias Exlivery.Users.User
iex> %User{}
%Exlivery.Users.User{email: nil, name: nil}
iex> %User{email: "cintiafumi@gmail.com", name: "Cintia Fumi"}
%Exlivery.Users.User{email: "cintiafumi@gmail.com", name: "Cintia Fumi"}
iex> user = %User{email: "cintiafumi@gmail.com", name: "Cintia Fumi"}
%Exlivery.Users.User{email: "cintiafumi@gmail.com", name: "Cintia Fumi"}
iex> is_map(user)
true
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
%Exlivery.Users.User{
  age: nil,
  cpf: nil,
  email: "cintiafumi@gmail.com",
  name: "Cintia Fumi"
}
iex> Map.put(user, :age, 36)
%Exlivery.Users.User{
  age: 36,
  cpf: nil,
  email: "cintiafumi@gmail.com",
  name: "Cintia Fumi"
}
iex> %{user | cpf: "123456789"}
%Exlivery.Users.User{
  age: nil,
  cpf: "123456789",
  email: "cintiafumi@gmail.com",
  name: "Cintia Fumi"
}
```

A partir de agora, sempre que formos transitar dados de usuário, iremos buildar uma struct e passar essa struct para nossas funções como argumento.

Também podemos fazer pattern matching:

```elixir
iex> %User{email: valor} = user
%Exlivery.Users.User{
  age: nil,
  cpf: nil,
  email: "cintiafumi@gmail.com",
  name: "Cintia Fumi"
}
iex> valor
"cintiafumi@gmail.com"
```

Agora temos um novo contexto `user` que vai ter várias funcionalidades ao redor de `user`. E com isso, seguiremos com separação de código por contexto (Domain Driven Design). Definindo os contextos da aplicação como boa prática, isolando os comportamentos, os códigos e os módulos da aplicação.

## Adicionando algumas validações para nossa struct

Por enquanto é possível criar uma struct de User com valores nulos. Para deixar alguns campos obrigatórios, usamos a diretiva `@enforce_keys`.

Vamos criar uma variável de módulo chamada `@keys` contendo essa lista e criamos a diretiva `@enforce_keys` passando essas chaves:

```elixir
defmodule Exlivery.Users.User do
  @keys [:name, :email, :cpf, :age]
  @enforce_keys @keys
  defstruct @keys
end
```

Ao recompilar e tentar criar uma struct, agora retorna um erro:

```elixir
iex> %User{}
** (ArgumentError) the following keys must also be given when building struct Exlivery.Users.User: [:name :email, :cpf, :age]
    (exlivery 0.1.0) expanding struct: Exlivery.Users.User.__struct__/1
    iex:14: (file)
```

Se quisermos que só `:name` seja obrigatório:

```elixir
defmodule Exlivery.Users.User do
  @keys [:name, :email, :cpf, :age]
  @enforce_keys [:name]
  defstruct @keys
end
```

Agora é possível criar passando todas chaves:

```elixir
iex> %User{email: "cintiafumi@gmail.com", name: "Cintia Fumi", cpf: "123456", age: 36}
%Exlivery.Users.User{
  age: 36,
  cpf: "123456",
  email: "cintiafumi@gmail.com",
  name: "Cintia Fumi"
}
```

Por ser muito trabalhoso passar todas chaves e valores para criar uma nova struct, é comum criarmos uma função `build`. Quando estamos dentro do módulo, não precisamos criar um `alias` ou referenciar o próprio módulo.

```elixir
defmodule Exlivery.Users.User do
  @keys [:name, :email, :cpf, :age]
  @enforce_keys @keys

  defstruct @keys

  def build(name, email, cpf, age) do
    %__MODULE__{
      name: name,
      email: email,
      cpf: cpf,
      age: age,
    }
  end
end
```

Agora, podemos criar uma struct chamando a função build:

```elixir
iex> User.build("Cintia Fumi", "cintiafumi@gmail.com", "123456", 36)
%Exlivery.Users.User{
  age: 36,
  cpf: "123456",
  email: "cintiafumi@gmail.com",
  name: "Cintia Fumi"
}
```

Mas para deixar a struct mais segura, vamos usar o pattern matching e restringir `age` para maiores de 18 anos de idade.

```elixir
  def build(name, email, cpf, age) when age >= 18 do
    %__MODULE__{
      name: name,
      email: email,
      cpf: cpf,
      age: age,
    }
  end
```

Ao tentar passar uma idade menor que 18 anos, vai retornar um erro:

```elixir
iex> User.build("Cintia Fumi", "cintiafumi@gmail.com", "123456", 6)
** (FunctionClauseError) no function clause matching in Exlivery.Users.User.build/4

   The following arguments were given to Exlivery.Users.User.build/4:

       # 1
       "Cintia Fumi"

       # 2
       "cintiafumi@gmail.com"

       # 3
       "123456"

       # 4
       6

   Attempted function clauses (showing 1 out of 1):

       def build(name, email, cpf, age) when age >= 18

   (exlivery 0.1.0) lib/users/user.ex:7: Exlivery.Users.User.build/4
```

Vamos adicionar o retorno de erro para caso envie parâmetros inválidos, e verificar se `cpf` é string:

```elixir
defmodule Exlivery.Users.User do
  @keys [:name, :email, :cpf, :age]
  @enforce_keys @keys

  defstruct @keys

  def build(name, email, cpf, age) when age >= 18 and is_bitstring(cpf) do
    {:ok, %__MODULE__{
      name: name,
      email: email,
      cpf: cpf,
      age: age,
    }}
  end

  def build(_name, _email, _cpf, _age), do: {:error, "Invalid parameters."}
end
```

E assim, o retorno fica:

```elixir
iex> User.build("Cintia Fumi", "cintiafumi@gmail.com", 123456, 36)
{:error, "Invalid parameters."}
iex> User.build("Cintia Fumi", "cintiafumi@gmail.com", "123456", 6)
{:error, "Invalid parameters."}
```
