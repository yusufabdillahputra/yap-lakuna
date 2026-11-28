# All-outlet dashboard

The **All-outlet dashboard** sums up today's sales for every outlet, the status of the cashier devices, and what needs follow-up on one screen. The menu appears once the [hosted version](hosting) is active, and in the web version, for staff with the *View reports* permission (default: owner and manager).

![All-outlet dashboard.](dashboard)

## What it shows

- **Sales today**: total sales across outlets, the number of transactions, and the number of outlets. "Today" follows the date in each outlet's own time zone, and the figures use the same rules as [Reports](reports) (voided receipts and returns are deducted).
- **Average per receipt**: sales divided by the number of transactions, rounded down.
- **Devices online**: cashier devices that reached the server in the last 10 minutes, e.g. *2 / 3*. When a device has not synced for over 1 hour, the note says when it last synced. Web devices are not counted.
- **Sync conflicts**: changes waiting for review on the server.
- **By outlet today**: sales, transactions, last sync, and device status for each outlet (*Online*, *1 device offline*, or *No devices*), with a **Total** row. On phones the table turns into cards.
- **Sales per hour**: a bar chart per hour of today. The hour axis always covers 08–17 and widens when there are sales outside those hours.
- **Best sellers this week**: the 5 products with the highest quantity sold in the last 7 days (including today); variants are combined into their product.
- **Needs attention**: conflicts awaiting review, devices that have not synced for over 1 hour, and the number of products below minimum stock per outlet. When there is nothing, the card turns into **All clear**.

## Steps

1. Open **All-outlet dashboard** from the menu.
2. Choose **All outlets** or a single outlet in the outlet picker. The cards, table, chart, and best sellers follow that choice.
3. Tap the *products below minimum stock* line for this outlet to open [Minimum stock](stock), or the conflicts line to open the **Hosted version** card (needs the *Sync & hosting* permission).
4. Tap **Download report** to save the dashboard summary to Excel (`dashboard-semua-cabang-261128.xlsx` or `dashboard-PST-261128.xlsx`).

> [!note] Sales figures come from data already synced to this device. Sales on a cashier device that is offline show up once that device is connected again.

## When device status is missing

Device status and conflicts are fetched from the server when the dashboard opens and every 60 seconds. When this device is offline, the cards read *Device status needs internet*; sales figures still show from the latest data.
