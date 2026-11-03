BEGIN;

--
-- Function: gen_random_uuid_v7()
-- Source: https://gist.github.com/kjmph/5bd772b2c2df145aa645b837da7eca74
-- License: MIT (copyright notice included on the generator source code).
--
create or replace function gen_random_uuid_v7()
returns uuid
as $$
begin
  -- use random v4 uuid as starting point (which has the same variant we need)
  -- then overlay timestamp
  -- then set version 7 by flipping the 2 and 1 bit in the version 4 string
  return encode(
    set_bit(
      set_bit(
        overlay(uuid_send(gen_random_uuid())
                placing substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3)
                from 1 for 6
        ),
        52, 1
      ),
      53, 1
    ),
    'hex')::uuid;
end
$$
language plpgsql
volatile;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "cash_movements" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "outlet_id" uuid NOT NULL,
    "cash_session_id" uuid NOT NULL,
    "direction" text NOT NULL,
    "amount" bigint NOT NULL,
    "note" text NOT NULL,
    "source" text NOT NULL DEFAULT 'manual'::text,
    "created_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" timestamp without time zone,
    "created_by" uuid,
    "updated_by" uuid,
    "version" bigint NOT NULL DEFAULT 1,
    "hlc" text NOT NULL,
    "origin_device_id" uuid
);

-- Indexes
CREATE INDEX "cash_movements_session_idx" ON "cash_movements" USING btree ("cash_session_id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "cash_sessions" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "outlet_id" uuid NOT NULL,
    "device_id" uuid NOT NULL,
    "status" text NOT NULL,
    "opened_by" uuid NOT NULL,
    "opened_at" timestamp without time zone NOT NULL,
    "opening_cash" bigint NOT NULL,
    "opening_note" text,
    "closed_by" uuid,
    "closed_at" timestamp without time zone,
    "expected_cash" bigint,
    "counted_cash" bigint,
    "difference" bigint,
    "counted_breakdown" text,
    "closing_note" text,
    "created_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" timestamp without time zone,
    "created_by" uuid,
    "updated_by" uuid,
    "version" bigint NOT NULL DEFAULT 1,
    "hlc" text NOT NULL,
    "origin_device_id" uuid
);

-- Indexes
CREATE INDEX "cash_sessions_device_status_idx" ON "cash_sessions" USING btree ("device_id", "status");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "cash_movements"
    ADD CONSTRAINT "cash_movements_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "cash_movements"
    ADD CONSTRAINT "cash_movements_fk_1"
    FOREIGN KEY("outlet_id")
    REFERENCES "outlets"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "cash_movements"
    ADD CONSTRAINT "cash_movements_fk_2"
    FOREIGN KEY("cash_session_id")
    REFERENCES "cash_sessions"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "cash_sessions"
    ADD CONSTRAINT "cash_sessions_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "cash_sessions"
    ADD CONSTRAINT "cash_sessions_fk_1"
    FOREIGN KEY("outlet_id")
    REFERENCES "outlets"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "cash_sessions"
    ADD CONSTRAINT "cash_sessions_fk_2"
    FOREIGN KEY("device_id")
    REFERENCES "devices"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "cash_sessions"
    ADD CONSTRAINT "cash_sessions_fk_3"
    FOREIGN KEY("opened_by")
    REFERENCES "staff_members"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "cash_sessions"
    ADD CONSTRAINT "cash_sessions_fk_4"
    FOREIGN KEY("closed_by")
    REFERENCES "staff_members"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261103074811903-sesi-kasir', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261103074811903-sesi-kasir', "timestamp" = now();

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
