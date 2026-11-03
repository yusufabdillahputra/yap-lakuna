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
CREATE TABLE "payments" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "sale_id" uuid NOT NULL,
    "method" text NOT NULL,
    "amount" bigint NOT NULL,
    "change_amount" bigint NOT NULL,
    "reference" text,
    "status" text NOT NULL,
    "confirmed_by" uuid,
    "confirmed_at" timestamp without time zone,
    "paid_at" timestamp without time zone NOT NULL,
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
CREATE INDEX "payments_sale_idx" ON "payments" USING btree ("sale_id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "sale_items" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "sale_id" uuid NOT NULL,
    "variant_id" uuid NOT NULL,
    "product_unit_id" uuid,
    "product_name" text NOT NULL,
    "variant_name" text NOT NULL,
    "unit_name" text NOT NULL,
    "factor_milli" bigint NOT NULL,
    "quantity_milli" bigint NOT NULL,
    "list_price" bigint NOT NULL,
    "unit_price" bigint NOT NULL,
    "line_total" bigint NOT NULL,
    "unit_cost" bigint NOT NULL,
    "tracks_stock" boolean NOT NULL,
    "sort_order" bigint NOT NULL,
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
CREATE INDEX "sale_items_sale_idx" ON "sale_items" USING btree ("sale_id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "sales" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "outlet_id" uuid NOT NULL,
    "device_id" uuid NOT NULL,
    "cash_session_id" uuid,
    "staff_id" uuid NOT NULL,
    "number" text NOT NULL,
    "status" text NOT NULL,
    "subtotal" bigint NOT NULL,
    "tier_discount" bigint NOT NULL,
    "total" bigint NOT NULL,
    "paid_amount" bigint NOT NULL,
    "change_amount" bigint NOT NULL,
    "item_count" bigint NOT NULL,
    "sold_at" timestamp without time zone NOT NULL,
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
CREATE UNIQUE INDEX "sales_number_idx" ON "sales" USING btree ("tenant_id", "number");
CREATE INDEX "sales_session_idx" ON "sales" USING btree ("cash_session_id");
CREATE INDEX "sales_outlet_sold_idx" ON "sales" USING btree ("outlet_id", "sold_at");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "payments"
    ADD CONSTRAINT "payments_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "payments"
    ADD CONSTRAINT "payments_fk_1"
    FOREIGN KEY("sale_id")
    REFERENCES "sales"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "sale_items"
    ADD CONSTRAINT "sale_items_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "sale_items"
    ADD CONSTRAINT "sale_items_fk_1"
    FOREIGN KEY("sale_id")
    REFERENCES "sales"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "sale_items"
    ADD CONSTRAINT "sale_items_fk_2"
    FOREIGN KEY("variant_id")
    REFERENCES "product_variants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "sale_items"
    ADD CONSTRAINT "sale_items_fk_3"
    FOREIGN KEY("product_unit_id")
    REFERENCES "product_units"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "sales"
    ADD CONSTRAINT "sales_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "sales"
    ADD CONSTRAINT "sales_fk_1"
    FOREIGN KEY("outlet_id")
    REFERENCES "outlets"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "sales"
    ADD CONSTRAINT "sales_fk_2"
    FOREIGN KEY("device_id")
    REFERENCES "devices"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "sales"
    ADD CONSTRAINT "sales_fk_3"
    FOREIGN KEY("cash_session_id")
    REFERENCES "cash_sessions"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "sales"
    ADD CONSTRAINT "sales_fk_4"
    FOREIGN KEY("staff_id")
    REFERENCES "staff_members"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261103093432462-penjualan', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261103093432462-penjualan', "timestamp" = now();

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
