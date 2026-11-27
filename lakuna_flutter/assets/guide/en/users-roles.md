# Users & roles

Every staff member has their own name, role, and PIN. The role decides the permissions: buttons and pages that are not allowed are hidden automatically.

![The permission matrix per role.](users)

## Adding staff

1. Open **Users & roles**, the **Users** tab, then tap **Add**.
2. Enter the **Name** and choose a **Role**: *Manager*, *Cashier*, *Waiter*, *Stock keeper*, or a custom role.
3. Enter the **PIN (6 digits)** and **Repeat PIN**.
4. Leave **Active** on, then tap **Save user**.

## Resetting and unlocking a PIN

- **Reset PIN**: open the staff member, enter the **New PIN** and **Repeat new PIN**, then **Reset PIN**. The old PIN is not needed.
- **Unlock**: staff who enter a wrong PIN 5 times are locked for 1 minute; tap **Unlock** to unlock now.
- For staff who leave, simply turn **Active** off so they no longer appear on the sign-in screen.

## Setting role permissions

1. Open the **Roles & permissions** tab. The matrix shows each role's permissions, such as *Create sales*, *Void receipts*, *Manual discounts*, and *View profit & loss*.
2. Tick or untick permissions, then **Save changes**.
3. Tap **Custom role** to create a new role, for example *Barista*.

> [!note] The owner always has every permission. The owner changes their own PIN and password in **My account**, with a repeat field for both.

## Sign-in and sign-out log

The **Sign-in log** tab records every time staff sign in or out on a cashier device. Only users with the *Users & roles* permission (owners and managers) can see it.

- The log is grouped by date, with the newest at the top. Each row shows the time, the staff name, the event, and the device code (for example *K01*).
- The events are:
  - *Signed in with PIN*;
  - *Signed in with password*;
  - *Signed in after store setup*;
  - *Signed out (Switch cashier)*;
  - *Signed out automatically*, when a staff account is deactivated or removed from the branch while that person is on duty.
- Choose a name under **Staff** to see one person's log. Tap **Load more** to see older entries.

> [!note] If the app is closed without **Switch cashier**, there is no *Signed out* row. The next sign-in on that device marks the end. Wrong PINs are not recorded in this log.
