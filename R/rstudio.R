#' RMarkdown help() on cursor word or selection  
#'
#' Analagous to the default `F1` shortcut in RStudio, except it opens the help
#'  for the thing the cursor is on, or is selected, in Rmd format.
#'
#' Bind the 'RMarkdown help() on object addin to a keyboard shortcut to use
#' this.
#' 
#' @return nothing. Opens document as side effect 
#' @export
rs_rmd_help <- function() {
    word_or_selection <- get_word_or_selection()
    rmd_help(word_or_selection)
}

get_word_or_selection <- function() {
    context <- rstudioapi::getActiveDocumentContext()
    current_selection <- rstudioapi::primary_selection(context)
    if (!is_zero_length_selection(current_selection)) {
        return(current_selection$text)
    }
    cursor_line <- get_cursor_line(context, current_selection)
    cursor_col <- get_cursor_col(current_selection)
    symbol_locations <- get_symbol_locations(cursor_line)
    cursor_symbol <-
        symbol_locations[symbol_locations$start <= cursor_col &
            symbol_locations$end >= cursor_col, ]
    if (nrow(cursor_symbol) == 0) {
        return(character(0))
    }
    substring(cursor_line, cursor_symbol$start, cursor_symbol$end)
}

is_zero_length_selection <- function(selection) {
    all(selection$range$start == selection$range$end)
}

get_cursor_line <- function(context, current_selection) {
    line_num <- current_selection$range$start["row"]
    context$contents[[line_num]]
}

get_cursor_col <- function(current_selection) {
    current_selection$range$start["column"]
}

get_symbol_locations <- function(code_line) {
    matches <- gregexpr("(?:[A-Za-z]|[.][A-Za-z])[A-Za-z0-9_.]+",
        code_line,
        perl = TRUE
    )
    match_df <- data.frame(
        start = c(matches[[1]]),
        length = attr(matches[[1]], "match.length")
    )
    match_df$end <- match_df$start + match_df$length - 1
    match_df
}