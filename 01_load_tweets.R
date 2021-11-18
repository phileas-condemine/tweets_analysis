library(data.table)
library(parallel)
library(dplyr)

my_files = list.files("data/tweets",recursive = T,full.names = T,pattern = "RDS$")
# my_files = list.files("data/tweets",recursive = F,full.names = T,pattern = "RDS$")

vars = c("user_id","status_id",
"created_at","screen_name",
"text","source",
"favorite_count","retweet_count",
"followers_count","statuses_count",
"favourites_count","verified",
"account_lang","reply_to_status_id",
"reply_to_user_id","quoted_status_id",
"quoted_user_id","retweet_user_id",
"retweet_status_id")

read_and_filter = function(filename,vars_to_keep){
  dt = setDT(readRDS(filename))
  dt = dt[,vars_to_keep,with=F]
  dt
}

t0 = Sys.time()
cl = makeCluster(detectCores()-1)
tmp = clusterEvalQ(cl, library(data.table))
tweets = parallel::parLapply(cl,my_files,read_and_filter,vars)
print(difftime(Sys.time(),t0,units="mins"))
stopCluster(cl)
names(tweets) <- my_files
tweets = rbindlist(tweets,idcol = "filename")
print(nrow(tweets))




memory_sizes = sort(sapply(tweets,object.size),decreasing = T)
memory_sizes/min(memory_sizes)


# list_type = names(tweets)[sapply(tweets,is.list)]
# tweets = tweets[,-list_type,with=F]
nrow(tweets)
tweets = tweets[,.SD[1],by=.(user_id,status_id)]
nrow(tweets)

txt_size = object.size(tweets$text);format(txt_size,"Mb")


regex_assureurs = paste0("((",paste(c(names(user_assureurs),unname(user_assureurs)),collapse=") | ("),"))")
tweets[,has_name_assureur := grepl(regex_assureurs,text,ignore.case = T)]
tweets[,.N,by=has_name_assureur]

# mentions_regex = "(( )|(^))@[A-z0-9_]+"
mentions_regex = "(( )|(^))@[^ ]+"
# hashtag_regex = "(( )|(^))#[A-z0-9_'-]+"
hashtag_regex = "(( )|(^))#[^ ]+"

website_regex = "(( )|(^))http[^ ]+"

# mentions = stringr::str_extract_all(tweets$text,mentions_regex)
# unique(unlist(mentions))
hashtags = stringr::str_extract_all(tweets$text,hashtag_regex)
unique(unlist(hashtags))
tweets[,text:=gsub(mentions_regex," ",text)]
as.character(round(100*object.size(tweets$text)/txt_size,1))
# tweets[,text:=gsub(hashtag_regex," ",text)]
tweets[,text:=gsub("#" ,"",text)]
as.character(round(100*object.size(tweets$text)/txt_size,1))
tweets[,text:=gsub(website_regex," ",text)]
as.character(round(100*object.size(tweets$text)/txt_size,1))


# tweets = tweets[!grepl("^RT",text)]
# nrow(tweets)
# stats = tweets[,.(nb=.N),by=.(sub_text = substr(text,1,3))]
# setorder(stats, -nb)
# View(stats[1:100])
# stats[sub_text == "RT "]
tweets$classif = ""
tweets[grepl("users",filename),tweets:="user_hist"]
tweets[grepl("random_tweets",filename),tweets:="random"]
tweets[!grepl("(random_tweets)|(users)",filename),tweets:="custom"]

users_tweets_random = tweets[tweets=="user_hist" & !(has_name_assureur)]
users_tweets_assurance = tweets[tweets=="user_hist" & (has_name_assureur)]
random_tweets = tweets[tweets=="random"]
tweets = tweets[tweets=="custom"]

print(c(nrow(users_tweets_random),nrow(users_tweets_assurance),nrow(random_tweets),nrow(tweets)))

saveRDS(tweets,"data/bronze/tweets.RDS")
saveRDS(random_tweets,"data/bronze/random_tweets.RDS")
# saveRDS(users_tweets_random,"data/bronze/users_random_tweets.RDS")
saveRDS(users_tweets_assurance,"data/bronze/users_tweets.RDS")

# dt = fread("data/datascientest/twitter_comment.csv",nrows = 1E+4)

