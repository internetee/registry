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
          Rails.logger.info "[REPP Nameservers] Starting bulk nameserver update"
          Rails.logger.info "[REPP Nameservers] Request params: #{params.inspect}"
          Rails.logger.info "[REPP Nameservers] Content-Type: #{request.content_type}"
          
          begin
            authorize! :manage, :repp
            Rails.logger.info "[REPP Nameservers] Authorization successful"
            
            @errors ||= []
            @successful = []

            nameserver_changes = if is_csv_request?
              Rails.logger.info "[REPP Nameservers] Processing CSV data from raw body"
              parse_nameserver_csv_from_body(request.raw_post)
            elsif bulk_params[:csv_file].present?
              Rails.logger.info "[REPP Nameservers] Processing CSV file upload"
              parse_nameserver_csv(bulk_params[:csv_file])
            else
              Rails.logger.info "[REPP Nameservers] Processing JSON data"
              bulk_params[:nameserver_changes]
            end
            
            Rails.logger.info "[REPP Nameservers] Nameserver changes to process: #{nameserver_changes.inspect}"

            nameserver_changes.each { |change| process_nameserver_change(change) }

            Rails.logger.info "[REPP Nameservers] Processing complete. Successful: #{@successful.count}, Failed: #{@errors.count}"
            
            # Применяем ту же логику ответов что и в transfer
            if @errors.any? && @successful.empty?
              # Все изменения провалились
              Rails.logger.error "[REPP Nameservers] All nameserver changes failed"
              
              error_summary = analyze_nameserver_errors(@errors)
              message = build_nameserver_error_message(error_summary, nameserver_changes.count)
              
              @response = { 
                code: 2304, 
                message: message, 
                data: { 
                  success: @successful, 
                  failed: @errors,
                  summary: {
                    total: nameserver_changes.count,
                    successful: @successful.count,
                    failed: @errors.count,
                    error_breakdown: error_summary
                  }
                } 
              }
              render(json: @response, status: :bad_request)
            elsif @errors.any? && @successful.any?
              # Частичный успех
              Rails.logger.warn "[REPP Nameservers] Partial success: #{@successful.count} succeeded, #{@errors.count} failed"
              
              error_summary = analyze_nameserver_errors(@errors)
              message = "#{@successful.count} nameserver changes successful, #{@errors.count} failed. " + 
                       build_nameserver_error_message(error_summary, @errors.count, partial: true)
              
              @response = { 
                code: 2400, 
                message: message, 
                data: { 
                  success: @successful, 
                  failed: @errors,
                  summary: {
                    total: nameserver_changes.count,
                    successful: @successful.count,
                    failed: @errors.count,
                    error_breakdown: error_summary
                  }
                } 
              }
              render(json: @response, status: :multi_status)
            else
              # Все успешно
              Rails.logger.info "[REPP Nameservers] All nameserver changes successful"
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
            
          rescue StandardError => e
            Rails.logger.error "[REPP Nameservers] Exception occurred: #{e.class} - #{e.message}"
            Rails.logger.error "[REPP Nameservers] Backtrace: #{e.backtrace.join("\n")}"
            
            @response = { code: 2304, message: "Nameserver bulk update failed: #{e.message}", data: {} }
            render(json: @response, status: :bad_request)
          end
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
          Rails.logger.info "[REPP Nameservers] Processing domain: #{change[:domain_name]}"
          
          begin
            domain = Epp::Domain.find_by!('name = ? OR name_puny = ?', 
                                         change[:domain_name], change[:domain_name])
            Rails.logger.info "[REPP Nameservers] Domain found: #{domain.name}"
            
            unless domain.registrar == current_user.registrar
              Rails.logger.warn "[REPP Nameservers] Authorization failed for #{domain.name}"
              error_info = {
                type: 'nameserver_change',
                domain_name: change[:domain_name],
                error_code: '2201',
                error_message: 'Authorization error',
                details: { code: '2201', msg: 'Authorization error' }
              }
              @errors << error_info
              return
            end

            existing_hostnames = domain.nameservers.map(&:hostname)
            Rails.logger.info "[REPP Nameservers] Existing nameservers: #{existing_hostnames}"
            
            if existing_hostnames.include?(change[:new_hostname])
              Rails.logger.info "[REPP Nameservers] Nameserver already exists, marking as successful"
              @successful << { type: 'nameserver_change', domain_name: domain.name }
              return
            end
            
            nameserver_actions = []
            
            if domain.nameservers.count > 0
              first_ns = domain.nameservers.first
              nameserver_actions << { hostname: first_ns.hostname, action: 'rem' }
              Rails.logger.info "[REPP Nameservers] Removing old nameserver: #{first_ns.hostname}"
            end
            
            nameserver_actions << { 
              hostname: change[:new_hostname], 
              action: 'add',
              ipv4: change[:ipv4] || [],
              ipv6: change[:ipv6] || []
            }
            Rails.logger.info "[REPP Nameservers] Adding new nameserver: #{change[:new_hostname]}"
            
            nameserver_params = { nameservers: nameserver_actions }

            action = Actions::DomainUpdate.new(domain, nameserver_params, false)

            if action.call
              Rails.logger.info "[REPP Nameservers] Nameserver change successful for #{domain.name}"
              @successful << { type: 'nameserver_change', domain_name: domain.name }
            else
              Rails.logger.info "[REPP Nameservers] Nameserver change failed for #{domain.name}"
              Rails.logger.info "[REPP Nameservers] Domain errors: #{domain.errors.inspect}"
              
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
          rescue ActiveRecord::RecordNotFound
            Rails.logger.warn "[REPP Nameservers] Domain not found: #{change[:domain_name]}"
            error_info = {
              type: 'nameserver_change',
              domain_name: change[:domain_name],
              error_code: '2303',
              error_message: 'Domain not found',
              details: { code: '2303', msg: 'Domain not found' }
            }
            @errors << error_info
          rescue StandardError => e
            Rails.logger.error "[REPP Nameservers] Unexpected error for #{change[:domain_name]}: #{e.message}"
            error_info = {
              type: 'nameserver_change',
              domain_name: change[:domain_name],
              error_code: 'UNKNOWN',
              error_message: e.message,
              details: { message: e.message }
            }
            @errors << error_info
          end
        end

        def is_csv_request?
          request.content_type&.include?('text/csv') || request.content_type&.include?('application/csv')
        end

        def parse_nameserver_csv_from_body(csv_data)
          nameserver_changes = []
          
          begin
            CSV.parse(csv_data, headers: true) do |row|
              next if row['Domain'].blank? || row['New_Nameserver'].blank?
              
              nameserver_changes << {
                domain_name: row['Domain'].strip,
                new_hostname: row['New_Nameserver'].strip,
                ipv4: row['IPv4']&.split(',')&.map(&:strip) || [],
                ipv6: row['IPv6']&.split(',')&.map(&:strip) || []
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
            @errors << { type: 'csv_error', message: 'CSV file is empty or missing required headers: Domain, New_Nameserver' }
          end

          Rails.logger.info "[REPP Nameservers] Parsed #{nameserver_changes.count} nameserver changes from CSV"
          nameserver_changes
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
            when '2303'
              messages << "#{error_info[:count]} domain#{'s' if error_info[:count] > 1} not found"
            when '2201'
              messages << "#{error_info[:count]} domain#{'s' if error_info[:count] > 1} unauthorized"
            when '2304'
              messages << "#{error_info[:count]} domain#{'s' if error_info[:count] > 1} prohibited from changes"
            when '2306'
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
