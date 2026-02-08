# lunary

> [!WARNING]
> This project is an experiment and should not be relied on in any production environment ever!

### About

Lunary is a dynamically-typed, procedural, interpreted scripting toy language with expressive syntax focused on composability and functional ergonomics. It currently runs on an Elixir backend (BEAM VM runtime), with the eventual goal being to port execution to LLVM.

### Requirements

- [Erlang/OTP](https://www.erlang.org/) >= 27
- [Elixir](https://elixir-lang.org/) >= 1.18

### Quickstart

#### Build lunary binary and run the REPL
```bash
  mix escript.build && mix repl
```

#### Build demo project (HTML resume builder)

You will need to install [WeasyPrint](https://weasyprint.org/) if you want to render the resume to a PDF.

```bash
  mix escript.build

  ./lunary examples/resume/resume.lun > examples/resume/resume.html | weasyprint - examples/resume/resume.pdf --media-type print --encoding utf-8
```

#### Run test suite
```bash
  mix test
```
