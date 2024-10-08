% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/p_map.R
\name{p_map}
\alias{p_map}
\alias{p_pointnull}
\alias{p_map.numeric}
\alias{p_map.get_predicted}
\alias{p_map.data.frame}
\alias{p_map.stanreg}
\alias{p_map.brmsfit}
\title{Bayesian p-value based on the density at the Maximum A Posteriori (MAP)}
\usage{
p_map(x, ...)

p_pointnull(x, ...)

\method{p_map}{numeric}(x, null = 0, precision = 2^10, method = "kernel", ...)

\method{p_map}{get_predicted}(
  x,
  null = 0,
  precision = 2^10,
  method = "kernel",
  use_iterations = FALSE,
  verbose = TRUE,
  ...
)

\method{p_map}{data.frame}(x, null = 0, precision = 2^10, method = "kernel", rvar_col = NULL, ...)

\method{p_map}{stanreg}(
  x,
  null = 0,
  precision = 2^10,
  method = "kernel",
  effects = c("fixed", "random", "all"),
  component = c("location", "all", "conditional", "smooth_terms", "sigma",
    "distributional", "auxiliary"),
  parameters = NULL,
  ...
)

\method{p_map}{brmsfit}(
  x,
  null = 0,
  precision = 2^10,
  method = "kernel",
  effects = c("fixed", "random", "all"),
  component = c("conditional", "zi", "zero_inflated", "all"),
  parameters = NULL,
  ...
)
}
\arguments{
\item{x}{Vector representing a posterior distribution, or a data frame of such
vectors. Can also be a Bayesian model. \strong{bayestestR} supports a wide range
of models (see, for example, \code{methods("hdi")}) and not all of those are
documented in the 'Usage' section, because methods for other classes mostly
resemble the arguments of the \code{.numeric} or \code{.data.frame}methods.}

\item{...}{Currently not used.}

\item{null}{The value considered as a "null" effect. Traditionally 0, but
could also be 1 in the case of ratios of change (OR, IRR, ...).}

\item{precision}{Number of points of density data. See the \code{n} parameter in \code{density}.}

\item{method}{Density estimation method. Can be \code{"kernel"} (default), \code{"logspline"}
or \code{"KernSmooth"}.}

\item{use_iterations}{Logical, if \code{TRUE} and \code{x} is a \code{get_predicted} object,
(returned by \code{\link[insight:get_predicted]{insight::get_predicted()}}), the function is applied to the
iterations instead of the predictions. This only applies to models that return
iterations for predicted values (e.g., \code{brmsfit} models).}

\item{verbose}{Toggle off warnings.}

\item{rvar_col}{A single character - the name of an \code{rvar} column in the data
frame to be processed. See example in \code{\link[=p_direction]{p_direction()}}.}

\item{effects}{Should results for fixed effects, random effects or both be
returned? Only applies to mixed models. May be abbreviated.}

\item{component}{Should results for all parameters, parameters for the
conditional model or the zero-inflated part of the model be returned? May
be abbreviated. Only applies to \pkg{brms}-models.}

\item{parameters}{Regular expression pattern that describes the parameters
that should be returned. Meta-parameters (like \code{lp__} or \code{prior_}) are
filtered by default, so only parameters that typically appear in the
\code{summary()} are returned. Use \code{parameters} to select specific parameters
for the output.}
}
\description{
Compute a Bayesian equivalent of the \emph{p}-value, related to the odds that a
parameter (described by its posterior distribution) has against the null
hypothesis (\emph{h0}) using Mills' (2014, 2017) \emph{Objective Bayesian Hypothesis
Testing} framework. It corresponds to the density value at the null (e.g., 0)
divided by the density at the Maximum A Posteriori (MAP).
}
\details{
Note that this method is sensitive to the density estimation \code{method}
(see the section in the examples below).
\subsection{Strengths and Limitations}{

\strong{Strengths:} Straightforward computation. Objective property of the posterior
distribution.

\strong{Limitations:} Limited information favoring the null hypothesis. Relates
on density approximation. Indirect relationship between mathematical
definition and interpretation. Only suitable for weak / very diffused priors.
}
}
\examples{
\dontshow{if (require("rstanarm") && require("emmeans") && require("brms") && require("BayesFactor")) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
library(bayestestR)

p_map(rnorm(1000, 0, 1))
p_map(rnorm(1000, 10, 1))
\donttest{
model <- suppressWarnings(
  rstanarm::stan_glm(mpg ~ wt + gear, data = mtcars, chains = 2, iter = 200, refresh = 0)
)
p_map(model)

p_map(suppressWarnings(
  emmeans::emtrends(model, ~1, "wt", data = mtcars)
))

model <- brms::brm(mpg ~ wt + cyl, data = mtcars)
p_map(model)

bf <- BayesFactor::ttestBF(x = rnorm(100, 1, 1))
p_map(bf)

# ---------------------------------------
# Robustness to density estimation method
set.seed(333)
data <- data.frame()
for (iteration in 1:250) {
  x <- rnorm(1000, 1, 1)
  result <- data.frame(
    Kernel = as.numeric(p_map(x, method = "kernel")),
    KernSmooth = as.numeric(p_map(x, method = "KernSmooth")),
    logspline = as.numeric(p_map(x, method = "logspline"))
  )
  data <- rbind(data, result)
}
data$KernSmooth <- data$Kernel - data$KernSmooth
data$logspline <- data$Kernel - data$logspline

summary(data$KernSmooth)
summary(data$logspline)
boxplot(data[c("KernSmooth", "logspline")])
}
\dontshow{\}) # examplesIf}
}
\references{
\itemize{
\item Makowski D, Ben-Shachar MS, Chen SHA, Lüdecke D (2019) Indices of Effect Existence and Significance in the Bayesian Framework. Frontiers in Psychology 2019;10:2767. \doi{10.3389/fpsyg.2019.02767}
\item Mills, J. A. (2018). Objective Bayesian Precise Hypothesis Testing. University of Cincinnati.
}
}
\seealso{
\href{https://www.youtube.com/watch?v=Ip8Ci5KUVRc}{Jeff Mill's talk}
}
