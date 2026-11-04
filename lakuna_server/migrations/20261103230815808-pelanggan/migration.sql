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
CREATE TABLE "customer_groups" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "name" text NOT NULL,
    "term_days" bigint NOT NULL DEFAULT 14,
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
CREATE INDEX "customer_groups_tenant_idx" ON "customer_groups" USING btree ("tenant_id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "customers" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "customer_group_id" uuid,
    "name" text NOT NULL,
    "phone" text,
    "address" text,
    "note" text,
    "credit_limit" bigint NOT NULL DEFAULT 0,
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
CREATE INDEX "customers_tenant_idx" ON "customers" USING btree ("tenant_id");
CREATE INDEX "customers_phone_idx" ON "customers" USING btree ("tenant_id", "phone");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "debt_payment_allocations" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "debt_payment_id" uuid NOT NULL,
    "document_type" text NOT NULL,
    "sale_id" uuid,
    "purchase_id" uuid,
    "amount" bigint NOT NULL,
    "balance_before" bigint NOT NULL,
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
CREATE INDEX "debt_payment_allocations_payment_idx" ON "debt_payment_allocations" USING btree ("debt_payment_id");
CREATE INDEX "debt_payment_allocations_sale_idx" ON "debt_payment_allocations" USING btree ("sale_id");
CREATE INDEX "debt_payment_allocations_purchase_idx" ON "debt_payment_allocations" USING btree ("purchase_id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "debt_payments" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "outlet_id" uuid NOT NULL,
    "device_id" uuid NOT NULL,
    "staff_id" uuid NOT NULL,
    "party" text NOT NULL,
    "customer_id" uuid,
    "supplier_id" uuid,
    "number" text NOT NULL,
    "amount" bigint NOT NULL,
    "method" text,
    "funding_source" text,
    "paid_on" timestamp without time zone NOT NULL,
    "cash_session_id" uuid,
    "balance_after" bigint NOT NULL,
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
CREATE UNIQUE INDEX "debt_payments_number_idx" ON "debt_payments" USING btree ("tenant_id", "number");
CREATE INDEX "debt_payments_customer_idx" ON "debt_payments" USING btree ("customer_id");
CREATE INDEX "debt_payments_supplier_idx" ON "debt_payments" USING btree ("supplier_id");
CREATE INDEX "debt_payments_session_idx" ON "debt_payments" USING btree ("cash_session_id");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "sale_returns" ADD COLUMN "debt_reduction" bigint NOT NULL DEFAULT 0;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "sales" ADD COLUMN "customer_id" uuid;
ALTER TABLE "sales" ADD COLUMN "due_on" timestamp without time zone;
CREATE INDEX "sales_customer_idx" ON "sales" USING btree ("customer_id");
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "customer_groups"
    ADD CONSTRAINT "customer_groups_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "customers"
    ADD CONSTRAINT "customers_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "customers"
    ADD CONSTRAINT "customers_fk_1"
    FOREIGN KEY("customer_group_id")
    REFERENCES "customer_groups"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "debt_payment_allocations"
    ADD CONSTRAINT "debt_payment_allocations_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "debt_payment_allocations"
    ADD CONSTRAINT "debt_payment_allocations_fk_1"
    FOREIGN KEY("debt_payment_id")
    REFERENCES "debt_payments"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "debt_payment_allocations"
    ADD CONSTRAINT "debt_payment_allocations_fk_2"
    FOREIGN KEY("sale_id")
    REFERENCES "sales"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "debt_payment_allocations"
    ADD CONSTRAINT "debt_payment_allocations_fk_3"
    FOREIGN KEY("purchase_id")
    REFERENCES "purchases"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "debt_payments"
    ADD CONSTRAINT "debt_payments_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "debt_payments"
    ADD CONSTRAINT "debt_payments_fk_1"
    FOREIGN KEY("outlet_id")
    REFERENCES "outlets"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "debt_payments"
    ADD CONSTRAINT "debt_payments_fk_2"
    FOREIGN KEY("device_id")
    REFERENCES "devices"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "debt_payments"
    ADD CONSTRAINT "debt_payments_fk_3"
    FOREIGN KEY("staff_id")
    REFERENCES "staff_members"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "debt_payments"
    ADD CONSTRAINT "debt_payments_fk_4"
    FOREIGN KEY("customer_id")
    REFERENCES "customers"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "debt_payments"
    ADD CONSTRAINT "debt_payments_fk_5"
    FOREIGN KEY("supplier_id")
    REFERENCES "suppliers"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "debt_payments"
    ADD CONSTRAINT "debt_payments_fk_6"
    FOREIGN KEY("cash_session_id")
    REFERENCES "cash_sessions"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "sales"
    ADD CONSTRAINT "sales_fk_6"
    FOREIGN KEY("customer_id")
    REFERENCES "customers"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261103230815808-pelanggan', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261103230815808-pelanggan', "timestamp" = now();

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
