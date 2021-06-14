#' Browse a help file as an Rmd
#'
#' A drop-in replacement for `help()`.
#' 
#' FUNCTION_DESCRIPTION
#'
#' @param topic bare symbol to search for help on.
#'
#' @return nothing
#' @export
#' @examples
#' rmd_help(help)
rmd_help <- function(topic) {
  the_topic <- deparse(substitute(topic))
  my_tmp <- tempfile()
  x <- tools::Rd2HTML(
    utils:::.getHelpFile(utils::help(the_topic)[[1]]),
    out = my_tmp,
    dynamic = TRUE
  )
  md_help <- system2("pandoc", c("-f", "html", "-t", "markdown+multiline_tables", "--columns=80", my_tmp), stdout = TRUE)
  examples_line <- which(grepl("#+\\sExamples", md_help))
  rmd_help <- c(md_help[1:examples_line + 1], "```{r}", md_help[(examples_line + 2):length(md_help)], "```")
  rstudioapi::documentNew(text = paste0(rmd_help, collapse = "\n"), type = "help.Rmd")
}
