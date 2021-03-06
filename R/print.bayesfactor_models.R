
# print.bayesfactor_models <- function(x, digits = 3, log = FALSE, show_names = TRUE, ...) {
#   BFE <- x
#   denominator <- attr(BFE, "denominator")
#   grid.type <- attr(BFE, "BF_method")
#   model_names <- rownames(BFE)
#
#   BFE <- as.data.frame(BFE)
#   if (log) {
#     BFE$BF <- log(BFE$BF)
#   }
#   BFE$BF <- insight::format_value(BFE$BF, digits = digits, missing = "NA", zap_small = log)
#   BFE$Model[BFE$Model == "1"] <- "(Intercept only)" # indicate null-model
#
#   if ((!show_names) || is.null(model_names) || length(model_names) != nrow(BFE)) {
#     BFE$i <- paste0("[", seq_len(nrow(BFE)), "]")
#   } else {
#     BFE$i <- paste0("[", model_names, "]")
#   }
#
#   # Denominator
#   denM <- .trim(paste0(BFE$i, " ", BFE$Model)[denominator])
#   BFE <- BFE[-denominator, ]
#   BFE <- BFE[c("i", "Model", "BF")]
#   colnames(BFE)[1] <- ""
#
#   # footer
#   footer <- list(
#     "\n* Against Denominator: ",
#     c(denM, "cyan"),
#     "\n*   Bayes Factor Type: ",
#     c(grid.type, "cyan"),
#     if (log) c("\n\nBayes Factors are on the log-scale.", "red")
#   )
#
#   cat(insight::export_table(
#     BFE,
#     sep = " ", header = NULL, align = c("llr"),
#     caption = c("# Bayes Factors for Model Comparison", "blue"),
#     footer = footer
#   ))
#
#   invisible(x)
# }



#' @importFrom insight print_color export_table
#' @export
print.bayesfactor_models_matrix <- function(x, digits = 2, log = FALSE, exact = TRUE, ...) {
  orig_x <- x

  # Format values
  x <- unclass(x)
  if (!log) x <- exp(x)
  sgn <- sign(x) < 0
  x <- insight::format_bf(abs(x), name = NULL, exact = exact, ...)
  diag(x) <- if (log) "0" else "1"
  if (any(sgn)) x[sgn] <- paste0("-", x[sgn])

  df <- as.data.frame(x)

  # Model names
  models <- colnames(df)
  models[models == "1"] <- "(Intercept only)"
  models <- paste0("[", seq_along(models), "] ", models)
  k <- max(sapply(c(models, "Denominator"), nchar)) + 2

  rownames(df) <- colnames(df) <- NULL
  df <- cbind(Model = models, df)
  colnames(df) <- c("placeholder", paste0(" [", seq_along(models), "] "))

  out <- insight::export_table(
    df,
    caption = c("# Bayes Factors for Model Comparison", "blue"),
    subtitle = c(sprintf("\n\n%sNumerator\nDenominator", paste(rep(" ", k), collapse = "")), "cyan"),
    footer = if (log) c("\nBayes Factors are on the log-scale.\n", "red")
  )
  out <- sub("placeholder", "\b\b", out)
  cat(out)

  invisible(orig_x)
}
