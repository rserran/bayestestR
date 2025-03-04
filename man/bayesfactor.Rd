% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bayesfactor.R
\name{bayesfactor}
\alias{bayesfactor}
\title{Bayes Factors (BF)}
\usage{
bayesfactor(
  ...,
  prior = NULL,
  direction = "two-sided",
  null = 0,
  hypothesis = NULL,
  effects = c("fixed", "random", "all"),
  verbose = TRUE,
  denominator = 1,
  match_models = FALSE,
  prior_odds = NULL
)
}
\arguments{
\item{...}{A numeric vector, model object(s), or the output from
\code{bayesfactor_models}.}

\item{prior}{An object representing a prior distribution (see 'Details').}

\item{direction}{Test type (see 'Details'). One of \code{0},
\code{"two-sided"} (default, two tailed), \code{-1}, \code{"left"} (left
tailed) or \code{1}, \code{"right"} (right tailed).}

\item{null}{Value of the null, either a scalar (for point-null) or a range
(for a interval-null).}

\item{hypothesis}{A character vector specifying the restrictions as logical conditions (see examples below).}

\item{effects}{Should results for fixed effects, random effects or both be
returned? Only applies to mixed models. May be abbreviated.}

\item{verbose}{Toggle off warnings.}

\item{denominator}{Either an integer indicating which of the models to use as
the denominator, or a model to be used as a denominator. Ignored for
\code{BFBayesFactor}.}

\item{match_models}{See details.}

\item{prior_odds}{Optional vector of prior odds for the models. See
\verb{BayesFactor::priorOdds<-}.}
}
\value{
Some type of Bayes factor, depending on the input. See
\code{\link[=bayesfactor_parameters]{bayesfactor_parameters()}}, \code{\link[=bayesfactor_models]{bayesfactor_models()}} or \code{\link[=bayesfactor_inclusion]{bayesfactor_inclusion()}}.
}
\description{
This function compte the Bayes factors (BFs) that are appropriate to the
input. For vectors or single models, it will compute \code{\link[=bayesfactor_parameters]{BFs for single parameters}}, or is \code{hypothesis} is specified,
\code{\link[=bayesfactor_restricted]{BFs for restricted models}}. For multiple models,
it will return the BF corresponding to \code{\link[=bayesfactor_models]{comparison between models}} and if a model comparison is passed, it will
compute the \code{\link[=bayesfactor_inclusion]{inclusion BF}}.
\cr\cr
For a complete overview of these functions, read the \href{https://easystats.github.io/bayestestR/articles/bayes_factors.html}{Bayes factor vignette}.
}
\note{
There is also a \href{https://easystats.github.io/see/articles/bayestestR.html}{\code{plot()}-method} implemented in the \href{https://easystats.github.io/see/}{\pkg{see}-package}.
}
\examples{
\dontshow{if (require("rstanarm") && require("logspline")) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
\dontrun{
library(bayestestR)

prior <- distribution_normal(1000, mean = 0, sd = 1)
posterior <- distribution_normal(1000, mean = 0.5, sd = 0.3)

bayesfactor(posterior, prior = prior, verbose = FALSE)

# rstanarm models
# ---------------
model <- suppressWarnings(rstanarm::stan_lmer(extra ~ group + (1 | ID), data = sleep))
bayesfactor(model, verbose = FALSE)

# Frequentist models
# ---------------
m0 <- lm(extra ~ 1, data = sleep)
m1 <- lm(extra ~ group, data = sleep)
m2 <- lm(extra ~ group + ID, data = sleep)

comparison <- bayesfactor(m0, m1, m2)
comparison

bayesfactor(comparison)
}
\dontshow{\}) # examplesIf}
}
