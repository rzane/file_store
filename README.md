# FileStore

[![github.com](https://img.shields.io/github/workflow/status/rzane/file_store/Build.svg)](https://github.com/rzane/file_store/actions?query=workflow%3ABuild)
[![coveralls.io](https://img.shields.io/coveralls/github/rzane/file_store.svg)](https://coveralls.io/github/rzane/file_store)
[![hex.pm](https://img.shields.io/hexpm/v/file_store.svg)](https://hex.pm/packages/file_store)
[![hex.pm](https://img.shields.io/hexpm/dt/file_store.svg)](https://hex.pm/packages/file_store)
[![hex.pm](https://img.shields.io/hexpm/l/file_store.svg)](https://hex.pm/packages/file_store)
[![github.com](https://img.shields.io/github/last-commit/rzane/file_store.svg)](https://github.com/rzane/file_store/commits/master)

FileStore allows you to read, write, upload, download, and interact with files, regardless of where they are stored.

It includes adapters for the following storage backends:

- [Disk](https://hexdocs.pm/file_store/FileStore.Adapters.Disk.html)
- [S3](https://hexdocs.pm/file_store/FileStore.Adapters.S3.html)
- [Memory](https://hexdocs.pm/file_store/FileStore.Adapters.Memory.html)
- [Null](https://hexdocs.pm/file_store/FileStore.Adapters.Null.html)

> [**View the documentation**](https://hexdocs.pm/file_store)

## Installation

The package can be installed by adding `file_store` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:file_store, "~> 0.1.0"}]
end
```

## Usage

Configure a new store:

```elixir
iex> store = FileStore.new(
...>   adapter: FileStore.Adapters.Disk,
...>   storage_path: "/path/to/store/files",
...>   base_url: "http://example.com/files/"
...> )
%FileStore{...}
```

Write a file to the store:

```elixir
iex> FileStore.write(store, "foo", "hello world")
:ok
```

Read a file from the store:

```elixir
iex> FileStore.read(store, "foo")
{:ok, "hello world"}
```

Get information about a file in the store:

```elixir
iex> FileStore.stat("foo")
{:ok, %FileStore.Stat{key: "foo", ...}}
```

Upload a file to the store:

```elixir
iex> FileStore.upload(store, "/path/to/upload.txt", "bar")
:ok
```

Download a file in the store to disk:

```elixir
iex> FileStore.download(store, "bar", "/path/to/download.txt")
:ok
```

Get a URL for the file:

```elixir
iex> FileStore.get_public_url(store, "bar")
"http://example.com/files/bar"
```

Get a signed URL for the file:

```elixir
iex> FileStore.get_signed_url(store, "bar")
{:ok, "http://..."}
```

List all files:

```elixir
iex> Enum.to_list(FileStore.list!(store))
["bar"]
```

Delete a file:

```elixir
iex> FileStore.delete(store, "bar")
:ok
```

## Creating a store

You can also create a dedicated store in your application.

```elixir
defmodule MyApp.Storage do
  use FileStore.Config, otp_app: :my_app
end
```

You'll need to provide configuration for this module:

```elixir
config :my_app, MyApp.Storage,
  adapter: FileStore.Adapters.Null
```

Now, you can interact with your store more conveniently:

```elixir
iex> MyApp.Storage.write("foo", "hello world")
:ok

iex> MyApp.Storage.read("foo")
{:ok, "hello world"}
```
