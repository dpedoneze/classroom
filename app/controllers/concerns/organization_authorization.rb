module OrganizationAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :set_organization, :authorize_organization_access
  end

  def authorize_organization_access
    return if @organization.users.include?(current_user) || current_user.staff?

    begin
      github_organization.admin?(decorated_current_user.login) ? @organization.users << current_user : not_found
    rescue
      not_found
    end
  end

  private

  def github_organization
    @github_organization ||= GitHubOrganization.new(current_user.github_client, @organization.github_id)
  end

  def set_organization
    @organization = Organization.friendly.find(params[:organization_id])
  end
end
