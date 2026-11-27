# Cash session & drawer

Sales are recorded in a cash session on this device so the drawer cash can be reconciled at closing. The cashier cannot sell before a session is open.

![An active cash session with its cash movements.](cash-session)

## Opening a session

1. Open **Cash session**.
2. If the store uses shifts, pick a **Shift**. The shift running now by the branch clock is already selected; change it if needed, or pick *No shift*.
3. Count the cash in the drawer and enter it as **Opening cash**. The note is optional.
4. Tap **Open session**.

> [!note] Owners and managers create the shift list (e.g. *Morning 07.00–15.00*, *Night 22.00–06.00*) in **Master data › Shifts**: enter a name, a start time, and an end time. An end time earlier than the start time means the shift crosses midnight. A shift already used by a session cannot be deleted. The session's shift shows on the active session card, the close-session title, the printed recap, and in [Reports](reports) › **Cash & sessions**.

## Cash in and out of the drawer

Tap **Record drawer cash**, choose **Cash in** or **Cash out**, enter the amount and description (e.g. buying ice), then **Save**. Turn on **Also record as an expense** when the cash out is a store cost, so it shows in the [profit & loss report](reports).

Expenses, supplier payments, and cash refunds from other modules are recorded automatically in the open session.

> [!note] When an amount leaving the drawer (here, a cash refund, an expense paid from the drawer, a supplier payment, or a purchase paid from the drawer) is larger than the *Expected cash in drawer*, the form shows a warning. You can still save, because the real drawer may differ from the estimate; make sure the cash is really there, and any difference shows up when you close the session. The same warning appears in the **Void transaction** dialog (cash receipts of this session) and when **voiding** a cash customer debt payment, since both also take cash out of the drawer.

## Closing a session

1. Tap **Close session**. The recap shows the opening cash, cash sales, cash refunds, cash in and out, and the amount that should be in the drawer.
2. Under *Count physical cash*, enter the number of notes for each denomination and the coins.
3. If there is a difference, fill in the **Difference note** (required).
4. Confirm the closing. The recap is saved on this device.

> [!note] Lost the recap slip, or the printer was off at closing? When no session is open, the **Previous sessions** card below the *Open session* form lists the last 5 sessions closed on this device: tap one, then **Print** or **Share PDF**. Owners and managers can also reprint a session from any device in [Reports](reports) › **Cash & sessions**.

> [!note] Static QRIS and card payments do not go into the drawer. They are shown separately in the recap so you can match them with your bank statement.

> [!warning] A split bill that is partly paid must be settled or cancelled before the session can close.
