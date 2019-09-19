#' Show pages that are liked by a public Facebook page and stores them in a data frame
#'
#' Show posts of a public Facebook page, by returning a data frame in which are collected the name of the page and the identifier.
#' The function needs a valid profile Chrome folder (see \code{fbSetAccount} for more information)
#'   
#' @param page_id The public likes of the Fb page to be shown.
#' @param user_path The location of the profile folder (folder name included).
#'
#'
#' @return A dataframe with information on public pages.
#' @author Moreno Mancosu \email{moreno.mancosu@@carloalberto.org}, Federico Vegetti \email{vegetti.fede@@gmail.com}
#'
#' @seealso \code{\link{setFbAccount}}
#' 
#' @examples
#' page_id <- "116716651695782" #Silvio Berlusconi's official page ID
#' user_path <- "C:/Users/Username/Desktop/Chrome_profile"
#' data <- fbSimLikes(user_path, page_id)
#' 
#' @export
#' 

fbSimLikes <- function(page_id, user_path,timeout = c(3, 6)) {
    

    #===============================================================
    ### Error if missing argument(s)
    if (methods::missingArg(page_id) | !exists("page_id", envir = parent.frame())) {
        stop("missing argument: page_id", call.=FALSE)
    }
    if (methods::missingArg(user_path) | !exists("user_path", envir = parent.frame())) {
        stop("missing argument: user_path", call.=FALSE)
    }

    #===============================================================
    
    #===============================================================
    ### Loads the right version of chromedriver 
    ### and passes the profile options from 'user_path'
    cDrv <- wdman::chrome(version = "2.40", verbose = FALSE, check = TRUE)
    eCaps <- RSelenium::getChromeProfile(dataDir = user_path, 
                                         profileDir = "Profile 1")
    eCaps$chromeOptions$args[[3]] <- "--disable-notifications"
    # eCaps$chromeOptions$args[[4]] <- "--headless"
    # if( minimal==TRUE) {
    #   eCaps$chromeOptions$args[[5]] <- "--window-position=20,20"
    #   eCaps$chromeOptions$args[[6]] <- "--window-size=20,20"
    # }
    remDr<- RSelenium::remoteDriver(remoteServerAddr = "localhost", 
                                    browserName = "chrome", 
                                    port = 4567L, 
                                    extraCapabilities = eCaps)

    #==========================================
    #========== FROM UID TO ID ================
    
     ### Opens a session and goes to the chosen page
    remDr$open()
    url_id <- paste0("https://m.facebook.com/", page_id)
    
    tryCatch({
        remDr$navigate(url_id)
    }, 
    error = function(e) {
        remDr$close()
        cDrv$stop()
        stop("something went wrong. Check your internet connection and try again.",call.=FALSE)
        
    }
    )
    
    if(length(remDr$findElements(using = 'id', 'mobile_login_bar')) > 0) {
      
      remDr$close()
      cDrv$stop()
      stop("you are not logged in. Please run fbSetAccount and try again.", 
           call. = FALSE)
      
    }
    
    var <- remDr$findElements(using = 'xpath', '//form[@method="post"]')
    elemtxt <- var[[1]]$getElementAttribute("outerHTML")[[1]]
    elemxml <- XML::htmlTreeParse(elemtxt, useInternalNodes = T, encoding = "UTF-8")
    
    uid <- gsub("^.*?id=", "", elemtxt)
    uid <- gsub("\\\" .*$", "", uid)
    
    #===============================================================
    ### FANS
    ### Opens a session and goes to the chosen page
    #remDr$open()
    url_id <- paste0("https://www.facebook.com/browse/fanned_pages/?id=", uid)
    
    tryCatch({
        remDr$navigate(url_id)
    }, 
    error = function(e) {
        remDr$close()
        cDrv$stop()
        stop("something went wrong. Check your internet connection and try again.",call.=FALSE)
        
    }
    )

    
    #### PARSING
    
    var <- remDr$findElements(using = 'xpath', '//div[@class="_6a"]')
    
    if(length(var) == 0) {
        print("No pages liked by the selected page.")
        break
    } else {
        link_data <- data.frame(page_id = 0,
                                page_name = 0,
                                stringsAsFactors = FALSE)
        
        for(i in 1:length(var)) {
            
            elemtxt <- var[[i]]$getElementAttribute("outerHTML")[[1]]
            elemxml <- XML::htmlTreeParse(elemtxt, useInternalNodes = T, encoding = "UTF-8")
            
            page_name <- XML::xpathSApply(elemxml, "//a", XML::xmlValue)
            
            ### page_id
            
            page_id <- XML::xpathSApply(elemxml, "//a", XML::xmlAttrs)
            page_id <- gsub("^.*facebook.com/","",page_id[1])
            page_id <- gsub("/.*$","",page_id)
            
            link_data[i,] <- "NA"
            link_data$page_name[i] <- page_name
            link_data$page_id[i] <- page_id
        }
    }
    
    remDr$close()
    cDrv$stop()
    
    # Return data
    return(link_data)
}
