#' Estimated means.
#' 
#' \code{cell_means} is a generic function for calculating the estimated means
#' of a linear model.
#' 
#' @param model A fitted linear model of type 'lm'.
#' @param ... Additional arguments to be passed to the particular method for the
#'   given model.
#' @return The form of the value returned by \code{cell_means} depends on the
#'   class of its argument. See the documentation of the particular methods for
#'   details of what is produced by that method.
#' @seealso \code{\link{cell_means.lm}}
#' @examples TODO: Need to complete.
#' @export
cell_means <- function(model, ...) UseMethod('cell_means')


#' Estimated values of a linear model.
#' 
#' \code{cell_means.lm} calculates the predicted values at specific points,
#' given a fitted regression model.
#' 
#' By default, this function will provide means at -1SD, the mean, and +1SD for
#' continuous variables, and at each levele of categorical variables. This can
#' be overridden with the \code{levels} parameter.
#' 
#' If there are additional covariates in the model other than what are selected
#' in the function call, these variables will be set to their respective means.
#' In the case of a categorical covariate, the results will be averaged across
#' all its levels.
#' 
#' @param model A fitted linear model of type 'lm'.
#' @param ... Pass through variable names to add them to the table.
#' @param levels A list with element names corresponding to some or all of the
#'   variables in the model. Each list element should be a vector with the names
#'   of factor levels (for categorical variables) or numeric points (for
#'   continuous variables) at which to test that variable.
#' @return A data frame with a row for each predicted value. The first few
#'   columns identify the level at which each variable in your model was set.
#'   After columns for each variable, the data frame has columns for the
#'   predicted value, the standard error of the predicted mean, and the 95%
#'   confidence interval.
#' @seealso \code{\link{cell_means}}
#' @examples TODO: Need to complete.
#' @export
cell_means.lm <- function(model, ..., levels=NULL) {
    var_names <- NULL
    if (length(list(...)) > 0) {
        # grab variable names and turn into strings
        dots <- substitute(list(...))[-1]
        var_names <- sapply(dots, deparse)
    }    
    return(cell_means_q.lm(model, var_names, levels))
}


#' Estimated values of a linear model.
#' 
#' \code{cell_means_q.lm} calculates the predicted values at specific points,
#' given a fitted regression model.
#' 
#' By default, this function will provide means at -1SD, the mean, and +1SD for
#' continuous variables, and at each levele of categorical variables. This can
#' be overridden with the \code{levels} parameter.
#' 
#' If there are additional covariates in the model other than what are selected
#' in the function call, these variables will be set to their respective means.
#' In the case of a categorical covariate, the results will be averaged across
#' all its levels.
#' 
#' Note that in most cases it is easier to use \code{\link{cell_means.lm}} and
#' pass variable names in directly instead of strings of variable names.
#' \code{cell_means_q.lm} uses standard evaluation in cases where such
#' evaluation is easier.
#' 
#' @param model A fitted linear model of type 'lm'.
#' @param vars A vector or list with variable names to be added to the table.
#' @param levels A list with element names corresponding to some or all of the
#'   variables in the model. Each list element should be a vector with the names
#'   of factor levels (for categorical variables) or numeric points (for
#'   continuous variables) at which to test that variable.
#' @return A data frame with a row for each predicted value. The first few
#'   columns identify the level at which each variable in your model was set.
#'   After columns for each variable, the data frame has columns for the
#'   predicted value, the standard error of the predicted mean, and the 95%
#'   confidence interval.
#' @seealso \code{\link{cell_means.lm}}
#' @examples TODO: Need to complete.
#' @export
cell_means_q.lm <- function(model, vars=NULL, levels=NULL) {
    factors <- .set_factors(model, vars, levels, sstest=FALSE)
    grid <- with(model$model, expand.grid(factors))
    
    predicted <- predict(model, newdata=grid, se=TRUE)
    grid$value <- predicted$fit
    grid$se <- predicted$se.fit
    grid$ci.lower <- predicted$fit - 1.96 * predicted$se.fit
    grid$ci.upper <- predicted$fit + 1.96 * predicted$se.fit
    return(grid)
}


