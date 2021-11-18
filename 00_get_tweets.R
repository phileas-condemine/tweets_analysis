# Sys.setenv(BEARER_TOKEN = readLines("twitter_api_token.txt"))
# bearer_token <- Sys.getenv("$BEARER_TOKEN")

library(httr)
library(jsonlite)
library(dplyr)
library(rtweet)
library(tidytext)
library(data.table)

get_general_tweets = F

# file.create("credentials/api_key.txt")
# file.create("credentials/api_key_secret.txt")
# file.create("credentials/consumer_api_key.txt")
# file.create("credentials/consumer_api_key_secret.txt")

twitter_token <- create_token(
  app = "SocialMediaTagging",
  consumer_key = readLines("credentials/consumer_api_key.txt"),
  consumer_secret = readLines("credentials/consumer_api_key_secret.txt"),
  access_token = readLines("credentials/access_token.txt"),
  access_secret = readLines("credentials/access_token_secret.txt"))
get_tokens()
rate_limit()

user_assureurs = unlist(jsonlite::read_json("data/helper/usernames_assureurs.json"))
one_user = sample(user_assureurs,1)

my_search_tweets = purrr::partial(search_tweets,
                                  include_rts = FALSE,
                                  lang ="fr",
                                  # token = twitter_token
                                  token = bearer_token()
)
my_search_tweets_dt = function(...){
  setDT(my_search_tweets(...))
}

if(get_general_tweets){
  general_tweets <- search_tweets(
    "filter:verified OR -filter:verified", n = 18000)
  general_tweets= setDT(general_tweets)
  file_path = paste0("data/tweets/random_tweets/",Sys.Date(),".RDS")
  if(file.exists(file_path)){
    rt_old = readRDS(file_path)
    print(general_tweets)
    general_tweets = rbind(general_tweets,rt_old)
    print(general_tweets)
    general_tweets = general_tweets[,.SD[1],by=.(user_id,status_id)]
    print(general_tweets)
  }
  saveRDS(general_tweets,file_path)
}

# for (one_user in user_assureurs){
# for (one_user in names(user_assureurs)){
get_tweets = function(usernames,keyword="",regex="(%s) (%s)",from_to_nothing = ""){
  # any_user = paste0("to:",usernames, collapse = " OR ")
  
  for (one_user in usernames){
    # assertthat::assert_that(!grepl(" ",keyword))
    one_user = paste0(from_to_nothing,one_user)
    if(keyword==""){
      q = paste0("(lang:fr) (",one_user,")")
    } else {
      # q = paste0("",sprintf(regex,any_user,keyword))
      # q = paste0("(lang:fr) ",sprintf(regex,any_user,keyword))
      q = paste0("(lang:fr) ",sprintf(regex,one_user,keyword))
    }
    print(q)
    rt = my_search_tweets_dt(q,type = "mixed",n=1000)
    if(nrow(rt)>0){
      if(nchar(keyword)>50){
        keyword = "long_list_of_keywords"
      }
      dir_path = paste0("data/tweets/",keyword)
      if(!dir.exists(dir_path)){
        dir.create(dir_path)
      }
      file_path = sprintf(file.path("data/tweets",keyword,"%s.RDS"),one_user)
      print(file_path)
      if(file.exists(file_path)){
        rt_old = readRDS(file_path)
        rt = rbind(rt,rt_old)
        rt = rt[,.SD[1],by=.(user_id,status_id)]
        
      }
      saveRDS(rt,file_path)
    }
  }
}

# key_words = c("agent", "auto", "cotisation", "désolé", "escroc", "excuse", 
#               "gestionnaire", "habitation", "habitation", "litige", "merci", 
#               "mutualiste", "mutuelle", "prime", "remboursement", "résiliation", 
#               "retard", "scandale", "sinistre", "voiture", "vol", "voleur")
# any_keywords = paste(key_words,collapse = " OR ")
# get_tweets(user_assureurs,any_keywords)

# get_tweets(user_assureurs,"voleur")
get_tweets(user_assureurs,"",from_to_nothing = "to:")
get_tweets(user_assureurs,"",from_to_nothing = "from:")
get_tweets(user_assureurs,"")
get_tweets(user_assureurs,"vol")
# get_tweets(user_assureurs,"scandale")
# get_tweets(user_assureurs,"escroc")
get_tweets(user_assureurs,"merci")
get_tweets(user_assureurs,"désolé")
# get_tweets(user_assureurs,"excuse")
get_tweets(user_assureurs,"sinistre")
get_tweets(user_assureurs,"résiliation")
get_tweets(user_assureurs,"remboursement")
# get_tweets(user_assureurs,"retard")
# get_tweets(user_assureurs,"prime")
# get_tweets(user_assureurs,"agent")
# get_tweets(user_assureurs,"gestionnaire")
get_tweets(user_assureurs,"habitation")
get_tweets(user_assureurs,"auto")
get_tweets(user_assureurs,"voiture")
get_tweets(user_assureurs,"cotisation")
get_tweets(user_assureurs,"mutuelle")
get_tweets(user_assureurs,"mutualiste")
# get_tweets(user_assureurs,"litige")


tweets=readRDS("data/silver/preprocessed.RDS")
users = unique(tweets$screen_name)
done = list.files("data/tweets/users/")
done = gsub(".RDS$","",done)
users = setdiff(users,done)
print(length(users))
safe_get_timeline = purrr::quietly(get_timeline)
reached_limit = F
while(!reached_limit){
  done = list.files("data/tweets/users/")
  done = gsub(".RDS$","",done)
  users = setdiff(users,done)
  if(length(users)==0){
    stop("all done !")
  }
  one_user = sample(users,1)
  rt <- safe_get_timeline(one_user, n = 3200,token = bearer_token())
  print(Sys.time())
  if(!is.null(rt$warnings)){
    # reached_limit=T
    Sys.sleep(10)
  }
  rt = rt$result
  if(nrow(rt)>0){
    dir_path = paste0("data/tweets/users/")
    if(!dir.exists(dir_path)){
      dir.create(dir_path)
    }
    file_path = paste0("data/tweets/users/",one_user,".RDS")
    print(file_path)
    if(file.exists(file_path)){
      rt_old = readRDS(file_path)
      rt = rbind(rt,rt_old)
      rt = rt[,.SD[1],by=.(user_id,status_id)]
      
    }
    saveRDS(rt,file_path)
  }
}
