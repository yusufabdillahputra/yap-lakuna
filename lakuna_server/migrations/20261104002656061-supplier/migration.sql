BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "debt_payments" ADD COLUMN "reference" text;
ALTER TABLE "debt_payments" ADD COLUMN "proof_media_id" uuid;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "suppliers" ADD COLUMN "contact_name" text;
ALTER TABLE "suppliers" ADD COLUMN "category" text;
ALTER TABLE "suppliers" ADD COLUMN "address" text;
ALTER TABLE "suppliers" ADD COLUMN "term_days" bigint NOT NULL DEFAULT 14;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "debt_payments"
    ADD CONSTRAINT "debt_payments_fk_7"
    FOREIGN KEY("proof_media_id")
    REFERENCES "media_files"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261104002656061-supplier', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261104002656061-supplier', "timestamp" = now();

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
