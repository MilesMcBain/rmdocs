.onLoad <- function(libname, pkgname) {
	pkg_user_dir <- get_pkg_user_dir()
	file_info_df <- fs::file_info(list.files(pkg_user_dir, full.names = TRUE))
	# Remove all files from previous days
	old_files <- as.numeric(Sys.Date() - as.Date(file_info_df$birth_time)) > 0
	unlink(file_info_df[old_files,]$path)
}
