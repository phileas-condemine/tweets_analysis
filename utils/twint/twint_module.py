import twint

c = twint.Config()

c.Username = "MMAssurances"
c.Limit = 10
c.Store_csv = True
c.Output = "none"

twint.run.Search(c)
