#' Highest Density Interval (HDI)
#'
#' Compute the **Highest Density Interval (HDI)** of posterior distributions.
#' All points within this interval have a higher probability density than points
#' outside the interval. The HDI can be used in the context of uncertainty
#' characterisation of posterior distributions as **Credible Interval (CI)**.
#'
#' @param x Vector representing a posterior distribution, or a data frame of such
#'   vectors. Can also be a Bayesian model. **bayestestR** supports a wide range
#'   of models (see, for example, `methods("hdi")`) and not all of those are
#'   documented in the 'Usage' section, because methods for other classes mostly
#'   resemble the arguments of the `.numeric` or `.data.frame`methods.
#' @param ci Value or vector of probability of the (credible) interval - CI
#'   (between 0 and 1) to be estimated. Default to `.95` (`95%`).
#' @param component Which type of parameters to return, such as parameters for
#' the conditional model, the zero-inflated part of the model, the dispersion
#' term, etc. See details in section _Model Components_. May be abbreviated.
#' Note that the *conditional* component also refers to the *count* or *mean*
#' component - names may differ, depending on the modeling package. There are
#' three convenient shortcuts (not applicable to *all* model classes):
#' - `component = "all"` returns all possible parameters.
#' - If `component = "location"`, location parameters such as `conditional`,
#'   `zero_inflated`, `smooth_terms`, or `instruments` are returned (everything
#'   that are fixed or random effects - depending on the `effects` argument -
#'   but no auxiliary parameters).
#' - For `component = "distributional"` (or `"auxiliary"`), components like
#'   `sigma`, `dispersion`, `beta` or `precision` (and other auxiliary
#'   parameters) are returned.
#' @param parameters Regular expression pattern that describes the parameters
#'   that should be returned. Meta-parameters (like `lp__` or `prior_`) are
#'   filtered by default, so only parameters that typically appear in the
#'   `summary()` are returned. Use `parameters` to select specific parameters
#'   for the output.
#' @param use_iterations Logical, if `TRUE` and `x` is a `get_predicted` object,
#' (returned by [`insight::get_predicted()`]), the function is applied to the
#' iterations instead of the predictions. This only applies to models that return
#' iterations for predicted values (e.g., `brmsfit` models).
#' @param verbose Toggle off warnings.
#' @param ... Currently not used.
#' @inheritParams insight::get_parameters.BFBayesFactor
#' @inheritParams insight::get_parameters
#'
#' @note There is also a [`plot()`-method](https://easystats.github.io/see/articles/bayestestR.html) implemented in the \href{https://easystats.github.io/see/}{\pkg{see}-package}.
#'
#' @section Model components:
#'
#' Possible values for the `component` argument depend on the model class.
#' Following are valid options:
#' - `"all"`: returns all model components, applies to all models, but will only
#'   have an effect for models with more than just the conditional model
#'   component.
#' - `"conditional"`: only returns the conditional component, i.e. "fixed
#'   effects" terms from the model. Will only have an effect for models with
#'   more than just the conditional model component.
#' - `"smooth_terms"`: returns smooth terms, only applies to GAMs (or similar
#'   models that may contain smooth terms).
#' - `"zero_inflated"` (or `"zi"`): returns the zero-inflation component.
#' - `"location"`: returns location parameters such as `conditional`,
#'   `zero_inflated`, or `smooth_terms` (everything that are fixed or random
#'   effects - depending on the `effects` argument - but no auxiliary
#'   parameters).
#' - `"distributional"` (or `"auxiliary"`): components like `sigma`,
#'   `dispersion`, `beta` or `precision` (and other auxiliary parameters) are
#'   returned.
#'
#' For models of class `brmsfit` (package **brms**), even more options are
#' possible for the `component` argument, which are not all documented in detail
#' here. See also [`?insight::find_parameters`](https://easystats.github.io/insight/reference/find_parameters.BGGM.html).
#'
#' @details Unlike equal-tailed intervals (see [`eti()`]) that typically exclude
#' `2.5%` from each tail of the distribution and always include the median, the
#' HDI is *not* equal-tailed and therefore always includes the mode(s) of posterior
#' distributions. While this can be useful to better represent the credibility
#' mass of a distribution, the HDI also has some limitations. See [`spi()`] for
#' details.
#'
#' The [`95%` or `89%` Credible Intervals (CI)](https://easystats.github.io/bayestestR/articles/credible_interval.html)
#' are two reasonable ranges to characterize the uncertainty related to the
#' estimation (see [here](https://easystats.github.io/bayestestR/articles/credible_interval.html)
#' for a discussion about the differences between these two values).
#'
#' The `89%` intervals (`ci = 0.89`) are deemed to be more stable than, for
#' instance, `95%` intervals (_Kruschke, 2014_). An effective sample size
#' of at least 10.000 is recommended if one wants to estimate `95%` intervals
#' with high precision (_Kruschke, 2014, p. 183ff_). Unfortunately, the
#' default number of posterior samples for most Bayes packages (e.g., `rstanarm`
#' or `brms`) is only 4.000 (thus, you might want to increase it when fitting
#' your model). Moreover, 89 indicates the arbitrariness of interval limits -
#' its only remarkable property is being the highest prime number that does not
#' exceed the already unstable `95%` threshold (_McElreath, 2015_).
#'
#' However, `95%` has some [advantages too](https://easystats.github.io/blog/posts/bayestestr_95/).
#' For instance, it shares (in the case of a normal posterior distribution) an
#' intuitive relationship with the standard deviation and it conveys a more
#' accurate image of the (artificial) bounds of the distribution. Also, because
#' it is wider, it makes analyses more conservative (i.e., the probability of
#' covering zero is larger for the `95%` CI than for lower ranges such as `89%`),
#' which is a good thing in the context of the reproducibility crisis.
#'
#' A `95%` equal-tailed interval (ETI) has `2.5%` of the distribution on either
#' side of its limits. It indicates the 2.5th percentile and the 97.5th
#' percentile. In symmetric distributions, the two methods of computing credible
#' intervals, the ETI and the [HDI][hdi], return similar results.
#'
#' This is not the case for skewed distributions. Indeed, it is possible that
#' parameter values in the ETI have lower credibility (are less probable) than
#' parameter values outside the ETI. This property seems undesirable as a summary
#' of the credible values in a distribution.
#'
#' On the other hand, the ETI range does change when transformations are applied
#' to the distribution (for instance, for a log odds scale to probabilities):
#' the lower and higher bounds of the transformed distribution will correspond
#' to the transformed lower and higher bounds of the original distribution.
#' On the contrary, applying transformations to the distribution will change
#' the resulting HDI.
#'
#' @inherit ci return
#'
#' @family ci
#' @seealso Other interval functions, such as [`hdi()`], [`eti()`], [`bci()`],
#' [`spi()`], [`si()`].
#'
#' @examplesIf all(insight::check_if_installed(c("rstanarm", "brms", "emmeans", "BayesFactor"), quietly = TRUE))
#' library(bayestestR)
#'
#' posterior <- rnorm(1000)
#' hdi(posterior, ci = 0.89)
#' hdi(posterior, ci = c(0.80, 0.90, 0.95))
#'
#' hdi(iris[1:4])
#' hdi(iris[1:4], ci = c(0.80, 0.90, 0.95))
#' \donttest{
#' model <- suppressWarnings(
#'   rstanarm::stan_glm(mpg ~ wt + gear, data = mtcars, chains = 2, iter = 200, refresh = 0)
#' )
#' hdi(model)
#' hdi(model, ci = c(0.80, 0.90, 0.95))
#'
#' hdi(emmeans::emtrends(model, ~1, "wt", data = mtcars))
#'
#' model <- brms::brm(mpg ~ wt + cyl, data = mtcars)
#' hdi(model)
#' hdi(model, ci = c(0.80, 0.90, 0.95))
#'
#' bf <- BayesFactor::ttestBF(x = rnorm(100, 1, 1))
#' hdi(bf)
#' hdi(bf, ci = c(0.80, 0.90, 0.95))
#' }
#' @author Credits go to **ggdistribute** and [**HDInterval**](https://github.com/mikemeredith/HDInterval).
#'
#' @references
#' - Kruschke, J. (2014). Doing Bayesian data analysis: A tutorial with R, JAGS,
#'   and Stan. Academic Press.
#' - McElreath, R. (2015). Statistical rethinking: A Bayesian course with
#'   examples in R and Stan. Chapman and Hall/CRC.
#'
#' @export
hdi <- function(x, ...) {
  UseMethod("hdi")
}


#' @export
hdi.default <- function(x, ...) {
  insight::format_error(paste0(
    "'hdi()' is not yet implemented for objects of class '",
    class(x)[1], "'."
  ))
}


#' @rdname hdi
#' @export
hdi.numeric <- function(x, ci = 0.95, verbose = TRUE, ...) {
  out <- do.call(rbind, lapply(ci, function(i) {
    .hdi(x, ci = i, verbose = verbose)
  }))
  class(out) <- unique(c("bayestestR_hdi", "see_hdi", "bayestestR_ci", "see_ci", class(out)))
  attr(out, "data") <- x
  out
}


#' @rdname hdi
#' @inheritParams p_direction
#' @export
hdi.data.frame <- function(x, ci = 0.95, rvar_col = NULL, verbose = TRUE, ...) {
  obj_name <- insight::safe_deparse_symbol(substitute(x))

  x_rvar <- .possibly_extract_rvar_col(x, rvar_col)
  if (length(x_rvar) > 0L) {
    cl <- match.call()
    cl[[1]] <- bayestestR::hdi
    cl$x <- x_rvar
    cl$rvar_col <- NULL
    out <- eval.parent(cl)

    attr(out, "object_name") <- sprintf('%s[["%s"]]', obj_name, rvar_col)

    return(.append_datagrid(out, x, long = length(ci) > 1L))
  }

  dat <- .compute_interval_dataframe(x = x, ci = ci, verbose = verbose, fun = "hdi")
  attr(dat, "object_name") <- obj_name
  dat
}


#' @export
hdi.draws <- function(x, ci = 0.95, verbose = TRUE, ...) {
  dat <- .compute_interval_dataframe(
    x = .posterior_draws_to_df(x),
    ci = ci,
    verbose = verbose,
    fun = "hdi"
  )
  attr(dat, "object_name") <- insight::safe_deparse_symbol(substitute(x))
  dat
}

#' @export
hdi.rvar <- hdi.draws


#' @export
hdi.MCMCglmm <- function(x, ci = 0.95, verbose = TRUE, ...) {
  ci_fun <- .check_ci_fun(list(...))
  nF <- x$Fixed$nfl
  d <- as.data.frame(x$Sol[, 1:nF, drop = FALSE])
  dat <- .compute_interval_dataframe(x = d, ci = ci, verbose = verbose, fun = ci_fun)
  attr(dat, "data") <- insight::safe_deparse_symbol(substitute(x))
  dat
}


#' @export
hdi.bamlss <- function(x,
                       ci = 0.95,
                       component = "all",
                       verbose = TRUE,
                       ...) {
  ci_fun <- .check_ci_fun(list(...))
  d <- insight::get_parameters(x, component = component)
  dat <- .compute_interval_dataframe(x = d, ci = ci, verbose = verbose, fun = ci_fun)
  dat <- .add_clean_parameters_attribute(dat, x)
  attr(dat, "data") <- insight::safe_deparse_symbol(substitute(x))
  dat
}


#' @export
hdi.mcmc <- function(x, ci = 0.95, verbose = TRUE, ...) {
  ci_fun <- .check_ci_fun(list(...))
  d <- as.data.frame(x)
  dat <- .compute_interval_dataframe(x = d, ci = ci, verbose = verbose, fun = ci_fun)
  attr(dat, "data") <- insight::safe_deparse_symbol(substitute(x))
  dat
}


#' @export
hdi.bcplm <- function(x, ci = 0.95, verbose = TRUE, ...) {
  ci_fun <- .check_ci_fun(list(...))
  d <- insight::get_parameters(x)
  dat <- .compute_interval_dataframe(x = d, ci = ci, verbose = verbose, fun = ci_fun)
  attr(dat, "data") <- insight::safe_deparse_symbol(substitute(x))
  dat
}

#' @export
hdi.bayesQR <- hdi.bcplm

#' @export
hdi.blrm <- hdi.bcplm

#' @export
hdi.mcmc.list <- hdi.bcplm

#' @export
hdi.BGGM <- hdi.bcplm


#' @export
hdi.sim.merMod <- function(x,
                           ci = 0.95,
                           effects = "fixed",
                           parameters = NULL,
                           verbose = TRUE,
                           ...) {
  ci_fun <- .check_ci_fun(list(...))

  dat <- .compute_interval_simMerMod(
    x = x,
    ci = ci,
    effects = effects,
    parameters = parameters,
    verbose = verbose,
    fun = ci_fun
  )
  out <- dat$result
  attr(out, "data") <- dat$data
  out
}


#' @export
hdi.sim <- function(x, ci = 0.95, parameters = NULL, verbose = TRUE, ...) {
  ci_fun <- .check_ci_fun(list(...))
  dat <- .compute_interval_sim(
    x = x,
    ci = ci,
    parameters = parameters,
    verbose = verbose,
    fun = ci_fun
  )
  out <- dat$result
  attr(out, "data") <- dat$data
  out
}


#' @export
hdi.emmGrid <- function(x, ci = 0.95, verbose = TRUE, ...) {
  xdf <- insight::get_parameters(x)
  out <- hdi(xdf, ci = ci, verbose = verbose, ...)
  out <- .append_datagrid(out, x, long = length(ci) > 1L)
  attr(out, "object_name") <- insight::safe_deparse_symbol(substitute(x))
  out
}

#' @export
hdi.emm_list <- hdi.emmGrid

#' @export
hdi.slopes <- function(x, ci = 0.95, verbose = TRUE, ...) {
  xrvar <- .get_marginaleffects_draws(x)
  out <- hdi(xrvar, ci = ci, verbose = verbose, ...)
  out <- .append_datagrid(out, x, long = length(ci) > 1L)
  attr(out, "object_name") <- insight::safe_deparse_symbol(substitute(x))
  out
}

#' @export
hdi.comparisons <- hdi.slopes

#' @export
hdi.predictions <- hdi.slopes


#' @export
hdi.stanreg <- function(x,
                        ci = 0.95,
                        effects = "fixed",
                        component = "location",
                        parameters = NULL,
                        verbose = TRUE,
                        ...) {
  cleaned_parameters <- .get_cleaned_parameters(x, ...)

  out <- .prepare_output(
    hdi(
      insight::get_parameters(
        x,
        effects = effects,
        component = component,
        parameters = parameters
      ),
      ci = ci,
      verbose = verbose,
      ...
    ),
    cleaned_parameters,
    inherits(x, "stanmvreg")
  )

  attr(out, "clean_parameters") <- cleaned_parameters
  attr(out, "object_name") <- insight::safe_deparse_symbol(substitute(x))
  class(out) <- unique(c("bayestestR_hdi", "see_hdi", class(out)))
  out
}

#' @export
hdi.stanfit <- hdi.stanreg

#' @export
hdi.blavaan <- hdi.stanreg


#' @rdname hdi
#' @export
hdi.brmsfit <- function(x,
                        ci = 0.95,
                        effects = "fixed",
                        component = "conditional",
                        parameters = NULL,
                        verbose = TRUE,
                        ...) {
  cleaned_parameters <- .get_cleaned_parameters(x, ...)

  out <- .prepare_output(
    hdi(
      insight::get_parameters(
        x,
        effects = effects,
        component = component,
        parameters = parameters
      ),
      ci = ci,
      verbose = verbose,
      ...
    ),
    cleaned_parameters
  )

  attr(out, "clean_parameters") <- cleaned_parameters
  attr(out, "object_name") <- insight::safe_deparse_symbol(substitute(x))
  class(out) <- unique(c("bayestestR_hdi", "see_hdi", class(out)))
  out
}


#' @export
hdi.BFBayesFactor <- function(x, ci = 0.95, verbose = TRUE, ...) {
  out <- hdi(insight::get_parameters(x), ci = ci, verbose = verbose, ...)
  attr(out, "object_name") <- insight::safe_deparse_symbol(substitute(x))
  out
}


#' @rdname hdi
#' @export
hdi.get_predicted <- function(x, ci = 0.95, use_iterations = FALSE, verbose = TRUE, ...) {
  if (isTRUE(use_iterations)) {
    if ("iterations" %in% names(attributes(x))) {
      out <- hdi(as.data.frame(t(attributes(x)$iterations)), ci = ci, verbose = verbose, ...)
    } else {
      insight::format_error("No iterations present in the output.")
    }
    attr(out, "object_name") <- insight::safe_deparse_symbol(substitute(x))
  } else {
    out <- hdi(as.numeric(x), ci = ci, verbose = verbose, ...)
  }
  out
}


# Helper ------------------------------------------------------------------


#' @keywords internal
.hdi <- function(x, ci = 0.95, verbose = TRUE) {
  check_ci <- .check_ci_argument(x, ci, verbose)

  if (!is.null(check_ci)) {
    return(check_ci)
  }

  # removes NA/NaN, but not Inf
  x_sorted <- unname(sort.int(x, method = "quick"))
  # See https://github.com/easystats/bayestestR/issues/39
  window_size <- ceiling(ci * length(x_sorted))

  if (window_size < 2) {
    if (verbose) {
      insight::format_alert("`ci` is too small or x does not contain enough data points, returning NAs.")
    }
    return(data.frame(
      CI = ci,
      CI_low = NA,
      CI_high = NA
    ))
  }

  nCIs <- length(x_sorted) - window_size

  if (nCIs < 1) {
    if (verbose) {
      insight::format_alert("`ci` is too large or x does not contain enough data points, returning NAs.")
    }
    return(data.frame(
      CI = ci,
      CI_low = NA,
      CI_high = NA
    ))
  }

  ci.width <- sapply(1:nCIs, function(.x) x_sorted[.x + window_size] - x_sorted[.x])

  # find minimum of width differences, check for multiple minima
  min_i <- which(ci.width == min(ci.width))
  n_candies <- length(min_i)

  if (n_candies > 1) {
    if (any(diff(sort(min_i)) != 1)) {
      if (verbose) {
        insight::format_alert("Identical densities found along different segments of the distribution, choosing rightmost.")
      }
      min_i <- max(min_i)
    } else {
      min_i <- floor(mean(min_i))
    }
  }

  data.frame(
    CI = ci,
    CI_low = x_sorted[min_i],
    CI_high = x_sorted[min_i + window_size]
  )
}
