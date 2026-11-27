# Reports & profit and loss

The **Reports** menu summarises sales, profit, stock, cash, receivables and payables, and returns for this branch.

![Today's report summary.](reports)

## Steps

1. Open **Reports** and choose a **Period**: *Today*, *Last 7 days*, *This month*, one of the previous months, or *Date range…*.
   - The last period you chose is remembered on this device for each branch, even after the app is closed. *This month* always means the current month, while a date range keeps its dates. A month that has dropped off the list goes back to *Today*.
   - *Date range…* opens a **From** / **To** window (at most 366 days, not after today), e.g. Nov 1–15. Net profit is compared with the same number of days just before, and the download file name includes the dates (`…-20261101-20261115-…`).
2. Choose a tab:
   - **Summary**: sales, gross profit, average per receipt, overdue receivables, sales by payment method, and best sellers. Under *Bank transfer* there is a breakdown per destination account (largest first; *No account* for older transfers), also in the Excel/PDF download.
   - When customers paid their receivables in the period, the payment method card gets a **Receivable payments** section: the total, the amount per method, and bank transfers per account. These follow the payment date and are not part of the sales above, so add both when you reconcile a bank statement. Voided payments are not counted.
   - **Sales**: by product, by cashier, or by category.
   - **Best sellers**.
   - **Profit & loss**: net sales, COGS, gross profit, operating expenses, and net profit, compared with the previous period. When a **Gross margin target** is set in [Settings](store-settings), the *Gross margin* card reads *Store target 25% · met* or *Store target 25% · 3.2 points short*. The *Gross profit* card on the **Summary** tab shows it too, for example *Margin 21.8% · Store target 25% · 3.2 points short*.
   - **Stock**, **Cash & sessions**, **Receivables & payables**, **Returns**.
   - In **Receivables & payables**, the **Receivables aging** and **Payables aging** tables group each document's balance by how long it is past due: *Not yet due*, *1–30 days overdue*, *31–60*, *61–90*, and *over 90 days*. Collect or pay the oldest first.
   - The **Receivables by customer** and **Payables by supplier** tables split each name's balance into the same groups, so you can see who owns the balance that is over 90 days past due. Empty groups are left blank. On narrow screens the table turns into cards that only list groups with a balance. The PDF of this tab is printed in landscape.
   - In **Cash & sessions**, tap a closed session (printer icon at the end of the row) to see its recap, then **Print recap** to the receipt printer or **Share PDF**. A reprinted recap carries a *Reprinted* line with its date and time. Sessions that are still open cannot be printed yet.
   - When sessions use shifts, the cashier column names the shift (e.g. *Sari · Morning*) and the **By shift** table sums up sessions, sales, and difference for each shift; sessions without a shift are grouped as *No shift*.
3. Tap **Download PDF** or **Download Excel** to save or share the report.

## How it is calculated

- COGS uses the weighted average cost at the time of sale.
- Operating expenses come from [Expenses](expenses); stock differences from [adjustments](stock).
- PB1 collected is not income and is left out.

> [!note] Reports need the *View reports* permission. The Profit & loss tab needs *View profit & loss*, so it can be hidden from managers.
