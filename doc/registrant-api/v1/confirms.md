# Pending operation confirmation

`GET /api/v1/registrant/confirms/:name/:template/:token` returns the current registrant and, for a change, the proposed registrant. `POST /api/v1/registrant/confirms/:name/:template/:token/:decision` records the decision. Template is `change` or `delete`; decision is `confirmed` or `rejected`.

From the activation time, both endpoints require an `Authorization: Bearer <token>` obtained through eeID login in registrant center and carrying a valid `authenticated_at`. The registry's IP-restricted `POST /api/v1/registrant/auth/eid` accepts an optional `authenticated_at` from eeID as Unix seconds or ISO 8601. Identity matching with the registrant is not performed. The email link token remains required.

A missing, invalid, or expired bearer returns HTTP 401 with `{"errors":[{"base":["Not authorized"]}]}`. An expired, completed or unknown pending operation returns HTTP 401 with `{"error":"Application expired or not found"}`. Decisions are available only for 48 hours from the original request; authentication does not extend the window.

In the .ee test environment, set `registrant_confirmation_eeid_required_from` to `2026-12-01T00:00:00+02:00`. Test both operation types and both decisions after eeID login. Also verify anonymous and invalid bearer requests are rejected, authentication alone leaves the request pending, and expired or completed requests cannot be acted upon. Before activation verify the existing anonymous flow.
