defmodule Thrash.StructDef do
  defmodule Field do
    defstruct(id: nil, required: nil, type: nil, name: nil, default: nil)
  end

  def read(modulename, struct_name) do
    try do
      {:ok, modulename.struct_info_ext(struct_name)}
    rescue
      e in FunctionClauseError ->
        {:error, []}
    end
    |> maybe_do(fn(struct_info) -> from_struct_info(struct_info) end)
  end

  def from_struct_info({:struct, fields}) do
    Enum.map(fields, fn({id, required, type, name, default}) ->
      %Field{id: id,
             required: undefined_to_nil(required),
             type: translate_type(type),
             name: name,
             default: translate_default(type, default)}
    end)
  end

  def to_defstruct(fields) do
    Enum.map(fields, fn(field) ->
      {field.name, field.default}
    end)
  end

  defp maybe_do({:ok, x}, f) do
    {:ok, f.(x)}
  end
  defp maybe_do({:error, x}), do: {:error, x}

  defp translate_type({:struct, {_from_mod, struct_module}}) do
    {:struct, Thrash.MacroHelpers.atom_to_elixir_module(struct_module)}
  end
  defp translate_type({:list, of_type}) do
    {:list, translate_type(of_type)}
  end
  defp translate_type(other_type), do: other_type

  defp translate_default({:struct, struct_module}, :undefined) do
    struct_module.__struct__
  end
  defp translate_default(:bool, :undefined), do: false
  defp translate_default({:list, _}, :undefined), do: []
  defp translate_default(_, :undefined), do: nil
  defp translate_default(_, default), do: default

  defp undefined_to_nil(:undefined), do: nil
  defp undefined_to_nil(x), do: x
end