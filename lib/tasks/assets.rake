Rake::Task["assets:precompile"].enhance do
  Rake::Task["assets:non_digested"].invoke
end

namespace :assets do
  task non_digested: :environment do
    manifest_path = Dir.glob(File.join(Rails.root, 'public/assets/.sprockets-manifest-*.json')).first
    manifest_data = JSON.load(File.new(manifest_path))

    manifest_data["assets"].each do |logical_path, digested_path|
      FileUtils.cp("public/assets/#{digested_path}", "public/assets/#{logical_path}")
    end
  end
end

task as: :environment do
  system('RAILS_ENV=production rake assets:precompile')
end
