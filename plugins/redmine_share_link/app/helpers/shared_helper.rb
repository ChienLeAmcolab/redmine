# plugins/redmine_share_link/app/helpers/share_helper.rb
module SharedHelper
  def self.secret_key
    # Lấy secret từ thiết lập plugin
    Setting.plugin_redmine_share_link['share_secret'] || 'ThayDoiSecretNay'
  end

  def self.generate_issue_token(issue)
    data = "issue-#{issue.id}"
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret_key, data)
  end

  def self.generate_project_token(project)
    data = "project-#{project.identifier}"
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret_key, data)
  end
end
