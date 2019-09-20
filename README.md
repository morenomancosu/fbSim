
# An introduction to the fbSim package

*Moreno Mancosu and Federico Vegetti*


```fbSim``` is an ```R``` package aimed at simulating an registered user behavior on Facebook, by using an automatic browsing approach. In includes a series of functions to allow ```R``` users to navigate automatically a public Facebook page and collect information on those pages' posts. This brief tutorial aims to introducing the basic functions of the library, and especially how to make the package work.

## System requirements

```fbSim``` needs also Google Chrome to be installed. In particular, the package has been tested with Chrome version ```67.0.3396.62```. You can chech the version of your installed build of Google chrome by typing the following line in Chrome's address bar. 

```{bash eval = FALSE}
chrome://version/
```


## Installation

It is possible to install ```fbSim``` in two ways: by employing ```install_github``` from the ```devtools``` package or by using the ```install()``` function from the package ```devtools``` on a downloaded tarball. In the first case, it is possible to install ```fbSim``` by typing:

```r
library(devtools)

tkn <- "token_extracted_from_github.com"

devtools::install_github("morenomancosu/fbSim")
```

In case you have at disposal the compressed tarball of ```fbSim``` (fbSim_0.1-1.tar.gz). It is possible to install it by typing:

```r
library(devtools)

d <- tempdir() #create a temporary directory

untar("fbSim_0.1-1.tar.gz", compressed = "gzip", exdir = d) # uncompress the tarball in 
                                                              # the temp directory

devtools::install(file.path(d, "fbSim"), dependencies = TRUE,
                  repos = "https://cloud.r-project.org/") # install the package 
                                                          # including dependencies
```

## Initial checks

Unlike similar packages like [```RFacebook```](https://cran.r-project.org/web/packages/Rfacebook/Rfacebook.pdf), ```fbSim``` does not need the user to provide an access token to run, but rather it needs an e-mail address and password associated to a valid Facebook profile. 

Note that in order to correctly scrape information, the language of the Facebook interface must be **English**. You can change the interface by operating on the "Language" settings [here](https://www.facebook.com/settings?tab=language). 


## Authentication: ```fbSetAccount```

The function ```fbSetAccount``` allows to produce a new Chrome profile by means of e-mail address and password. Producing a new user does not change in any way your normal Chrome usage. The function does not store any object in ```R``` workspace, but creates a folder containing profile information (included the anonymized version of user's Facebook ID and password) in a format that Chrome understands. The syntax works as follows:

```r
user <- "user@domain.org"
user_path <- "C:/Users/Username/Desktop/Chrome_profile"
fbSetAccount(user, user_path)
```

In example code above, the function creates a folder in which profile information are inserted. We highly reccomend inserting the entire path of the folder instead of just the name of the folder (e.g. for a Windows user, ```C:/Users/Username/Desktop/Chrome_profile``` is better than just ```Chrome_profile```). Before producing the folder, you will be asked to enter your Facebook profile's password. 

Once you created the profile folder, it will be used by all the other functions of ```fbSim```. The profile is permanent, and there is no need to refresh it (as in the case of old access tokens in ```RFacebook```). For this reason, it is reccomandable **not** to delete the folder and use it for other sessions.



## Navigate Facebook public posts in a page: ```fbSimPosts```

The function ```fbSimPosts``` allows to get navigate and get information on the posts from a given Facebook page. The function needs the user to insert as argument the Facebook ID of the page (this can be obtained e.g. on [https://findmyfbid.com/](https://findmyfbid.com/)) or the UID (non-numeric identifier) of the page. In addition, the function needs to know the path to a valid profile folder that contains user's email and password (the folder is produced with ```fbSetAccount```). Other additional arguments that the function requires are:

- The number of posts to be automatically navigated (default is 25).
- The boundaries of the ```timeout``` between a request and the other (in seconds). Tests on the routine have found that a timeout going from 3 to 6 seconds is sufficiently slow not to lead to issues to the Facebook platform (an high frequency of requests might lead Facebook to shut down your account because of an attempt of DDoS[^Distributed Denial of Service.]).

In the following example, we navigate the last 25 posts from Silvio Berlusconi's Facebook page.

```r
fb_page_id <- "116716651695782"  # Silvio Berlusconi's official page ID
user_path <- "C:/Users/Username/Desktop/Chrome_profile"
posts <- fbSimPosts(user_path, page_id, n_posts = 25, timeout = c(3, 6))
```


The function ```fbSimPosts``` produces a ```data.frame``` object which contains the following variables:

- ```page_id```: the ID of the page that made the post (the same as the input argument).
- ```post_id```: the ID of the post, which can be used to access the post itself via web browser, as well as to mine additional information about the post.
- ```datetime```: the date and time when the post was made.
- ```react```: the number of reactions to the post.
- ```comm```: the number of comments to the post.
- ```shares```: the number of times the post was shared by other users.
- ```pinned```: a variable that is 1 when the post is pinned and 0 otherwise
- ```text_post```: the textual content of the post.
- ```link```: in the case another post/webpage is linked, the link which the post directs to.
- ```date_collect```: the date and time when the post was collected.


## Navigate the pages that a specific page likes: ```fbSimLikes```

The function ```fbSimLikes``` allows to get navigate and get information on the pages that a certain Facebook page likes. As in ```fbSimPosts```, the function needs the user to insert as argument the Facebook ID of the page (this can be obtained e.g. on [https://findmyfbid.com/](https://findmyfbid.com/)), as well as the path to a valid profile folder that contains user's email and password (the folder is produced with ```fbSetAccount```).

In the following example, we navigate the pages liked by Silvio Berlusconi's Facebook page. ```fbSimLikes``` allows to place indistinctely both ID (numeric identifier) and UID (non-numeric identifier) of the page, and returns the UID of the liked pages.

```r
fb_page_id <- "116716651695782"  # Silvio Berlusconi's official page ID
user_path <- "C:/Users/Username/Desktop/Chrome_profile"
posts <- fbSimLikes(user_path, page_id)
```


The function ```fbSimLikes``` produces a ```data.frame``` object which contains the following variables:

- ```post_name```: the name of the page
- ```page_id```: the non-numerical ID of the page