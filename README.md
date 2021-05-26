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

## Criando a struct de Order e Itens

Vamos criar um app de delivery, onde podemos criar pedidos e gerar um arquivo csv para ser consumido pelo outro projeto. E tentar criar a integração entre os projetos.

Temos um usuário. Agora, vamos criar um pedido. O pedido terá a referência para o usuário e para os itens.

Vamos criar um novo contexto com a struct em `/lib/orders/order.ex`:

```elixir
defmodule Exlivery.Orders.Order do
  @keys [:user_cpf, :delivery_address, :items, :total_price]

  @enforce_keys @keys

  defstruct @keys

  def build do
    {:ok, %__MODULE__{user_cpf: nil, delivery_address: nil, items: nil, total_price: nil}}
  end
end
```

Mas antes temos que definir a struct para representar os `items`, que vai ter: descrição, valor, quantidade. Em `/lib/orders/item.ex`.

Os campos de `description` (ex: pizza de frango), `category` (possíveis categorias que tínhamos no relatório, ex: pizza, hamburguer), `unity_price` (20 reais) e `quantity` (sempre acima de zero).

A função `build` tem validações de `quantity` maior que zero e `category` tem que estar presente em `@categories`.

```elixir
defmodule Exlivery.Orders.Item do
  @categories [:pizza, :hamburguer, :carne, :prato_feito, :japonesa, :sobremesa]

  @keys [:description, :category, :unity_price, :quantity]

  @enforce_keys @keys

  defstruct @keys

  def build(description, category, unity_price, quantity)
      when quantity > 0 and category in @categories do
    {:ok,
     %__MODULE__{
       description: description,
       category: category,
       unity_price: unity_price,
       quantity: quantity
     }}
  end
end
```

Vamos no `iex`:

```elixir
iex> alias Exlivery.Orders.Item
Exlivery.Orders.Item

iex> Item.build("Pizza de peperoni", :pizza, 50.00, 1)
{:ok,
 %Exlivery.Orders.Item{
   category: :pizza,
   description: "Pizza de peperoni",
   quantity: 1,
   unity_price: 50.0
 }}

iex> Item.build("Pizza de peperoni", :pizza, 50.00, 0)
** (FunctionClauseError) no function clause matching in Exlivery.Orders.Item.build/4

    The following arguments were given to Exlivery.Orders.Item.build/4:

        # 1
        "Pizza de peperoni"

        # 2
        :pizza

        # 3
        50.0

        # 4
        0

    Attempted function clauses (showing 1 out of 1):

        def build(description, category, unity_price, quantity) when quantity > 0 and (category === :pizza or category === :hamburguer or category === :carne or category === :prato_feito or category === :japonesa or category === :sobremesa)

    (exlivery 0.1.0) lib/orders/item.ex:10: Exlivery.Orders.Item.build/4

iex> Item.build("Pizza de peperoni", :banana, 50.00, 1)
** (FunctionClauseError) no function clause matching in Exlivery.Orders.Item.build/4

    The following arguments were given to Exlivery.Orders.Item.build/4:

        # 1
        "Pizza de peperoni"

        # 2
        :banana

        # 3
        50.0

        # 4
        1

    Attempted function clauses (showing 1 out of 1):

        def build(description, category, unity_price, quantity) when quantity > 0 and (category === :pizza or category === :hamburguer or category === :carne or category === :prato_feito or category === :japonesa or category === :sobremesa)

    (exlivery 0.1.0) lib/orders/item.ex:10: Exlivery.Orders.Item.build/4
```

Para começar as validações para caso não dê match no `build`, vamos retornar um `:error`:

```elixir
  def build(_description, _category, _unity_price, _quantity) do
    {:error, "Invalid parameters"}
  end
```

No `iex`:

```elixir
iex> Item.build("Pizza de peperoni", :banana, 50.00, 1)
{:error, "Invalid parameters"}

iex> Item.build("Pizza de peperoni", :pizza, 50.00, 0)
{:error, "Invalid parameters"}
```

## Utilizando a lib Decimal

Uma validação que devemos adicionar em relação ao item é no `unity_price`, pois normalmente nunca vemos num sistema real em produção a utilização de valor de preço monetário (seja real ou dólar ou qualquer outra moeda) como números de pontos flutuantes `float`. Porque ocorrem erros de arredondamento na nossa máquina que podem causar inconsistências no banco de dados ou no sistema. Então, todo sistema que vai lidar com dinheiro, temos que arrumar uma melhor forma de tratar do que simplesmente utilizar `float`, para não perder a precisão. Uma das formas utilizadas é gravar esses valores como números inteiros. No caso de R$ 100,53 guardaremos 10053 e depois convertemos esse valor para o usuário final. E quando recebe um valor com decimais, multiplica por 100.

Para não perder a precisão e ao mesmo tempo ter praticidade, temos libs para auxiliar nessa questão. Vamos usar a lib [Decimal](https://hexdocs.pm/decimal/readme.html) que vai dar precisão monetária.

Vamos instalar a dependência em `mix.exs`:

```elixir
  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:decimal, "~> 2.0"}
    ]
  end
```

Agora vamos para o `iex`. Podemos usar a função `new` ou `cast` para transformar uma string em decimal.

```elixir
iex> Decimal.cast("100.55")
{:ok, #Decimal<100.55>}

iex> Decimal.new("100.66")
#Decimal<100.66>
```

O `cast` funciona para string ou float, e o `new` sempre em string:

```elixir
iex> Decimal.cast(50.55)
{:ok, #Decimal<50.55>}

iex> Decimal.new(50.55)
** (FunctionClauseError) no function clause matching in Decimal.new/1

    The following arguments were given to Decimal.new/1:

        # 1
        50.55

    Attempted function clauses (showing 3 out of 3):

        def new(%Decimal{sign: sign, coef: coef, exp: exp} = num) when (sign === 1 or sign === -1) and (is_integer(coef) and coef >= 0 or (coef === :NaN or coef === :inf)) and is_integer(exp)
        def new(int) when is_integer(int)
        def new(binary) when is_binary(binary)

    (decimal 2.0.0) lib/decimal.ex:1083: Decimal.new/1
```

Iremos utilizar a lib Decimal sempre que for usar valores monetários. O fato de ser uma struct não tem problema.

Se passar uma string qualquer, retorna um `:error`

```elixir
iex> Decimal.cast("banana")
:error
```

Então, vamos tratar isso na aplicação. Antes de rodar o `build` da struct:

```elixir
defmodule Exlivery.Orders.Item do
  @categories [:pizza, :hamburguer, :carne, :prato_feito, :japonesa, :sobremesa]

  @keys [:description, :category, :unity_price, :quantity]

  @enforce_keys @keys

  defstruct @keys

  def build(description, category, unity_price, quantity)
      when quantity > 0 and category in @categories do
    unity_price
    |> Decimal.cast()
    |> build_item(description, category, quantity)
  end

  def build(_description, _category, _unity_price, _quantity) do
    {:error, "Invalid parameters"}
  end

  defp build_item({:ok, unity_price}, description, category, quantity) do
    {:ok,
     %__MODULE__{
       description: description,
       category: category,
       unity_price: unity_price,
       quantity: quantity
     }}
  end

  defp build_item(:error, _description, _category, _quantity), do: {:error, "Invalid price."}
end
```

No `iex`:

```elixir
iex> alias Exlivery.Orders.Item
Exlivery.Orders.Item

iex> Item.build("Pizza de peperoni", :pizza, 50.00, 1)
{:ok,
 %Exlivery.Orders.Item{
   category: :pizza,
   description: "Pizza de peperoni",
   quantity: 1,
   unity_price: #Decimal<50.0>
 }}

iex> Item.build("Pizza de peperoni", :pizza, 0.00, 1)
{:ok,
 %Exlivery.Orders.Item{
   category: :pizza,
   description: "Pizza de peperoni",
   quantity: 1,
   unity_price: #Decimal<0.0>
 }}

iex> Item.build("Pizza de peperoni", :pizza, "50.55", 1)
{:ok,
 %Exlivery.Orders.Item{
   category: :pizza,
   description: "Pizza de peperoni",
   quantity: 1,
   unity_price: #Decimal<50.55>
 }}

iex> Item.build("Pizza de peperoni", :pizza, "banana", 1)
{:error, "Invalid price."}
```

## Finalizando a struct de Order

Vamos refatorar o module de User para adicionar a chave `address`:

```elixir
defmodule Exlivery.Users.User do
  @keys [:address, :name, :email, :cpf, :age]
  @enforce_keys @keys

  defstruct @keys

  def build(address, name, email, cpf, age) when age >= 18 and is_bitstring(cpf) do
    {:ok,
     %__MODULE__{
       address: address,
       name: name,
       email: email,
       cpf: cpf,
       age: age
     }}
  end

  def build(_address, _name, _email, _cpf, _age), do: {:error, "Invalid parameters."}
end
```

Vamos validar a criação da `order`, fazendo pattern matching das chaves de `User` e da lista de `Item`. E fazemos o pattern matching do `head` da lista para ter certeza que tem pelo menos um item na lista, ao invés de uma lista em branco.

Se receber qualquer coisa diferente de `User`, temos que retornar um erro.

O `total_price`, temos que calcular. Multiplicar `unity_price` com `quantity` de cada `Item`. E como estamos com valores monetários, vamos usar sempre a lib Decimal para as operações matemáticas.

```elixir
defmodule Exlivery.Orders.Order do
  alias Exlivery.Orders.Item
  alias Exlivery.Users.User

  @keys [:user_cpf, :delivery_address, :items, :total_price]

  @enforce_keys @keys

  defstruct @keys

  def build(%User{cpf: cpf, address: address}, [%Item{} | _items] = items) do
    {:ok,
     %__MODULE__{
       user_cpf: cpf,
       delivery_address: address,
       items: items,
       total_price: calculate_total_price(items)
     }}
  end

  def build(_user, _items), do: {:error, "Invalid parameters."}

  defp calculate_total_price(items) do
    Enum.reduce(items, Decimal.new("0.00"), &sum_prices(&1, &2))
  end

  defp sum_prices(%Item{unity_price: price, quantity: quantity}, acc) do
    price
    |> Decimal.mult(quantity)
    |> Decimal.add(acc)
  end
end
```

E para testar no `iex`, vamos criar uma lista com dois items:

```elixir
iex> {:ok, item1} = Item.build("Pizza de peperoni", :pizza, "25.5", 2)
{:ok,
 %Exlivery.Orders.Item{
   category: :pizza,
   description: "Pizza de peperoni",
   quantity: 2,
   unity_price: #Decimal<25.5>
 }}

iex> {:ok, item2} = Item.build("Açaí", :sobremesa, "15.0", 1)
{:ok,
 %Exlivery.Orders.Item{
   category: :sobremesa,
   description: "Açaí",
   quantity: 1,
   unity_price: #Decimal<15.0>
 }}

iex> items = [item1, item2]
[
  %Exlivery.Orders.Item{
    category: :pizza,
    description: "Pizza de peperoni",
    quantity: 2,
    unity_price: #Decimal<25.5>
  },
  %Exlivery.Orders.Item{
    category: :sobremesa,
    description: "Açaí",
    quantity: 1,
    unity_price: #Decimal<15.0>
  }
]
```

Vamos criar um user:

```elixir
iex> alias Exlivery.Users.User
Exlivery.Users.User

iex> {:ok, user} = User.build("Rua das bananeiras", "Cintia", "cintia@banana.com", "12345678900", 36)
{:ok,
 %Exlivery.Users.User{
   address: "Rua das bananeiras",
   age: 36,
   cpf: "12345678900",
   email: "cintia@banana.com",
   name: "Cintia"
 }}
```

E por fim, criar uma order:

```elixir
iex> alias Exlivery.Orders.Order
Exlivery.Orders.Order

iex> Order.build(user, items)
{:ok,
 %Exlivery.Orders.Order{
   delivery_address: "Rua das bananeiras",
   items: [
     %Exlivery.Orders.Item{
       category: :pizza,
       description: "Pizza de peperoni",
       quantity: 2,
       unity_price: #Decimal<25.5>
     },
     %Exlivery.Orders.Item{
       category: :sobremesa,
       description: "Açaí",
       quantity: 1,
       unity_price: #Decimal<15.0>
     }
   ],
   total_price: #Decimal<66.00>,
   user_cpf: "12345678900"
 }}

iex> Order.build(user, [])
{:error, "Invalid parameters."}

iex> Order.build("banana", items)
{:error, "Invalid parameters."}
```

## Criando o User test

Vamos criar o teste passando os parâmetros corretamente e

```elixir
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
```

## Conhecendo a lib ExMachina

Para instalar [ExMachina](https://github.com/thoughtbot/ex_machina), temos que fazer algumas configurações. Em `mix.exs`, adicionamos nas dependências:

```elixir
  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:decimal, "~> 2.0"},
      {:ex_machina, "~> 2.7.0"}, # Adicionar essa linha
    ]
  end
```

Ainda no mesmo arquivo, adicionar a parte de `env` conforme [documentação](https://github.com/thoughtbot/ex_machina):

```elixir
  def project do
    [
      app: :exlivery,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env), # Adicionar essa linha
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end
  # ...

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
```

Pois, se estivermos em ambiente `test`, compilar também a pasta `test/support` além da pasta `lib` que é a default.

O `iex` é iniciado por default com env em dev:

```bash
$ iex -S mix
```

```elixir
iex> Mix.env
:dev
```

Mas podemos alterar o env ao iniciar:

```bash
$ MIX_ENV=test iex -S mix
```

Então, o env é de teste:

```elixir
iex> Mix.env
:test
```

Agora vamos criar a `factory`, para facilitar a criação de `user` e `item` nos testes. Vamos criar o arquivo `test/support/factory.ex` que vai ser um módulo como qualquer outro que vamos criar as estruturas para auxiliar nosso teste.

Devemos usar a notação no nome usando `_factory` no final para `ExMachina` entender que isso é uma factory e então criamos a struct.

```elixir
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
```

A diferença de criar com `ExMachina` é que agora no teste, vamos importar o `Exlivery.Factory` e usar a factory.

```elixir
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
      response = {:ok, build(:user, age, 15)}

      expected_response = {:error, "Invalid parameters."}

      assert response == expected_response
    end
  end
end
```

Obs.: usar o [style guide](https://github.com/christopheradams/elixir_style_guide#module-attribute-ordering) para saber a ordem dos atributos, diretivas e macros dentro de um módulo.

## Testando a struct de Item

Adicionamos `item_factory`

```elixir
  def item_factory do
    %Item{
      description: "Pizza de peperoni",
      category: :pizza,
      unity_price: Decimal.new("35.5"),
      quantity: 1
    }
  end
```

Temos que validar `quantity`, `category` e `unity_price` na criação do Item. Criamos um arquivo `test/orders/order_test.exs`.

```elixir
defmodule Exlivery.Orders.ItemTest do
  use ExUnit.Case

  import Exlivery.Factory

  alias Exlivery.Orders.Item

  describe "build/4" do
    test "when all params are valid, returns an item" do
      response = Item.build("Pizza de peperoni", :pizza, "35.5", 1)

      expected_response = {:ok, build(:item)}

      assert response == expected_response
    end

    test "when there is an invalid category, returns an error" do
      response = Item.build("Pizza de peperoni", :banana, "35.5", 1)

      expected_response = {:error, "Invalid parameters"}

      assert response == expected_response
    end

    test "when there is an invalid price, returns an error" do
      response = Item.build("Pizza de peperoni", :pizza, "banana_price", 1)

      expected_response = {:error, "Invalid price."}

      assert response == expected_response
    end

    test "when there is an invalid quantity, returns an error" do
      response = Item.build("Pizza de peperoni", :pizza, "35.5", 0)

      expected_response = {:error, "Invalid parameters"}

      assert response == expected_response
    end
  end
end
```

## Testando a struct de Order

Vamos criar o arquivo `test/orders/order_test.exs` e o `order_factory`.

```elixir
  def order_factory do
    %Order{
      delivery_address: "Rua das bananeiras, 35",
      items: [
        build(:item),
        build(:item,
          description: "Temaki de atum",
          category: :japonesa,
          quantity: 2,
          unity_price: Decimal.new("20.50")
        )
      ],
      total_price: Decimal.new("76.50"),
      user_cpf: "12345678900"
    }
  end
```

Uma forma de criar a lista de items seria usando `build_list(2, :item)`, mas vamos usar somente o `build` para modificar com mais facilidade cada um dos items.

```elixir
defmodule Exlivery.Orders.OrderTest do
  use ExUnit.Case

  import Exlivery.Factory

  alias Exlivery.Orders.Order

  describe "build/2" do
    test "when all params are valid, returns an item" do
      user = build(:user)

      items = [
        build(:item),
        build(:item,
          description: "Temaki de atum",
          category: :japonesa,
          quantity: 2,
          unity_price: Decimal.new("20.50")
        )
      ]

      response = Order.build(user, items)

      expected_response = {:ok, build(:order)}

      assert response == expected_response
    end

    test "when there is not items in the order, returns an error" do
      user = build(:user)

      items = []

      response = Order.build(user, items)

      expected_response = {:error, "Invalid parameters"}

      assert response == expected_response
    end
  end
end
```

---

## Utilizando Agents pra manter estado

Os processos normalmente têm um estado porque ele tem um pedaço de memória que ele pode enviar e receber mensagens, e manter um dado enquanto ele viver.

[Agent](https://elixir-lang.org/getting-started/mix-otp/agent.html) é um processo específico para guardar estados.

Na linguagem funcional, temos o contexto imutável. Então, não trabalhamos com variáveis globais, ou classes (objetos) que mantém estados.

Para simular um banco de dados, onde poderemos salvar e atualizar usuários e pedidos, vamos utilizar o Agent.

O Agent é usado em produção em casos muito específicos, mas para podermos avançar na nossa lógica e poder avançar nos conceitos da linguagem em si, é legal fazermos esse passo para habituarmos com pattern matching, funções, módulo Enum, e para simular a ideia de banco de dados.

Faremos uma introdução em `Agent` pelo `iex`. Usamos o módulo Agent para criar um Agent e quando iniciamos o Agent, criamos a função para dizer o estado inicial dele.

```elixir
iex> Agent.start_link fn -> %{} end
{:ok, #PID<0.198.0>}
```

Recebemos um PID pois ele é um processo. Vamos salvar sua referência por pattern matching

```elixir
iex> {:ok, agent} = Agent.start_link fn -> %{} end
{:ok, #PID<0.200.0>}
```

Lembrando que usamos `Process.alive` para saber se o processo estava vivo

```elixir
iex> Process.alive?(agent)
true
```

Então o `agent` está vivo enquanto a aplicação está em execução ou enquanto não o encerrarmos explicitamente.

Podemos atualizar o estado desse `agent`

```elixir
iex> Agent.update(agent, fn my_map -> Map.put(my_map, :fruta, "banana") end)
:ok

iex> Agent.get(agent, fn my_map -> my_map end)
%{fruta: "banana"}
```

Podemos ver o estado e a fruta ainda está no estado ainda.

Ao atualizar de novo o `agent`

```elixir
iex> Agent.update(agent, fn my_map -> Map.put(my_map, :vegetal, "cenoura") end)
:ok

iex> Agent.get(agent, fn my_map -> my_map end)
%{fruta: "banana", vegetal: "cenoura"}
```

O map vai existir enquanto o `agent` executar.

Então, vamos usar o `Agent` para manter o estado de usuário e de pedido da aplicação.

## Criando o User Agent

Vamos criar um novo arquivo no contexto de user `users/agent.ex`. Precisamos criar a função `start_link` para iniciar o Agent e ter um PID de retorno. Recebemos o estado inicial mas não iremos utilizá-lo. Essa função devolve o estado inicial, que vai ser um map vazio onde iremos armazenar os usuários. Sempre que usamos o Agent dentro de um módulo, damos um nome a ele para podemos utilizá-lo fora desse módulo.

```elixir
defmodule Exlivery.Users.Agent do
  alias Exlivery.Users.User

  use Agent

  def start_link(_initial_state) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

end
```

Vamos criar a função de `save` que vai receber uma struct de user e vamos chamar a função `Agent.update` passando o PID, que nesse caso é o nome do módulo. Também precisamos de uma função `update_state` para colocarmos nosso usuário no estado atual.

Por pattern matching, pegamos o cpf do user e então vamos alterar o nosso agent

```elixir
defmodule Exlivery.Users.Agent do
  alias Exlivery.Users.User

  use Agent

  def start_link(_initial_state) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def save(%User{} = user), do: Agent.update(__MODULE__, &update_state(&1, user))

  defp update_state(state, %User{cpf: cpf} = user), do: Map.put(state, cpf, user)
end
```

Para ler os dados do Agent, vamos criar a função `get` e `get_user`. Se passar um cpf inexistente, retornamos um `:error`.

```elixir
defmodule Exlivery.Users.Agent do
  alias Exlivery.Users.User

  use Agent

  def start_link(_initial_state) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def save(%User{} = user), do: Agent.update(__MODULE__, &update_state(&1, user))

  def get(cpf), do: Agent.get(__MODULE__, &get_user(&1, cpf))

  defp get_user(state, cpf) do
    case Map.get(state, cpf) do
      nil -> {:error, "User not found."}
      user -> {:ok, user}
    end
  end

  defp update_state(state, %User{cpf: cpf} = user), do: Map.put(state, cpf, user)
end
```

A função `get_user` também poderia ser assim sem `case`:

```elixir
  defp get_user(state, cpf) do
    state
    |> Map.get(cpf)
    |> handle_get()
  end

  defp handle_get(nil), do: {:error, "User not found."}
  defp handle_get(user), do: {:ok, user}
```

No `iex` vamos criar uma mapa qualquer e ver o retorno do `Map.get` com uma chave existente `:a` e com uma chave inexistente `:c`

```elixir
iex> map = %{a: 1, b: 2}
%{a: 1, b: 2}

iex> Map.get(map, :a)
1

iex> Map.get(map, :c)
nil
```

Para criar um `alias` direto, o módulo `Agent` já existe, então vamos renomear com `as`. Temos que passar qualquer coisas no `start_link` mesmo que não usamos o estado inicial.

Precisamos criar um `user` para então salvá-lo `user` no nosso `Agent.

```elixir
iex> alias Exlivery.Users.Agent, as: UserAgent
Exlivery.Users.Agent

iex> UserAgent.start_link(%{})
{:ok, #PID<0.564.0>}

iex> alias Exlivery.Users.User
Exlivery.Users.User

iex> {:ok, user} = User.build("Rua das bananeiras", "Cintia", "cintia@banana.com", "12345678900", 36)
{:ok,
 %Exlivery.Users.User{
   address: "Rua das bananeiras",
   age: 36,
   cpf: "12345678900",
   email: "cintia@banana.com",
   name: "Cintia"
 }}

iex> UserAgent.save(user)
:ok

iex> UserAgent.get("12345678900")
{:ok,
 %Exlivery.Users.User{
   address: "Rua das bananeiras",
   age: 36,
   cpf: "12345678900",
   email: "cintia@banana.com",
   name: "Cintia"
 }}

iex> UserAgent.get("banana")
{:error, "User not found."}
```
