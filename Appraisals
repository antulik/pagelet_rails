RAILS_VERSIONS = %w(
  4.2.8
  5.0.2
  5.1.0
)

RAILS_VERSIONS.each do |version|
  appraise "rails_#{version}" do
    gem 'rails', version
    gem 'minitest', '~> 5.10', '!= 5.10.2'
  end
end
