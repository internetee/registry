class VersionGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  def create_version_file
    template "version.rb.erb", "app/models/version/#{file_name}_version.rb"
  end

  def class_name
    file_name.camelize
  end
end
