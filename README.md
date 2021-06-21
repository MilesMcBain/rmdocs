
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rmdocs

<!-- badges: start -->

<!-- badges: end -->

Browse help files as RMarkdown source documents.

## Installation

``` r
# install.packages("devtools")
devtools::install_github("milesmcbain/rmdocs")
```

## Usage

``` r
rmdocs::rmd_help(help)
```

Use option `rmd_doc_width` to control the text width of the
documentation output. Defaults to 80.

### VSCode setup

In `keybindings.json`:

``` json
[
    {
        "description": "Rmd helpfile for object",
        "key": "ctrl+shift+h",
        "command": "r.runCommandWithSelectionOrWord",
        "args": "rmddocs::rmd_help($$)",
        "when": "editorTextFocus"
    },
]
```
