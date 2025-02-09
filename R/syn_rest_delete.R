#' Synapse rest DELETE command
#'
#' @param path Path to synapse endpoint
#'
#' @return Synapse API class
#' @importFrom httr modify_url DELETE http_type status_code
#' @importFrom jsonlite fromJSON
#' @export
#'
#' @examples
#' rest_DELETE("entity/syn26896636")
rest_DELETE <- function(path) {
  url <- httr::modify_url("https://repo-prod.prod.sagebase.org/repo/v1",
    hostname = "repo-prod.prod.sagebase.org/repo/v1",
    path = path
  )

  # resp <- httr::DELETE(url, ua,
  #                      httr::add_headers(Authorization = paste0("Bearer ", synapse_pat)))
  resp <- httr::RETRY(
    "DELETE", url, syn_global$ua,
    httr::add_headers(Authorization = paste0("Bearer ", syn_global$synapse_pat)),
    terminate_on = c(400, 401, 403, 404)
  )

  if (httr::status_code(resp) != 204) {
    parsed <- jsonlite::fromJSON(httr::content(resp, "text"), simplifyVector = FALSE)
    stop(
      sprintf(
        "Synapse rest GET request failed [%s]\n%s",
        httr::status_code(resp),
        parsed$reason
      ),
      call. = FALSE
    )
  }

  structure(
    list(
      content = NULL,
      path = path,
      response = resp
    ),
    class = "synapse_api"
  )
}
