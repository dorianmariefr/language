# language

`language` is a Parsing Expression Grammar (PEG) in Crystal.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     language:
       github: dorianmariefr/language
   ```

2. Run `shards install`

## Usage

```crystal
require "language"

boolean = Language.create do
  root do
    (str("true") | str("false")).aka(:boolean)
  end
end

boolean.parse("true") # {:boolean => "true"}
```

- `any` is for matching any character, e.g. `any.repeat` will match any text
- `str(string)` is for matching a string, e.g. `str("hello")` will match the string
  `hello`
- `absent` is for not matching the previous match, e.g. `str("hello").absent`
  will not match `hello`
- `ignore` is for not making the match part of the output, e.g.
  `str("hello").ignore` will match `hello` but not return it
- `maybe` is for optionally matching, e.g. `str("hello").maybe` will match
  `hello` or will just continue if not matched
- `repeat(min = 0, max = nil)` will match until it doesn't match (with an
  optional minimum and a maximum) e.g. `str("hello").repeat` will match `""`,
  `"hello"`, `"hellohello"`, etc.
- `aka(name)` will register the match into its own key of the resulting hash,
  e.g. `str("hello").aka(:match)` will return `{ :match => "hello" }`
- `|` is used as "or" e.g. `str("hello") | str("goodbye")` will match `hello` or
  `goodbye`
- `>>` (same as `<<`) is used as "and", e.g. `str("hel") >> str("lo")`
  will match `hello`

See [the spec/ folder](https://github.com/dorianmariefr/language/tree/main/spec)
for more examples.

## Development

- `crystal spec` to run the specs

## Contributors

- [Dorian Marié](https://github.com/dorianmariefr) - creator and maintainer
