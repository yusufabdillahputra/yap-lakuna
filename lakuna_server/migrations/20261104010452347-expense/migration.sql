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
CREATE TABLE "expense_categories" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "name" text NOT NULL,
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
CREATE INDEX "expense_categories_tenant_idx" ON "expense_categories" USING btree ("tenant_id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "expenses" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "outlet_id" uuid NOT NULL,
    "device_id" uuid NOT NULL,
    "staff_id" uuid NOT NULL,
    "expense_category_id" uuid NOT NULL,
    "number" text NOT NULL,
    "spent_on" timestamp without time zone NOT NULL,
    "description" text NOT NULL,
    "amount" bigint NOT NULL,
    "funding_source" text NOT NULL,
    "cash_session_id" uuid,
    "cash_movement_id" uuid,
    "receipt_media_id" uuid,
    "voided_at" timestamp without time zone,
    "voided_by" uuid,
    "void_reason" text,
    "void_cash_movement_id" uuid,
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
CREATE UNIQUE INDEX "expenses_number_idx" ON "expenses" USING btree ("tenant_id", "number");
CREATE INDEX "expenses_outlet_day_idx" ON "expenses" USING btree ("outlet_id", "spent_on");
CREATE INDEX "expenses_category_idx" ON "expenses" USING btree ("expense_category_id");
CREATE INDEX "expenses_session_idx" ON "expenses" USING btree ("cash_session_id");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "expense_categories"
    ADD CONSTRAINT "expense_categories_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "expenses"
    ADD CONSTRAINT "expenses_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "expenses"
    ADD CONSTRAINT "expenses_fk_1"
    FOREIGN KEY("outlet_id")
    REFERENCES "outlets"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "expenses"
    ADD CONSTRAINT "expenses_fk_2"
    FOREIGN KEY("device_id")
    REFERENCES "devices"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "expenses"
    ADD CONSTRAINT "expenses_fk_3"
    FOREIGN KEY("staff_id")
    REFERENCES "staff_members"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "expenses"
    ADD CONSTRAINT "expenses_fk_4"
    FOREIGN KEY("expense_category_id")
    REFERENCES "expense_categories"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "expenses"
    ADD CONSTRAINT "expenses_fk_5"
    FOREIGN KEY("cash_session_id")
    REFERENCES "cash_sessions"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "expenses"
    ADD CONSTRAINT "expenses_fk_6"
    FOREIGN KEY("cash_movement_id")
    REFERENCES "cash_movements"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "expenses"
    ADD CONSTRAINT "expenses_fk_7"
    FOREIGN KEY("receipt_media_id")
    REFERENCES "media_files"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "expenses"
    ADD CONSTRAINT "expenses_fk_8"
    FOREIGN KEY("void_cash_movement_id")
    REFERENCES "cash_movements"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261104010452347-expense', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261104010452347-expense', "timestamp" = now();

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
