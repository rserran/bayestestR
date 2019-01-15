bayestestR
================
Dominique Makowski
2019-01-15

-   [bayestestR](#bayestestr)
    -   [Goal](#goal)
    -   [Installation](#installation)
    -   [Functions](#functions)
    -   [Comparison of Indices](#comparison-of-indices)
        -   [Generate Regression Data with Noise](#generate-regression-data-with-noise)
        -   [Comparison of Parameter Point-Estimates](#comparison-of-parameter-point-estimates)
        -   [Comparison of Indices of Effect Existence](#comparison-of-indices-of-effect-existence)
    -   [Conclusions and Guidelines](#conclusions-and-guidelines)
    -   [Credits](#credits)

------------------------------------------------------------------------

bayestestR
==========

[![Build Status](https://travis-ci.org/DominiqueMakowski/bayestestR.svg?branch=master)](https://travis-ci.org/DominiqueMakowski/bayestestR) [![codecov](https://codecov.io/gh/DominiqueMakowski/bayestestR/branch/master/graph/badge.svg)](https://codecov.io/gh/DominiqueMakowski/bayestestR) [![HitCount](http://hits.dwyl.io/DominiqueMakowski/bayestestR.svg)](http://hits.dwyl.io/DominiqueMakowski/bayestestR)

Utilities for Analyzing Bayesian Posterior Distributions and Models

------------------------------------------------------------------------

Goal
----

`bayestestR` is a lightweight package providing utilities to describe posterior distributions and Bayesian models.

Installation
------------

Run the following:

``` r
install.packages("devtools")
library("devtools")
install_github("DominiqueMakowski/bayestestR")
library("bayestestR")
```

------------------------------------------------------------------------

Functions
---------

-   **`bayes_p()`**: Compute a Bayesian equivalent p value, related to the odds that a parameter (described by its posterior distribution) has againt the null hypothesis (h0) using Mills' (2014, 2017) Objective Bayesian Hypothesis Testing paradigm.

``` r
bayes_p(posterior = rnorm(1000, 0, 1))
bayes_p(posterior = rnorm(1000, 10, 1))
```

-   **`rope()`**: Compute the proportion of the HDI of a posterior distribution that lies within a region of practical equivalence.

``` r
rope(posterior = rnorm(1000, 0, 0.01), rope = c(-0.1, 0.1))
rope(posterior = rnorm(1000, 0, 1), rope = c(-0.1, 0.1))
rope(posterior = rnorm(1000, 1, 0.01), rope = c(-0.1, 0.1))
```

-   **`rope_overlap()`**: Compute how much of the posterior distribution is within a distributed region of practical equivalence.

``` r
rope_overlap(posterior = rnorm(1000, 0, 0.01), rope = c(-0.1, 0.1))
rope_overlap(posterior = rnorm(1000, 0, 1), rope = c(-0.1, 0.1))
rope_overlap(posterior = rnorm(1000, 1, 0.01), rope = c(-0.1, 0.1))
```

-   **`rope_test()`**: Perform a Test for Practical Equivalence based on the "HDI+ROPE decision rule" (Kruschke 2018) to check whether parameter values should be accepted or rejected against an explicitely formulated "null hypothesis".

``` r
rope_test(posterior = rnorm(1000, 0, 0.01), rope = c(-0.1, 0.1))
rope_test(posterior = rnorm(1000, 0, 1), rope = c(-0.1, 0.1))
rope_test(posterior = rnorm(1000, 1, 0.01), rope = c(-0.1, 0.1))
```

-   **`pd()`**: Compute the Probability of Direction (pd, also known as the Maximum Probability of Effect - MPE). It varies between 50% and 100% and can be interpreted as the probability that a parameter (described by its posterior distribution) is positive or negative (following the medianAc�?��?cs sign). It is defined as the proportion of the posterior distribution of the median's sign.

``` r
# Compute the pdSimulate a posterior distribution of mean 1 and SD 1
pd(rnorm(1000, mean = 1, sd = 1))
```

-   **`hdi()`**: Compute the highest density interval (HDI) of a posterior distribution, i.e., the interval which contains all points within the interval have a higher probability density than points outside the interval.

``` r
posterior <- rnorm(1000)
hdi(posterior, prob = 0.9)
hdi(posterior, prob = c(0.8, 0.9, 0.95))
```

-   **`map_estimate()`**: Find the Highest Maximum A Posteriori (MAP) estimate of a posterior.

``` r
posterior <- rnorm(1000)
map_estimate(posterior)
```

-   **`rnorm_perfect()`**: Generate a sample of size n with a near-perfect normal distribution.

``` r
x <- rnorm_perfect(n = 10)
plot(density(x))
```

-   **`overlap()`**: Calculate the overlap coefficient between two kernel density estimates.

``` r
overlap(x=rnorm(1000, 0, 1), y=rnorm(1000, 1, 1))
```

------------------------------------------------------------------------

Comparison of Indices
---------------------

### Generate Regression Data with Noise

``` r
library(ggplot2)
library(dplyr)
library(tidyr)

df <- read.csv("https://raw.github.com/DominiqueMakowski/bayestestR/master/data/bayes_indices.csv")
```

For the sake of time and computational space, we downloaded the data from github. However, you can find the code to generate it again below.

``` r
library(rstanarm)
library(broom)

set.seed(333)

data <- data.frame(x = scale(rnorm(50, 0, 1)))
data$y <- scale(data$x)


bayes_indices <- data.frame()
for(noise in c(0.1, seq(0.5, 5, by=0.5))){
  print(noise)
  for(i in 1:1000){
    cat(".")
    df <- data
    df$y <- df$y + rnorm(50, mean = 0, sd = noise)

    freq_model <- lm(y ~ x, data=df)
    summary(freq_model)
    beta <- broom::tidy(freq_model)[2, ]$estimate
    p <- broom::tidy(freq_model)[2, ]$p.value

    out <- capture.output(bayes_model <- rstanarm::stan_glm(y ~ x, data=df))
    posterior <- as.data.frame(bayes_model)$x

    median <- median(posterior)
    mean <- mean(posterior)
    map <- map_estimate(posterior)[1]

    pd <- pd(posterior)
    rope <- rope(posterior, rope = c(-0.1, 0.1))
    rope_overlap <- rope_overlap(posterior, rope = c(-0.1, 0.1))
    bayes_p <- bayes_p(posterior)

    bayes_indices <- rbind(bayes_indices,
                       data.frame(noise=noise,
                                  iteration=i,
                                  beta = beta,
                                  median = median,
                                  mean = mean,
                                  map = map,
                                  p = p,
                                  pd = pd,
                                  rope = rope,
                                  rope_overlap = rope_overlap,
                                  bayes_p = bayes_p))
  }
}

write.csv(bayes_indices, "../data/bayes_indices.csv")
```

### Comparison of Parameter Point-Estimates

#### Relationship with the theorethical true value (0)

``` r
df %>% 
  select(noise, beta, median, mean, map) %>% 
  gather(estimate, value, -noise) %>% 
  mutate(noise = as.factor(noise),
         value = value-1) %>% 
  ggplot(aes(x = noise, y = value, fill = estimate)) +
  geom_boxplot() +
  geom_hline(yintercept = 0) +
  theme_classic() +
  scale_fill_manual(values = c("beta" = "grey", "map" = "red", "mean" = "green", "median" = "blue"))
```

![](vignettes/readme_files/figure-markdown_github/unnamed-chunk-3-1.png)

``` r
t.test(df$beta, mu = 1)
```

    ## 
    ##  One Sample t-test
    ## 
    ## data:  df$beta
    ## t = -0.044431, df = 10999, p-value = 0.9646
    ## alternative hypothesis: true mean is not equal to 1
    ## 95 percent confidence interval:
    ##  0.9918574 1.0077817
    ## sample estimates:
    ## mean of x 
    ## 0.9998195

``` r
t.test(df$map, mu = 1)
```

    ## 
    ##  One Sample t-test
    ## 
    ## data:  df$map
    ## t = -0.74252, df = 10999, p-value = 0.4578
    ## alternative hypothesis: true mean is not equal to 1
    ## 95 percent confidence interval:
    ##  0.9889701 1.0049694
    ## sample estimates:
    ## mean of x 
    ## 0.9969697

``` r
t.test(df$mean, mu = 1)
```

    ## 
    ##  One Sample t-test
    ## 
    ## data:  df$mean
    ## t = -0.65122, df = 10999, p-value = 0.5149
    ## alternative hypothesis: true mean is not equal to 1
    ## 95 percent confidence interval:
    ##  0.9894202 1.0053031
    ## sample estimates:
    ## mean of x 
    ## 0.9973616

``` r
t.test(df$median, mu = 1)
```

    ## 
    ##  One Sample t-test
    ## 
    ## data:  df$median
    ## t = -0.63978, df = 10999, p-value = 0.5223
    ## alternative hypothesis: true mean is not equal to 1
    ## 95 percent confidence interval:
    ##  0.9894654 1.0053500
    ## sample estimates:
    ## mean of x 
    ## 0.9974077

#### Relationship with the frequentist beta

``` r
df %>% 
  select(noise, beta, median, mean, map) %>% 
  gather(index, value, -noise, -beta) %>% 
  ggplot(aes(x = beta, y = value, color = index)) +
  geom_point(alpha = 0.1, shape = 16) +
  geom_smooth(method = "loess") +
  facet_wrap(~index, scales = "free") +
  theme_classic() +
  theme(strip.background = element_blank()) +
  scale_color_manual(values = c("map" = "red", "mean" = "green", "median" = "blue"))
```

![](vignettes/readme_files/figure-markdown_github/unnamed-chunk-5-1.png)

### Comparison of Indices of Effect Existence

#### Relationship with the Frequentist p value

``` r
df %>% 
  select(noise, p, pd, bayes_p, rope, rope_overlap) %>% 
  gather(index, value, -noise, -p) %>% 
  ggplot(aes(x = p, y = value, color = index)) +
  geom_point(shape=16, alpha=0.1) +
  facet_wrap(~index, scales = "free") +
  theme_classic() +
  theme(strip.background = element_blank()) +
  scale_color_manual(values = c("bayes_p" = "#f44336", "pd" = "#2196F3", "rope" = "#4CAF50", "rope_overlap" = "#FFC107"))
```

![](vignettes/readme_files/figure-markdown_github/unnamed-chunk-6-1.png)

#### Suggested cut-off values to mimic frequentist arbitrary clusters

This is to be used as rules-of-thumb **reference** only not a stone-carved criterion.

``` r
df$sig_05 <- factor(ifelse(df$p > .05, "n.s.", "*"), levels=c("n.s.", "*"))
df$sig_01 <- factor(ifelse(df$p > .01, "n.s.", "**"), levels=c("n.s.", "**"))
df$sig_001 <- factor(ifelse(df$p > .001, "n.s.", "***"), levels=c("n.s.", "***"))

get_data <- function(predictor, outcome, lbound=0, ubound=0.3){
  fit <- glm(paste(outcome, "~", predictor), data=df, family = "binomial")
  data <- data.frame(x=1:100) 
  data[predictor] <- seq(lbound, ubound, length.out = 100)
  data$index <- predictor
  data[outcome] = predict(fit, newdata=data, type="response")
  data <- select_(data, "value"=predictor, outcome, "index")
  return(data)
}
```

##### Significant at .05

``` r
data <- rbind(
  get_data(predictor="bayes_p", outcome="sig_05", lbound=0, ubound=0.3),
  get_data(predictor="pd", outcome="sig_05", lbound=95, ubound=100),
  get_data(predictor="rope", outcome="sig_05", lbound=0, ubound=0.05),
  get_data(predictor="rope_overlap", outcome="sig_05", lbound=0, ubound=0.05))


data %>% 
  mutate(index = as.factor(index)) %>% 
  ggplot(aes(x=value, y=sig_05, color=index)) +
  geom_line(size=1) +
  facet_wrap(~index, scales = "free") +
  theme_classic() +
  theme(strip.background = element_blank()) +
  scale_color_manual(values = c("bayes_p" = "#f44336", "pd" = "#2196F3", "rope" = "#4CAF50", "rope_overlap" = "#FFC107")) +
  ylab("Probability of being significant at p < .05\n")
```

![](vignettes/readme_files/figure-markdown_github/unnamed-chunk-8-1.png)

##### Significant at .01

``` r
data <- rbind(
  get_data(predictor="bayes_p", outcome="sig_01", lbound=0, ubound=0.1),
  get_data(predictor="pd", outcome="sig_01", lbound=98, ubound=100),
  get_data(predictor="rope", outcome="sig_01", lbound=0, ubound=0.01),
  get_data(predictor="rope_overlap", outcome="sig_01", lbound=0, ubound=0.02))


data %>% 
  mutate(index = as.factor(index)) %>% 
  ggplot(aes(x=value, y=sig_01, color=index)) +
  geom_line(size=1) +
  facet_wrap(~index, scales = "free") +
  theme_classic() +
  theme(strip.background = element_blank()) +
  scale_color_manual(values = c("bayes_p" = "#f44336", "pd" = "#2196F3", "rope" = "#4CAF50", "rope_overlap" = "#FFC107")) +
  ylab("Probability of being significant at p < .01\n")
```

![](vignettes/readme_files/figure-markdown_github/unnamed-chunk-9-1.png)

##### Significant at .001

``` r
data <- rbind(
  get_data(predictor="bayes_p", outcome="sig_001", lbound=0, ubound=0.025),
  get_data(predictor="pd", outcome="sig_001", lbound=99.5, ubound=100),
  get_data(predictor="rope", outcome="sig_001", lbound=0, ubound=0.01),
  get_data(predictor="rope_overlap", outcome="sig_001", lbound=0, ubound=0.01))


data %>% 
  mutate(index = as.factor(index)) %>% 
  ggplot(aes(x=value, y=sig_001, color=index)) +
  geom_line(size=1) +
  facet_wrap(~index, scales = "free") +
  theme_classic() +
  theme(strip.background = element_blank()) +
  scale_color_manual(values = c("bayes_p" = "#f44336", "pd" = "#2196F3", "rope" = "#4CAF50", "rope_overlap" = "#FFC107")) +
  ylab("Probability of being significant at p < .001\n")
```

![](vignettes/readme_files/figure-markdown_github/unnamed-chunk-10-1.png)

#### Relationship between the two ROPE indices

``` r
df %>% 
  ggplot(aes(x = rope, y = rope_overlap, color=p)) +
  geom_point(shape=16, alpha=0.2) +
  theme_classic() 
```

![](vignettes/readme_files/figure-markdown_github/unnamed-chunk-11-1.png)

<!-- ### Relationship with Noise -->
<!-- ```{r, message=FALSE, warning=FALSE} -->
<!-- df %>%  -->
<!--   select(noise, p, bayes_p, pd, rope, rope_overlap) %>%  -->
<!--   gather(index, value, -noise) %>%  -->
<!--   mutate(noise = as.factor(noise)) %>% -->
<!--   ggplot(aes(x=noise, y=value, fill=index)) + -->
<!--   geom_boxplot() + -->
<!--   # geom_point() + -->
<!--   # geom_smooth(method="loess") + -->
<!--   facet_wrap(~index, scales="free") + -->
<!--   theme_classic() + -->
<!--   theme(strip.background = element_blank()) + -->
<!--   scale_fill_manual(values=c("p"="#9C27B0", "bayes_p"="#f44336", "pd"="#2196F3", "rope"="#4CAF50", "rope_overlap"="#FFC107")) -->
<!-- ``` -->
<!-- ```{r, message=FALSE, warning=FALSE} -->
<!-- summary(lm(p ~ noise, data=df)) -->
<!-- summary(lm(bayes_p ~ noise, data=df)) -->
<!-- summary(lm(pd ~ noise, data=df)) -->
<!-- summary(lm(rope ~ noise, data=df)) -->
<!-- summary(lm(rope_overlap ~ noise, data=df)) -->
<!-- ``` -->
Conclusions and Guidelines
--------------------------

From that, we can conclude:

-   The MAP estimate seems to be more biased than the mean and the median of the posterior distribution.
-   Beyond being more robust, the median makes more sense than the mean in a probabilistic framework (*e.g.*, there is 50% chance that the true effect is either higher or lower than the median).
-   The traditional ROPE is not sensitive to delineate highly "significant" effects. Use ROPE O instead (based on the overlap).
-   The Probability of Direction (pd) is the closest index to the frequentist *p* value.

**To minimally describe a posterior distribution of a parameter in the context of null-hypothesis testing, we recommend reporting the Median, the 90% CI (the 90% HDI), the Probability of Direction and, especially in the context of confirmatory analyses, the ROPE (overlap based) with an explicitly specified range.**

Credits
-------

Parts of the code in this package was inspired / shamelessly copied from other great packages that you must check out and cite, such as [sjstats](https://github.com/strengejacke/sjstats) or [BayesTesting.jl](https://github.com/tszanalytics/BayesTesting.jl). All credits go to their authors.
