BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "sale_items" ADD COLUMN "discount_amount" bigint NOT NULL DEFAULT 0;
ALTER TABLE "sale_items" ADD COLUMN "discount_bp" bigint NOT NULL DEFAULT 0;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "sales" ADD COLUMN "discount_amount" bigint NOT NULL DEFAULT 0;
ALTER TABLE "sales" ADD COLUMN "discount_bp" bigint NOT NULL DEFAULT 0;
ALTER TABLE "sales" ADD COLUMN "line_discount_amount" bigint NOT NULL DEFAULT 0;
ALTER TABLE "sales" ADD COLUMN "discount_approved_by" uuid;

--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261104045959871-manual-discount', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261104045959871-manual-discount', "timestamp" = now();

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
