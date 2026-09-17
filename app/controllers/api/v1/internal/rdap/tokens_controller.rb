module Api
  module V1
    module Internal
      module Rdap
        # Registry-side implementation of the six pinned RDAP token operations
        # (RDAP spec 10-rdap-issued-api-token). RDAP owns no database; it mints an
        # opaque token, keyed-HMACs it, and persists ONLY the digest + non-PII
        # metadata here through this endpoint. The raw token and the HMAC secret
        # never cross this boundary.
        #
        # `token_hash` everywhere is that keyed HMAC-SHA-256 digest — the store key
        # and the request-time lookup key. The subject is sensitive PII (a national
        # id): read it from the request body / query string, never from the path,
        # and never log it (filtered in filter_parameter_logging.rb).
        class TokensController < BaseController
          # POST /api/v1/internal/rdap/tokens
          # Persist a freshly minted token. Body: token_hash, subject, token_class,
          # expires_at (required); label, issued_at (optional). Returns the stored row.
          def create
            token = RdapApiToken.new(
              token_hash:  params[:token_hash],
              subject:     params[:subject],
              token_class: params[:token_class],
              label:       params[:label].presence,
              issued_at:   parse_time(params[:issued_at]) || Time.zone.now,
              expires_at:  parse_time(params[:expires_at])
            )

            if token.save
              render json: serialize(token), status: :created
            else
              render_error(token.errors.full_messages.join(', '), :unprocessable_entity)
            end
          end

          # GET /api/v1/internal/rdap/tokens/active?token_hash=:digest
          # Resolve a presented digest to its ACTIVE row (not revoked, not expired),
          # or 404. Not-found / revoked / expired are indistinguishable to the caller.
          def active
            token = RdapApiToken.active_by_hash(params[:token_hash]).first

            if token
              render json: serialize(token), status: :ok
            else
              render_error('No active token', :not_found)
            end
          end

          # GET /api/v1/internal/rdap/tokens?subject=:eeid_subject
          # The caller's own tokens (metadata only) for the self-service affordance.
          def index
            tokens = RdapApiToken.for_subject(params[:subject]).order(issued_at: :desc)
            render json: tokens.map { |token| serialize(token) }, status: :ok
          end

          # POST /api/v1/internal/rdap/tokens/revoke  { token_hash }
          # Revoke one token by digest. Idempotent, 204 even for an unknown digest.
          def revoke
            token = RdapApiToken.find_by(token_hash: params[:token_hash])
            token&.revoke!
            head :no_content
          end

          # POST /api/v1/internal/rdap/tokens/revoke_all  { subject }
          # Revoke EVERY not-yet-revoked token for the subject (the kill-all path).
          # Returns the number revoked (for the operator rake task output).
          def revoke_all
            count = RdapApiToken.for_subject(params[:subject])
                                .where(revoked_at: nil)
                                .update_all(revoked_at: Time.zone.now)
            render json: { revoked_count: count }, status: :ok
          end

          # POST /api/v1/internal/rdap/tokens/touch  { token_hash }
          # Best-effort last-used marker. Updates last_used_at ONLY, never expires_at.
          # Non-blocking, idempotent, 204 even for an unknown digest.
          def touch
            token = RdapApiToken.find_by(token_hash: params[:token_hash])
            token&.touch_last_used!
            head :no_content
          end

          private

          def serialize(token)
            {
              token_hash:   token.token_hash,
              subject:      token.subject,
              token_class:  token.token_class,
              label:        token.label,
              issued_at:    iso8601(token.issued_at),
              expires_at:   iso8601(token.expires_at),
              last_used_at: iso8601(token.last_used_at),
              revoked_at:   iso8601(token.revoked_at),
            }
          end

          def iso8601(value)
            value&.utc&.iso8601
          end

          def parse_time(value)
            return nil if value.blank?

            Time.zone.parse(value.to_s)
          rescue ArgumentError
            nil
          end
        end
      end
    end
  end
end
