# Sys.setenv(BEARER_TOKEN = readLines("twitter_api_token.txt"))
# bearer_token <- Sys.getenv("$BEARER_TOKEN")

library(httr)
library(jsonlite)
library(dplyr)
library(rtweet)
library(tidytext)

twitter_token <- create_token(
  app = "SocialMediaTagging",
  consumer_key = readLines("credentials/api_key.txt"),
  consumer_secret = readLines("credentials/api_key_secret.txt"),
  access_token = readLines("credentials/consumer_api_key.txt"),
  access_secret = readLines("credentials/consumer_api_key_secret.txt"))
get_tokens()
rate_limit()

rt <- search_tweets(
  "covea",
  n = 10,
  include_rts = FALSE,
  # geocode = "47.189893,2.434847,400mi",
  lang ="fr",
  token = twitter_token
)


library(httr)



require(httr)
require(jsonlite)
require(dplyr)
bearer_token <- readLines("credentials/twitter_api_token.txt")
headers <- c(`Authorization` = sprintf('Bearer %s', bearer_token))
params <- list(`user.fields` = 'description',
               `expansion` = 'pinned_tweet_id')
handle <- "phileas_c"
url_handle <-
  sprintf('https://api.twitter.com/2/users/by?usernames=%s', handle)
response <-
  httr::GET(url = url_handle,
            httr::add_headers(.headers = headers),
            query = params)
obj <- httr::content(response, as = "text")
print(obj)
json_data <- fromJSON(obj, flatten = TRUE) %>% as.data.frame
View(json_data)
final <-
  sprintf(
    "Handle: %s\nBio: %s\nPinned Tweet: %s",
    json_data$data.username,
    json_data$data.description,
    json_data$includes.tweets.text
  )
