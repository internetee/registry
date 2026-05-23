require 'csv'
module Repp
  module V1
    module Domains
      class NameserversController < BaseController
        before_action :set_domain, only: %i[index create destroy]
        before_action :set_nameserver, only: %i[destroy]

        THROTTLED_ACTIONS = %i[index create destroy].freeze
        include Shunter::Integration::Throttle

        COMMAND_FAILED_EPP_CODE = 2400
        PROHIBIT_EPP_CODE = 2304
        OBJECT_DOES_NOT_EXIST_EPP_CODE = 2303
        AUTHORIZATION_ERROR_EPP_CODE = 2201
        PARAMETER_VALUE_POLICY_ERROR_EPP_CODE = 2306
        UNKNOWN_EPP_CODE = 2000

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

          nameserver_changes = if is_csv_request?
            parse_nameserver_csv_from_body(request.raw_post)
          elsif bulk_params[:csv_file].present?
            parse_nameserver_csv(bulk_params[:csv_file])
          else
            bulk_params[:nameserver_changes]
          end
          
          nameserver_changes.each { |change| process_nameserver_change(change) }

          if @errors.any? && @successful.empty?
            render_empty_success_objects_with_errors(nameserver_changes_count: nameserver_changes.count)
          elsif @errors.any? && @successful.any?
            render_success_objects_and_objects_with_errors(nameserver_changes_count: nameserver_changes.count)
          else
            render_success(data: { 
              success: @successful, 
              failed: @errors,
              summary: {
                total: nameserver_changes.count,
                successful: @successful.count,
                failed: @errors.count
              }
            })
          end
        end

        private

        def render_success_objects_and_objects_with_errors(nameserver_changes_count:)
          error_summary = analyze_nameserver_errors(@errors)
          message = "#{successful.count} nameserver changes successful, #{errors.count} failed. " + 
                    build_nameserver_error_message(error_summary, errors.count, partial: true)
          
          response = build_nameserver_response_for_bulk_operation(code: COMMAND_FAILED_EPP_CODE, message: message, successful: @successful, errors: @errors, nameserver_changes_count: nameserver_changes_count, error_summary: error_summary)
          render(json: response, status: :multi_status)
        end

        def render_empty_success_objects_with_errors(nameserver_changes_count:)
          error_summary = analyze_nameserver_errors(@errors)
          message = build_nameserver_error_message(error_summary, nameserver_changes_count)
          
          @response = build_nameserver_response_for_bulk_operation(code: PROHIBIT_EPP_CODE, message: message, successful: @successful, errors: @errors, nameserver_changes_count: nameserver_changes_count, error_summary: error_summary)
          render(json: @response, status: :bad_request)
        end

        def build_nameserver_response_for_bulk_operation(code:, message:, successful:, errors:, nameserver_changes_count:, error_summary:)
          {
            code: code, 
            message: message, 
            data: { 
              success: successful, 
              failed: errors,
              summary: {
                total: nameserver_changes_count,
                successful: successful.count,
                failed: errors.count,
                error_breakdown: error_summary
              }
            } 
          }
        end

        def csv_parse_wrapper(csv_data)
          yield
        rescue CSV::MalformedCSVError => e
          @errors << { type: 'csv_error', message: "Invalid CSV format: #{e.message}" }
          return []
        rescue StandardError => e
          @errors << { type: 'csv_error', message: "Error processing CSV: #{e.message}" }
          return []
        end

        def parse_nameserver_csv(csv_file)
          nameserver_changes = []
          
          csv_parse_wrapper(csv_file) do
            CSV.foreach(csv_file.path, headers: true) do |row|
              next if row['Domain'].blank?
              
              nameserver_changes << {
                domain_name: row['Domain'].strip,
                new_hostname: bulk_params[:new_hostname] || '',
                ipv4: bulk_params[:ipv4] || [],
                ipv6: bulk_params[:ipv6] || []
              }
            end
          end

          if nameserver_changes.empty?
            @errors << { type: 'csv_error', message: 'CSV file is empty or missing required header: Domain' }
          elsif bulk_params[:new_hostname].blank?
            @errors << { type: 'csv_error', message: 'new_hostname parameter is required when using CSV' }
          end

          nameserver_changes
        end

        def parse_nameserver_csv_from_body(csv_data)
          nameserver_changes = []
          
          csv_parse_wrapper(csv_data) do
            CSV.parse(csv_data, headers: true) do |row|
              next if row['Domain'].blank? || row['New_Nameserver'].blank?
              
              nameserver_changes << {
                domain_name: row['Domain'].strip,
                new_hostname: row['New_Nameserver'].strip,
                ipv4: row['IPv4']&.split(',')&.map(&:strip) || [],
                ipv6: row['IPv6']&.split(',')&.map(&:strip) || []
              }
            end
          end

          if nameserver_changes.empty?
            @errors << { type: 'csv_error', message: 'CSV file is empty or missing required headers: Domain, New_Nameserver' }
          end

          nameserver_changes
        end

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

        def build_error_info(change:, error_code:, error_message:, details:)
          {
            type: 'nameserver_change',
            domain_name: change[:domain_name],
            error_code: error_code.to_s,
            error_message: error_message,
            details: details
          }
        end

        def process_nameserver_change_wrapper(change)
          yield
        rescue ActiveRecord::RecordNotFound => e
          @errors << build_error_info(
            change: change, error_code: OBJECT_DOES_NOT_EXIST_EPP_CODE, 
            error_message: 'Domain not found', 
            details: { code: OBJECT_DOES_NOT_EXIST_EPP_CODE.to_s, msg: 'Domain not found' }
          )
        rescue StandardError => e
          @errors << build_error_info(
            change: change, 
            error_code: UNKNOWN_EPP_CODE, 
            error_message: e.message, 
            details: { message: e.message }
          )
        end

        def process_nameserver_change(change)
          process_nameserver_change_wrapper(change) do
            domain = Epp::Domain.find_by!('name = ? OR name_puny = ?', 
                                         change[:domain_name], change[:domain_name])
            
            unless domain.registrar == current_user.registrar
              @errors << build_error_info(
                change: change, 
                error_code: AUTHORIZATION_ERROR_EPP_CODE, 
                error_message: 'Authorization error', 
                details: { code: AUTHORIZATION_ERROR_EPP_CODE.to_s, msg: 'Authorization error' })
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

            action = Actions::DomainUpdate.new(domain, nameserver_params, false)

            if action.call
              @successful << { type: 'nameserver_change', domain_name: domain.name }
            else      
              epp_error = domain.errors.where(:epp_errors).first
              error_details = epp_error&.options || { message: domain.errors.full_messages.join(', ') }
              
              error_info = {
                type: 'nameserver_change',
                domain_name: domain.name,
                error_code: error_details[:code] || 'UNKNOWN',
                error_message: error_details[:msg] || error_details[:message] || 'Unknown error',
                details: error_details
              }
              
              @errors << error_info
            end
          end
        end

        def is_csv_request?
          request.content_type&.include?('text/csv') || request.content_type&.include?('application/csv')
        end



        def analyze_nameserver_errors(errors)
          error_counts = {}
          
          errors.each do |error|
            error_code = error[:error_code] || 'UNKNOWN'
            error_message = error[:error_message] || 'Unknown error'
            
            key = "#{error_code}:#{error_message}"
            error_counts[key] ||= { 
              code: error_code, 
              message: error_message, 
              count: 0, 
              domains: [] 
            }
            error_counts[key][:count] += 1
            error_counts[key][:domains] << error[:domain_name]
          end
          
          error_counts.values
        end

        def build_nameserver_error_message(error_summary, total_count, partial: false)
          return "All #{total_count} nameserver changes failed" if error_summary.empty?
          
          messages = []
          
          error_summary.each do |error_info|
            case error_info[:code]
            when OBJECT_DOES_NOT_EXIST_EPP_CODE.to_s
              messages << "#{error_info[:count]} domain#{'s' if error_info[:count] > 1} not found"
            when AUTHORIZATION_ERROR_EPP_CODE.to_s
              messages << "#{error_info[:count]} domain#{'s' if error_info[:count] > 1} unauthorized"
            when PROHIBIT_EPP_CODE.to_s
              messages << "#{error_info[:count]} domain#{'s' if error_info[:count] > 1} prohibited from changes"
            when PARAMETER_VALUE_POLICY_ERROR_EPP_CODE.to_s
              messages << "#{error_info[:count]} nameserver#{'s' if error_info[:count] > 1} invalid"
            else
              messages << "#{error_info[:count]} change#{'s' if error_info[:count] > 1} failed (#{error_info[:message]})"
            end
          end
          
          prefix = partial ? "Failures: " : "All #{total_count} changes failed: "
          prefix + messages.join(', ')
        end
      end
    end
  end
end
