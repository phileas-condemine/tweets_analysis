library(data.table)

username_poubelle = c("MMA_Rage")

username_ban = c("Indeadt")


tweets=rbindlist(list(
  readRDS("data/bronze/tweets.RDS"),
  readRDS("data/bronze/users_tweets.RDS")
))

tweets = tweets[!screen_name%in%username_ban]


saveRDS(tweets,"data/silver/preprocessed.RDS")
