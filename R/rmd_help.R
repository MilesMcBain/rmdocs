#' Browse a help file as an Rmd
#'
#' A drop-in replacement for `help()` that opens the help file as Rmd.
#'
#' You're better off binding this to a key or using the RStudio addin. See
#'  README.
#'
#' @param topic bare symbol to search for help on. pkg::func syntax is supported and if used `package` is ignored.
#' @param package package name to resolve symbol in
#' @return nothing. Opens help as side effect.
#' @export
#' @examples
#' \dontrun{
#' rmd_help(help)
#' }
rmd_help <- function(topic, package = NULL) {
  the_topic <- deparse(substitute(topic))
  is_namespaced <- grepl(":{2,3}", the_topic)
  help_call_args <- list()
  if (is_namespaced && !is.null(package)) package <- NULL ## namespace takes priority
  if (is_namespaced) {
    the_topic_split <- strsplit(the_topic, ":{2,3}")[[1]]
    help_call_args$package <- the_topic_split[[1]]
    help_call_args$topic <- the_topic_split[[2]]
  } else {
    help_call_args$topic <- the_topic
    if (!is.null(package)) help_call_args$package <- package
  }
  help_matches <- do.call(utils::help, help_call_args)
  if (length(help_matches) < 1) stop("Couldn't find help for ", as.character(the_topic))

  help_file <- help_matches[[1]]
  help_file_name <- fs::path_file(help_file)
  help_file_path_split <- fs::path_split(help_file)[[1]]
  help_file_folder <- help_file_path_split[[length(help_file_path_split) - 2]] # <pkg_folder>/help
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
    ),
    outputEncoding = "UTF-8"
  )

  help_text <-
    paste0(
      readLines(target_file, encoding = "UTF-8"),
      collapse = "\n"
      )


  ## Set headings to markdown style
  with_headings <- gsub(
    "(\\r?\\n\\r?\\n)([A-Z].*)(?<=:)(\\r?\\n\\r?\\n)",
    "\\1### \\2\\3",
    help_text,
    perl = TRUE
  )
  without_heading_colons <- gsub("(\\r?\\n###[^:]+):", "\\1", with_headings)
  md_help <- strsplit(without_heading_colons, "\\r?\\n")[[1]]

  examples_line <- which(grepl("###\\sExamples", md_help))
  if (length(examples_line) > 0) {
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
  if (length(usage_line) > 0) {
    headings <- which(grepl("^###", rmd_help))
    usage_end_line <- min(headings[headings > usage_line]) - 2
    rmd_help <- c(
      rmd_help[1:usage_line + 1],
      # Mark this usage chunk for non-evalualtion
      "```{r eval=FALSE}",
      rmd_help[(usage_line + 2):usage_end_line],
      "```",
      rmd_help[(usage_end_line + 1):length(rmd_help)]
    )
  }

  rmd_help <- c(paste0("# {", help_file_folder, "} / ", help_file_name), "", rmd_help)
  readr::write_file(paste0(rmd_help, collapse = "\n"), target_file)
  rstudioapi::navigateToFile(target_file)
}

get_pkg_user_dir <- function() {
  rmdocs_user_dir <- R_user_dir("rmdocs")
  if (!dir.exists(rmdocs_user_dir)) {
    dir.create(rmdocs_user_dir, recursive = TRUE)
  }
  rmdocs_user_dir
}

#' @noRd
#' @export
`?` <- function(e1, e2) eval(bquote(rmdocs::rmd_help(.(substitute(e1)))))

#' @noRd
#' @export
help <- rmd_help

.onAttach <- function(libname, pkgname) {
  packageStartupMessage("{rmdocs} is masking `?` and `help` to bring you {rmarkdown} help. Long Live RMD!")
}
