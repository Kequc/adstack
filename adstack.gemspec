# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "adstack"
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nathan Lunde-Berry"]
  s.date = "2012-08-01"
  s.description = "Attempts to lower the amount of complex API work one would have to do when interacting with Google's Adwords API."
  s.email = "nathan.lundeberry@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rvmrc",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "adstack.gemspec",
    "lib/adstack.rb",
    "lib/adstack/api.rb",
    "lib/adstack/api/geo_location_service.rb",
    "lib/adstack/api/location_id_service.rb",
    "lib/adstack/api/report_service.rb",
    "lib/adstack/api/traffic_estimator_service.rb",
    "lib/adstack/config.rb",
    "lib/adstack/helper.rb",
    "lib/adstack/helper/address.rb",
    "lib/adstack/helper/budget.rb",
    "lib/adstack/helper/geo_location.rb",
    "lib/adstack/helper/geo_point.rb",
    "lib/adstack/helper/keyword_estimate.rb",
    "lib/adstack/helper/money.rb",
    "lib/adstack/helper/network_setting.rb",
    "lib/adstack/item.rb",
    "lib/adstack/item/ad.rb",
    "lib/adstack/item/ad/text_ad.rb",
    "lib/adstack/item/ad_extension.rb",
    "lib/adstack/item/ad_extension/location_extension.rb",
    "lib/adstack/item/ad_extension/mobile_extension.rb",
    "lib/adstack/item/ad_group.rb",
    "lib/adstack/item/ad_group_criterion.rb",
    "lib/adstack/item/ad_group_criterion/keyword.rb",
    "lib/adstack/item/budget_order.rb",
    "lib/adstack/item/campaign.rb",
    "lib/adstack/item/campaign_criterion.rb",
    "lib/adstack/item/campaign_criterion/location.rb",
    "lib/adstack/item/campaign_criterion/platform.rb",
    "lib/adstack/item/campaign_criterion/proximity.rb",
    "lib/adstack/item/customer.rb",
    "lib/adstack/service.rb",
    "lib/adstack/service/ad_extension_service.rb",
    "lib/adstack/service/ad_group_criterion_service.rb",
    "lib/adstack/service/ad_group_service.rb",
    "lib/adstack/service/ad_service.rb",
    "lib/adstack/service/budget_order_service.rb",
    "lib/adstack/service/campaign_criterion_service.rb",
    "lib/adstack/service/campaign_service.rb",
    "lib/adstack/service/customer_service.rb",
    "lib/adstack/toolkit.rb",
    "lib/hash_patches.rb",
    "test/helper.rb",
    "test/test_adstack.rb"
  ]
  s.homepage = "http://github.com/kequc/adstack"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Tool for interacting with the Google Adwords API at a decreased level of complication."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<google-ads-common>, ["= 0.7.3"])
      s.add_runtime_dependency(%q<google-adwords-api>, ["= 0.6.3"])
      s.add_runtime_dependency(%q<curb>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<tzinfo>, [">= 0"])
      s.add_runtime_dependency(%q<activemodel>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<google-ads-common>, ["= 0.7.3"])
      s.add_dependency(%q<google-adwords-api>, ["= 0.6.3"])
      s.add_dependency(%q<curb>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<tzinfo>, [">= 0"])
      s.add_dependency(%q<activemodel>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<google-ads-common>, ["= 0.7.3"])
    s.add_dependency(%q<google-adwords-api>, ["= 0.6.3"])
    s.add_dependency(%q<curb>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<tzinfo>, [">= 0"])
    s.add_dependency(%q<activemodel>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end

