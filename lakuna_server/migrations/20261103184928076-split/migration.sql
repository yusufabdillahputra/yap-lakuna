BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "payments" ADD COLUMN "guest_label" text;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "sale_items" ADD COLUMN "guest_label" text;
ALTER TABLE "sale_items" ADD COLUMN "split_from_item_id" uuid;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "sales" ADD COLUMN "split_mode" text;
ALTER TABLE "sales" ADD COLUMN "split_guests" bigint;

--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261103184928076-split', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261103184928076-split', "timestamp" = now();

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
