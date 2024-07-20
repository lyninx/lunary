# lunary

```bash
  mix escript.build && ./lunary test/example.lun
```

```elixir
  Lunary.Main.perform(":a = 7 :b = 4 :result = :a + :b")
  %{a: 7, result: 11, b: 4}
```