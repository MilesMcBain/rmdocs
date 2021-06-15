
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

## Example

``` r
rmdocs::rmd_help(help)
```

### VSCode setup

In `keybindings.json`:

``` json
[
    {
        "description": "Rmd helpfile for object",
        "key": "ctrl+shift+h",
        "command": "r.runCommandWithSelectionOrWord",
        "args": "rmdocs::rmd_help($$)",
        "when": "editorTextFocus"
    },
]
```
