#' xbrlus: Interface to XBRL US API
#'
#' This package provides an interface to XBRL US API.
#'
#' All APIs (except for the CIKLookup) require use of a valid XBRL US API
#' key. You can get the key and read the terms of usage at
#' \url{https://xbrl.us/use/howto/data-analysis-toolkit/}.
#'
#' \pkg{xbrlus} functions will read the API key from environment variable
#' \code{XBRLUS_API_KEY}.
#' To start R session with the initialized environvent variable
#' create an .Renviron file in your R home with a line like this:
#'
#' \code{XBRLUS_API_KEY=************}
#'
#' To check where your R home is, try \code{normalizePath("~")}.
#'
#' @references
#'  \itemize{
#'    \item{Data Analysis Toolkit and API description on GitHub: \url{https://github.com/xbrlus/data_analysis_toolkit}}
#'  }
#'
#' @docType package
#' @name xbrlus-package
#' @aliases xbrlus
NULL

xbrlus_url <- "https://csuite.xbrl.us/php/dispatch.php?"



xbrlus_api_key <- function() {
  key <- Sys.getenv("XBRLUS_API_KEY")
  if(key == "") {
    stop("XBRLUS_API_KEY environment variable is empty. Type ?xbrlus for help.")
  }
  key
}

xbrlus_get <- function(task, params, add_api_key = TRUE) {
  query <- c(list(Task = task), params)

  if(add_api_key) {
    query[["API_Key"]] = xbrlus_api_key()
  }
  res <- httr::GET(xbrlus_url, query = query)
  xbrlus_validate(res)
  xbrlus_parse(res)
}

xbrlus_validate <- function(res) {

  if(!inherits(res, "response")) {
    stop("Not a HTTP response object")
  }
  if(res$status_code >= 400) {
    err_message <- httr::content(res, as = "text", encoding = "UTF-8")
    if( XML::isXMLString(err_message)) {
      doc <- XML::xmlParse(err_message, options = XML::NOCDATA)
      lerror <- XML::xmlToList(doc)
      err_message <- paste(lerror, collapse = "\n")
    }
    stop("HTTP error: ", res$status_code, "\n", err_message, call. = FALSE)
  }
  if(substring(res$headers$`content-type`, 1, 8) != "text/xml") {
    stop("Returned message is not an xml", call. = FALSE)
  }

}

xbrlus_parse <- function(res) {
  res_txt <- httr::content(res, as = "text", encoding = "UTF-8")
  doc <- XML::xmlParse(res_txt, asText = TRUE, options = XML::NOCDATA)
  XML::xmlToList(doc)
}

xbrlus_to_data_frame <- function(ret, element_name = "fact") {
  if(!any(names(ret) == element_name)) return(data.frame())
  ret <- do.call(
    rbind,
    c(lapply(ret[names(ret) == element_name], function(x) {
      x[sapply(x,is.null)] <- NA
      as.data.frame(x, stringsAsFactors = FALSE)
    }),
    make.row.names = FALSE)
  )
}

