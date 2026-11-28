# Hosted version

The hosted version syncs the data of every branch and device to your store's own server. The app keeps working offline: sales are saved on the device first, then sent to the server as soon as there is a connection. This needs the *Sync & hosting* permission (default: owner).

![Hosted version settings.](hosting)

## What you need

- **Server address**, for example `https://sync.yourstore.id`. Choose *Lakuna server* if your app offers it, or *Own server* for a server on the store's VPS.
- **Activation code** from the server operator (8 letters/digits, single use).
- **Owner account** on the server: email and password. No account yet? Create one in step 2 with a verification code sent to your email.

## Activating on the first device

1. Open **Settings › Hosted version** and tap **Activate hosted version**.
2. **Server & code**: choose the server, enter the activation code, tap **Check**, then **Next**. If the server is older than the app, *Server needs an update* appears; ask the server operator to update it first.
3. **Owner account**: sign in, or choose **Create an account**, tap **Send code**, enter the code from the email and the password twice (at least 8 characters).
4. **Upload data**: tap **Activate and upload data**. Store data, products, stock and sales history upload in stages, with progress per group. The upload can be paused (**Pause upload**) and resumed, and continues if the app is closed and opened again.
5. **Done**: tap **Done**. The card shows *Active · server …*.

> [!note] Data stays on the device. The server is a shared copy; when the network drops, the cashier can keep selling.

## Sync status at the top of the screen

The chip at the top right shows the sync state:

- **Synced · 14:32**: every change has been sent.
- **Syncing… (35)**: changes are being sent.
- **Waiting for network (35)**: the device is offline; changes are sent automatically once online.
- **Sync paused**: sync was paused from the Hosted version card.
- **Needs attention**: something is wrong, for example the device clock is off or the server rejects the token. The owner can tap the chip to open the Hosted version card and read the explanation.

On phones the chip is only an icon with a colored dot; long-press it to see the text.

## Hosted version card

Once active, the card shows the server, the last sync time and how many changes are waiting. Its buttons:

- **Sync now**: send and fetch changes right away.
- **Pause sync** / **Resume sync**: stop temporarily, e.g. when mobile data is limited.
- **Create device pairing code**: create a code to add a device (see below).

## Adding a device or branch

1. On an active device, tap **Create device pairing code**. An 8-character code appears with a full code such as `https://sync.yourstore.id#ABCD2345`. It is valid for 15 minutes and works once. Tap **Copy full code** and send it to the new device, e.g. over WhatsApp.
2. On the new device, choose **Join a store that already uses hosting** on the welcome screen. On a device that already has data, open **Settings › Hosted version** and use the same button.
3. Paste the full code into the address field: address and code fill in by themselves. Tap **Check code**.
4. Choose the branch, enter the **Device code** (1–6 letters/digits, e.g. `K02`, used in receipt numbers) and the device name, then tap **Join**.
5. Store data is pulled from the server and the app reloads. Sign in with your staff PIN as usual.

> [!warning] Joining replaces the data on this device with the store's data from the server. If the device already has sales, the app warns you and makes a backup in the data folder (*backup-sebelum-gabung*) before replacing it. The old data is also kept in a *sebelum-gabung-…* folder.

## Photos and images

All store images are synced too: product photos, purchase invoice photos, expense receipt photos, supplier payment proofs, QRIS stickers, the receipt logo, and floor plan images. After their data is sent (even when other data needs attention), the image files are uploaded to the server storage one by one; an identical image is never uploaded twice. Other devices download an image the first time it is needed, for example when that product or purchase is opened, and keep it on the device.

Until an image is downloaded (the device is offline, or the source device has not uploaded it yet), a placeholder is shown. An image downloaded within a few seconds shows right away; if it takes longer, the real image shows the next time that screen is opened. A failed download is retried after about 2 minutes. Downloads are checked against the original; a file damaged on the way is discarded and retried later. An upload or download stalled for more than 2 minutes is stopped and retried in the next sync cycle.

## Troubleshooting

- **Device clock is off**: turn on automatic date and time on the device, then tap **Sync now**.
- **Server rejects the device token**: the device was revoked or the store was removed on the server. Contact the server operator.
- **Server unreachable**: check the address and the network. Changes stay saved and are sent later.
- **Restoring a backup** turns the hosted version off on that device; activate or join again if needed.
