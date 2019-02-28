defmodule Brcpfcnpj.Changeset do
  @moduledoc """
  Define funções para serem utilizadas em conjunto com a API de changeset do Ecto.
  """

  @type error() :: {String.t(), Keyword.t()}
  @type t :: %{
          required(:changes) => %{required(atom()) => term()},
          required(:errors) => [{atom(), error()}],
          required(:valid?) => boolean(),
          optional(any()) => any()
        }

  @doc """
  Valida se essa mudação é um cnpj válido.

  ## Options

    * `:message` - A mensagem em caso de erro, o default é "Invalid Cnpj"

  ## Examples

      validate_cnpj(changeset, :cnpj)

  """
  @spec validate_cnpj(t, atom, Keyword.t()) :: t
  def validate_cnpj(changeset, field, opts \\ []) when is_atom(field) do
    validate(changeset, field, fn value ->
      cond do
        Brcpfcnpj.cnpj_valid?(%Cnpj{number: value}) -> []
        true -> [{field, message(opts, {"Invalid Cnpj", validation: :cnpj})}]
      end
    end)
  end

  @doc """
  Valida se essa mudação é um cpf válido.

  ## Options

    * `:message` - A mensagem em caso de erro, o default é "Invalid Cpf"

  ## Examples

      validate_cpf(changeset, :cpf)

  """
  @spec validate_cpf(t, atom, Keyword.t()) :: t
  def validate_cpf(changeset, field, opts \\ []) when is_atom(field) do
    validate(changeset, field, fn value ->
      cond do
        Brcpfcnpj.cpf_valid?(%Cpf{number: value}) -> []
        true -> [{field, message(opts, {"Invalid Cpf", validation: :cpf})}]
      end
    end)
  end

  defp validate(changeset, field, validator) do
    %{changes: changes, errors: errors} = changeset

    value = Map.get(changes, field)
    new = if is_nil(value), do: [], else: validator.(value)

    case new do
      [] -> changeset
      [_ | _] -> %{changeset | errors: new ++ errors, valid?: false}
    end
  end

  defp message(opts, default) do
    message = Keyword.get(opts, :message, default)
    format_message(message)
  end

  defp format_message({_, _} = msg), do: msg
  defp format_message(msg) when is_binary(msg), do: {msg, []}
end
