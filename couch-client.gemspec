# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{couch-client}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Robert Sosinski"]
  s.date = %q{2010-10-30}
  s.description = %q{CouchClient is Ruby library that can be used to interact with CouchDB}
  s.email = %q{email@robertsosinski.com}
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README.markdown", "TODO", "lib/couch-client.rb", "lib/couch-client/attachment.rb", "lib/couch-client/attachment_list.rb", "lib/couch-client/collection.rb", "lib/couch-client/connection.rb", "lib/couch-client/connection_handler.rb", "lib/couch-client/consistent_hash.rb", "lib/couch-client/database.rb", "lib/couch-client/design.rb", "lib/couch-client/document.rb", "lib/couch-client/hookup.rb", "lib/couch-client/row.rb"]
  s.files = ["CHANGELOG", "LICENSE", "Manifest", "README.markdown", "Rakefile", "TODO", "lib/couch-client.rb", "lib/couch-client/attachment.rb", "lib/couch-client/attachment_list.rb", "lib/couch-client/collection.rb", "lib/couch-client/connection.rb", "lib/couch-client/connection_handler.rb", "lib/couch-client/consistent_hash.rb", "lib/couch-client/database.rb", "lib/couch-client/design.rb", "lib/couch-client/document.rb", "lib/couch-client/hookup.rb", "lib/couch-client/row.rb", "spec/attachment_list_spec.rb", "spec/attachment_spec.rb", "spec/collection_spec.rb", "spec/conection_handler_spec.rb", "spec/connection_spec.rb", "spec/consistent_hash_spec.rb", "spec/couch-client_spec.rb", "spec/database_spec.rb", "spec/design_spec.rb", "spec/document_spec.rb", "spec/files/image.png", "spec/files/plain.txt", "spec/hookup_spec.rb", "spec/row_spec.rb", "spec/spec_helper.rb", "couch-client.gemspec"]
  s.homepage = %q{http://github.com/robertsosinski/couch-client}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Couch-client", "--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{couch-client}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{The goal of CouchClient is to make documents feel as much as possible as what they already represent, a Hash of primitives, Arrays and other Hashes.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 1.4.6"])
      s.add_runtime_dependency(%q<curb>, [">= 0.7.8"])
    else
      s.add_dependency(%q<json>, [">= 1.4.6"])
      s.add_dependency(%q<curb>, [">= 0.7.8"])
    end
  else
    s.add_dependency(%q<json>, [">= 1.4.6"])
    s.add_dependency(%q<curb>, [">= 0.7.8"])
  end
end
