begin  
  if Rails.env.test? || Rails.env.development?
    require 'rspec/core/rake_task'
    require 'open3'

    desc 'Run all specs against server'
    task 'test' do
      test_against_server { Rake::Task['spec'].invoke }
    end

    desc 'Run EPP specs against server'
    task 'test:epp' do
      test_against_server { Rake::Task['spec:epp'].invoke }
    end

    desc 'Run all but EPP specs'
    RSpec::Core::RakeTask.new('test:other') do |t|
      t.rspec_opts = '--tag ~epp'
    end

    desc 'Run all but EPP specs'
    RSpec::Core::RakeTask.new('test:all_but_features') do |t|
      t.rspec_opts = '--tag ~feature'
    end

    desc 'Generate EPP doc from specs'
    RSpec::Core::RakeTask.new('test:epp_doc') do |t|
      ENV['EPP_DOC'] = 'true'
      t.rspec_opts = '--tag epp --require support/epp_doc.rb --format EppDoc'
    end

    Rake::Task[:default].prerequisites.clear
    task default: :test

    def test_against_server
      _stdin, _stdout, _stderr, wait_thr = Open3.popen3('unicorn -E test -p 8989')
      pid = wait_thr.pid
      begin
        yield
      ensure
        `kill #{pid}`
      end
    end
  end
rescue LoadError => e
  puts e # rspec gem not loaded, probably we are in production machine
end
