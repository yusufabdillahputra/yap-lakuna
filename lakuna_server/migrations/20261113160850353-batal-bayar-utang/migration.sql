BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "debt_payments" ADD COLUMN "voided_at" timestamp without time zone;
ALTER TABLE "debt_payments" ADD COLUMN "voided_by" uuid;
ALTER TABLE "debt_payments" ADD COLUMN "void_reason" text;
ALTER TABLE "debt_payments" ADD COLUMN "void_cash_movement_id" uuid;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "debt_payments"
    ADD CONSTRAINT "debt_payments_fk_8"
    FOREIGN KEY("void_cash_movement_id")
    REFERENCES "cash_movements"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261113160850353-batal-bayar-utang', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261113160850353-batal-bayar-utang', "timestamp" = now();

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
