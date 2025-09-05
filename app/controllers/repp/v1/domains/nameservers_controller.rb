require 'csv'
module Repp
  module V1
    module Domains
      class NameserversController < BaseController
        before_action :set_domain, only: %i[index create destroy]
        before_action :set_nameserver, only: %i[destroy]

        THROTTLED_ACTIONS = %i[index create destroy].freeze
        include Shunter::Integration::Throttle

        api :GET, '/repp/v1/domains/:domain_name/nameservers'
        desc "Get domain's nameservers"
        def index
          nameservers = @domain.nameservers
          data = { nameservers: nameservers.as_json(only: %i[hostname ipv4 ipv6]) }
          render_success(data: data)
        end

        api :POST, '/repp/v1/domains/:domain_name/nameservers'
        desc 'Create new nameserver for domain'
        param :nameservers, Array, required: true, desc: 'Array of new nameservers' do
          param :hostname, String, required: true, desc: 'Nameserver hostname'
          param :ipv4, Array, required: false, desc: 'Array of IPv4 values'
          param :ipv6, Array, required: false, desc: 'Array of IPv6 values'
        end
        def create
          params[:nameservers].each { |n| n[:action] = 'add' }
          action = Actions::DomainUpdate.new(@domain, nameserver_params, current_user)

          unless action.call
            handle_errors(@domain)
            return
          end

          render_success(data: { domain: { name: @domain.name } })
        end

        api :DELETE, '/repp/v1/domains/:domain/nameservers/:nameserver'
        desc 'Delete specific nameserver from domain'
        def destroy
          nameserver = { nameservers: [{ hostname: params[:id], action: 'rem' }] }
          action = Actions::DomainUpdate.new(@domain, nameserver, false)

          unless action.call
            handle_errors(@domain)
            return
          end

          render_success(data: { domain: { name: @domain.name } })
        end

        api :POST, '/repp/v1/domains/nameservers/bulk'
        desc 'Bulk update nameservers for multiple domains (supports JSON data or CSV file upload)'
        param :data, Hash, required: false, desc: 'JSON data for nameserver changes' do
          param :nameserver_changes, Array, required: true, desc: 'Array of nameserver changes' do
            param :domain_name, String, required: true, desc: 'Domain name'
            param :new_hostname, String, required: true, desc: 'New nameserver hostname'
            param :ipv4, Array, required: false, desc: 'Array of IPv4 addresses'
            param :ipv6, Array, required: false, desc: 'Array of IPv6 addresses'
          end
        end
        def bulk_update
          authorize! :manage, :repp
          @errors ||= []
          @successful = []

          nameserver_changes = if bulk_params[:csv_file].present?
            parse_nameserver_csv(bulk_params[:csv_file])
          else
            bulk_params[:nameserver_changes]
          end

          nameserver_changes.each { |change| process_nameserver_change(change) }

          render_success(data: { success: @successful, failed: @errors })
        end

        private

        def set_nameserver
          @nameserver = @domain.nameservers.find_by!(hostname: params[:id])
        end

        def nameserver_params
          params.permit(:domain_id, nameservers: [[:hostname, :action, { ipv4: [], ipv6: [] }]])
        end

        def bulk_params
          if params[:csv_file].present?
            params.permit(:csv_file, :new_hostname, ipv4: [], ipv6: [])
          else
            params.require(:data).require(:nameserver_changes)
            params.require(:data).permit(nameserver_changes: [%i[domain_name new_hostname], { ipv4: [], ipv6: [] }])
          end
        end

        def parse_nameserver_csv(csv_file)
          nameserver_changes = []
          
          begin
            CSV.foreach(csv_file.path, headers: true) do |row|
              next if row['Domain'].blank?
              
              nameserver_changes << {
                domain_name: row['Domain'].strip,
                new_hostname: bulk_params[:new_hostname] || '',
                ipv4: bulk_params[:ipv4] || [],
                ipv6: bulk_params[:ipv6] || []
              }
            end
          rescue CSV::MalformedCSVError => e
            @errors << { type: 'csv_error', message: "Invalid CSV format: #{e.message}" }
            return []
          rescue StandardError => e
            @errors << { type: 'csv_error', message: "Error processing CSV: #{e.message}" }
            return []
          end

          if nameserver_changes.empty?
            @errors << { type: 'csv_error', message: 'CSV file is empty or missing required header: Domain' }
          elsif bulk_params[:new_hostname].blank?
            @errors << { type: 'csv_error', message: 'new_hostname parameter is required when using CSV' }
          end

          nameserver_changes
        end

        def process_nameserver_change(change)
          begin
            domain = Epp::Domain.find_by!('name = ? OR name_puny = ?', 
                                         change[:domain_name], change[:domain_name])
            
            unless domain.registrar == current_user.registrar
              @errors << { 
                type: 'nameserver_change', 
                domain_name: change[:domain_name],
                errors: { code: 2201, msg: 'Authorization error' }
              }
              return
            end

            existing_hostnames = domain.nameservers.map(&:hostname)
            
            if existing_hostnames.include?(change[:new_hostname])
              @successful << { type: 'nameserver_change', domain_name: domain.name }
              return
            end
            
            nameserver_actions = []
            
            if domain.nameservers.count > 0
              first_ns = domain.nameservers.first
              nameserver_actions << { hostname: first_ns.hostname, action: 'rem' }
            end
            
            nameserver_actions << { 
              hostname: change[:new_hostname], 
              action: 'add',
              ipv4: change[:ipv4] || [],
              ipv6: change[:ipv6] || []
            }
            
            nameserver_params = { nameservers: nameserver_actions }

            action = Actions::DomainUpdate.new(domain, nameserver_params, current_user)

            if action.call
              @successful << { type: 'nameserver_change', domain_name: domain.name }
            else
              @errors << { 
                type: 'nameserver_change', 
                domain_name: domain.name,
                errors: domain.errors.where(:epp_errors).first&.options || domain.errors.full_messages
              }
            end
          rescue ActiveRecord::RecordNotFound
            @errors << { 
              type: 'nameserver_change', 
              domain_name: change[:domain_name],
              errors: { code: 2303, msg: 'Domain not found' }
            }
          rescue StandardError => e
            @errors << { 
              type: 'nameserver_change', 
              domain_name: change[:domain_name],
              errors: { message: e.message }
            }
          end
        end
      end
    end
  end
end
