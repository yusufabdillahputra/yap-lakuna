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
CREATE TABLE "purchase_items" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "purchase_id" uuid NOT NULL,
    "variant_id" uuid NOT NULL,
    "product_unit_id" uuid,
    "product_name" text NOT NULL,
    "variant_name" text NOT NULL,
    "unit_name" text NOT NULL,
    "factor_milli" bigint NOT NULL,
    "quantity_milli" bigint NOT NULL,
    "unit_price" bigint NOT NULL,
    "line_total" bigint NOT NULL,
    "landed_unit_cost" bigint NOT NULL,
    "avg_cost_before" bigint,
    "avg_cost_after" bigint,
    "sell_price_before" bigint,
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
CREATE INDEX "purchase_items_purchase_idx" ON "purchase_items" USING btree ("purchase_id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "purchase_return_items" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "purchase_return_id" uuid NOT NULL,
    "purchase_item_id" uuid NOT NULL,
    "quantity_milli" bigint NOT NULL,
    "amount" bigint NOT NULL,
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
CREATE INDEX "purchase_return_items_return_idx" ON "purchase_return_items" USING btree ("purchase_return_id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "purchase_returns" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "outlet_id" uuid NOT NULL,
    "device_id" uuid NOT NULL,
    "purchase_id" uuid NOT NULL,
    "staff_id" uuid NOT NULL,
    "cash_session_id" uuid,
    "number" text NOT NULL,
    "amount" bigint NOT NULL,
    "debt_reduction" bigint NOT NULL,
    "refund_amount" bigint NOT NULL,
    "refund_source" text,
    "note" text,
    "returned_at" timestamp without time zone NOT NULL,
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
CREATE INDEX "purchase_returns_purchase_idx" ON "purchase_returns" USING btree ("purchase_id");
CREATE UNIQUE INDEX "purchase_returns_number_idx" ON "purchase_returns" USING btree ("tenant_id", "number");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "purchases" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "outlet_id" uuid NOT NULL,
    "device_id" uuid NOT NULL,
    "stock_location_id" uuid NOT NULL,
    "supplier_id" uuid,
    "staff_id" uuid NOT NULL,
    "cash_session_id" uuid,
    "number" text NOT NULL,
    "invoice_no" text,
    "status" text NOT NULL,
    "purchased_on" timestamp without time zone NOT NULL,
    "subtotal" bigint NOT NULL,
    "discount" bigint NOT NULL,
    "shipping" bigint NOT NULL,
    "total" bigint NOT NULL,
    "paid_amount" bigint NOT NULL,
    "funding_source" text,
    "due_on" timestamp without time zone,
    "note" text,
    "received_at" timestamp without time zone,
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
CREATE INDEX "purchases_outlet_idx" ON "purchases" USING btree ("outlet_id", "purchased_on");
CREATE INDEX "purchases_supplier_idx" ON "purchases" USING btree ("supplier_id");
CREATE UNIQUE INDEX "purchases_number_idx" ON "purchases" USING btree ("tenant_id", "number");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "suppliers" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "name" text NOT NULL,
    "phone" text,
    "note" text,
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
CREATE INDEX "suppliers_tenant_idx" ON "suppliers" USING btree ("tenant_id");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "purchase_items"
    ADD CONSTRAINT "purchase_items_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "purchase_items"
    ADD CONSTRAINT "purchase_items_fk_1"
    FOREIGN KEY("purchase_id")
    REFERENCES "purchases"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "purchase_items"
    ADD CONSTRAINT "purchase_items_fk_2"
    FOREIGN KEY("variant_id")
    REFERENCES "product_variants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "purchase_items"
    ADD CONSTRAINT "purchase_items_fk_3"
    FOREIGN KEY("product_unit_id")
    REFERENCES "product_units"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "purchase_return_items"
    ADD CONSTRAINT "purchase_return_items_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "purchase_return_items"
    ADD CONSTRAINT "purchase_return_items_fk_1"
    FOREIGN KEY("purchase_return_id")
    REFERENCES "purchase_returns"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "purchase_return_items"
    ADD CONSTRAINT "purchase_return_items_fk_2"
    FOREIGN KEY("purchase_item_id")
    REFERENCES "purchase_items"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "purchase_returns"
    ADD CONSTRAINT "purchase_returns_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "purchase_returns"
    ADD CONSTRAINT "purchase_returns_fk_1"
    FOREIGN KEY("outlet_id")
    REFERENCES "outlets"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "purchase_returns"
    ADD CONSTRAINT "purchase_returns_fk_2"
    FOREIGN KEY("device_id")
    REFERENCES "devices"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "purchase_returns"
    ADD CONSTRAINT "purchase_returns_fk_3"
    FOREIGN KEY("purchase_id")
    REFERENCES "purchases"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "purchase_returns"
    ADD CONSTRAINT "purchase_returns_fk_4"
    FOREIGN KEY("staff_id")
    REFERENCES "staff_members"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "purchase_returns"
    ADD CONSTRAINT "purchase_returns_fk_5"
    FOREIGN KEY("cash_session_id")
    REFERENCES "cash_sessions"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "purchases"
    ADD CONSTRAINT "purchases_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "purchases"
    ADD CONSTRAINT "purchases_fk_1"
    FOREIGN KEY("outlet_id")
    REFERENCES "outlets"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "purchases"
    ADD CONSTRAINT "purchases_fk_2"
    FOREIGN KEY("device_id")
    REFERENCES "devices"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "purchases"
    ADD CONSTRAINT "purchases_fk_3"
    FOREIGN KEY("stock_location_id")
    REFERENCES "stock_locations"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "purchases"
    ADD CONSTRAINT "purchases_fk_4"
    FOREIGN KEY("supplier_id")
    REFERENCES "suppliers"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "purchases"
    ADD CONSTRAINT "purchases_fk_5"
    FOREIGN KEY("staff_id")
    REFERENCES "staff_members"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "purchases"
    ADD CONSTRAINT "purchases_fk_6"
    FOREIGN KEY("cash_session_id")
    REFERENCES "cash_sessions"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "suppliers"
    ADD CONSTRAINT "suppliers_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261103222601917-pembelian', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261103222601917-pembelian', "timestamp" = now();

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
