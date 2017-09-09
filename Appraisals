RAILS_VERSIONS = %w(
  4.2.9
  5.0.5
  5.1.3
)

RAILS_VERSIONS.each do |version|
  appraise "rails_#{version}" do
    gem 'rails', version

    # http://stackoverflow.com/questions/43886586/minitest-plugin-rb9-getting-wrong-number-of-arguments
    gem 'minitest', '= 5.10.1', '!= 5.10.2'
  end
end
