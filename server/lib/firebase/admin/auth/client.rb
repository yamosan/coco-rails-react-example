require 'google/apis/identitytoolkit_v3'

module Firebase
  module Admin
    module Auth
      SCOPE = %w[
        https://www.googleapis.com/auth/identitytoolkit
      ].freeze

      class Client
        def initialize(service_account_key_json_path)
          @credentials = Google::Auth::ServiceAccountCredentials.make_creds(
            json_key_io: File.open(service_account_key_json_path),
            scope: SCOPE
          )
          @project_id = @credentials.project_id
          @service = Google::Apis::IdentitytoolkitV3::IdentityToolkitService.new
          @service.authorization = @credentials

          @id_token_verifier = IdTokenVerifier.new(@project_id)
        end

        def create_user(email:, password:)
          request = Google::Apis::IdentitytoolkitV3::SignupNewUserRequest.new(
            email:,
            password:,
            email_verified: true
          )
          @service.signup_new_user(request)
        end

        def verify_id_token(id_token)
          @id_token_verifier.verify(id_token)
        end
      end
    end
  end
end
