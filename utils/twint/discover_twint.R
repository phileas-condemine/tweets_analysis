## https://github.com/twintproject/twint
# system("pip3 install twint")
user_assureurs = unlist(jsonlite::read_json("data/helper/usernames_assureurs.json"))
one_user = sample(user_assureurs,1)
system(sprintf("twint -u %s",one_user))

twint = reticulate::import("twint")
twint_conf = twint$Config()
twint_conf$Username = one_user
twint_conf$Username

res = twint$run$Search(twint_conf)
