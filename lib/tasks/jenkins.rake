require 'rubygems'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'

RSpec::Core::RakeTask.new(:all => ["ci:setup:rspec", "spec:rcov"]) do |t|
   t.pattern = '**/*_spec.rb'
   t.rcov = true
end

# namespace :jenkins do

#   def rspec_report_path
#     "reports/rspec/"
#   end

#   task :spec_report_setup do
#     rm_rf rspec_report_path
#     mkdir_p rspec_report_path
#   end


#   task :ci => [:report_setup, 'jenkins:setup:rspec', 'rake:spec']

#   task :unit => [:spec_report_setup, "jenkins:setup:rspec", 'rake:spec:lib']

#   task :functional => [:spec_report_setup,
#                        "jenkins:setup:rspec",
#                        'rake:spec', ]

#   namespace :setup do
#     task :pre_ci do
#       ENV["CI_REPORTS"] = rspec_report_path
#       gem 'ci_reporter'
#       require 'ci/reporter/rake/rspec'
#     end
#     task :rspec => [:pre_ci, "ci:setup:rspec"]
#   end

# end
