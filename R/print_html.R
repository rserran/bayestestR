#' @export
print_html.describe_posterior <- function(x, digits = 2, caption = "Summary of Posterior Distribution", ...) {
  .print_html_default(x = x, digits = digits, caption = caption, ...)
}


#' @export
print_html.point_estimate <- function(x, digits = 2, caption = "Point Estimate", ...) {
  .print_html_default(x = x, digits = digits, caption = caption, ...)
}


#' @export
print_html.map_estimate <- function(x, digits = 2, caption = "MAP Estimate", ...) {
  .print_html_default(x = x, digits = digits, caption = caption, ...)
}


#' @export
print_html.p_direction <- function(x, digits = 2, caption = "Probability of Direction (pd)", ...) {
  .print_html_default(x = x, digits = digits, caption = caption, ...)
}


#' @export
print_html.p_map <- function(x, digits = 2, caption = "MAP-based p-value", ...) {
  .print_html_default(x = x, digits = digits, caption = caption, ...)
}


#' @export
print_html.p_rope <- function(x, digits = 2, ...) {
  # check if we have multiple ROPE values
  if (insight::n_unique(x$ROPE_low) > 1) {
    caption <- "Proportion of samples inside the ROPE"
  } else {
    caption <- sprintf(
      "Proportion of samples inside the ROPE [%.*f, %.*f]",
      digits,
      x$ROPE_low[1],
      digits,
      x$ROPE_high[1]
    )
    x$ROPE_low <- x$ROPE_high <- NULL
  }
  .print_html_default(x = x, digits = digits, caption = caption, ci_string = "ROPE", ...)
}


#' @export
print_html.p_significance <- function(x, digits = 2, ...) {
  threshold <- attributes(x)$threshold
  if (is.list(threshold)) {
    caption <- "Practical Significance"
    out <- as.data.frame(do.call(rbind, threshold))
    colnames(out) <- c("ROPE_low", "ROPE_high")
    x$ROPE_low <- out$ROPE_low
    x$ROPE_high <- out$ROPE_high
    ci_string <- "ROPE"
  } else {
    caption <- sprintf(
      "Practical Significance (threshold: %s)",
      insight::format_value(attributes(x)$threshold, digits = digits)
    )
    ci_string <- NULL
  }
  .print_html_default(x = x, digits = digits, caption = caption, ci_string = ci_string, ...)
}


#' @export
print_html.bayestestR_hdi <- function(x, digits = 2, caption = "Highest Density Interval", ...) {
  .print_html_default(x = x, digits = digits, caption = caption, ci_string = "HDI", ...)
}


#' @export
print_html.bayestestR_eti <- function(x, digits = 2, caption = "Equal-Tailed Interval", ...) {
  .print_html_default(x = x, digits = digits, caption = caption, ci_string = "ETI", ...)
}


#' @export
print_html.bayestestR_si <- function(x, digits = 2, caption = "Support Interval", ...) {
  .print_html_default(x = x, digits = digits, caption = caption, ci_string = "SI", ...)
}


# special handling for bayes factors ------------------


#' @export
print_html.bayesfactor_models <- function(x,
                                          digits = 3,
                                          log = FALSE,
                                          show_names = TRUE,
                                          caption = "Bayes Factors for Model Comparison",
                                          ...) {
  .print_bf_html_default(
    x = x,
    digits = digits,
    log = log,
    show_names = show_names,
    caption = caption,
    align = "llr",
    ...
  )
}


#' @export
print_html.bayesfactor_inclusion <- function(x,
                                             digits = 3,
                                             log = FALSE,
                                             caption = "Inclusion Bayes Factors (Model Averaged)",
                                             ...) {
  .print_bf_html_default(
    x = x,
    digits = digits,
    log = log,
    caption = caption,
    align = "lrrr",
    ...
  )
}


#' @export
print_html.bayesfactor_restricted <- function(x,
                                              digits = 3,
                                              log = FALSE,
                                              caption = "Bayes Factor (Order-Restriction)",
                                              ...) {
  .print_bf_html_default(x = x, digits = digits, log = log, caption = caption, ...)
}


#' @export
print_html.bayesfactor_parameters <- function(x, digits = 3, log = FALSE, ...) {
  # retrieve information with cleaned parameter names
  cp <- attr(x, "clean_parameters")

  # format data frame and columns
  formatted_table <- format(
    x,
    cp = cp,
    digits = digits,
    log = log,
    format = "html",
    ...
  )

  insight::export_table(formatted_table, format = "html")
}


# util ---------------


.print_html_default <- function(x, digits = 2, caption = NULL, subtitles = NULL, ci_string = "CI", ...) {
  # retrieve information with cleaned parameter names
  cp <- attr(x, "clean_parameters")

  # format data frame and columns
  formatted_table <- format(
    x,
    cp = cp,
    digits = digits,
    format = "html",
    ci_string = ci_string,
    caption = caption,
    subtitles = subtitles,
    ...
  )

  # print for data frame - I don't think we need a special handling for
  # numeric values to have a markdown-table output
  insight::export_table(
    formatted_table,
    caption = caption,
    format = "html"
  )
}


.print_bf_html_default <- function(x,
                                   digits = 3,
                                   log = FALSE,
                                   show_names = NULL,
                                   caption = NULL,
                                   align = NULL,
                                   ...) {
  formatted_table <- format(
    x,
    digits = digits,
    log = log,
    show_names = show_names,
    caption = caption,
    format = "html",
    ...
  )

  insight::export_table(
    formatted_table,
    align = align,
    caption = caption,
    format = "html"
  )
}
