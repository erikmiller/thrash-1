defmodule Thrash.BinaryTest do
  use ExUnit.Case

  def dump_bin(name, b) do
    IO.puts("#{name}:")
    b
    |> :binary.bin_to_list
    |> Enum.chunk(25, 25, [])
    |> Enum.each(fn(c) -> IO.puts(inspect c) end)
  end

  defmodule TacoType do
    @mapping %{
      carnitas: 124
    }

    @reverse_mapping Enum.into(@mapping, []) |> Enum.map(fn({k, v}) -> {v, k} end) |> Enum.into(%{})

    def id(sym), do: @mapping[sym]

    def atom(id), do: @reverse_mapping[id]
  end

  defmodule TestSubStruct do
    defstruct sub_id: nil, sub_name: nil

    require Thrash.Protocol.Binary
    Thrash.Protocol.Binary.generate_deserializer(sub_id: :i32, sub_name: :string)
    Thrash.Protocol.Binary.generate_serializer(sub_id: :i32, sub_name: :string)
  end

  defmodule TestStruct do
    defstruct(id: nil,
              name: nil,
              list_of_ints: [],
              bigint: nil,
              sub_struct: %TestSubStruct{},
              flag: false,
              floatval: nil,
              taco_pref: :chicken)

    require Thrash.Protocol.Binary
    Thrash.Protocol.Binary.generate_deserializer(id: :i32,
                                                 name: :string,
                                                 list_of_ints: {:list, :i32},
                                                 bigint: :i64,
                                                 sub_struct: {:struct, TestSubStruct},
                                                 flag: :bool,
                                                 floatval: :double,
                                                 taco_pref: {:enum, TacoType})
    Thrash.Protocol.Binary.generate_serializer(id: :i32,
                                               name: :string,
                                               list_of_ints: {:list, :i32},
                                               bigint: :i64,
                                               sub_struct: {:struct, TestSubStruct},
                                               flag: :bool,
                                               floatval: :double,
                                               taco_pref: {:enum, TacoType})

    def test_str do
      hex = "0800010000002A0B0002000000086D79207468696E670F0003080000000600000004000000080000000F00000010000000170000002A0A0004FFFFF6E7B18D60010C00050800010000004D0B00020000000C6120737562207374727563740002000601040007400921FB53C8D4F10800080000007C00"
      Base.decode16!(hex)
    end

    def test_struct do
      sub_struct = %TestSubStruct{sub_id: 77, sub_name: "a sub struct"}
      %TestStruct{id: 42,
                  name: "my thing",
                  list_of_ints: [4, 8, 15, 16, 23, 42],
                  bigint: -9999999999999,
                  sub_struct: sub_struct,
                  flag: true,
                  floatval: 3.14159265,
                  taco_pref: :carnitas}
    end
  end

  test "deserializes a struct" do
    {deserialized, ""} = TestStruct.deserialize(TestStruct.test_str)
    assert(deserialized == TestStruct.test_struct)
  end

  test "serializes a struct" do
    serialized = TestStruct.serialize(TestStruct.test_struct)
    assert(serialized == TestStruct.test_str)
  end
end
