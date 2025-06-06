% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/si.R
\name{si}
\alias{si}
\alias{si.numeric}
\alias{si.stanreg}
\alias{si.get_predicted}
\alias{si.data.frame}
\title{Compute Support Intervals}
\usage{
si(posterior, ...)

\method{si}{numeric}(posterior, prior = NULL, BF = 1, verbose = TRUE, ...)

\method{si}{stanreg}(
  posterior,
  prior = NULL,
  BF = 1,
  verbose = TRUE,
  effects = "fixed",
  component = "location",
  parameters = NULL,
  ...
)

\method{si}{get_predicted}(
  posterior,
  prior = NULL,
  BF = 1,
  use_iterations = FALSE,
  verbose = TRUE,
  ...
)

\method{si}{data.frame}(posterior, prior = NULL, BF = 1, rvar_col = NULL, verbose = TRUE, ...)
}
\arguments{
\item{posterior}{A numerical vector, \code{stanreg} / \code{brmsfit} object,
\code{emmGrid} or a data frame - representing a posterior distribution(s)
from (see 'Details').}

\item{...}{Arguments passed to and from other methods. (Can be used to pass
arguments to internal \code{\link[logspline:logspline]{logspline::logspline()}}.)}

\item{prior}{An object representing a prior distribution (see 'Details').}

\item{BF}{The amount of support required to be included in the support interval.}

\item{verbose}{Toggle off warnings.}

\item{effects}{Should variables for fixed effects (\code{"fixed"}), random effects
(\code{"random"}) or both (\code{"all"}) be returned? Only applies to mixed models. May
be abbreviated.

For models of from packages \strong{brms} or \strong{rstanarm} there are additional
options:
\itemize{
\item \code{"fixed"} returns fixed effects.
\item \code{"random_variance"} return random effects parameters (variance and
correlation components, e.g. those parameters that start with \code{sd_} or
\code{cor_}).
\item \code{"grouplevel"} returns random effects group level estimates, i.e. those
parameters that start with \code{r_}.
\item \code{"random"} returns both \code{"random_variance"} and \code{"grouplevel"}.
\item \code{"all"} returns fixed effects and random effects variances.
\item \code{"full"} returns all parameters.
}}

\item{component}{Which type of parameters to return, such as parameters for
the conditional model, the zero-inflated part of the model, the dispersion
term, etc. See details in section \emph{Model Components}. May be abbreviated.
Note that the \emph{conditional} component also refers to the \emph{count} or \emph{mean}
component - names may differ, depending on the modeling package. There are
three convenient shortcuts (not applicable to \emph{all} model classes):
\itemize{
\item \code{component = "all"} returns all possible parameters.
\item If \code{component = "location"}, location parameters such as \code{conditional},
\code{zero_inflated}, \code{smooth_terms}, or \code{instruments} are returned (everything
that are fixed or random effects - depending on the \code{effects} argument -
but no auxiliary parameters).
\item For \code{component = "distributional"} (or \code{"auxiliary"}), components like
\code{sigma}, \code{dispersion}, \code{beta} or \code{precision} (and other auxiliary
parameters) are returned.
}}

\item{parameters}{Regular expression pattern that describes the parameters
that should be returned. Meta-parameters (like \code{lp__} or \code{prior_}) are
filtered by default, so only parameters that typically appear in the
\code{summary()} are returned. Use \code{parameters} to select specific parameters
for the output.}

\item{use_iterations}{Logical, if \code{TRUE} and \code{x} is a \code{get_predicted} object,
(returned by \code{\link[insight:get_predicted]{insight::get_predicted()}}), the function is applied to the
iterations instead of the predictions. This only applies to models that return
iterations for predicted values (e.g., \code{brmsfit} models).}

\item{rvar_col}{A single character - the name of an \code{rvar} column in the data
frame to be processed. See example in \code{\link[=p_direction]{p_direction()}}.}
}
\value{
A data frame containing the lower and upper bounds of the SI.

Note that if the level of requested support is higher than observed in the data, the
interval will be \verb{[NA,NA]}.
}
\description{
A support interval contains only the values of the parameter that predict the observed data better
than average, by some degree \emph{k}; these are values of the parameter that are associated with an
updating factor greater or equal than \emph{k}. From the perspective of the Savage-Dickey Bayes factor, testing
against a point null hypothesis for any value within the support interval will yield a Bayes factor smaller
than \emph{1/k}.
}
\details{
\strong{For more info, in particular on specifying correct priors for factors with more than 2 levels,
see \href{https://easystats.github.io/bayestestR/articles/bayes_factors.html}{the Bayes factors vignette}.}

This method is used to compute support intervals based on prior and posterior distributions.
For the computation of support intervals, the model priors must be proper priors (at the very least
they should be \emph{not flat}, and it is preferable that they be \emph{informative} - note
that by default, \code{brms::brm()} uses flat priors for fixed-effects; see example below).
}
\note{
There is also a \href{https://easystats.github.io/see/articles/bayestestR.html}{\code{plot()}-method} implemented in the \href{https://easystats.github.io/see/}{\pkg{see}-package}.
}
\section{Choosing a value of \code{BF}}{

The choice of \code{BF} (the level of support) depends on what we want our interval
to represent:
\itemize{
\item A \code{BF} = 1 contains values whose credibility is not decreased by observing the data.
\item A \code{BF} > 1 contains values who received more impressive support from the data.
\item A \code{BF} < 1 contains values whose credibility has \emph{not} been impressively
decreased by observing the data. Testing against values outside this interval
will produce a Bayes factor larger than 1/\code{BF} in support of the alternative.
E.g., if an SI (BF = 1/3) excludes 0, the Bayes factor against the point-null
will be larger than 3.
}
}

\section{Setting the correct \code{prior}}{

For the computation of Bayes factors, the model priors must be proper priors
(at the very least they should be \emph{not flat}, and it is preferable that
they be \emph{informative}); As the priors for the alternative get wider, the
likelihood of the null value(s) increases, to the extreme that for completely
flat priors the null is infinitely more favorable than the alternative (this
is called \emph{the Jeffreys-Lindley-Bartlett paradox}). Thus, you should
only ever try (or want) to compute a Bayes factor when you have an informed
prior.
\cr\cr
(Note that by default, \code{brms::brm()} uses flat priors for fixed-effects;
See example below.)
\cr\cr
It is important to provide the correct \code{prior} for meaningful results,
to match the \code{posterior}-type input:
\itemize{
\item \strong{A numeric vector} - \code{prior} should also be a \emph{numeric vector}, representing the prior-estimate.
\item \strong{A data frame} - \code{prior} should also be a \emph{data frame}, representing the prior-estimates, in matching column order.
\itemize{
\item If \code{rvar_col} is specified, \code{prior} should be \emph{the name of an \code{rvar} column} that represents the prior-estimates.
}
\item \strong{Supported Bayesian model (\code{stanreg}, \code{brmsfit}, etc.)}
\itemize{
\item \code{prior} should be \emph{a model an equivalent model with MCMC samples from the priors \strong{only}}. See \code{\link[=unupdate]{unupdate()}}.
\item If \code{prior} is set to \code{NULL}, \code{\link[=unupdate]{unupdate()}} is called internally (not supported for \code{brmsfit_multiple} model).
}
\item \strong{Output from a \code{{marginaleffects}} function} - \code{prior} should also be \emph{an equivalent output} from a \code{{marginaleffects}} function based on a prior-model
(See \code{\link[=unupdate]{unupdate()}}).
\item \strong{Output from an \code{{emmeans}} function}
\itemize{
\item \code{prior} should also be \emph{an equivalent output} from an \code{{emmeans}} function based on a prior-model (See \code{\link[=unupdate]{unupdate()}}).
\item \code{prior} can also be \emph{the original (posterior) model}, in which case the function
will try to "unupdate" the estimates (not supported if the estimates have undergone
any transformations -- \code{"log"}, \code{"response"}, etc. -- or any \code{regrid}ing).
}
}
}

\examples{
\dontshow{if (require("logspline") && require("rstanarm") && require("brms") && require("emmeans")) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
library(bayestestR)

prior <- distribution_normal(1000, mean = 0, sd = 1)
posterior <- distribution_normal(1000, mean = 0.5, sd = 0.3)

si(posterior, prior, verbose = FALSE)
\donttest{
# rstanarm models
# ---------------
library(rstanarm)
contrasts(sleep$group) <- contr.equalprior_pairs # see vignette
stan_model <- stan_lmer(extra ~ group + (1 | ID), data = sleep)
si(stan_model, verbose = FALSE)
si(stan_model, BF = 3, verbose = FALSE)

# emmGrid objects
# ---------------
library(emmeans)
group_diff <- pairs(emmeans(stan_model, ~group))
si(group_diff, prior = stan_model, verbose = FALSE)

# brms models
# -----------
library(brms)
contrasts(sleep$group) <- contr.equalprior_pairs # see vingette
my_custom_priors <-
  set_prior("student_t(3, 0, 1)", class = "b") +
  set_prior("student_t(3, 0, 1)", class = "sd", group = "ID")

brms_model <- suppressWarnings(brm(extra ~ group + (1 | ID),
  data = sleep,
  prior = my_custom_priors,
  refresh = 0
))
si(brms_model, verbose = FALSE)
}
\dontshow{\}) # examplesIf}
}
\references{
Wagenmakers, E., Gronau, Q. F., Dablander, F., & Etz, A. (2018, November 22).
The Support Interval. \doi{10.31234/osf.io/zwnxb}
}
\seealso{
Other ci: 
\code{\link{bci}()},
\code{\link{ci}()},
\code{\link{eti}()},
\code{\link{hdi}()},
\code{\link{spi}()}
}
\concept{ci}
