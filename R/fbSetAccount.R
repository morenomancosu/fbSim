#' Set a (permanent) Fb account
#'
#' Produces a folder containing Chrome profile information and saved Fb password and email
#'
#' @param user Your Facebook e-mail (The Fb password is requested once the function is called).
#' @param user_path The location of the folder (folder name included). 
#' @param chrome_ver The installed version of Google Chrome. To get the Chrome version go to chrome://version in Chrome's address bar and use the first two digits - e.g. if the version is 73.0.3683.86, just use 73). 
#'
#' @return A folder in \code{"user_path"} containing a Chrome profile ready to access to Facebook.
#' @author Moreno Mancosu \email{moreno.mancosu@@carloalberto.org}, Federico Vegetti \email{vegetti.fede@@gmail.com}
#'
#' @examples
#' user <- "user@@domain.org"
#' user_path <- "C:/Users/Username/Desktop/Chrome_profile"
#' fbSetAccount(user, user_path)
#'
#' @export

fbSetAccount <- function(user, user_path = "Chrome_profile",chrome_ver = 77) {
    
    #============================================================================================
    #### Check whether arguments are ok
    #### Namely, whether they are not missing...
    if (methods::missingArg(user) | !exists("user", envir = parent.frame())) {
        stop("missing argument: user",call.=FALSE)
    }
    #### ... or non-character
    if (is.character(user)==FALSE | is.character(user_path)==FALSE) {
        stop("all arguments must be a character",call.=FALSE)
    }
    
    #####
    
    ver <- "77.0.3865.40"
    if(chrome_ver==78) {
        ver <- "78.0.3904.11"
    } else if(chrome_ver==77) {
        ver <- "77.0.3865.40"
    } else if(chrome_ver==76) {
        ver <- "76.0.3809.126"
    } else if(chrome_ver==75) {
        ver <- "75.0.3770.140"
    } else if(chrome_ver==74) {
        ver <- "74.0.3729.6"  
    } else if(chrome_ver==73) {
        ver <- "73.0.3683.68" 
    }
    
    #===============================================================
    #### loads the right version of chromedriver
    #### and passes the profile options. It creates the folder
    #### 
    cDrv <- wdman::chrome(version = ver, verbose = FALSE, check = TRUE)
    eCaps <- RSelenium::getChromeProfile(dataDir = user_path, 
                              profileDir = "Profile 1")
    eCaps$chromeOptions$args[[3]] <- "--disable-notifications"
    # eCaps$chromeOptions$args[[4]] <- "--headless"
    remDr <- RSelenium::remoteDriver(remoteServerAddr = "localhost", 
                          browserName = "chrome", 
                          port = 4567L, 
                          extraCapabilities = eCaps)
    #===============================================================
    
    #===============================================================
    ### The browser goes into Facebook main page and logs in
    ### With the new fb policy infos are automatically saved in the profile folder
    ### which should be created in the folder indicated as argument.
    
    pass <- getPass::getPass("Enter your Facebook profile's password: ")
    
    tryCatch({
      suppressMessages({
        
        remDr$open()
        remDr$navigate("http://www.facebook.com")
        
      })
    }, 
    error = function(e) {
      remDr$close()
      cDrv$stop()
      stop("something went wrong. Check your internet connection and try again.", call.=FALSE)
      
    }
    )
    
    tryCatch({
      suppressMessages({
        
        remDr$findElement("id", "email")$sendKeysToElement(list(user))
        remDr$findElement("id", "pass")$sendKeysToElement(list(pass))
        remDr$findElements("id", "loginbutton")[[1]]$clickElement()
        
      })
    },
    error = function(e) {
      warning(paste0("the account has already been set! Please delete the folder in ",
                     user_path, 
                     " to set it again"),
              call. = FALSE)
      
    }
    )
    
    string <- remDr$getCurrentUrl()[[1]]
    if (grepl("login_attempt=", string)) {
      
      remDr$close()
      cDrv$stop()
      stop("something went wrong. Check your e-mail and password and try again.", 
           call. = FALSE)
      
    }
    else {
      # Close ports
      remDr$close()
      cDrv$stop()
    }
 
    #===============================================================
    
    
}
