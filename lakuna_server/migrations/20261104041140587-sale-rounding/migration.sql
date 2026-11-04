BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "sales" ADD COLUMN "tax_inclusive" boolean NOT NULL DEFAULT false;
ALTER TABLE "sales" ADD COLUMN "rounding_amount" bigint NOT NULL DEFAULT 0;

--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261104041140587-sale-rounding', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261104041140587-sale-rounding', "timestamp" = now();

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
