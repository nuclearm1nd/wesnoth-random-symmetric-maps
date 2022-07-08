### Testing

Install luaunit package (requires luarocks package manager to be installed)

```bash
luarocks install --tree .luamodules luaunit
```

Run unit tests

```bash
make test
```

### Running

Compile and copy files to wesnoth addons folder

```bash
make deploy
```

