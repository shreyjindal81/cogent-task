CREATE TABLE IF NOT EXISTS cmdb_assets(
  asset_id UUID PRIMARY KEY,
  fqdn TEXT,
  business_unit TEXT,
  owner_email TEXT,
  created_at TIMESTAMP
);

INSERT INTO cmdb_assets(asset_id,fqdn,business_unit,owner_email,created_at) VALUES
('11111111-1111-1111-1111-111111111111','web-01.acme.local','ENG','alice@acme.com','2024-11-05T09:00:00Z'),
('22222222-2222-2222-2222-222222222222','db-01.acme.local','ENG','bob@acme.com','2023-07-12T12:00:00Z'),
('33333333-3333-3333-3333-333333333333','win-01.acme.local','FIN','carol@acme.com','2025-01-20T08:30:00Z'),
('44444444-4444-4444-4444-444444444444','eng-ci-01.acme.local','ENG','devops@acme.com','2024-03-01T10:10:00Z'),
('55555555-5555-5555-5555-555555555555','hr-app-01.acme.local','HR','hr-sys@acme.com','2022-12-01T14:00:00Z'),
('66666666-6666-6666-6666-666666666666','finance-core-01.acme.local','FIN','finops@acme.com','2023-02-15T16:45:00Z'),
('77777777-7777-7777-7777-777777777777','sales-portal-01.acme.local','SALES','salesit@acme.com','2024-05-22T09:15:00Z'),
('88888888-8888-8888-8888-888888888888','shared-cache-01.acme.local','PLATFORM','platform@acme.com','2023-09-09T11:25:00Z');