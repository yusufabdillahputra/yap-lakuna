BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "activation_codes" (
    "id" bigserial PRIMARY KEY,
    "code_hash" text NOT NULL,
    "note" text NOT NULL,
    "created_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" timestamp without time zone NOT NULL,
    "used_at" timestamp without time zone,
    "tenant_id" uuid
);

-- Indexes
CREATE UNIQUE INDEX "activation_codes_code_idx" ON "activation_codes" USING btree ("code_hash");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "device_credentials" (
    "id" bigserial PRIMARY KEY,
    "tenant_id" uuid NOT NULL,
    "device_id" uuid NOT NULL,
    "token_hash" text NOT NULL,
    "created_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_seen_at" timestamp without time zone,
    "revoked_at" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "device_credentials_token_idx" ON "device_credentials" USING btree ("token_hash");
CREATE INDEX "device_credentials_device_idx" ON "device_credentials" USING btree ("device_id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "pairing_codes" (
    "id" bigserial PRIMARY KEY,
    "tenant_id" uuid NOT NULL,
    "code_hash" text NOT NULL,
    "created_by_device_id" uuid NOT NULL,
    "created_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" timestamp without time zone NOT NULL,
    "used_at" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "pairing_codes_code_idx" ON "pairing_codes" USING btree ("code_hash");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "sync_changes" (
    "id" bigserial PRIMARY KEY,
    "tenant_id" uuid NOT NULL,
    "outlet_id" uuid,
    "table_name" text NOT NULL,
    "row_id" uuid NOT NULL,
    "hlc" text NOT NULL,
    "origin_device_id" uuid,
    "payload_json" text NOT NULL,
    "received_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "sync_changes_tenant_seq_idx" ON "sync_changes" USING btree ("tenant_id", "id");
CREATE UNIQUE INDEX "sync_changes_row_hlc_idx" ON "sync_changes" USING btree ("row_id", "hlc");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "sync_conflicts" (
    "id" bigserial PRIMARY KEY,
    "tenant_id" uuid NOT NULL,
    "table_name" text NOT NULL,
    "row_id" uuid NOT NULL,
    "winner_hlc" text,
    "loser_hlc" text NOT NULL,
    "loser_device_id" uuid,
    "loser_payload_json" text NOT NULL,
    "reason" text NOT NULL,
    "created_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolved_at" timestamp without time zone
);

-- Indexes
CREATE INDEX "sync_conflicts_tenant_idx" ON "sync_conflicts" USING btree ("tenant_id", "created_at");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "tenant_owners" (
    "id" bigserial PRIMARY KEY,
    "tenant_id" uuid NOT NULL,
    "auth_user_id" uuid NOT NULL,
    "created_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "tenant_owners_tenant_user_idx" ON "tenant_owners" USING btree ("tenant_id", "auth_user_id");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "device_credentials"
    ADD CONSTRAINT "device_credentials_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "pairing_codes"
    ADD CONSTRAINT "pairing_codes_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "sync_changes"
    ADD CONSTRAINT "sync_changes_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "sync_conflicts"
    ADD CONSTRAINT "sync_conflicts_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "tenant_owners"
    ADD CONSTRAINT "tenant_owners_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261128044149827-sync-server', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261128044149827-sync-server', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20261015164015382', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261015164015382', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
