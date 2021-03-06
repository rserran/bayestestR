% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/convert_bayesian_to_frequentist.R
\name{convert_bayesian_as_frequentist}
\alias{convert_bayesian_as_frequentist}
\alias{bayesian_as_frequentist}
\title{Convert (refit) a Bayesian model to frequentist}
\usage{
convert_bayesian_as_frequentist(model, data = NULL)

bayesian_as_frequentist(model, data = NULL)
}
\arguments{
\item{model}{A Bayesian model.}

\item{data}{Data used by the model. If \code{NULL}, will try to extract it
from the model.}
}
\description{
Refit Bayesian model as frequentist. Can be useful for comparisons.
}
\examples{
\donttest{
# Rstanarm ----------------------
if (require("rstanarm")) {
  # Simple regressions
  model <- stan_glm(Sepal.Length ~ Species,
    data = iris, chains = 2, refresh = 0
  )
  bayesian_as_frequentist(model)
}
}

\dontrun{
if (require("rstanarm")) {
  model <- stan_glm(vs ~ mpg,
    family = "binomial",
    data = mtcars, chains = 2, refresh = 0
  )
  bayesian_as_frequentist(model)

  # Mixed models
  model <- stan_glmer(Sepal.Length ~ Petal.Length + (1 | Species),
    data = iris, chains = 2, refresh = 0
  )
  bayesian_as_frequentist(model)

  model <- stan_glmer(vs ~ mpg + (1 | cyl),
    family = "binomial",
    data = mtcars, chains = 2, refresh = 0
  )
  bayesian_as_frequentist(model)
}
}

}
