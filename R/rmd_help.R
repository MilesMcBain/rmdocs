#' Browse a help file as an Rmd
#'
#' A drop-in replacement for `help()` that opens the help file as Rmd.
#' 
#' You're better off binding this to a key. See README.
#'
#' @param topic bare symbol to search for help on.
#'
#' @return nothing. Opens help as side effect.
#' @export
#' @examples
#' rmd_help(help)
rmd_help <- function(topic) {
  the_topic <- deparse(substitute(topic))
  help_matches <- utils::help(the_topic)
  if (length(help_matches) < 1) stop("Couldn't find help for ", as.character(the_topic))

  help_file <- help_matches[[1]]
  help_file_name <- fs::path_file(help_file)
  pkg_user_dir <- get_pkg_user_dir()
  target_file_name <- paste0(help_file_name, "_help.rmd")
  target_file <- fs::file_create(file.path(pkg_user_dir, target_file_name))

  x <- tools::Rd2txt(
    utils:::.getHelpFile(help_file),
    out = target_file,
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
    readr::read_file(target_file)

  ## Set headings to markdown style
  with_headings <- gsub("(\\r?\\n\\r?\\n)([A-Z].*)(?<=:)(\\r?\\n\\r?\\n)", "\\1### \\2\\3", help_file, perl = TRUE)
  without_heading_colons <- gsub("(\\r?\\n###[^:]+):", "\\1", with_headings)
  md_help <- strsplit(without_heading_colons, "\\r?\\n")[[1]]

  examples_line <- which(grepl("###\\sExamples", md_help))
  if (any(examples_line)) {
    rmd_help <- c(
      md_help[1:examples_line + 1],
      "```{r}",
      md_help[(examples_line + 2):length(md_help)],
      "```"
    )
  } else {
    rmd_help <- md_help
  }
  usage_line <- which(grepl("###\\sUsage", rmd_help))
  if (any(usage_line)) {
    headings <- which(grepl("^###", rmd_help))
    usage_end_line <- min(headings[headings > usage_line]) - 2
    rmd_help <- c(
      rmd_help[1:usage_line + 1],
      "```{r}",
      rmd_help[(usage_line + 2):usage_end_line],
      "```",
      rmd_help[(usage_end_line + 1):length(rmd_help)]
    )
  }

  rmd_help <- c(paste0("# ", help_file_name), "", rmd_help)
  readr::write_file(paste0(rmd_help, collapse = "\n"), target_file)
  rstudioapi::navigateToFile(target_file)
}

get_pkg_user_dir <- function() {
  rmdocs_user_dir <- tools::R_user_dir("rmdocs")
  if (!dir.exists(rmdocs_user_dir)) {
    dir.create(rmdocs_user_dir, recursive = TRUE)
  }
  rmdocs_user_dir
}
