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
  x <- tools::Rd2txt(
    utils:::.getHelpFile(utils::help(topic)[[1]]),
    out = my_tmp,
    options = list(
      width = getOption("rmd_doc_width", default = 80),
      itemBullet = "* ",
      underline_titles = FALSE,
      sectionIndent = 0,
      code_quote = TRUE,
      showURLs = TRUE
    )
  )
  
  help_file <- 
    readr::read_file(my_tmp)

  ## Set headings to markdown style
  with_headings <- gsub("(\\r?\\n\\r?\\n)([A-Z].*)(?<=:)(\\r?\\n\\r?\\n)", "\\1### \\2\\3", help_file, perl = TRUE)
  without_heading_colons <- gsub("(\\r?\\n###[^:]+):", "\\1", with_headings)
  md_help <- strsplit(without_heading_colons, "\\r?\\n")[[1]]

  examples_line <- which(grepl("#+\\sExamples", md_help))
  rmd_help <- c(md_help[1:examples_line + 1], "```{r}", md_help[(examples_line + 2):length(md_help)], "```")
  rstudioapi::documentNew(text = paste0(rmd_help, collapse = "\n"), type = "help.Rmd")
}
