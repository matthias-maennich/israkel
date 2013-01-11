# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "israkel"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Johannes Plunien"]
  s.date = "2013-01-11"
  s.description = "Collection of common rake tasks for the iPhone Simulator like start/stop and some more."
  s.email = "plu@pqpq.de"
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "README.md",
    "Rakefile",
    "VERSION",
    "israkel.gemspec",
    "lib/israkel.rb",
    "lib/israkel/tasks.rb"
  ]
  s.homepage = "http://github.com/plu/israkel"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Collection of common rake tasks for the iPhone Simulator."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, ["~> 1.7.6"])
      s.add_runtime_dependency(%q<rake>, ["~> 0.9.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.4"])
    else
      s.add_dependency(%q<json>, ["~> 1.7.6"])
      s.add_dependency(%q<rake>, ["~> 0.9.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
    end
  else
    s.add_dependency(%q<json>, ["~> 1.7.6"])
    s.add_dependency(%q<rake>, ["~> 0.9.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
  end
end

