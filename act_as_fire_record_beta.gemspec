require_relative "lib/act_as_fire_record_beta/version"

Gem::Specification.new do |spec|
  spec.name        = "act_as_fire_record_beta"
  spec.version     = ActAsFireRecordBeta::VERSION
  spec.authors     = ["Junichi Ito"]
  spec.email       = ["me@jnito.com"]
  spec.summary     = "ActiveRecord like interface for Firestore"
  spec.description = "ActiveRecord like interface for Firestore"
  spec.homepage    = "https://github.com/JunichiIto/act_as_fire_record_beta"
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/JunichiIto/act_as_fire_record_beta"
  spec.metadata["changelog_uri"] = "https://github.com/JunichiIto/act_as_fire_record_beta/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails"
  spec.add_dependency "google-cloud-firestore"
end
