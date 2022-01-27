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
  [{:file_store, "~> 0.3"}]
end
```

## Usage

Configure a new store:

```elixir
store = FileStore.Adapters.Disk.new(
  storage_path: "/path/to/store/files",
  base_url: "http://example.com/files/"
)
```

Now, you can manipulate files in your store:

```elixir
iex> FileStore.upload(store, "hello.txt", "world.txt")
:ok

iex> FileStore.read(store, "world.txt")
{:ok, "hello world"}

iex> FileStore.stat(store, "world.txt")
{:ok,
 %FileStore.Stat{
   etag: "5eb63bbbe01eeed093cb22bb8f5acdc3",
   key: "hello.txt",
   size: 11,
   type: "application/octet-stream"
 }}

iex> FileStore.get_public_url(store, "world.txt")
"http://localhost:4000/world.txt"
```

[Click here to see all available operations.](https://hexdocs.pm/file_store/FileStore.html#summary)

## Middleware

#### Logger

To enable logging, just wrap your store with the logging middleware:

```elixir
iex> store
...> |> FileStore.Middleware.Logger.new()
...> |> FileStore.read("test.txt")
# 02:37:30.724 [debug] READ OK key="test.txt"
{:ok, "hello"}
```

#### Errors

The errors middleware will wrap error values:

```elixir
iex> store
...> |> FileStore.Middleware.Errors.new()
...> |> FileStore.read("bizcorp.jpg")
{:error, %FileStore.Error{...}}
```

One of the following structs will be returned:

- `FileStore.Error`
- `FileStore.UploadError`
- `FileStore.DownloadError`
- `FileStore.CopyError`
- `FileStore.RenameError`

Because the error implements the `Exception` behaviour, you can `raise` it.

#### Prefix

The prefix middleware allows you to prepend a prefix to all operations.

```elixir
iex> store
...> |> FileStore.Middleware.Prefix.new(prefix: "company/logos")
...> |> FileStore.read("bizcorp.jpg")
```

In the example above, `bizcorp.jpg` was translated to `companies/logos/bizcorp.jpg`.

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
  adapter: FileStore.Adapters.Null,
  middleware: [FileStore.Middleware.Errors]
```

Now, you can interact with your store more conveniently:

```elixir
iex> MyApp.Storage.write("foo", "hello world")
:ok

iex> MyApp.Storage.read("foo")
{:ok, "hello world"}
```

## Contributing

In order to test the S3 adapter, we run Minio locally in a Docker container. To start the Minio
service, run the following script:

    $ bin/start

To run the test suite, run:

    $ bin/test
