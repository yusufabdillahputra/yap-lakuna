BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "device_credentials" ADD COLUMN "expires_at" timestamp without time zone;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "owner_backup_codes" (
    "id" bigserial PRIMARY KEY,
    "auth_user_id" uuid NOT NULL,
    "code_hash" text NOT NULL,
    "used_at" timestamp without time zone
);

-- Indexes
CREATE INDEX "owner_backup_codes_user_idx" ON "owner_backup_codes" USING btree ("auth_user_id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "owner_totp" (
    "id" bigserial PRIMARY KEY,
    "auth_user_id" uuid NOT NULL,
    "secret_encrypted" text NOT NULL,
    "confirmed_at" timestamp without time zone,
    "last_used_step" bigint,
    "failed_attempts" bigint NOT NULL DEFAULT 0,
    "locked_until" timestamp without time zone,
    "created_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "owner_totp_user_idx" ON "owner_totp" USING btree ("auth_user_id");


--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261128162839756-login-web', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261128162839756-login-web', "timestamp" = now();

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
