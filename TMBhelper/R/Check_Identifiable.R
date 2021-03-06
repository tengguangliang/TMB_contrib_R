
#' Check for identifiability of fixed effects
#'
#' \code{Check_Identifiable} calculates the matrix of second-derivatives of the marginal likelihood w.r.t. fixed effects, to see if any linear combinations are unidentifiable
#'
#' @param obj, The compiled object
#'
#' @return A tagged list of the hessian and the message

#' @export
Check_Identifiable = function( obj ){

  # Extract fixed effects
  ParHat = TMBhelper:::extract_fixed( obj )

  # Check for problems
  Gr = obj$gr( ParHat )
  if( any(Gr>0.01) ) stop("Some gradients are high, please improve optimization and only then use `Check_Identifiable`")

  # Finite-different hessian
  List = NULL
  List[["Hess"]] = optimHess( par=ParHat, fn=obj$fn, gr=obj$gr )

  # Check eigendecomposition
  List[["Eigen"]] = eigen( List[["Hess"]] )
  List[["WhichBad"]] = which( List[["Eigen"]]$values < sqrt(.Machine$double.eps) )

  # Check result
  if( length(List[["WhichBad"]])==0 ){
    # print message
    message( "All parameters are identifiable" )
  }else{
    # Check for parameters
    RowMax = apply( List[["Eigen"]]$vectors[,List[["WhichBad"]],drop=FALSE], MARGIN=1, FUN=function(vec){max(abs(vec))} )
    List[["BadParams"]] = data.frame("Param"=names(obj$par), "MLE"=ParHat, "Param_check"=ifelse(RowMax>0.1, "Bad","OK"))
    # print message
    print( List[["BadParams"]] )
  }

  # Return
  return( invisible(List) )
}
