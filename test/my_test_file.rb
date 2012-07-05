require './adstack'
Adstack::Config.load!("/Users/nathan/rubyapps/appstack/config/adapi.yml", :sandbox)
account = Adstack::AccountService.find(:sample)
