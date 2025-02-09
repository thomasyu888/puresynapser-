#' Synapse REST GET command
#'
#' @param path Path to synapse endpoint
#'
#' @return Synapse API class
#' @importFrom httr modify_url GET http_type status_code
#' @importFrom jsonlite fromJSON
#' @export
#'
#' @examples
#' rest_GET("entity/syn7222066")
rest_GET <- function(path) {
  url <- httr::modify_url("https://repo-prod.prod.sagebase.org/repo/v1",
    hostname = "repo-prod.prod.sagebase.org/repo/v1",
    path = path
  )

  # resp <- httr::GET(url, ua,
  #                   httr::add_headers(Authorization = paste0("Bearer ", synapse_pat)))
  resp <- httr::RETRY(
    "GET", url, syn_global$ua,
    httr::add_headers(Authorization = paste0("Bearer ", syn_global$synapse_pat)),
    terminate_on = c(400, 401, 403, 404)
  )
  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  parsed <- jsonlite::fromJSON(httr::content(resp, "text"), simplifyVector = FALSE)

  if (!httr::status_code(resp) %in% c(200, 201)) {
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
      content = parsed,
      path = path,
      response = resp
    ),
    class = "synapse_api"
  )
}
