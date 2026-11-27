# Accepting static QRIS

The free version uses the store's own static QRIS image. The app does not receive payment proof automatically, so the cashier confirms once the money has arrived.

![The store QRIS sticker shown in full, waiting for the cashier to confirm.](pay-qris)

## Before you start

The owner uploads the QRIS sticker image in **Settings › Payment methods**, fills in the merchant details, then turns on **Static QRIS active at the cashier**. One image per branch. Upload the whole sticker (not just the QR code) as PNG, JPG, or WebP, up to 5 MB.

## Steps

1. On the Pay screen, choose **Static QRIS**. The QRIS image and the total appear on screen. Tap **Enlarge QRIS image** so the customer can scan it more easily.
2. Ask the customer to scan and type exactly the same amount.
3. Check the incoming-money notification on the store phone or the bank statement.
4. Tap **Paid**. The cashier's name and the confirmation time are recorded.

> [!warning] Do not tap Paid based only on the customer's screenshot. Make sure the money has really arrived.

If the money has not arrived, tap **Not received** and choose another method or wait a moment.

## Manager PIN for Paid

Staff with the *Confirm manual payments* permission tap **Paid** directly. Staff without it can still accept QRIS: after they tap **Paid**, the **Manager approval** dialog opens, and a manager checks the statement and enters their PIN. That manager is recorded as the one who confirmed.

The owner can require a PIN from every cashier by turning off **Cashiers may confirm without a manager PIN** in **Settings › Payment methods**. After that, only staff who also have the *Manage settings* permission (owners and managers) tap Paid directly, and only they can approve. One PIN covers every QRIS part of a payment; adding another QRIS part or switching the payment method asks for the PIN again. Waiting split bill parts on the Tables screen ask for a PIN per part.
