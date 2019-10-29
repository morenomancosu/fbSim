
# An introduction to the ```fbSim``` package

*Moreno Mancosu and Federico Vegetti*


```fbSim``` is an ```R``` package which simulates the behavior of a registered user on Facebook, by using an automatic browsing approach. It includes a series of functions to allow ```R``` users to automatically browse a public Facebook page and collect information on the page's posts. The type of information collected is similar to what could be obtained using [Netvizz](https://wiki.digitalmethods.net/Dmi/ToolNetvizz) (RIP) until September 4th, 2019. This brief tutorial introduces the basic functions of the library, and describes how to make the package work.

## System requirements

```fbSim``` depends on Google Chrome. The package has been tested with Chrome version ```77.x```, but it is possible to change Chrome version (```fbSim``` supports Chrome version ```73.x``` or later, see below). You can check your version of Chrome by typing the following line in the browser's address bar:

```{bash eval = FALSE}
chrome://version/
```

## Installation

You can install ```fbSim``` either by using the function ```install_github()``` or the function ```install()``` (both from the package ```devtools```) on a downloaded tarball. In the first case, you can install ```fbSim``` by typing:

```r
library(devtools)

devtools::install_github("morenomancosu/fbSim")
```

In case you have cloned the package from this repository (usually ```fbSim-master.zip```) you can install it by unzipping it and typing:

```r
library(devtools)

devtools::install("path/to/file/fbSim-master", dependencies = TRUE)
```

## Initial checks

Unlike similar packages such as [```RFacebook```](https://cran.r-project.org/web/packages/Rfacebook/Rfacebook.pdf), ```fbSim``` does not need the user to provide an access token, but instead it needs the e-mail address and password associated to a valid Facebook profile. 

Note that, for the package to work correctly, the language of Facebook interface must be **English**. You can change the interface by going to the "Language" settings [here](https://www.facebook.com/settings?tab=language). 


## Authentication: ```fbSetAccount```

The function ```fbSetAccount``` allows to produce a new Chrome profile with your Facebook credentials stored in it. Producing a new user does not change in any way your normal Chrome usage. The function does not store any object in ```R``` workspace, but creates a folder containing profile information (including the encrypted Facebook ID and password) in a format that Chrome understands. The syntax works as follows:

```r
user <- "user@domain.org"
user_path <- "C:/Users/Username/Desktop/Chrome_profile"
fbSetAccount(user, user_path)
```

In the code above, the function creates a folder where the profile information is stored. We highly reccomend providing the entire path to the folder instead of just the name of the folder (e.g. for a Windows user, ```C:/Users/Username/Desktop/Chrome_profile``` is better than just ```Chrome_profile```). Before producing the folder, you will be asked to enter your Facebook password. 

Once you created the folder, the same Chrome profile will be used by all the other functions of ```fbSim```. The profile is permanent, and there is no need to refresh it (as in the case of old access tokens in ```RFacebook```). For this reason, we reccomand **not** to delete the folder, and to use it for all other sessions.

**Important**: If any function of ```fbSim``` returns the error "version requested doesn't match versions available", you probably have issues with your version of Chrome. If the version of Chrome on your computer is older than ```77.x```, you can change the version by adding the option ```chrome_ver = xx``` (where ```xx``` is replaced by the first two digits of your Chrome version). ```fbSim``` supports Chrome ```73.x``` or newer.

## Navigate Facebook public posts in a page: ```fbSimPosts```

The function ```fbSimPosts``` allows you to navigate and get information about the posts from a target public Facebook page. The function needs the user to insert as argument the Facebook ID of the page (this can be obtained e.g. on [https://findmyfbid.com/](https://findmyfbid.com/)) or the UID (non-numeric identifier) of the page. In addition, the full path to a valid Chrome profile folder that contains the encrypted user email and password (produced with ```fbSetAccount```) must be provided. Other additional arguments of the function are:

- The number of posts to be automatically navigated (default is 25).
- The boundaries of the ```timeout``` between a request and the other (in seconds). Tests on the routine have found that a timeout going from 3 to 6 seconds is sufficiently slow not to overflow Facebook with requests (too frequent requests might prompt Facebook to block your account because of an attempt of DDoS).

In the following example, we navigate the last 25 posts from Silvio Berlusconi's Facebook page.

```r
fb_page_id <- "SilvioBerlusconi"  # Silvio Berlusconi's page UID
user_path <- "C:/Users/Username/Desktop/Chrome_profile"
posts <- fbSimPosts(user_path, page_id, n_posts = 25, timeout = c(3, 6))
```

The function ```fbSimPosts``` produces a ```data.frame``` containing the following variables:

- ```page_id```: the ID of the target page (the same as the input argument).
- ```post_id```: the ID of the post, which can be used to access the post itself via web browser.
- ```datetime```: the date and time when the post was published.
- ```react```: the approximate number of reactions to the post.
- ```comm```: the approximate number of comments to the post.
- ```shares```: the approximate number of times the post was shared by other users.
- ```pinned```: a variable that is 1 when the post is "pinned" and 0 otherwise.
- ```text_post```: the textual content of the post.
- ```link```: in case another post/webpage is linked, the link which the post directs to.
- ```date_collect```: the date and time when the post was collected.


## Navigate the pages liked by a page: ```fbSimLikes```

The function ```fbSimLikes``` allows to navigate and get information about the pages liked by a target Facebook page. As in ```fbSimPosts```, the function accepts as arguments the Facebook ID or UID of the target page, as well as the path to a valid Chrome profile folder that contains the encrypted user email and password (produced with ```fbSetAccount```).

In the following example, we navigate the pages liked by Silvio Berlusconi's page. ```fbSimLikes``` accepts either the ID (numeric identifier) or the UID (non-numeric identifier) of the page, and returns the UID of the liked pages.

```r
fb_page_id <- "SilvioBerlusconi"  # Silvio Berlusconi's official page UID
user_path <- "C:/Users/Username/Desktop/Chrome_profile"
likedpages <- fbSimLikes(user_path, page_id)
```

The function ```fbSimLikes``` produces a ```data.frame``` containing the following variables:

- ```page_name```: the name of the pages liked by the target page.
- ```page_id```: the UID of the pages liked by the target page.
