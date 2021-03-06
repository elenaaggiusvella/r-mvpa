#' Intended for use with caret; takes a list of items generated by companion function
#' get.caret.model.spec, each of which has one value "method" and one value "tuning"
#' These specify changeable parameters for models
#' It provides a changeable framework so that multiple mthods can all be tested at once
#' There is a list of models here: http://topepo.github.io/caret/modelList.html
#' @param formula object of class formula to pass to train {caret}
#' @param data which the formula describes which will be passed to train {caret}
#' @param trControl passed directly to train {caret}; a list of values that define how this function acts. Default value if each item doesn't have its own trControl. See trainControl and http://topepo.github.io/caret/training.html#custom. (NOTE: If given, this argument must be named.)
#' @param training.list; a list describing a list of train {caret} values to run. Should be a list of objects generated by get.caret.model.spec. Each should contain exactly two values, to be passed to train {caret}: method and tuning. If tuning is an integer, it will be passed to tuneLength. If tuning is a data frame, it will be passed to tuneGrid. If it is null, train's default values for tuneLength will apply. Otherwise an error is generated.
#' @export
#' @examples
#' caret.train.model.list()
#' 
caret.train.model.list.formula <- function(formula, data, trControl,training.list){
  print("running the formula version")
  caret.model.list = list()
  for(i in 1:length(training.list)){
    caret.model.spec <- training.list[[i]]
    gcmc.formals <- names(formals(get.caret.model.spec))[1:(length(names(formals(get.caret.model.spec)))-1)]
    spec.values <- names(caret.model.spec)[1:(length(names(caret.model.spec))-1)]
    if(all(spec.values %in% c(gcmc.formals,"params")
           && gcmc.formals %in% spec.values))
    {
      print(paste0("Running model ",as.character(i), " of ",
                   as.character(length(training.list)),
                   " for method ", caret.model.spec$method))
      #depends on the type of tuning we want to do.
      list.entry.name <- paste0(as.character(i),caret.model.spec$method)
      
      #pass params to train, which will then get passed on to the specific method being run.
      if("params"  %in% names(caret.model.spec)){
        #print("params is in the names; sending a valid params.ul")
        params.ul <- caret.model.spec$params #unlist(caret.model.spec$params)
        #unlist is giving us problems even when recursive is turned off. Let's seet if we can pass in a list without using it.
        #I suspect it'll be problematic though :S
      }else
      {
        params.ul <- list()
        #print("no params detected. namescaretmodelspec is ")
        print(names(caret.model.spec))
      }
      if (("trControl" %in% names(params.ul))==F){
        #add the default trControl to the params.ul list.
        params.ul <- append(params.ul, list("trControl"=trControl))
      }
      
      if(is.null(caret.model.spec$tuning)){
        #           do.call(train,
        #                   c(list(reduced.voxels.ds$x, reduced.voxels.ds$y,
        #                          method = train.list.svm.nnet[[1]]$method,
        #                          preProcess = train.list.svm.nnet[[1]]$preProcess,
        #                          trControl = control,
        #                          tuneGrid = train.list.svm.nnet[[1]]$tuning),
        #                     params.ul)          
        caret.model.list[[list.entry.name]] <- do.call(train,
                                                       c(list(x, y,
                                                              method = caret.model.spec$method,
                                                              #                    trControl = trControl,
                                                              preProcess = caret.model.spec$preProcess),
                                                         params.ul))
        #           train(x, y,
        #                 method = caret.model.spec$method,
        #                 trControl = trControl,
        #                 preProcess = caret.model.spec$preProcess,
        #                 params.ul
      }else if (class(caret.model.spec$tuning)=="numeric"){
        caret.model.list[[list.entry.name]] <- 
          do.call(train,
                  c(list(x, y,
                         method = caret.model.spec$method,
                         #                trControl = trControl,
                         tuneLength = caret.model.spec$tuning,
                         preProcess = caret.model.spec$preProcess),
                    params.ul))
        #)
      }else if (class(caret.model.spec$tuning)=="data.frame"){
        caret.model.list[[list.entry.name]] <- 
          do.call(train,
                  c(list(x, y,
                         method = caret.model.spec$method,
                         #                trControl = trControl,
                         tuneGrid = caret.model.spec$tuning,
                         preProcess = caret.model.spec$preProcess),
                    params.ul))
        # )
      }else{
        stop("Unrecognized tuning method passed to train.caret.model.list")
      }
    }else
    {
      print(names(caret.model.spec))
      print(names(formals(get.caret.model.spec)))
      stop("One or more items passed to train.caret.model.list in the training.list does not appear to be a canonical caret model spec list.")
      
    }
    
  }
  return(caret.model.list)
}