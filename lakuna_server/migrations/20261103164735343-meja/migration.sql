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
CREATE TABLE "dining_areas" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "outlet_id" uuid NOT NULL,
    "name" text NOT NULL,
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
CREATE INDEX "dining_areas_outlet_idx" ON "dining_areas" USING btree ("outlet_id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "dining_tables" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "outlet_id" uuid NOT NULL,
    "dining_area_id" uuid,
    "name" text NOT NULL,
    "seats" bigint NOT NULL DEFAULT 4,
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
CREATE INDEX "dining_tables_outlet_idx" ON "dining_tables" USING btree ("outlet_id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "kitchen_tickets" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "outlet_id" uuid NOT NULL,
    "device_id" uuid NOT NULL,
    "sale_id" uuid NOT NULL,
    "number" bigint NOT NULL,
    "staff_id" uuid NOT NULL,
    "sent_at" timestamp without time zone NOT NULL,
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
CREATE INDEX "kitchen_tickets_sale_idx" ON "kitchen_tickets" USING btree ("sale_id");
CREATE INDEX "kitchen_tickets_device_idx" ON "kitchen_tickets" USING btree ("device_id", "sent_at");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "sale_items" ADD COLUMN "kitchen_status" text;
ALTER TABLE "sale_items" ADD COLUMN "kitchen_ticket_id" uuid;
ALTER TABLE "sale_items" ADD COLUMN "note" text;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "sales" ADD COLUMN "order_type" text NOT NULL DEFAULT 'retail'::text;
ALTER TABLE "sales" ADD COLUMN "dining_table_id" uuid;
ALTER TABLE "sales" ADD COLUMN "bill_number" text;
ALTER TABLE "sales" ADD COLUMN "queue_number" bigint;
ALTER TABLE "sales" ADD COLUMN "customer_name" text;
ALTER TABLE "sales" ADD COLUMN "guest_count" bigint;
ALTER TABLE "sales" ADD COLUMN "opened_by" uuid;
ALTER TABLE "sales" ADD COLUMN "opened_at" timestamp without time zone;
ALTER TABLE "sales" ADD COLUMN "bill_requested_at" timestamp without time zone;
ALTER TABLE "sales" ADD COLUMN "service_bp" bigint NOT NULL DEFAULT 0;
ALTER TABLE "sales" ADD COLUMN "tax_bp" bigint NOT NULL DEFAULT 0;
ALTER TABLE "sales" ADD COLUMN "service_amount" bigint NOT NULL DEFAULT 0;
ALTER TABLE "sales" ADD COLUMN "tax_amount" bigint NOT NULL DEFAULT 0;
ALTER TABLE "sales" ADD COLUMN "void_reason" text;
ALTER TABLE "sales" ADD COLUMN "voided_by" uuid;
ALTER TABLE "sales" ADD COLUMN "voided_at" timestamp without time zone;
CREATE INDEX "sales_outlet_status_idx" ON "sales" USING btree ("outlet_id", "status");
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "dining_areas"
    ADD CONSTRAINT "dining_areas_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "dining_areas"
    ADD CONSTRAINT "dining_areas_fk_1"
    FOREIGN KEY("outlet_id")
    REFERENCES "outlets"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "dining_tables"
    ADD CONSTRAINT "dining_tables_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "dining_tables"
    ADD CONSTRAINT "dining_tables_fk_1"
    FOREIGN KEY("outlet_id")
    REFERENCES "outlets"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "dining_tables"
    ADD CONSTRAINT "dining_tables_fk_2"
    FOREIGN KEY("dining_area_id")
    REFERENCES "dining_areas"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "kitchen_tickets"
    ADD CONSTRAINT "kitchen_tickets_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "kitchen_tickets"
    ADD CONSTRAINT "kitchen_tickets_fk_1"
    FOREIGN KEY("outlet_id")
    REFERENCES "outlets"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "kitchen_tickets"
    ADD CONSTRAINT "kitchen_tickets_fk_2"
    FOREIGN KEY("device_id")
    REFERENCES "devices"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "kitchen_tickets"
    ADD CONSTRAINT "kitchen_tickets_fk_3"
    FOREIGN KEY("sale_id")
    REFERENCES "sales"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "kitchen_tickets"
    ADD CONSTRAINT "kitchen_tickets_fk_4"
    FOREIGN KEY("staff_id")
    REFERENCES "staff_members"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "sale_items"
    ADD CONSTRAINT "sale_items_fk_4"
    FOREIGN KEY("kitchen_ticket_id")
    REFERENCES "kitchen_tickets"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "sales"
    ADD CONSTRAINT "sales_fk_5"
    FOREIGN KEY("dining_table_id")
    REFERENCES "dining_tables"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261103164735343-meja', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261103164735343-meja', "timestamp" = now();

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
