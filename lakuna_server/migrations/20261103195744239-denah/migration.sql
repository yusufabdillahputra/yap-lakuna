BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "dining_areas" ADD COLUMN "layout_mode" text NOT NULL DEFAULT 'grid'::text;
ALTER TABLE "dining_areas" ADD COLUMN "floor_media_id" uuid;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "dining_tables" ADD COLUMN "shape" text NOT NULL DEFAULT 'square'::text;
ALTER TABLE "dining_tables" ADD COLUMN "pos_x" bigint;
ALTER TABLE "dining_tables" ADD COLUMN "pos_y" bigint;
ALTER TABLE "dining_tables" ADD COLUMN "width" bigint NOT NULL DEFAULT 80;
ALTER TABLE "dining_tables" ADD COLUMN "height" bigint NOT NULL DEFAULT 80;
ALTER TABLE "dining_tables" ADD COLUMN "can_merge" boolean NOT NULL DEFAULT false;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "dining_areas"
    ADD CONSTRAINT "dining_areas_fk_2"
    FOREIGN KEY("floor_media_id")
    REFERENCES "media_files"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261103195744239-denah', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261103195744239-denah', "timestamp" = now();

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
