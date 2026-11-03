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
CREATE TABLE "stock_adjustment_items" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "adjustment_id" uuid NOT NULL,
    "variant_id" uuid NOT NULL,
    "system_milli" bigint NOT NULL,
    "physical_milli" bigint NOT NULL,
    "difference_milli" bigint NOT NULL,
    "unit_cost" bigint NOT NULL,
    "value" bigint NOT NULL,
    "note" text,
    "sort_order" bigint NOT NULL DEFAULT 0,
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
CREATE INDEX "stock_adjustment_items_adjustment_idx" ON "stock_adjustment_items" USING btree ("adjustment_id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "stock_adjustments" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "outlet_id" uuid NOT NULL,
    "stock_location_id" uuid NOT NULL,
    "number" text NOT NULL,
    "reason" text NOT NULL,
    "note" text,
    "total_value" bigint NOT NULL,
    "staff_id" uuid NOT NULL,
    "adjusted_at" timestamp without time zone NOT NULL,
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
CREATE INDEX "stock_adjustments_outlet_idx" ON "stock_adjustments" USING btree ("outlet_id", "adjusted_at");
CREATE UNIQUE INDEX "stock_adjustments_number_idx" ON "stock_adjustments" USING btree ("tenant_id", "number");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "stock_adjustment_items"
    ADD CONSTRAINT "stock_adjustment_items_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "stock_adjustment_items"
    ADD CONSTRAINT "stock_adjustment_items_fk_1"
    FOREIGN KEY("adjustment_id")
    REFERENCES "stock_adjustments"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "stock_adjustment_items"
    ADD CONSTRAINT "stock_adjustment_items_fk_2"
    FOREIGN KEY("variant_id")
    REFERENCES "product_variants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "stock_adjustments"
    ADD CONSTRAINT "stock_adjustments_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "stock_adjustments"
    ADD CONSTRAINT "stock_adjustments_fk_1"
    FOREIGN KEY("outlet_id")
    REFERENCES "outlets"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "stock_adjustments"
    ADD CONSTRAINT "stock_adjustments_fk_2"
    FOREIGN KEY("stock_location_id")
    REFERENCES "stock_locations"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "stock_adjustments"
    ADD CONSTRAINT "stock_adjustments_fk_3"
    FOREIGN KEY("staff_id")
    REFERENCES "staff_members"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261103133809437-stock', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261103133809437-stock', "timestamp" = now();

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
