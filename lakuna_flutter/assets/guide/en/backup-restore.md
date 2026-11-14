# Backup & restore

In the free version, all data and images live only on this device. Regular backups keep your data safe if the phone or computer breaks. This needs the *Backup & restore* permission (default: owner).

![The Data & backup settings.](backup)

## Making a backup

1. Open **Settings › Data & backup**.
2. Tap **Back up now**.
3. On a computer, the .zip file is saved in *Documents › Lakuna › Backup*. On a phone, choose a destination from the share menu, for example Google Drive or WhatsApp to yourself.

The backup file holds the database and all images. Keep it somewhere safe because it contains your store data.

> [!note] Home reminds you when the last backup is more than 7 days old or there has never been one.

## Daily automatic backup (computer)

On Windows, Linux, and macOS, Lakuna makes its own backup once a day while the app is open, so your data stays safe even if you forget to tap **Back up now**.

- Files are saved to *Documents › Lakuna › Backup › Otomatis*. The last seven backups are kept and older ones are deleted. Manual backups in the *Backup* folder are never deleted.
- The first check runs two minutes after the app opens, then every hour. A backup is made when the last automatic backup is more than 24 hours old, also while the PIN screen is open.
- **Settings › Data & backup** shows the **Daily automatic backup** switch (on by default), the folder location, and when the last automatic backup ran. If it fails (for example, the disk is full), a warning appears and the app retries every hour.
- An automatic backup also counts as the last backup, so the Home reminder does not appear while automatic backups are running.

> [!note] Automatic backups are not password-locked. If your Documents folder syncs to the cloud (for example OneDrive or iCloud Drive), copies are stored in your cloud account too. Turn the switch off if you do not want that, and use **Back up now** with a password lock.

Automatic backup is not available on phones and tablets yet; keep using **Back up now** there.

## Locking a backup with a password

If you keep backups in Google Drive, WhatsApp, or on a flash drive, lock them with a password so nobody else can read them.

1. In **Settings › Data & backup**, turn on **Lock with a password**.
2. Fill in **Backup password** (at least 8 characters) and **Retype password** with the same text.
3. Tap **Back up now**. The result message says *Password-locked backup*.

> [!warning] The password is not saved in the app. Keep it somewhere safe: without it the backup cannot be restored, not even by the Lakuna team.

When restoring a locked backup, the app asks for its password before showing the summary. If it is wrong, try again without picking the file again.

## Restoring from a backup

1. Open **Settings › Data & backup**, tap **Restore**, and choose the .zip file (automatic backups are in the *Backup › Otomatis* folder).
2. If the backup is locked, enter its password and tap **Unlock**.
3. Check the backup summary: store, branch, device, date, number of sales and products.
4. Type the store name exactly as asked, then tap **Restore & reload**.
5. The app reloads with the data from the backup.

> [!warning] All data on this device is replaced by the backup. The old data is moved to a *sebelum-pulihkan* folder in the data location, so it can still be rescued if you picked the wrong file.

If the backup file is damaged, the app automatically goes back to the old data. A backup from a newer Lakuna version can be restored after updating the app.

## Moving to a new device

On a new device you don't need to create a store first.

1. Install Lakuna and open it. The *Set up your store* wizard appears.
2. On the first step (*Language & theme*), tap **Restore from backup** and choose the .zip file from the old device.
3. If the backup is locked, enter its password and tap **Unlock**. Check the summary, type the store name, then tap **Restore & reload**.
4. The app reloads to the sign-in screen. Sign in with a staff PIN, as on the old device.

This button is only shown before a store exists. After that, restore from **Settings › Data & backup**.

> [!warning] The new device continues the old device's code and receipt numbers. Don't use the same backup on two devices at once.
