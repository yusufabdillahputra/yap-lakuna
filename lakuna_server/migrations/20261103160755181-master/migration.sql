BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "categories" ADD COLUMN "parent_id" uuid;
ALTER TABLE "categories" ADD COLUMN "color" text;
ALTER TABLE "categories" ADD COLUMN "show_in_cashier" boolean NOT NULL DEFAULT true;
ALTER TABLE "categories" ADD COLUMN "is_active" boolean NOT NULL DEFAULT true;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "categories"
    ADD CONSTRAINT "categories_fk_1"
    FOREIGN KEY("parent_id")
    REFERENCES "categories"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261103160755181-master', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261103160755181-master', "timestamp" = now();

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
