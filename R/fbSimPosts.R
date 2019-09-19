#' Show posts of a public Facebook page and stores some information in a dataframe
#'
#' Show posts of a public Facebook page, by returning a data frame in which are collected the text of the post, the unique identifier, an indicator of whether the post is pinned or not, number of reactions, likes, shares, and comments.
#' The function needs a valid profile Chrome folder (see \code{fbSetAccount} for more information)
#'   
#' @param page_id The public Fb page to be shown.
#' @param user_path The location of the profile folder (folder name included).
#' @param n_posts The number of posts to be shown (from the most recent to the oldest)
#' @param timeout The system timeout between a browser action and the other. Default is c(3, 6), namely a random time between 3 and 6 seconds.
#'
#'
#' @return A dataframe with information on public posts.
#' @author Moreno Mancosu \email{moreno.mancosu@@carloalberto.org}, Federico Vegetti \email{vegetti.fede@@gmail.com}
#'
#' @seealso \code{\link{setFbAccount}}
#' 
#' @examples
#' page_id <- "116716651695782" #Silvio Berlusconi's official page ID
#' user_path <- "C:/Users/Username/Desktop/Chrome_profile"
#' data <- fbSimPosts(user_path, page_id, n_posts = 10)
#' 
#' @export
#' 

fbSimPosts <- function(page_id, user_path, n_posts = 25, timeout = c(3, 6)) {
    
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
    #===============================================================
    
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
    
    repeat {
        
        ################# RESTART FROM HERE
        
        ### The m. does not contain any post, we must go down for a while (usually 3 times)
        
        for (i in 1:3) {
            webElem <- remDr$findElement("css", "body")
            webElem$sendKeysToElement(list(key = "end"))
            Sys.sleep(stats::runif(1, min = min(timeout), max = max(timeout)))
        }
        
        var <- remDr$findElements(using = 'xpath', '//div[@class="_3drp"]')
        
        #### Since class _55wo _gui is also present in things that are not post, we have to erase it
        #### when it does not provide a correct post_id
        
        for(i in 1:length(var)) {
            
            elemtxt <- var[[i]]$getElementAttribute("outerHTML")[[1]]
            elemxml <- XML::htmlTreeParse(elemtxt, useInternalNodes = T, encoding = "UTF-8")
            
            page <- XML::xpathSApply(elemxml, "//article", XML::xmlGetAttr, "data-store")
            
            if(class(page)=="NULL"){
                var <- var[-i]
            }
        }
        
        ###### if exp. number of posts not reached, repeat the loop
        
        if(length(var)<= n_posts) {
            print(length(var))
        }
        else {
            print(n_posts)
            break
        }
    }
    
    #### PARSING
    
    #### creates df
    
    post_data <- data.frame(page_id = 0,
                            post_id = 0,
                            datetime = "",
                            date_collect = 0,
                            react = 0,
                            comm = 0,
                            shares = 0,
                            pinned = 0,
                            text_post = "",
                            # text_orig = "",
                            link = "",
                            stringsAsFactors = FALSE)
    
    ##### parses post by post
    
    for (i in 1:n_posts) {
        
        #### FIRST POST
        
        elemtxt <- var[[i]]$getElementAttribute("outerHTML")[[1]] #####CAMBIA L'1
        elemxml <- XML::htmlTreeParse(elemtxt, useInternalNodes = T, encoding = "UTF-8")
        
        page <- XML::xpathSApply(elemxml, "//article", XML::xmlGetAttr, "data-store")
        
        ### POST_ID
        
        post_id <- gsub("^.*top_level_post_id.", "", page)
        post_id <- gsub(":tl_objid.*$", "", post_id)
        
        ### PAGE_ID
        
        page_id <- gsub("^.*:page_id.", "", page)
        page_id <- gsub(":page_insights..*$", "", page_id)
        page_id <- gsub(":photo_id..*$", "", page_id)
        page_id <- gsub("photo_attachments_list..*$", "", page_id)
        page_id <- gsub(":story_location..*$", "", page_id)
        page_id <- gsub(":", "", page_id)
        
        ### PUBLISH TIME
        
        datetime <- gsub("^.*publish_time\\\\\\\":", "", page)
        datetime <- gsub(",\\\\\\\"story_name.*$", "", datetime)
        datetime <- gsub(",\\\\\\\"object_fbtype.*$", "", datetime)
        
        ### REACTIONS
        
        react <- XML::xpathSApply(elemxml, "//div[@class='_1g06']", XML::xmlValue)
        react <- XML::xpathSApply(elemxml, "//div[@class='_1g06']", XML::xmlValue)
        if(length(react) > 0) {
            react <- gsub("^.* and ", "", react)
            react <- gsub(" others", "", react)
            react <- ifelse(grepl("K", react), as.numeric(sub("K", "", react))*1000, as.numeric(react))
            
        } else {
            react <- 0
        }
        
        ### COMMENTS AND SHARES
        
        # commshare <- XML::xpathSApply(elemxml, "//div[@class='_1fnt']", XML::xmlValue)
        commshare <- XML::xpathSApply(elemxml, "//span[@class='_1j-c']", XML::xmlValue)
        if(sum(grepl("comment", commshare)) == 0){
            comm <- 0
        } else {
            comm <- gsub(" comment.*", "", commshare[grepl("comment", commshare)])
            comm <- ifelse(grepl("K", comm), 
                           as.numeric(sub("K", "", comm))*1000, 
                           as.numeric(comm))
        }
        if(sum(grepl("share", commshare)) == 0){
            shares <- 0
        } else {
            shares <- gsub(" share.*", "", commshare[grepl("share", commshare)])
            shares <- ifelse(grepl("K", shares), 
                             as.numeric(sub("K", "", shares))*1000, 
                             as.numeric(shares))
        }
        
        ### IS_PINNED?
        
        pin <- XML::xpathSApply(elemxml, "//i[@class='img _4q4l img _2sxw']", XML::xmlValue)
        pinned <- ifelse(is.character(pin) == T,1,0) 
        
        ### TEXT
        
        text <- XML::xpathSApply(elemxml, "//div[@class='_5rgt _5nk5 _5msi']", XML::xmlValue)
        text <- sapply(text, function(x) gsub("… More", "", x))
        if(length(text) >= 1) {
            text_post <- text[1]
            # text_orig <- text[2]
        } else {
            text_post <- ""
            # text_orig <- ""
        }
        text <- sub("See Translation", "", text)
        
        ### LINK
        
        link_prov <- XML::xpathSApply(elemxml, "//a[@class='touchable _4qxt']", XML::xmlAttrs)
        if(length(link_prov) > 0) {
            link <- URLdecode(link_prov[3])
            link <- gsub("https://lm.facebook.com/l.php\\?u=","",link)
            link <- gsub("\\?fbclid=.*$","",link)
        } else {
            link <- ""
        }
        
        ### POPULATE DATASET
        
        post_data[i,] <- "NA"
        post_data$page_id[i] <- page_id
        post_data$post_id[i] <- post_id
        post_data$datetime[i] <- datetime
        post_data$react[i] <- react
        post_data$comm[i] <- comm
        post_data$shares[i] <- shares
        post_data$pinned[i] <- pinned
        post_data$text_post[i] <- text_post
        # post_data$text_orig[i] <- text_orig
        post_data$link[i] <- link
        post_data$date_collect[i] <- as.character(Sys.time())
        
    }
    
    # Convert date
    post_data$datetime <- anytime::anytime(as.numeric(post_data$datetime))
    
    remDr$close()
    cDrv$stop()
    
    # Return data
    return(post_data)
}
