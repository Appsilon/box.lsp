options(
  languageserver.parser_hooks = list(
    "box::use" = box.lsp::box_use_parser
  )
)
