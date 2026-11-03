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
CREATE TABLE "modifier_groups" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "name" text NOT NULL,
    "min_select" bigint NOT NULL DEFAULT 0,
    "max_select" bigint NOT NULL DEFAULT 1,
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
CREATE INDEX "modifier_groups_tenant_idx" ON "modifier_groups" USING btree ("tenant_id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "modifiers" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "modifier_group_id" uuid NOT NULL,
    "name" text NOT NULL,
    "price_delta" bigint NOT NULL DEFAULT 0,
    "is_default" boolean NOT NULL DEFAULT false,
    "is_available" boolean NOT NULL DEFAULT true,
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
CREATE INDEX "modifiers_group_idx" ON "modifiers" USING btree ("modifier_group_id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "product_modifier_groups" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "product_id" uuid NOT NULL,
    "modifier_group_id" uuid NOT NULL,
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
CREATE INDEX "product_modifier_groups_product_idx" ON "product_modifier_groups" USING btree ("product_id");
CREATE INDEX "product_modifier_groups_group_idx" ON "product_modifier_groups" USING btree ("modifier_group_id");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "sale_item_modifiers" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "tenant_id" uuid NOT NULL,
    "sale_item_id" uuid NOT NULL,
    "modifier_id" uuid NOT NULL,
    "group_name" text NOT NULL,
    "name" text NOT NULL,
    "price_delta" bigint NOT NULL,
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
CREATE INDEX "sale_item_modifiers_item_idx" ON "sale_item_modifiers" USING btree ("sale_item_id");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "sale_items" ADD COLUMN "modifier_delta" bigint NOT NULL DEFAULT 0;
ALTER TABLE "sale_items" ADD COLUMN "modifier_key" text;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "modifier_groups"
    ADD CONSTRAINT "modifier_groups_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "modifiers"
    ADD CONSTRAINT "modifiers_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "modifiers"
    ADD CONSTRAINT "modifiers_fk_1"
    FOREIGN KEY("modifier_group_id")
    REFERENCES "modifier_groups"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "product_modifier_groups"
    ADD CONSTRAINT "product_modifier_groups_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "product_modifier_groups"
    ADD CONSTRAINT "product_modifier_groups_fk_1"
    FOREIGN KEY("product_id")
    REFERENCES "products"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "product_modifier_groups"
    ADD CONSTRAINT "product_modifier_groups_fk_2"
    FOREIGN KEY("modifier_group_id")
    REFERENCES "modifier_groups"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "sale_item_modifiers"
    ADD CONSTRAINT "sale_item_modifiers_fk_0"
    FOREIGN KEY("tenant_id")
    REFERENCES "tenants"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "sale_item_modifiers"
    ADD CONSTRAINT "sale_item_modifiers_fk_1"
    FOREIGN KEY("sale_item_id")
    REFERENCES "sale_items"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "sale_item_modifiers"
    ADD CONSTRAINT "sale_item_modifiers_fk_2"
    FOREIGN KEY("modifier_id")
    REFERENCES "modifiers"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR lakuna
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lakuna', '20261103175303114-modifier', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261103175303114-modifier', "timestamp" = now();

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
