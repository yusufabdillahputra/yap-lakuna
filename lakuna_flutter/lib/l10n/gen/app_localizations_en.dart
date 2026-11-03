// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lakuna';

  @override
  String get appTagline => 'Offline point of sale for small businesses';

  @override
  String get offlineBadge => 'Offline · data on this device';

  @override
  String get menuHome => 'Home';

  @override
  String get menuCashier => 'Cashier';

  @override
  String get menuHistory => 'History';

  @override
  String get menuProducts => 'Products';

  @override
  String get menuStock => 'Stock';

  @override
  String get menuPurchases => 'Purchases';

  @override
  String get menuCustomers => 'Customers';

  @override
  String get menuSuppliers => 'Suppliers';

  @override
  String get menuExpenses => 'Expenses';

  @override
  String get menuReports => 'Reports';

  @override
  String get menuUsers => 'Users & roles';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuGuide => 'Guide';

  @override
  String get menuGroupSales => 'Sales';

  @override
  String get menuGroupInventory => 'Inventory';

  @override
  String get menuGroupContacts => 'Contacts';

  @override
  String get menuGroupFinance => 'Finance';

  @override
  String get menuGroupSystem => 'System';

  @override
  String get homeWelcomeTitle => 'Welcome to Lakuna';

  @override
  String get homeWelcomeBody =>
      'Retail checkout, cash sessions, and products are ready to use. Purchases, history, and reports follow in upcoming releases.';

  @override
  String get homeDeviceLabel => 'Device ID';

  @override
  String get homeDataLabel => 'Data location';

  @override
  String get homeVersionLabel => 'Version';

  @override
  String comingSoonTitle(String module) {
    return '$module is coming soon';
  }

  @override
  String get comingSoonBody =>
      'This module is being built and will be available in an upcoming release.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsSaveError =>
      'Settings could not be saved. Please try again.';

  @override
  String get onboardingWelcome => 'Welcome';

  @override
  String get onboardingHeadline => 'Set up your store in 4 steps';

  @override
  String get onboardingOfflineNote =>
      'All data is stored on this device. You can turn on the hosted version at any time.';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingStepLanguage => 'Language & theme';

  @override
  String get onboardingStepBusiness => 'Business type & branch';

  @override
  String get onboardingStepOwner => 'Owner account & PIN';

  @override
  String get onboardingStepSummary => 'Ready to sell';

  @override
  String get onboardingTitleLanguage => 'Choose language and theme';

  @override
  String get onboardingTitleBusiness => 'Business type & first branch';

  @override
  String get onboardingTitleOwner => 'Owner account & PIN';

  @override
  String get onboardingTitleSummary => 'Review, then start selling';

  @override
  String get businessTypeLabel => 'Business type';

  @override
  String get businessRetail => 'Retail';

  @override
  String get businessRetailDesc =>
      'Grocery, wholesale, hardware store, phone counter.';

  @override
  String get businessFnb => 'F&B';

  @override
  String get businessFnbDesc =>
      'Food stall, café, coffee shop. With tables & open bills.';

  @override
  String get businessMixed => 'Mixed';

  @override
  String get businessMixedDesc => 'Sell goods as well as food and drinks.';

  @override
  String get fieldBusinessName => 'Business name';

  @override
  String get fieldOutletName => 'Branch name';

  @override
  String get fieldOutletCode => 'Branch code (for receipt numbers)';

  @override
  String get fieldDeviceCode => 'Device code';

  @override
  String get fieldTimezone => 'Time zone';

  @override
  String get fieldOwnerName => 'Owner name';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldPasswordConfirm => 'Repeat password';

  @override
  String get fieldPin => 'PIN (6 digits)';

  @override
  String get fieldPinConfirm => 'Repeat PIN';

  @override
  String get receiptPreviewLabel => 'Sample receipt number';

  @override
  String get receiptPreviewNote =>
      'Branch, device, date, sequence. Safe even when several cashiers are offline.';

  @override
  String get ownerNote =>
      'The PIN is used to sign in and switch cashiers. The email and password are used to sign in as the owner.';

  @override
  String get errorRequired => 'Required';

  @override
  String get errorTooLong => 'Up to 60 characters';

  @override
  String get errorInvalidCode => '2–6 letters or digits';

  @override
  String get errorInvalidEmail => 'Invalid email format';

  @override
  String get errorPasswordTooShort => 'At least 8 characters';

  @override
  String get errorPasswordMismatch => 'The passwords do not match';

  @override
  String get errorInvalidPin => 'The PIN must be 6 digits';

  @override
  String get errorPinMismatch => 'The PINs do not match';

  @override
  String get errorInvalidTimezone => 'Choose a time zone';

  @override
  String get summaryBusiness => 'Business';

  @override
  String get summaryOutlet => 'Branch';

  @override
  String get summaryDevice => 'Device';

  @override
  String get summaryOwner => 'Owner';

  @override
  String get summaryNote =>
      'Your data is saved only after you press Start selling.';

  @override
  String get buttonBack => 'Back';

  @override
  String get buttonNextBusiness => 'Next: business type';

  @override
  String get buttonNextOwner => 'Next: owner account';

  @override
  String get buttonNextSummary => 'Next: summary';

  @override
  String get buttonStartSelling => 'Start selling';

  @override
  String get setupFailed => 'The store could not be saved. Please try again.';

  @override
  String get homeStoreLabel => 'Store';

  @override
  String get setupAlreadyDone =>
      'This device already holds incomplete store data. Restore from a backup or contact support.';

  @override
  String get loginTitle => 'Who\'s on duty?';

  @override
  String get loginSelectStaff => 'Choose your name to enter your PIN.';

  @override
  String loginEnterPinFor(String name) {
    return 'Enter $name\'s PIN';
  }

  @override
  String get loginNoPin => 'No PIN yet';

  @override
  String get loginPinNote =>
      'PINs are verified on this device. 5 wrong attempts → locked for 1 minute.';

  @override
  String get loginOwnerLink => 'Sign in with email & password (owner)';

  @override
  String get loginOwnerTitle => 'Sign in as owner';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginBackToPin => 'Back to PIN';

  @override
  String get loginBackToStaff => 'Choose someone else';

  @override
  String get loginKeypadCancel => 'Cancel';

  @override
  String get loginKeypadDelete => 'Delete one digit';

  @override
  String loginWrongPin(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wrong PIN. $count attempts left.',
      one: 'Wrong PIN. 1 attempt left.',
    );
    return '$_temp0';
  }

  @override
  String loginLocked(int seconds) {
    return 'Too many attempts. Try again in $seconds s.';
  }

  @override
  String get loginWrongCredentials => 'Wrong email or password.';

  @override
  String get loginStaffUnavailable =>
      'This staff member is no longer active at this branch.';

  @override
  String get loginFailed => 'Sign-in failed. Try again.';

  @override
  String get loginLoadFailed => 'Could not load the staff list.';

  @override
  String get loginRetry => 'Try again';

  @override
  String get switchCashier => 'Switch cashier';

  @override
  String get homeStaffLabel => 'On duty';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleCashier => 'Cashier';

  @override
  String get roleWaiter => 'Waiter';

  @override
  String get roleStockKeeper => 'Stock keeper';

  @override
  String get menuCashSession => 'Cash session';

  @override
  String get cashDrawerTitle => 'Cash session · Cash drawer';

  @override
  String cashCashierLabel(String name) {
    return 'Cashier: $name';
  }

  @override
  String get cashOpenTitle => 'Open cash session';

  @override
  String get cashOpenBody =>
      'Count the money in the drawer before you start selling, then record it as the opening cash.';

  @override
  String get cashOpeningCash => 'Opening cash';

  @override
  String get cashOpeningNote => 'Note (optional)';

  @override
  String get cashOpenButton => 'Open session';

  @override
  String get cashActive => 'Active session';

  @override
  String cashOpenedBy(String time, String name, String device) {
    return 'Opened $time by $name · $device';
  }

  @override
  String get cashExpected => 'Expected cash in drawer';

  @override
  String get cashCloseButton => 'Close session';

  @override
  String get cashMovementsTitle => 'Cash movements this session';

  @override
  String get cashColTime => 'Time';

  @override
  String get cashColNote => 'Description';

  @override
  String get cashColSource => 'Source';

  @override
  String get cashColAmount => 'Amount';

  @override
  String get cashOpeningRow => 'Opening cash';

  @override
  String get cashSourceOpening => 'Session opened';

  @override
  String get cashSourceManual => 'Manual';

  @override
  String get cashMovementsFootnote =>
      'Expenses, debt payments, and cash refunds from other modules will be recorded automatically in the open session.';

  @override
  String get cashRecordTitle => 'Record drawer cash';

  @override
  String get cashOutflow => 'Cash out';

  @override
  String get cashInflow => 'Cash in';

  @override
  String get cashAmount => 'Amount';

  @override
  String get cashNote => 'Description';

  @override
  String get cashNoteHint => 'E.g. buy ice';

  @override
  String get cashSave => 'Save';

  @override
  String cashNeedsPermission(String permission) {
    return 'Requires the $permission permission.';
  }

  @override
  String cashCloseTitle(String name) {
    return 'Close cash session · $name';
  }

  @override
  String get cashBackToDrawer => 'Back to cash drawer';

  @override
  String get cashStatTransactions => 'Transactions';

  @override
  String get cashStatSales => 'Sales';

  @override
  String get cashStatVoids => 'Voids / returns';

  @override
  String get cashRecapTitle => 'Cash drawer recap';

  @override
  String cashRecapOpening(String time) {
    return 'Opening cash ($time)';
  }

  @override
  String get cashRecapCashSales => 'Cash sales';

  @override
  String get cashRecapInflow => 'Other cash in';

  @override
  String get cashRecapOutflow => 'Cash out';

  @override
  String get cashRecapExpected => 'Expected in drawer';

  @override
  String get cashRecapNonCash => 'Static QRIS (confirmed) · card';

  @override
  String get cashRecapFootnote =>
      'Static QRIS & card payments don\'t go into the drawer; they are shown separately to match against the bank statement.';

  @override
  String get cashCountTitle => 'Count physical cash';

  @override
  String cashSheetsLabel(String denomination) {
    return 'Rp $denomination notes';
  }

  @override
  String get cashCoins => 'Coins';

  @override
  String get cashCounted => 'Counted cash';

  @override
  String get cashDifference => 'Difference';

  @override
  String get cashDifferenceExact => 'Exact';

  @override
  String get cashClosingNote => 'Difference note';

  @override
  String get cashClosingNoteHint => 'Required when there is a difference';

  @override
  String get cashClosedTitle => 'Cash session closed';

  @override
  String cashClosedBody(String time) {
    return 'Closed at $time. The recap is saved on this device.';
  }

  @override
  String get cashStartNew => 'Open a new session';

  @override
  String get cashErrorNegative => 'Cannot be negative';

  @override
  String get cashErrorNotPositive => 'Must be more than 0';

  @override
  String get cashErrorTooLong => 'At most 200 characters';

  @override
  String cashErrorNotPermitted(String permission) {
    return 'You don\'t have the $permission permission.';
  }

  @override
  String get cashErrorAlreadyOpen =>
      'A session was already opened elsewhere. The data has been reloaded.';

  @override
  String get cashErrorNotOpen =>
      'The session was already closed elsewhere. The data has been reloaded.';

  @override
  String get cashErrorFailed => 'Could not save. Try again.';

  @override
  String get cashLoadFailed => 'The cash session could not be loaded.';

  @override
  String get productsTitle => 'Products & stock';

  @override
  String get productsTitleMobile => 'Products';

  @override
  String productsSummary(int active, int low) {
    return '$active active products · $low below minimum stock';
  }

  @override
  String productsSummaryShort(int active, int low) {
    return '$active active · $low below minimum';
  }

  @override
  String get productsNew => 'New product';

  @override
  String get productsSearchHint => 'Search name, SKU, or barcode';

  @override
  String get productsCategoryFilter => 'Category';

  @override
  String get productsAllCategories => 'All';

  @override
  String productsBelowMinimumChip(int count) {
    return 'Below minimum ($count)';
  }

  @override
  String get productsColProduct => 'Product';

  @override
  String get productsColCategory => 'Category';

  @override
  String get productsColVariantUnit => 'Variant / unit';

  @override
  String get productsColCost => 'Cost price';

  @override
  String get productsColPrice => 'Selling price';

  @override
  String get productsColTiers => 'Wholesale';

  @override
  String get productsColStock => 'Stock';

  @override
  String productsVariantsCount(int count) {
    return '$count variants';
  }

  @override
  String get productsStockFootnote =>
      'Stock is calculated from the movement history (opening stock, purchases, sales, returns, adjustments).';

  @override
  String get productsEmptyTitle => 'No products yet';

  @override
  String get productsEmptyBody =>
      'Add your first product so it can be sold at the cashier.';

  @override
  String get productsNoMatch => 'No matching products.';

  @override
  String get productsLoadFailed => 'The products could not be loaded.';

  @override
  String productsStock(String qty) {
    return 'Stock $qty';
  }

  @override
  String productsStockMin(String qty, String min) {
    return 'Stock $qty / min $min';
  }

  @override
  String get productsInactive => 'Not for sale';

  @override
  String get productFormNewTitle => 'New product';

  @override
  String productFormEditTitle(String name) {
    return 'Edit product · $name';
  }

  @override
  String get productFormCancel => 'Cancel';

  @override
  String get productFormSave => 'Save';

  @override
  String get productFormBasicInfo => 'Basic info';

  @override
  String get productFormName => 'Product name';

  @override
  String get productFormCategory => 'Category';

  @override
  String get productFormKind => 'Type';

  @override
  String get productKindGoods => 'Goods (track stock)';

  @override
  String get productKindService => 'Service (no stock)';

  @override
  String get productKindMenu => 'F&B menu';

  @override
  String get productFormBaseUnit => 'Base unit';

  @override
  String get productFormBaseUnitHint => 'pcs, bottle, kg';

  @override
  String get productFormSku => 'Parent SKU';

  @override
  String get productFormBrand => 'Brand';

  @override
  String get productFormActive => 'Sold at the cashier';

  @override
  String get productFormTaxable => 'Taxable (PB1/VAT)';

  @override
  String get productFormTaxableHint => 'Follows the store tax settings';

  @override
  String get productFormOptional => 'Optional';

  @override
  String get productTabVariants => 'Variants';

  @override
  String get productTabUnits => 'Units & conversion';

  @override
  String get productTabTiers => 'Wholesale prices';

  @override
  String get productTabUnitsShort => 'Units';

  @override
  String get productTabTiersShort => 'Wholesale';

  @override
  String get productVariantName => 'Variant';

  @override
  String get productVariantNameHint => 'e.g. 2 L';

  @override
  String get productVariantSku => 'SKU';

  @override
  String get productVariantBarcode => 'Barcode';

  @override
  String get productCostPrice => 'Cost price';

  @override
  String get productSellPrice => 'Selling price';

  @override
  String get productMinStock => 'Min stock';

  @override
  String get productOpeningStock => 'Opening stock';

  @override
  String get productAddVariant => 'Add variant';

  @override
  String get productRemoveRow => 'Remove row';

  @override
  String productVariantFallback(int index) {
    return 'Variant $index';
  }

  @override
  String get productSelectVariant => 'Variant';

  @override
  String get productBaseUnitRow => 'base unit';

  @override
  String get productUnitName => 'Unit';

  @override
  String productUnitFactor(String unit) {
    return 'Contains ($unit)';
  }

  @override
  String get productUnitPriceHint => 'Empty = price × contents';

  @override
  String get productAddUnit => 'Add unit';

  @override
  String productUnitsHelp(String unit, String conversion, String factor) {
    return 'Stock is always kept in the base unit ($unit). Selling 1 $conversion takes $factor $unit off the stock card.';
  }

  @override
  String productUnitsHelpBase(String unit) {
    return 'Stock is always kept in the base unit ($unit).';
  }

  @override
  String get productUnitsEmpty => 'No conversion units yet, e.g. a box of 12.';

  @override
  String productTierMinQty(String unit) {
    return 'From quantity ($unit)';
  }

  @override
  String productTierPrice(String unit) {
    return 'Price per $unit';
  }

  @override
  String get productTierAppliesTo => 'Applies to';

  @override
  String get productTierAllCustomers => 'All customers';

  @override
  String get productAddTier => 'Add price tier';

  @override
  String get productTiersHelp =>
      'Wholesale prices apply automatically at the cashier once the quantity reaches the tier.';

  @override
  String get productTiersEmpty => 'No wholesale prices yet.';

  @override
  String get productBaseUnitPlaceholder => 'base unit';

  @override
  String get productSaveFailed => 'The product could not be saved. Try again.';

  @override
  String get productNotFound =>
      'The product was not found or has been deleted.';

  @override
  String get productFixErrors => 'Check the fields marked in red.';

  @override
  String productErrorNotPermitted(String permission) {
    return 'You do not have the $permission permission.';
  }

  @override
  String productErrorTooLong(int max) {
    return 'At most $max characters';
  }

  @override
  String get productErrorNegative => 'Cannot be negative';

  @override
  String get productErrorNotPositive => 'Must be more than 0';

  @override
  String get productErrorDuplicate => 'Duplicated in this product';

  @override
  String get productErrorSameAsBase => 'Same as the base unit';

  @override
  String get productErrorFactorTooSmall => 'Must contain more than 1';

  @override
  String get productErrorMinQtyTooSmall => 'Must be more than 1';

  @override
  String productErrorTaken(String name) {
    return 'Already used by $name';
  }

  @override
  String get productErrorVariantsRequired => 'At least one variant';

  @override
  String cashierContext(String name, String time) {
    return 'Cashier: $name · Session opened $time';
  }

  @override
  String get cashierSearchHint => 'Search product or scan barcode…';

  @override
  String get cashierScannerReady => 'Scanner ready';

  @override
  String cashierScanUnknown(String code) {
    return 'Unknown barcode: $code';
  }

  @override
  String get cashierAllCategories => 'All';

  @override
  String get cashierNoProducts =>
      'No active products yet. Add them in Products.';

  @override
  String get cashierNoMatch => 'No matching products.';

  @override
  String cashierStock(String qty) {
    return 'Stock $qty';
  }

  @override
  String get cashierOrder => 'Order';

  @override
  String get cashierWalkIn => 'Walk-in customer · Takeaway';

  @override
  String get cashierCartEmpty =>
      'No items yet. Scan a barcode or tap a product.';

  @override
  String cashierTierNote(String qty) {
    return 'wholesale ≥ $qty';
  }

  @override
  String get cashierSubtotal => 'Subtotal';

  @override
  String get cashierTierDiscount => 'Wholesale discount';

  @override
  String get cashierTotal => 'Total';

  @override
  String get cashierClear => 'Clear';

  @override
  String get cashierPay => 'Pay';

  @override
  String cashierPayAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String cashierMobileSummary(int lines, String items) {
    return '$lines products · $items items';
  }

  @override
  String get cashierViewOrder => 'View order';

  @override
  String get cashierPickTitle => 'Choose variant / unit';

  @override
  String get cashierQtyTitle => 'Change quantity';

  @override
  String cashierQtyLabel(String unit) {
    return 'Quantity ($unit)';
  }

  @override
  String get cashierQtySave => 'Save';

  @override
  String get cashierCancel => 'Cancel';

  @override
  String get cashierDecrease => 'Decrease';

  @override
  String get cashierIncrease => 'Increase';

  @override
  String get cashierNoSessionTitle => 'Open a cash session first';

  @override
  String get cashierNoSessionBody =>
      'Sales are recorded in this device\'s cash session so the drawer can be reconciled at closing.';

  @override
  String get cashierOpenSession => 'Open cash session';

  @override
  String get cashierLoadFailed => 'Couldn\'t load the cashier.';

  @override
  String paymentTitle(String amount) {
    return 'Payment · Total $amount';
  }

  @override
  String get paymentBack => 'Back to order';

  @override
  String paymentLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentCashHint => 'Calculates change';

  @override
  String get paymentCard => 'Debit / credit card';

  @override
  String get paymentCardHint => 'Separate EDC';

  @override
  String get paymentTransfer => 'Bank transfer';

  @override
  String get paymentTransferHint => 'Check the statement first';

  @override
  String get paymentReceived => 'Amount received';

  @override
  String get paymentExact => 'Exact amount';

  @override
  String get paymentChange => 'Change';

  @override
  String paymentShort(String amount) {
    return 'Short by $amount';
  }

  @override
  String get paymentApproval => 'Card approval no. (optional)';

  @override
  String get paymentApprovalHint => 'e.g. 004512';

  @override
  String get paymentReference => 'Transfer reference (optional)';

  @override
  String get paymentReferenceTooLong => 'Up to 40 characters';

  @override
  String paymentNonCashNote(String amount) {
    return 'Amount paid equals the total $amount.';
  }

  @override
  String get paymentFinish => 'Complete payment';

  @override
  String get paymentErrorSession =>
      'The cash session is closed. Open a session again to continue.';

  @override
  String get paymentErrorUnavailable =>
      'A product is no longer available. Check the order.';

  @override
  String get paymentErrorShort => 'The amount received is less than the total.';

  @override
  String get paymentErrorGeneric => 'Couldn\'t save the payment. Try again.';

  @override
  String get successHeader => 'Payment complete';

  @override
  String successReceiptNo(String number) {
    return 'Receipt $number';
  }

  @override
  String get successTitle => 'Payment successful';

  @override
  String successDetail(String method, String amount, String time, String name) {
    return '$method $amount · $time · $name';
  }

  @override
  String get successChange => 'Change';

  @override
  String get successNegativeTitle => 'Stock went negative';

  @override
  String successNegativeBody(String name, String qty) {
    return '$name is now $qty. Check stock or record an adjustment.';
  }

  @override
  String get successPrintNote =>
      'Receipt printing and PDF sharing arrive with the Receipt & printer module.';

  @override
  String get successNew => 'New transaction';

  @override
  String get receiptNo => 'No';

  @override
  String get receiptDate => 'Date';

  @override
  String get receiptCashier => 'Cashier';

  @override
  String get receiptTotal => 'TOTAL';

  @override
  String get receiptChange => 'Change';

  @override
  String get receiptThanks => 'Thank you, see you again!';

  @override
  String cashierPriceFrom(String price) {
    return 'from $price';
  }

  @override
  String get paymentErrorPermission =>
      'You are not allowed to save sales. Ask the owner or a manager.';
}
