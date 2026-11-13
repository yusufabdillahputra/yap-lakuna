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
  String get menuMore => 'More';

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
  String get cashRecapCashRefunds => 'Cash refunds';

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
      'Wholesale prices apply automatically at the cashier once the quantity reaches the tier. A customer group price applies when a customer in that group is selected at the cashier; when two prices apply, the cheaper one wins.';

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
      'Auto-print after payment can be turned on in Settings › Receipt & printer.';

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

  @override
  String get paymentQris => 'Static QRIS';

  @override
  String get paymentQrisHint => 'Manual confirmation';

  @override
  String get paymentSplit => 'Split across methods';

  @override
  String get paymentSplitHint => 'Split payment';

  @override
  String paymentSplitSummary(int count) {
    return 'Split · $count methods';
  }

  @override
  String get paymentErrorQrisOff =>
      'Static QRIS is turned off for this branch. Choose another method.';

  @override
  String get paymentErrorUnconfirmed => 'QRIS has not been confirmed as paid.';

  @override
  String get paymentErrorSplit =>
      'The split is not valid. Check each method\'s amount.';

  @override
  String get paymentErrorConfirmPermission =>
      'You are not allowed to confirm QRIS payments. Ask a supervisor.';

  @override
  String get qrisPending => 'Waiting for cashier confirmation';

  @override
  String get qrisInstruction => 'Scan the QRIS and type the exact amount';

  @override
  String qrisSettlement(String target) {
    return 'Funds go to: $target';
  }

  @override
  String get qrisStep1 => 'Show the QRIS sticker to the customer.';

  @override
  String qrisStep2(String amount) {
    return 'The customer scans and types $amount.';
  }

  @override
  String get qrisStep3 =>
      'Check the incoming payment notification or statement.';

  @override
  String get qrisStep4 => 'Press Paid once the funds arrive.';

  @override
  String get qrisWarning =>
      'Do not confirm from the customer\'s screenshot alone. Make sure the funds have arrived.';

  @override
  String get qrisEnlarge => 'Enlarge QRIS image';

  @override
  String get qrisTapFullscreen => 'Tap the image for full screen';

  @override
  String get qrisImageLabel => 'Store static QRIS sticker';

  @override
  String get qrisClose => 'Close';

  @override
  String get qrisNotReceived => 'Not received';

  @override
  String get qrisPaid => 'Paid';

  @override
  String get qrisNoPermission =>
      'Requires payment confirmation permission (payments:confirm).';

  @override
  String get splitTitle => 'Split payment';

  @override
  String get splitHint => 'Example: part cash, the rest QRIS or card.';

  @override
  String get splitAmount => 'Amount';

  @override
  String get splitAdd => 'Add method';

  @override
  String get splitRemove => 'Remove';

  @override
  String get splitConfirm => 'Confirm';

  @override
  String get splitReceived => 'Received';

  @override
  String get splitPending => 'Waiting';

  @override
  String get splitRemaining => 'Remaining';

  @override
  String get splitCashExists =>
      'Cash is already added. Remove it first to change it.';

  @override
  String get splitOverRemaining =>
      'More than remaining. Change only comes from cash.';

  @override
  String get splitPendingNote => 'Confirm every waiting QRIS before finishing.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionPayments => 'Payment methods';

  @override
  String get settingsSectionAppearance => 'Appearance & language';

  @override
  String settingsBranchScope(String outlet) {
    return 'Applies to $outlet · all devices in this branch';
  }

  @override
  String get qrisSettingsBreadcrumb => 'Payment methods › Static QRIS';

  @override
  String get qrisSettingsImageTitle => 'Static QRIS image';

  @override
  String get qrisSettingsImageSubtitle =>
      'Used on the QRIS payment screen and can be reprinted as a table sticker';

  @override
  String get qrisSettingsNoImage => 'No QRIS image yet';

  @override
  String qrisSettingsFileInfo(String name, String size) {
    return '$name · $size';
  }

  @override
  String get qrisSettingsReplace => 'Replace QRIS image';

  @override
  String get qrisSettingsUpload => 'Upload QRIS image';

  @override
  String get qrisSettingsUploadHint =>
      'Choose the sticker file from this device. PNG, JPG, or WebP, up to 5 MB.';

  @override
  String get qrisSettingsPick => 'Choose file';

  @override
  String get qrisSettingsCheckTitle => 'Check results';

  @override
  String qrisSettingsPortrait(String ratio) {
    return 'Portrait ratio detected ($ratio). The image is shown whole, never cropped.';
  }

  @override
  String qrisSettingsNotPortrait(String ratio) {
    return 'The image is not portrait ($ratio). Make sure this is the whole QRIS sticker.';
  }

  @override
  String qrisSettingsResolution(int width, int height) {
    return 'Resolution $width × $height px.';
  }

  @override
  String qrisSettingsLowResolution(int width, int height) {
    return 'Resolution $width × $height px. At least 1000 px wide is recommended for sharp tablets.';
  }

  @override
  String get qrisSettingsUnsupported => 'The file is not PNG, JPG, or WebP.';

  @override
  String get qrisSettingsTooLarge => 'The file is larger than 5 MB.';

  @override
  String get qrisSettingsWholeTitle =>
      'Upload the whole sticker, not a cropped QR';

  @override
  String get qrisSettingsWholeBody =>
      'Use the original file from your bank/PJP or a straight photo of the whole sticker: QRIS + GPN header, merchant name, NMID, terminal code, QR, and \"SATU QRIS UNTUK SEMUA\". Customers need to see the store name before paying.';

  @override
  String get qrisSettingsMerchantTitle => 'Merchant details';

  @override
  String get qrisSettingsMerchantName => 'Merchant name on the QRIS';

  @override
  String get qrisSettingsNmid => 'NMID';

  @override
  String get qrisSettingsNmidHint => 'National merchant ID';

  @override
  String get qrisSettingsTerminal => 'Terminal code';

  @override
  String get qrisSettingsSettlement => 'Funds go to';

  @override
  String get qrisSettingsSettlementHint =>
      'A hint for cashiers checking statements, e.g. BCA account 123-456-7890';

  @override
  String get qrisSettingsEnabled => 'Static QRIS active at the cashier';

  @override
  String get qrisSettingsRequirePaid => '\"Paid\" confirmation required';

  @override
  String get qrisSettingsRequirePaidHint =>
      'Always on for static QRIS; cannot be turned off';

  @override
  String get qrisSettingsSave => 'Save';

  @override
  String get qrisSettingsCancel => 'Cancel';

  @override
  String get qrisSettingsSaved => 'QRIS settings saved';

  @override
  String get qrisSettingsImageMissing =>
      'Upload a QRIS image before turning it on.';

  @override
  String qrisSettingsTooLong(int max) {
    return 'At most $max characters';
  }

  @override
  String get qrisSettingsNmidInvalid => 'Letters and digits only, up to 20';

  @override
  String get qrisSettingsLoadError => 'QRIS settings failed to load.';

  @override
  String get receiptSampleNumber => 'PST-K01-261103-0001';

  @override
  String get receiptPrinterTitle => 'Receipt printer';

  @override
  String get receiptPrinterNone => 'No printer yet';

  @override
  String get receiptPrinterNoneHint =>
      'Set one up in Settings › Receipt & printer. Without a printer, Print receipt opens the system print dialog.';

  @override
  String get printerKindBluetooth => 'Bluetooth';

  @override
  String get printerKindNetwork => 'Network (LAN)';

  @override
  String get printerKindSystem => 'System print dialog';

  @override
  String get receiptPrint => 'Print receipt';

  @override
  String get receiptShare => 'Share PDF';

  @override
  String get receiptPrinted => 'Receipt sent to the printer.';

  @override
  String receiptPdfSaved(String path) {
    return 'PDF saved to $path';
  }

  @override
  String get receiptShareError => 'Could not create the receipt PDF.';

  @override
  String get printerRetry => 'Try again';

  @override
  String get printerErrorBluetoothOff =>
      'Bluetooth is off. Turn it on and try again.';

  @override
  String get printerErrorPermission =>
      'Bluetooth permission denied. Allow it in the device settings.';

  @override
  String get printerErrorConnect =>
      'Cannot reach the printer. Make sure it is on and in range.';

  @override
  String get printerErrorWrite => 'Could not send data to the printer.';

  @override
  String get printerErrorTimeout => 'The printer did not respond.';

  @override
  String get printerErrorUnsupported =>
      'This printer type is not supported on this device.';

  @override
  String get printerErrorGeneric => 'Could not print the receipt.';

  @override
  String get settingsSectionReceipt => 'Receipt & printer';

  @override
  String get receiptSettingsBreadcrumb => 'Receipt & printer';

  @override
  String get receiptDeviceTitle => 'This device\'s printer';

  @override
  String get receiptDeviceSubtitle =>
      'Stored on this device only, not shared with other devices.';

  @override
  String get printerSearch => 'Find printers';

  @override
  String get printerBluetoothEmpty =>
      'No paired printers yet. Pair the printer in the device\'s Bluetooth settings, then search again.';

  @override
  String get printerBluetoothUnsupported =>
      'Bluetooth printers are available on Android. On this device use a network printer or the system print dialog.';

  @override
  String get printerSelected => 'Selected';

  @override
  String get printerChoose => 'Choose';

  @override
  String get printerAddress => 'Printer address';

  @override
  String get printerAddressHint =>
      'IP or host name, default port 9100. Example 192.168.1.50:9100';

  @override
  String get printerAddressInvalid =>
      'Invalid address. Example 192.168.1.50 or 192.168.1.50:9100';

  @override
  String get printerUseAddress => 'Use this address';

  @override
  String get printerSystemNote =>
      'The receipt goes as a PDF to the operating system\'s print dialog, for USB printers or printers with a driver.';

  @override
  String get printerUseSystem => 'Use the system print dialog';

  @override
  String get printerTest => 'Test print';

  @override
  String get printerTestSent => 'Test print sent.';

  @override
  String get printerForget => 'Forget printer';

  @override
  String get receiptOutletTitle => 'Receipts for this branch';

  @override
  String get receiptPaperWidth => 'Paper width';

  @override
  String receiptPaperOption(int mm, int columns) {
    return '$mm mm · $columns columns';
  }

  @override
  String get receiptHeader => 'Receipt header';

  @override
  String get receiptHeaderHint =>
      'Address, phone, or other text under the store name. Up to 4 lines.';

  @override
  String get receiptFooter => 'Receipt footer';

  @override
  String get receiptFooterHint => 'Closing message. Up to 4 lines.';

  @override
  String get receiptTooManyLines => 'Up to 4 lines';

  @override
  String get receiptLineTooLong => 'Up to 48 characters per line';

  @override
  String get receiptAutoPrint => 'Print automatically after payment';

  @override
  String get receiptAutoPrintHint => 'Only for Bluetooth or network printers.';

  @override
  String get receiptPreviewTitle => 'Receipt preview';

  @override
  String get receiptSettingsSave => 'Save';

  @override
  String get receiptSettingsCancel => 'Cancel';

  @override
  String get receiptSettingsSaved => 'Receipt settings saved';

  @override
  String get receiptSettingsLoadError => 'Could not load receipt settings.';

  @override
  String get stockTitle => 'Stock';

  @override
  String stockSubtitle(String location, String outlet) {
    return '$location · $outlet';
  }

  @override
  String get stockTabList => 'Product list';

  @override
  String get stockTabAdjustment => 'Adjustment';

  @override
  String get stockTabCard => 'Stock card';

  @override
  String get stockTabMinimum => 'Minimum stock';

  @override
  String get stockTabLocations => 'Stock locations';

  @override
  String get stockLoadFailed => 'Stock data failed to load.';

  @override
  String get stockSearchHint => 'Search name, SKU or barcode';

  @override
  String get stockLocation => 'Location';

  @override
  String get stockColProduct => 'Product';

  @override
  String get stockColStock => 'Stock';

  @override
  String get stockColMinimum => 'Minimum';

  @override
  String get stockColValue => 'Value (COGS)';

  @override
  String get stockColSystem => 'System';

  @override
  String get stockColPhysical => 'Physical';

  @override
  String get stockColDifference => 'Difference';

  @override
  String get stockColReason => 'Reason';

  @override
  String get stockBadgeLow => 'Below minimum';

  @override
  String get stockBadgeNegative => 'Negative';

  @override
  String get stockEmpty => 'No goods yet. Add them under Products.';

  @override
  String get stockNoMatch => 'No matching products.';

  @override
  String stockValueTotal(String value) {
    return 'Stock value $value';
  }

  @override
  String get stockAdjustmentNew => 'New stock adjustment';

  @override
  String stockAdjustmentMeta(String number, String staff) {
    return '$number · $staff';
  }

  @override
  String get stockReasonLabel => 'General reason';

  @override
  String get stockReasonRoutineCheck => 'Routine check';

  @override
  String get stockReasonDamaged => 'Damaged';

  @override
  String get stockReasonLost => 'Lost';

  @override
  String get stockReasonExpired => 'Expired';

  @override
  String get stockReasonOther => 'Other';

  @override
  String get stockNoteLabel => 'Note';

  @override
  String get stockNoteHint => 'E.g. weekly routine check';

  @override
  String get stockLineNoteHint => 'Line reason';

  @override
  String get stockAddLabel => 'Scan / add product';

  @override
  String get stockAddHint => 'Scan a barcode or type a product name';

  @override
  String stockAddNotFound(String code) {
    return 'Product \"$code\" not found.';
  }

  @override
  String get stockAddAlready =>
      'This product is already in the adjustment list.';

  @override
  String get stockLinesEmpty =>
      'Add the products you counted, then enter their physical stock. Rows left empty are not saved.';

  @override
  String get stockTotal => 'Total';

  @override
  String get stockSave => 'Save adjustment';

  @override
  String get stockClear => 'Cancel';

  @override
  String stockSaved(String number) {
    return 'Adjustment $number saved.';
  }

  @override
  String get stockPermissionNote =>
      'Requires the stock:adjust permission. Recorded as stock movements with a reason, so it can be audited.';

  @override
  String get stockNoPermission =>
      'You can only view stock. Adjustments require the stock:adjust permission.';

  @override
  String get stockErrorEmpty =>
      'Enter the physical stock of at least one product.';

  @override
  String get stockErrorNegative => 'Physical stock cannot be negative.';

  @override
  String get stockErrorDuplicate => 'The same product appears twice.';

  @override
  String get stockErrorNotGoods => 'Services and menu items have no stock.';

  @override
  String get stockErrorUnknownVariant =>
      'The product was deleted or not found.';

  @override
  String get stockErrorUnknownLocation => 'Stock location not found.';

  @override
  String get stockErrorNoChange =>
      'No difference: physical stock equals system stock.';

  @override
  String get stockErrorNoteTooLong => 'The reason or note is too long.';

  @override
  String get stockErrorGeneric => 'The adjustment failed to save.';

  @override
  String get stockRecentTitle => 'Recent adjustments';

  @override
  String get stockRecentEmpty => 'No adjustments yet.';

  @override
  String stockRecentMeta(String reason, int count, String staff) {
    return '$reason · $count products · $staff';
  }

  @override
  String get stockCardTitle => 'Stock card';

  @override
  String stockCardCurrent(String stock, String minimum) {
    return 'Current stock $stock · minimum $minimum';
  }

  @override
  String stockCardCurrentNoMin(String stock) {
    return 'Current stock $stock';
  }

  @override
  String get stockCardProduct => 'Product';

  @override
  String get stockColTime => 'Time';

  @override
  String get stockColDescription => 'Description';

  @override
  String get stockColInOut => 'In/out';

  @override
  String get stockColBalance => 'Balance';

  @override
  String get stockCardEmpty => 'No movements yet.';

  @override
  String get stockCardNote =>
      'The stock card is a ledger of movements. The balance is never edited directly, only through new entries.';

  @override
  String stockCardOpening(String balance) {
    return 'Earlier balance $balance';
  }

  @override
  String get stockSourceOpening => 'Opening stock';

  @override
  String get stockSourceSale => 'Sale';

  @override
  String get stockSourceSaleReturn => 'Sales return';

  @override
  String get stockSourcePurchase => 'Purchase';

  @override
  String get stockSourcePurchaseReturn => 'Purchase return';

  @override
  String get stockSourceTransfer => 'Transfer';

  @override
  String get stockSourceAdjustment => 'Adjustment';

  @override
  String get stockMinimumTitle => 'Below minimum stock';

  @override
  String stockMinimumCount(int count) {
    return '$count products';
  }

  @override
  String get stockMinimumEmpty => 'All stock is above minimum.';

  @override
  String get stockMinimumPurchaseSoon =>
      'Purchase orders from this list will come with the Purchases module.';

  @override
  String get stockLocationsHint =>
      'Display, warehouse, or separate shelves in this branch.';

  @override
  String get stockLocationDefault => 'Default';

  @override
  String get stockLocationNameLabel => 'Location name';

  @override
  String get stockLocationAdd => 'Add location';

  @override
  String get stockLocationRename => 'Rename';

  @override
  String get stockLocationSave => 'Save';

  @override
  String get stockLocationCancel => 'Cancel';

  @override
  String get stockLocationErrorEmpty => 'Location name is required.';

  @override
  String get stockLocationErrorTooLong =>
      'Location name can have at most 40 characters.';

  @override
  String get stockLocationErrorDuplicate =>
      'This name is already used in this branch.';

  @override
  String get stockRemoveLine => 'Remove row';

  @override
  String get menuMasterData => 'Master data';

  @override
  String get masterTitle => 'Master data';

  @override
  String get masterSubtitle =>
      'Reference data used by products, stock, cashier & reports';

  @override
  String get masterTabCategories => 'Categories';

  @override
  String get masterTabUnits => 'Units';

  @override
  String get masterTabLocations => 'Stock locations';

  @override
  String get masterTabPayments => 'Payment methods';

  @override
  String get masterLoadFailed => 'Could not load master data.';

  @override
  String get masterCategoryAdd => 'Category';

  @override
  String get masterColCategory => 'Category';

  @override
  String get masterColProducts => 'Products';

  @override
  String get masterColActive => 'Active';

  @override
  String get masterCategoryEdit => 'Edit';

  @override
  String masterMoveUp(String name) {
    return 'Move $name up';
  }

  @override
  String masterMoveDown(String name) {
    return 'Move $name down';
  }

  @override
  String get masterOrderHint =>
      'This order is used for the category tabs on the cashier screen. Tap the arrows to move a category up or down.';

  @override
  String masterProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String get masterCategoryHidden => 'Hidden in cashier';

  @override
  String get masterCategoryInactive => 'Inactive';

  @override
  String get masterCategoryEmpty =>
      'No categories yet. Add one here or straight from the product form.';

  @override
  String get masterFormNew => 'New category';

  @override
  String get masterFormEdit => 'Edit category';

  @override
  String get masterFormName => 'Category name';

  @override
  String get masterFormParent => 'Parent category';

  @override
  String get masterFormParentNone => '(none)';

  @override
  String get masterFormParentLocked =>
      'This category has subcategories, so it cannot have a parent.';

  @override
  String get masterFormColor => 'Color';

  @override
  String get masterColorNone => 'No color';

  @override
  String masterColorPick(int number) {
    return 'Color $number';
  }

  @override
  String get masterFormShowInCashier => 'Show in cashier';

  @override
  String get masterFormShowInCashierHint =>
      'Appears as a category tab on the cashier screen.';

  @override
  String get masterFormActive => 'Active';

  @override
  String get masterFormActiveHint =>
      'Inactive categories are hidden in the cashier and not suggested in the product form; their products are still sold.';

  @override
  String get masterFormCancel => 'Cancel';

  @override
  String get masterFormSave => 'Save category';

  @override
  String get masterFormDelete => 'Delete category';

  @override
  String masterCategorySaved(String name) {
    return 'Category $name saved.';
  }

  @override
  String get masterErrNameEmpty => 'Category name is required.';

  @override
  String masterErrNameTooLong(int max) {
    return 'Category name can be at most $max characters.';
  }

  @override
  String get masterErrNameDuplicate => 'This category name is already used.';

  @override
  String get masterErrParentMissing => 'Parent category not found.';

  @override
  String get masterErrParentSelf => 'A category cannot be its own parent.';

  @override
  String get masterErrParentNested =>
      'The parent must be a top-level category (one level only).';

  @override
  String get masterErrHasChildren =>
      'A category with subcategories cannot have a parent.';

  @override
  String get masterErrColor => 'Pick a color from the palette.';

  @override
  String masterInUseProducts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
    );
    return 'Cannot delete: still used by $_temp0.';
  }

  @override
  String masterInUseChildren(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subcategories',
      one: '1 subcategory',
    );
    return 'Cannot delete: still has $_temp0.';
  }

  @override
  String get masterActionFailed => 'Could not save. Please try again.';

  @override
  String get masterUnitsHint =>
      'Units are used in the product form as base and conversion units. A rename shows up on every product right away.';

  @override
  String get masterUnitName => 'Unit name';

  @override
  String get masterUnitAdd => 'Add unit';

  @override
  String masterUnitRename(String name) {
    return 'Rename $name';
  }

  @override
  String masterUnitDelete(String name) {
    return 'Delete $name';
  }

  @override
  String get masterUnitSave => 'Save';

  @override
  String get masterUnitCancel => 'Cancel';

  @override
  String get masterUnitErrEmpty => 'Unit name is required.';

  @override
  String masterUnitErrTooLong(int max) {
    return 'Unit name can be at most $max characters.';
  }

  @override
  String get masterUnitErrDuplicate => 'This unit name is already used.';

  @override
  String get masterUnitEmpty =>
      'No units yet. Units are also created from the product form.';

  @override
  String get masterLocationsHint =>
      'Stock locations per branch (shop floor, warehouse). Add and rename them on the Stock screen.';

  @override
  String get masterLocationsManage => 'Manage in Stock';

  @override
  String get masterPaymentsHint =>
      'Payment methods available at the cashier. Static QRIS, receipts, and printers are set up in Settings.';

  @override
  String get masterPaymentsOpen => 'Open Settings';

  @override
  String get masterPaymentQrisHint => 'QRIS sticker image + Paid button';

  @override
  String get masterPaymentAlways => 'Always available';

  @override
  String masterInUseBoth(int products, int children) {
    String _temp0 = intl.Intl.pluralLogic(
      products,
      locale: localeName,
      other: '$products products',
      one: '1 product',
    );
    String _temp1 = intl.Intl.pluralLogic(
      children,
      locale: localeName,
      other: '$children subcategories',
      one: '1 subcategory',
    );
    return 'Cannot delete: still used by $_temp0 and has $_temp1.';
  }

  @override
  String masterDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get masterDeleteBody =>
      'Deleted data no longer appears in lists and pickers.';

  @override
  String get masterDeleteConfirm => 'Delete';

  @override
  String get masterDeleteCancel => 'Cancel';

  @override
  String get menuTables => 'Tables';

  @override
  String billTableLabel(String label) {
    return 'Table $label';
  }

  @override
  String billTakeAwayLabel(String label) {
    return 'Take away $label';
  }

  @override
  String paymentBillLines(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$label · $_temp0';
  }

  @override
  String get successBackToTables => 'Back to tables';

  @override
  String get receiptOrder => 'Order';

  @override
  String get receiptSubtotal => 'Subtotal';

  @override
  String receiptService(String pct) {
    return 'Service $pct';
  }

  @override
  String receiptTax(String pct) {
    return 'PB1 $pct';
  }

  @override
  String get cashierBillLoadFailed =>
      'Could not open the bill. It may already be paid or voided.';

  @override
  String get cashierBillBack => 'Back to tables';

  @override
  String get diningTitle => 'Tables';

  @override
  String diningSubtitle(String staff, int occupied, int total) {
    return 'Server: $staff · $occupied of $total tables occupied';
  }

  @override
  String get diningDineIn => 'Dine in';

  @override
  String get diningTakeAway => 'Take away';

  @override
  String get diningLegendEmpty => 'Empty';

  @override
  String get diningLegendOpen => 'Occupied · open bill';

  @override
  String get diningLegendRequested => 'Bill requested';

  @override
  String get diningAllAreas => 'All';

  @override
  String get diningNoArea => 'No area';

  @override
  String get diningNoTables =>
      'No tables yet. Add them in Master data › Tables & areas.';

  @override
  String diningSeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seats',
      one: '1 seat',
    );
    return '$_temp0';
  }

  @override
  String diningMinutes(int m) {
    return '$m min';
  }

  @override
  String diningHours(int h, int m) {
    return '$h h $m min';
  }

  @override
  String diningDays(int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '$d days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get diningTakeAwayNew => 'New take away';

  @override
  String get diningTakeAwayNone => 'No open take away orders.';

  @override
  String diningTakeAwayItems(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0 · $time';
  }

  @override
  String get diningStatusNew => 'New';

  @override
  String get diningStatusKitchen => 'In kitchen';

  @override
  String get diningStatusServed => 'Served';

  @override
  String get diningStatusReady => 'Ready';

  @override
  String get diningStatusEmpty => 'Empty';

  @override
  String get diningDeleteEmpty => 'Delete empty bill';

  @override
  String get diningSelectHint =>
      'Select a table or take away order to see its bill.';

  @override
  String diningBillTableTitle(String label) {
    return 'Table $label · Open bill';
  }

  @override
  String diningBillTakeAwayTitle(String label) {
    return '$label · Take away';
  }

  @override
  String diningBillGuests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '1 guest',
    );
    return '$_temp0';
  }

  @override
  String diningBillOpened(String time) {
    return 'opened $time';
  }

  @override
  String diningBillServer(String name) {
    return 'Server $name';
  }

  @override
  String get diningAddMenu => 'Menu';

  @override
  String get diningBillEmpty => 'No items yet. Tap + Menu to add some.';

  @override
  String get diningMarkServed => 'Mark served';

  @override
  String get diningRemoveItem => 'Remove item';

  @override
  String get diningSubtotal => 'Subtotal';

  @override
  String diningService(String pct) {
    return 'Service $pct (dine in)';
  }

  @override
  String diningTax(String pct) {
    return 'PB1 $pct';
  }

  @override
  String get diningTotal => 'Total';

  @override
  String diningSend(int count) {
    return 'Send to kitchen ($count new)';
  }

  @override
  String get diningRequestBill => 'Request bill';

  @override
  String get diningCancelRequest => 'Cancel bill request';

  @override
  String get diningMove => 'Move table';

  @override
  String get diningVoid => 'Void bill';

  @override
  String diningPay(String amount) {
    return 'Close & pay · $amount';
  }

  @override
  String get diningPayNoPermission =>
      'Payment is taken by a cashier (needs the sales permission).';

  @override
  String get diningBack => 'Back to tables';

  @override
  String diningOpenTitle(String label) {
    return 'Open table $label';
  }

  @override
  String get diningGuests => 'Guests';

  @override
  String get diningGuestsInvalid => 'Enter 1–99 guests.';

  @override
  String get diningOpen => 'Open bill';

  @override
  String get diningCancel => 'Cancel';

  @override
  String get diningCustomerName => 'Customer name (optional)';

  @override
  String get diningCreate => 'Create';

  @override
  String diningMoveTitle(String label) {
    return 'Move $label to';
  }

  @override
  String get diningMoveNone => 'No empty tables.';

  @override
  String diningVoidTitle(String label) {
    return 'Void bill $label?';
  }

  @override
  String get diningVoidBody =>
      'The bill is closed without payment and stock does not change. The reason is kept in history.';

  @override
  String get diningVoidReason => 'Reason';

  @override
  String get diningVoidReasonInvalid =>
      'A reason is required, at most 120 characters.';

  @override
  String get diningVoidKeep => 'Keep bill';

  @override
  String diningMenuTitle(String label) {
    return 'Add items · $label';
  }

  @override
  String get diningSearch => 'Search menu';

  @override
  String get diningNote => 'Kitchen note for the next item (optional)';

  @override
  String get diningNoteTooLong => 'Notes are at most 120 characters.';

  @override
  String diningAdded(String name) {
    return 'Added: $name';
  }

  @override
  String get diningDone => 'Done';

  @override
  String get diningNoMenu => 'No menu items found.';

  @override
  String get diningLoadFailed => 'Could not load tables.';

  @override
  String get diningErrorLocked =>
      'Items already in the kitchen cannot be changed or removed.';

  @override
  String get diningErrorOccupied => 'That table already has an open bill.';

  @override
  String get diningErrorNothingToSend => 'There are no new items to send.';

  @override
  String get diningErrorNotFound =>
      'The bill was not found or is already closed.';

  @override
  String get diningErrorNotEmpty => 'The bill still has items.';

  @override
  String get diningErrorUnavailable => 'That menu item is no longer available.';

  @override
  String get diningErrorInput => 'Invalid input.';

  @override
  String get diningErrorPermission =>
      'You do not have permission for this action.';

  @override
  String get diningErrorGeneric => 'The action failed. Please try again.';

  @override
  String get ticketDialogTitle => 'Sent to kitchen';

  @override
  String get ticketHeading => 'KITCHEN TICKET';

  @override
  String ticketDineIn(String label) {
    return 'Table $label · Dine in';
  }

  @override
  String ticketTakeAway(String label) {
    return '$label · Take away';
  }

  @override
  String get ticketNo => 'No';

  @override
  String get ticketTime => 'Time';

  @override
  String get ticketStaff => 'Server';

  @override
  String get ticketFooter => 'New items only · no prices';

  @override
  String get ticketPrint => 'Print ticket';

  @override
  String get ticketClose => 'Close';

  @override
  String get ticketPrinted => 'Ticket sent to the printer.';

  @override
  String get ticketPrintFailed =>
      'The ticket failed to print. Check the printer in Settings › Receipt & printer.';

  @override
  String get masterTabTables => 'Tables & areas';

  @override
  String get diningSetupHint =>
      'Tables are used on the Tables screen (F&B). Table names are unique per branch; areas are optional.';

  @override
  String get diningSetupAreas => 'Areas';

  @override
  String get diningSetupAreaAdd => 'Add area';

  @override
  String diningSetupAreaTables(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tables',
      one: '1 table',
    );
    return '$_temp0';
  }

  @override
  String get diningSetupAreasEmpty =>
      'No areas yet. For example: Indoor, Terrace, 2nd floor.';

  @override
  String get diningSetupTables => 'Tables';

  @override
  String get diningSetupTableAdd => 'Add table';

  @override
  String get diningSetupTableRange => 'Add several';

  @override
  String get diningSetupTablesEmpty =>
      'No tables yet. Use Add several to create T1–T12 at once.';

  @override
  String get diningSetupNoArea => 'No area';

  @override
  String get diningSetupName => 'Name';

  @override
  String get diningSetupArea => 'Area';

  @override
  String get diningSetupSeats => 'Seats';

  @override
  String get diningSetupPrefix => 'Prefix';

  @override
  String get diningSetupFrom => 'From';

  @override
  String get diningSetupTo => 'To';

  @override
  String diningSetupPreview(String names) {
    return 'Will create: $names';
  }

  @override
  String get diningSetupRangeInvalid => 'Invalid range (1–50 tables at once).';

  @override
  String get diningSetupNewArea => 'New area';

  @override
  String get diningSetupRenameArea => 'Rename area';

  @override
  String get diningSetupNewTable => 'New table';

  @override
  String get diningSetupEditTable => 'Edit table';

  @override
  String get diningSetupSave => 'Save';

  @override
  String get diningSetupCancel => 'Cancel';

  @override
  String get diningSetupDelete => 'Delete';

  @override
  String diningSetupDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get diningSetupDeleteBody =>
      'Deleted items no longer appear on the Tables screen.';

  @override
  String get diningSetupMoveUp => 'Move up';

  @override
  String get diningSetupMoveDown => 'Move down';

  @override
  String get diningSetupEdit => 'Edit';

  @override
  String get diningSetupErrNameEmpty => 'Name is required.';

  @override
  String diningSetupErrNameTooLong(int max) {
    return 'Names are at most $max characters.';
  }

  @override
  String get diningSetupErrNameDuplicate => 'That name is already used.';

  @override
  String diningSetupErrNameDuplicateAt(String name) {
    return 'The name $name is already used.';
  }

  @override
  String get diningSetupErrSeats => 'Seats must be 1–99.';

  @override
  String diningSetupErrAreaInUse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tables',
      one: '1 table',
    );
    return 'This area still has $_temp0. Move or delete them first.';
  }

  @override
  String get diningSetupErrTableBusy => 'This table still has an open bill.';

  @override
  String get diningSetupErrGeneric => 'The action failed. Please try again.';

  @override
  String get diningSetupLoadFailed => 'Could not load tables.';

  @override
  String get settingsSectionTaxes => 'Tax & service';

  @override
  String get fnbRatesTitle => 'Tax & service charge';

  @override
  String get fnbRatesSubtitle =>
      'Applies to open bills on the Tables screen at this branch.';

  @override
  String get fnbRatesService => 'Service charge (%)';

  @override
  String get fnbRatesServiceHint => '0–30%, steps of 0.5';

  @override
  String get fnbRatesTax => 'Restaurant tax / PB1 (%)';

  @override
  String get fnbRatesTaxHint => '0–20%, steps of 0.5';

  @override
  String get fnbRatesInvalidService => 'Enter 0–30 in steps of 0.5.';

  @override
  String get fnbRatesInvalidTax => 'Enter 0–20 in steps of 0.5.';

  @override
  String get fnbRatesNote =>
      'Service applies to dine in only. PB1 is calculated on subtotal + service.';

  @override
  String get fnbRatesPreview => 'Dine-in example';

  @override
  String get fnbRatesSave => 'Save rates';

  @override
  String get fnbRatesSaved => 'Rates saved.';

  @override
  String get fnbRatesLoadFailed => 'Could not load the rates.';

  @override
  String get fnbRatesSaveFailed => 'Could not save the rates.';

  @override
  String get masterTabModifiers => 'Modifier groups';

  @override
  String get modifierHint =>
      'Changes apply to new orders; old receipts keep a copy of modifier names & prices.';

  @override
  String get modifierGroups => 'Modifier groups';

  @override
  String get modifierAdd => 'Add group';

  @override
  String get modifierEmpty =>
      'No modifier groups yet. E.g. Size, Sugar level, Topping.';

  @override
  String get modifierLoadFailed => 'Modifier groups failed to load.';

  @override
  String modifierRuleRequired(int count) {
    return 'Required · pick $count';
  }

  @override
  String modifierRuleRequiredRange(int min, int max) {
    return 'Required · pick $min–$max';
  }

  @override
  String modifierRuleOptional(int max) {
    return 'Optional · max $max';
  }

  @override
  String modifierOptionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count options',
      one: '1 option',
    );
    return '$_temp0';
  }

  @override
  String modifierUsedBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'used by $count menus',
      one: 'used by 1 menu',
      zero: 'not used by any menu',
    );
    return '$_temp0';
  }

  @override
  String get modifierNewGroup => 'New modifier group';

  @override
  String get modifierEditGroup => 'Edit modifier group';

  @override
  String get modifierName => 'Group name';

  @override
  String get modifierRequired => 'Required';

  @override
  String get modifierRequiredHint =>
      'Customers must choose before the item goes on the bill.';

  @override
  String get modifierMin => 'Minimum';

  @override
  String get modifierMax => 'Maximum';

  @override
  String get modifierMaxHint => 'Maximum 1 shows as a single choice.';

  @override
  String get modifierOptions => 'Options';

  @override
  String get modifierOptionName => 'Option name';

  @override
  String get modifierOptionPrice => 'Extra price';

  @override
  String get modifierOptionPriceHint =>
      'Use minus for a discount, e.g. -3,000.';

  @override
  String get modifierOptionDefault => 'Default';

  @override
  String get modifierOptionAvailable => 'Available';

  @override
  String get modifierOptionSoldOut => 'Sold out';

  @override
  String get modifierOptionAdd => 'Add option';

  @override
  String get modifierOptionRemove => 'Remove option';

  @override
  String get modifierErrNameEmpty => 'Group name is required.';

  @override
  String modifierErrNameTooLong(int max) {
    return 'At most $max characters.';
  }

  @override
  String get modifierErrNameDuplicate => 'Group name is already used.';

  @override
  String modifierErrSelectRange(int max) {
    return 'Minimum must be ≤ maximum, maximum 1–$max.';
  }

  @override
  String get modifierErrMinAboveOptions =>
      'Minimum is more than the number of options.';

  @override
  String modifierErrOptionCount(int max) {
    return 'Add 1–$max options.';
  }

  @override
  String get modifierErrOptionNameEmpty => 'Option name is required.';

  @override
  String get modifierErrOptionNameDuplicate => 'Duplicate option name.';

  @override
  String get modifierErrOptionPrice =>
      'Extra price must be within ±IDR 1,000,000.';

  @override
  String get modifierErrDefaultsAboveMax =>
      'More default options than the maximum.';

  @override
  String modifierErrInUse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'The group is still used by $count menus. Remove it from the menu forms first.',
      one: 'The group is still used by 1 menu. Remove it from the menu form first.',
    );
    return '$_temp0';
  }

  @override
  String get modifierErrGeneric => 'Could not save. Try again.';

  @override
  String modifierDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get modifierDeleteBody =>
      'Its options are deleted too. Old receipts keep their copy.';

  @override
  String get productTabModifiers => 'Modifiers';

  @override
  String get productErrorModifierMissing =>
      'A modifier group was deleted. Remove it and save again.';

  @override
  String get productModifiersEmpty =>
      'No groups attached. The item goes straight to the bill without choices.';

  @override
  String get productModifiersHelp =>
      'The order here is the order on the modifier sheet in Tables.';

  @override
  String get productModifiersNoMaster =>
      'No modifier groups yet. Create them in Master data › Modifier groups.';

  @override
  String get productModifierAttach => 'Add group';

  @override
  String get productModifierRemove => 'Remove';

  @override
  String modifierSheetAdd(String total) {
    return 'Add to bill · $total';
  }

  @override
  String get modifierSheetQty => 'Quantity';

  @override
  String get modifierSheetLess => 'Decrease';

  @override
  String get modifierSheetMore => 'Increase';

  @override
  String get modifierSheetPriceInvalid =>
      'Modifier discounts exceed the item price.';

  @override
  String get modifierSheetNote => 'Note for the kitchen (optional)';

  @override
  String get diningErrorModifierRequired =>
      'Modifier choices are incomplete or invalid. Open the item again.';

  @override
  String get diningErrorModifierSoldOut =>
      'A modifier option is sold out. Choose another.';

  @override
  String get diningErrorModifierPrice =>
      'Modifier discounts exceed the item price.';

  @override
  String get diningSplit => 'Split bill';

  @override
  String diningSplitStatus(int paid, int total) {
    return 'Split · $paid of $total guests paid';
  }

  @override
  String diningContinueSplit(String amount) {
    return 'Continue split · $amount';
  }

  @override
  String get diningErrorSplitLocked =>
      'This bill is locked because part of it is paid. Continue on the Split bill screen.';

  @override
  String paymentPartSubtitle(String bill, String label) {
    return '$bill · Guest $label\'s part';
  }

  @override
  String paymentPartNext(String bill) {
    return '$bill · Next guest';
  }

  @override
  String get paymentPartWait => 'Save and wait for confirmation';

  @override
  String paymentPartDue(String label) {
    return 'Guest $label\'s part';
  }

  @override
  String get paymentPartBack => 'Back to split';

  @override
  String receiptGuestPayment(String label, String method) {
    return 'Guest $label · $method';
  }

  @override
  String get cashSessionErrorOpenSplit =>
      'A split bill is still partly paid. Settle it or cancel waiting parts before closing the session.';

  @override
  String billSplitTitle(String bill, int guests) {
    return 'Split bill · $bill · $guests guests';
  }

  @override
  String billSplitRates(String service, String tax) {
    return 'Service $service · Tax $tax';
  }

  @override
  String get billSplitRatesOff => 'Tax & service: off';

  @override
  String get billSplitChooseMode => 'Choose how to split the bill.';

  @override
  String get billSplitModeItem => 'By item';

  @override
  String get billSplitModeEqual => 'Split evenly';

  @override
  String get billSplitModeAmount => 'Custom amount';

  @override
  String get billSplitGuests => 'Guests';

  @override
  String get billSplitGuestLess => 'Remove a guest';

  @override
  String get billSplitGuestMore => 'Add a guest';

  @override
  String get billSplitItems => 'Items on the bill';

  @override
  String get billSplitItemsHint =>
      'Tap a guest to give them one portion. Items with more than 1 are split per portion.';

  @override
  String billSplitPortionPrice(String price) {
    return '$price each';
  }

  @override
  String billSplitUnassignedCount(int count) {
    return '$count portions have no guest yet.';
  }

  @override
  String billSplitGuest(String label) {
    return 'Guest $label';
  }

  @override
  String get billSplitGuestEmpty => 'No portions yet.';

  @override
  String get billSplitStatusUnpaid => 'Unpaid';

  @override
  String billSplitStatusPaid(String methods) {
    return 'Paid · $methods';
  }

  @override
  String get billSplitStatusPending => 'Static QRIS · waiting';

  @override
  String get billSplitCancelPayment => 'Cancel';

  @override
  String billSplitPay(String label) {
    return 'Pay part $label';
  }

  @override
  String billSplitNextGuest(String label) {
    return 'Next guest ($label)';
  }

  @override
  String get billSplitAmount => 'Amount';

  @override
  String billSplitAmountHint(String amount) {
    return 'Max $amount';
  }

  @override
  String get billSplitPayAmount => 'Pay';

  @override
  String get billSplitTotal => 'Bill total';

  @override
  String billSplitPaid(String labels) {
    return 'Paid ($labels)';
  }

  @override
  String billSplitPending(String labels) {
    return 'Awaiting confirmation ($labels)';
  }

  @override
  String get billSplitRemaining => 'Remaining';

  @override
  String get billSplitNote =>
      'The bill stays open until every part is paid. Each part is recorded as a payment on the same receipt, so reports and stock stay in one piece.';

  @override
  String get billSplitCancel => 'Cancel split';

  @override
  String get billSplitLocked =>
      'The split is locked because a part is already paid. Cancel waiting QRIS parts to change it.';

  @override
  String get billSplitDone => 'Bill paid';

  @override
  String billSplitDoneBody(String number) {
    return 'Every part is paid. Receipt $number is saved.';
  }

  @override
  String get billSplitLoadFailed => 'The split bill couldn\'t be loaded.';

  @override
  String get billSplitErrorLocked =>
      'A part is already paid; the split can\'t be changed.';

  @override
  String get billSplitErrorGuests => 'Guests must be 2–8.';

  @override
  String get billSplitErrorUnassigned =>
      'Assign every portion to a guest first.';

  @override
  String get billSplitErrorPartPaid => 'This guest has already paid.';

  @override
  String get billSplitErrorAmount =>
      'The amount must be above 0 and at most the remaining balance.';

  @override
  String get billSplitErrorNothingDue => 'This guest has nothing to pay.';

  @override
  String get billSplitErrorPending => 'Only QRIS can wait for confirmation.';

  @override
  String get billSplitErrorGeneric =>
      'The split bill action failed. Try again.';

  @override
  String diningVoidSplitPaid(String amount) {
    return 'Parts already paid ($amount) are returned to the guests and not counted in the cash session.';
  }

  @override
  String get floorErrorImageTooLarge =>
      'The floor plan image is larger than 5 MB.';

  @override
  String get floorErrorImageFormat =>
      'Unsupported format. Use PNG, JPG, WebP, or SVG.';

  @override
  String get floorErrorNameEmpty => 'Table name is required.';

  @override
  String get floorErrorNameTooLong =>
      'Table name can be at most 20 characters.';

  @override
  String get floorErrorNameDuplicate =>
      'This table name is already used at this branch.';

  @override
  String get floorErrorSeats => 'Seats must be 1 to 99.';

  @override
  String get floorErrorSize => 'Width and height must be 20 to 600.';

  @override
  String get floorErrorPosition => 'The table is outside the floor plan.';

  @override
  String get floorErrorInUse => 'A deleted table still has an open bill.';

  @override
  String get floorErrorPermission => 'Requires the Manage settings permission.';

  @override
  String get floorErrorGeneric => 'Could not save the layout. Try again.';

  @override
  String floorErrorOn(String table, String message) {
    return '$table: $message';
  }

  @override
  String get floorShapeRound => 'Round';

  @override
  String get floorShapeSquare => 'Square';

  @override
  String get floorShapeLong => 'Long';

  @override
  String get floorShapeBar => 'Bar seat';

  @override
  String get floorDiscardTitle => 'Discard changes?';

  @override
  String get floorDiscardBody => 'Unsaved layout changes will be lost.';

  @override
  String get floorDiscardKeep => 'Cancel';

  @override
  String get floorDiscardConfirm => 'Discard';

  @override
  String get floorLoadFailed => 'Could not load the floor plan.';

  @override
  String get floorBack => 'Back';

  @override
  String get floorNoArea =>
      'No areas yet. Add one first, e.g. Indoor or Terrace.';

  @override
  String get floorTitle => 'Arrange floor plan';

  @override
  String get floorSubtitle => 'Settings › Tables & areas (F&B)';

  @override
  String get floorAddArea => '+ Area';

  @override
  String get floorAddAreaTitle => 'New area';

  @override
  String get floorAreaName => 'Area name';

  @override
  String get floorAddAreaSave => 'Add';

  @override
  String get floorGridInfoTitle => 'Grid mode';

  @override
  String floorGridInfoBody(String area) {
    return 'Tables in $area show as an ordered grid on the Tables screen. Choose Floor plan to upload a floor plan and place tables.';
  }

  @override
  String floorSeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seats',
      one: '1 seat',
    );
    return '$_temp0';
  }

  @override
  String get floorUndo => 'Undo';

  @override
  String get floorRedo => 'Redo';

  @override
  String get floorReplaceImage => 'Replace floor plan image';

  @override
  String get floorOpacity => 'Plan opacity';

  @override
  String floorSnap(int size) {
    return 'Snap to $size px grid';
  }

  @override
  String floorZoom(int percent) {
    return 'Zoom $percent%';
  }

  @override
  String get floorZoomIn => 'Zoom in';

  @override
  String get floorZoomOut => 'Zoom out';

  @override
  String get floorZoomFit => 'Fit to screen';

  @override
  String floorUploadTitle(String area) {
    return 'Upload a floor plan for $area';
  }

  @override
  String get floorUploadBody =>
      'A photo of a hand sketch, an export from a floor plan app, or an architect drawing. PNG / JPG / WebP / SVG, up to 5 MB.';

  @override
  String get floorPickFile => 'Choose file';

  @override
  String get floorTakePhoto => 'Take photo';

  @override
  String get floorTipsTitle => 'Image tips';

  @override
  String get floorTipAngle => 'Viewpoint';

  @override
  String get floorTipAngleValue => 'From above, straight';

  @override
  String get floorTipSize => 'Size';

  @override
  String get floorTipSizeValue => 'At least 1200 px wide';

  @override
  String get floorTipContent => 'Contents';

  @override
  String get floorTipContentValue => 'Walls, doors, kitchen, bar';

  @override
  String get floorTipStorage =>
      'The image is stored on this device. With hosting, it is uploaded to object storage like product photos.';

  @override
  String get floorTipGrid =>
      'No floor plan? Choose Grid mode. Tables show as usual and you can switch any time.';

  @override
  String floorPreset(String shape, int seats) {
    String _temp0 = intl.Intl.pluralLogic(
      seats,
      locale: localeName,
      other: '$seats seats',
      one: '1 seat',
    );
    return '$shape · $_temp0';
  }

  @override
  String get floorAddTable => 'Add table';

  @override
  String get floorAddTableHint =>
      'Tap to place a table in the middle of the view.';

  @override
  String get floorUnplaced => 'Not placed yet';

  @override
  String get floorUnplacedHint =>
      'Tables from grid mode without a position. Tap to place.';

  @override
  String get floorUnplacedNone => 'All tables are placed.';

  @override
  String floorModeTitle(String area) {
    return 'Layout mode · $area';
  }

  @override
  String get floorModeGrid => 'Grid';

  @override
  String get floorModeGridHint =>
      'No floor plan. Tables show as an ordered grid.';

  @override
  String get floorModeFloor => 'Floor plan';

  @override
  String get floorModeFloorHint =>
      'Upload a floor plan, then place the tables.';

  @override
  String floorSelected(String name) {
    return 'Table $name selected';
  }

  @override
  String get floorSelectHint =>
      'Tap a table on the plan to edit its name, seats, shape, and size.';

  @override
  String get floorName => 'Name';

  @override
  String get floorSeatsLabel => 'Seats';

  @override
  String get floorShape => 'Shape';

  @override
  String get floorWidth => 'Width';

  @override
  String get floorHeight => 'Height';

  @override
  String get floorOrientation => 'Orientation';

  @override
  String get floorHorizontal => 'Horizontal';

  @override
  String get floorVertical => 'Vertical';

  @override
  String get floorCanMerge => 'Can be joined with the next table';

  @override
  String get floorDelete => 'Delete table';

  @override
  String get floorUnsaved => 'You have unsaved changes.';

  @override
  String get floorSave => 'Save layout';

  @override
  String get floorSaving => 'Saving…';

  @override
  String get diningLayoutGrid => 'Grid';

  @override
  String get diningLayoutFloor => 'Floor plan';

  @override
  String get diningArrange => 'Arrange floor plan';

  @override
  String get diningFloorLocked => 'Positions locked · pan & zoom only';

  @override
  String get diningUnplaced => 'Not placed yet';

  @override
  String get diningNoFloorArea => 'No area uses a floor plan yet.';

  @override
  String get approvalTitle => 'Manager approval';

  @override
  String get approvalStaff => 'Approver';

  @override
  String get approvalPin => 'Approver PIN';

  @override
  String get approvalCancel => 'Cancel';

  @override
  String get approvalSubmit => 'Approve';

  @override
  String get approvalNone =>
      'No other staff with this permission and a PIN at this branch.';

  @override
  String get approvalNotPermitted =>
      'This staff member is not allowed to do this.';

  @override
  String get approvalVoidSale =>
      'Voiding a sale needs the sales:void permission. Ask an authorised staff member to enter their PIN.';

  @override
  String get approvalVoidBill =>
      'Cancelling a bill needs the sales:void permission. Ask an authorised staff member to enter their PIN.';

  @override
  String get historyTitle => 'Sales history';

  @override
  String get historyLoadFailed => 'Could not load the history.';

  @override
  String historySummary(String range, int count, String total) {
    return '$range · $count sales · $total';
  }

  @override
  String get historyExport => 'Export to Excel';

  @override
  String historyExportSaved(String path) {
    return 'Excel file saved to $path';
  }

  @override
  String get historyExportFailed => 'Export failed. Try again.';

  @override
  String get historyEmpty => 'No sales match this filter.';

  @override
  String get historyPickSale =>
      'Pick a sale to see its details, return items, reprint or void it.';

  @override
  String get historyRangeToday => 'Today';

  @override
  String get historyRangeYesterday => 'Yesterday';

  @override
  String get historyRangeWeek => '7 days';

  @override
  String get historyFilterStaff => 'Cashier';

  @override
  String get historyFilterAllStaff => 'All cashiers';

  @override
  String get historyFilterMethod => 'Method';

  @override
  String get historyFilterAllMethods => 'All methods';

  @override
  String get historyFilterStatus => 'Status';

  @override
  String get historyStatusAll => 'All statuses';

  @override
  String get historyStatusCompleted => 'Completed';

  @override
  String get historyStatusPartial => 'Partly returned';

  @override
  String get historyStatusReturned => 'Returned';

  @override
  String get historyStatusReturnedAny => 'Returned';

  @override
  String get historyStatusVoided => 'Voided';

  @override
  String get historyColNumber => 'Receipt';

  @override
  String get historyColDate => 'Date';

  @override
  String get historyColTime => 'Time';

  @override
  String get historyColStaff => 'Cashier';

  @override
  String get historyColMethod => 'Method';

  @override
  String get historyColTotal => 'Total';

  @override
  String get historyColReturned => 'Returned';

  @override
  String get historyColNet => 'Net';

  @override
  String get historyColStatus => 'Status';

  @override
  String get historyBack => 'Back';

  @override
  String get historyTotalOriginal => 'Original total';

  @override
  String get historyReturnedTotal => 'Returned';

  @override
  String get historyNet => 'Net value';

  @override
  String historyVoidedBy(String name, String reason) {
    return 'Voided by $name: $reason';
  }

  @override
  String get historyItems => 'Items';

  @override
  String historyItemReturned(String qty) {
    return '$qty returned';
  }

  @override
  String get historyReturnAll => 'Return all';

  @override
  String historyReturnQty(String left) {
    return 'Return quantity ($left left)';
  }

  @override
  String get historyReturns => 'Returns';

  @override
  String get historyReturnTitle => 'Return items';

  @override
  String get historyReturnReason => 'Reason';

  @override
  String get historyReasonDamaged => 'Damaged';

  @override
  String get historyReasonWrongItem => 'Wrong item';

  @override
  String get historyReasonExpired => 'Expired';

  @override
  String get historyReasonOther => 'Other';

  @override
  String get historyReturnNote => 'Note (optional)';

  @override
  String get historyReturnNoteRequired => 'Note (required)';

  @override
  String get historyRefundMethod => 'Refund';

  @override
  String get historyRefundCash => 'Cash from drawer';

  @override
  String get historyRefundTransfer => 'Transfer';

  @override
  String get historyRefundDebt => 'Deduct from credit';

  @override
  String get historyRefundCashNeedsSession =>
      'Cash refunds need an open cash session on this device.';

  @override
  String get historyRestock => 'Put items back in stock';

  @override
  String historyReturnSubmit(String amount) {
    return 'Process return · $amount';
  }

  @override
  String get historyReprint => 'Reprint receipt';

  @override
  String get historyClose => 'Close';

  @override
  String get historyVoid => 'Void sale';

  @override
  String get historyVoidHint =>
      'Needs the sales:void permission (manager PIN). Voiding reverses stock and payment with new entries; old data is kept.';

  @override
  String historyVoidTitle(String number) {
    return 'Void receipt $number?';
  }

  @override
  String get historyVoidBody =>
      'Stock is restored and the sale no longer counts in the session recap.';

  @override
  String get historyVoidReason => 'Void reason';

  @override
  String get historyVoidKeep => 'Keep sale';

  @override
  String get historyVoidBlockStatus =>
      'This sale is already voided or returned.';

  @override
  String get historyVoidBlockReturned =>
      'A sale with returns cannot be voided.';

  @override
  String get historyVoidBlockNotToday => 'Only today\'s sales can be voided.';

  @override
  String get historyVoidBlockSession =>
      'Only sales in this device\'s open cash session can be voided.';

  @override
  String get historyErrReturnEmpty =>
      'Enter a return quantity for at least one item.';

  @override
  String get historyErrReturnQuantity =>
      'Return quantity exceeds what is left.';

  @override
  String get historyErrReturnNote =>
      'A note is required for Other (max 200 characters).';

  @override
  String get historyErrReturnStatus => 'This sale can no longer be returned.';

  @override
  String get historyErrRefundMethod =>
      'This refund method is not available yet.';

  @override
  String get historyErrNoSession =>
      'Open a cash session first for cash refunds.';

  @override
  String get historyErrVoidReason =>
      'A reason is required (max 120 characters).';

  @override
  String get historyErrNotPermitted => 'You are not allowed to do this.';

  @override
  String get historyErrNotFound => 'Receipt not found.';

  @override
  String get historyErrGeneric => 'Something went wrong. Try again.';

  @override
  String get receiptBannerReprint => 'REPRINT';

  @override
  String get receiptBannerVoid => 'VOID';

  @override
  String get receiptReturned => 'Returned';

  @override
  String get receiptNet => 'Net';

  @override
  String get stockNoteVoid => 'Sale voided';

  @override
  String get purchasesTitle => 'Purchases';

  @override
  String get purchasesSubtitle =>
      'Goods received from suppliers, including purchase returns';

  @override
  String get purchasesNew => 'New purchase';

  @override
  String get purchasesTabPurchases => 'Purchases';

  @override
  String get purchasesTabReturns => 'Purchase returns';

  @override
  String get purchasesSearch => 'Search number / supplier';

  @override
  String get purchasesColNumber => 'Number';

  @override
  String get purchasesColSupplier => 'Supplier';

  @override
  String get purchasesColTotal => 'Total';

  @override
  String get purchasesColStatus => 'Status';

  @override
  String get purchasesColValue => 'Value';

  @override
  String get purchasesColSource => 'Original purchase';

  @override
  String get purchasesStatusDraft => 'Draft';

  @override
  String get purchasesStatusPaid => 'Paid';

  @override
  String get purchasesStatusDebt => 'Payable';

  @override
  String get purchasesDraftTag => 'draft';

  @override
  String get purchasesReturnTag => 'return';

  @override
  String get purchasesNoSupplier => 'No supplier';

  @override
  String get purchasesEmpty => 'No purchases yet.';

  @override
  String get purchasesReturnsEmpty => 'No purchase returns yet.';

  @override
  String get purchasesLoadFailed => 'Purchases failed to load.';

  @override
  String purchaseFormNew(String number) {
    return 'New purchase · $number';
  }

  @override
  String purchaseFormDraft(String number) {
    return 'Draft · $number';
  }

  @override
  String get purchaseSupplier => 'Supplier';

  @override
  String get purchaseSupplierNew => '+ New supplier';

  @override
  String get purchaseSupplierNewName => 'New supplier name';

  @override
  String get purchaseSupplierPick => 'Pick from the list';

  @override
  String get purchaseInvoiceNo => 'Supplier invoice no.';

  @override
  String get purchaseDate => 'Date';

  @override
  String get purchaseLocation => 'Receive into';

  @override
  String get purchaseColProduct => 'Product';

  @override
  String get purchaseColUnit => 'Unit';

  @override
  String get purchaseColQty => 'Qty';

  @override
  String get purchaseColPrice => 'Cost price';

  @override
  String get purchaseColSubtotal => 'Subtotal';

  @override
  String get purchaseRemoveLine => 'Remove line';

  @override
  String get purchaseScan => '+ Scan / search product';

  @override
  String get purchaseScanHint => 'Barcode, SKU or product name';

  @override
  String purchaseScanNotFound(String code) {
    return 'Product \"$code\" not found.';
  }

  @override
  String get purchaseNoLines =>
      'No products yet. Scan a barcode or search by name.';

  @override
  String get purchasePaidNow => 'Pay now';

  @override
  String get purchasePayInFull => 'Pay in full';

  @override
  String get purchaseFundingFrom => 'From';

  @override
  String get fundingStoreCash => 'Store cash';

  @override
  String get fundingDrawer => 'Cash drawer';

  @override
  String get fundingBank => 'Bank account';

  @override
  String get purchaseDueOn => 'Balance due on';

  @override
  String get purchaseNote => 'Note';

  @override
  String get purchaseSubtotal => 'Subtotal';

  @override
  String get purchaseDiscount => 'Invoice discount';

  @override
  String get purchaseShipping => 'Shipping';

  @override
  String get purchaseTotal => 'Total';

  @override
  String get purchaseDebtLeft => 'Balance becomes payable';

  @override
  String get purchaseSaveDraft => 'Save draft';

  @override
  String get purchaseReceive => 'Receive goods & save';

  @override
  String get purchaseDeleteDraft => 'Delete draft';

  @override
  String purchaseReceiveNote(String location) {
    return 'On save: $location stock increases (ledger), the average cost is updated, and the supplier payable is recorded.';
  }

  @override
  String purchaseDraftSaved(String number) {
    return 'Draft $number saved.';
  }

  @override
  String get purchaseErrLines => 'Add at least one product.';

  @override
  String get purchaseErrQty => 'Qty must be more than 0.';

  @override
  String get purchaseErrPrice => 'Invalid cost price.';

  @override
  String get purchaseErrDiscount => 'The discount can\'t exceed the subtotal.';

  @override
  String get purchaseErrShipping => 'Invalid shipping cost.';

  @override
  String get purchaseErrPaid => 'Payment can\'t exceed the total.';

  @override
  String get purchaseErrSupplier =>
      'Choose or type a supplier for a purchase on credit.';

  @override
  String get purchaseErrDueOn =>
      'Set a due date, not before the purchase date.';

  @override
  String purchaseErrInvoiceNo(int max) {
    return 'Invoice no. is at most $max characters.';
  }

  @override
  String purchaseErrNote(int max) {
    return 'The note is at most $max characters.';
  }

  @override
  String get purchaseErrDrawer =>
      'Paying from the cash drawer needs an open cashier session on this device.';

  @override
  String get purchaseErrNotEditable =>
      'This purchase was already received and can\'t be changed.';

  @override
  String get purchaseErrNotFound => 'Purchase not found.';

  @override
  String get purchaseErrNotPermitted =>
      'You don\'t have permission to manage purchases.';

  @override
  String get purchaseErrGeneric =>
      'The purchase couldn\'t be saved. Try again.';

  @override
  String purchaseFrom(String supplier) {
    return 'Purchase from $supplier';
  }

  @override
  String get purchaseBadgePaid => 'Paid';

  @override
  String get purchaseBadgeDebt => 'Unpaid · payable';

  @override
  String get purchaseCreatedBy => 'Created by';

  @override
  String get purchaseReceivedTitle => 'Goods received';

  @override
  String purchaseReceivedSubtitle(String location) {
    return '$location stock increased through the ledger when the purchase was saved';
  }

  @override
  String get purchaseColAvgCost => 'Average cost';

  @override
  String get purchaseColSellPrice => 'Sell price';

  @override
  String get purchaseColSuggested => 'Suggested price';

  @override
  String get purchaseColChangePrice => 'Change price';

  @override
  String get purchaseBelowSuggested => 'Below suggestion';

  @override
  String get purchaseSafe => 'OK';

  @override
  String purchaseApplyPrices(int count) {
    return 'Apply sell price ($count products)';
  }

  @override
  String get purchasePricesApplied => 'Sell prices updated.';

  @override
  String get purchaseAvgCostNote =>
      'Average cost uses a weighted moving average in the base unit. The suggested price keeps the margin of the sell price at receipt. Tick \"Change price\", then Apply sell price.';

  @override
  String get purchaseSummary => 'Summary';

  @override
  String get purchasePaidSoFar => 'Paid';

  @override
  String get purchaseReturned => 'Returned';

  @override
  String get purchaseDebt => 'Balance payable';

  @override
  String purchaseDueIn(String date, int days) {
    return 'Due $date (in $days days).';
  }

  @override
  String purchaseDueToday(String date) {
    return 'Due $date (today).';
  }

  @override
  String purchaseOverdue(String date, int days) {
    return 'Due $date ($days days overdue).';
  }

  @override
  String get purchasePayments => 'Payments';

  @override
  String get purchasePaymentDate => 'Date';

  @override
  String get purchasePaymentDesc => 'Description';

  @override
  String get purchasePaymentFrom => 'From';

  @override
  String get purchasePaymentAmount => 'Amount';

  @override
  String get purchaseDownPayment => 'Down payment';

  @override
  String purchaseReturnReduction(String number) {
    return 'Return $number (reduces payable)';
  }

  @override
  String purchaseReturnRefund(String number) {
    return 'Return $number (refund)';
  }

  @override
  String get purchaseNoPayments => 'No payments yet.';

  @override
  String get purchasePayDebt => 'Pay payable';

  @override
  String get purchaseActions => 'Actions';

  @override
  String get purchaseReturnAction => 'Purchase return';

  @override
  String get purchaseReturnActionNote =>
      'Creates an RB-… document that reduces stock and the payable. A received purchase can\'t be deleted, only returned.';

  @override
  String get purchaseReturnTitle => 'Purchase return';

  @override
  String purchaseReturnRemaining(String qty) {
    return 'Left $qty';
  }

  @override
  String get purchaseReturnQty => 'Return qty';

  @override
  String get purchaseReturnNote => 'Return note';

  @override
  String get purchaseRefundTo => 'Refund to';

  @override
  String purchaseReturnSplit(String debt, String refund) {
    return 'Reduces payable $debt · refund $refund';
  }

  @override
  String purchaseReturnSubmit(String amount) {
    return 'Process return · $amount';
  }

  @override
  String get purchaseReturnCancel => 'Cancel';

  @override
  String get purchaseReturnErrEmpty =>
      'Enter a return qty for at least one item.';

  @override
  String get purchaseReturnErrQty => 'The return qty exceeds what\'s left.';

  @override
  String get purchaseReturnErrStock =>
      'There isn\'t enough stock at the purchase location to return.';

  @override
  String get purchaseReturnErrRefund => 'Choose where the refund goes.';

  @override
  String get purchaseReturnErrStatus =>
      'Only received purchases can be returned.';

  @override
  String purchaseReturnDone(String number) {
    return 'Return $number recorded.';
  }

  @override
  String get purchaseReturnsMade => 'Returns made';

  @override
  String get purchaseDetailLoadFailed => 'The purchase details failed to load.';

  @override
  String get purchaseErrLocation =>
      'Stock location not found. Choose another location.';

  @override
  String get purchaseRefundToHint => 'Choose cash or account';

  @override
  String get customersTitle => 'Customers & receivables';

  @override
  String customersSubtitle(int count) {
    return '$count customers · receivables tracked per invoice';
  }

  @override
  String get customersImport => 'Import Excel';

  @override
  String get customersNew => 'Customer';

  @override
  String get customersSearch => 'Search name or phone';

  @override
  String get customersColCustomer => 'Customer';

  @override
  String get customersColGroup => 'Group';

  @override
  String get customersColDebt => 'Receivable';

  @override
  String get customersEmpty =>
      'No customers yet. Add one or import from Excel.';

  @override
  String get customersNoMatch => 'No matching customers.';

  @override
  String get customersLoadFailed => 'Couldn\'t load customers.';

  @override
  String get customersSelectHint =>
      'Select a customer to see receivables and receive payments.';

  @override
  String get customersTotalDebt => 'Total receivables';

  @override
  String customersTotalDebtSub(int debtors, int overdue) {
    return '$debtors customers · $overdue invoices overdue';
  }

  @override
  String customerOverdueCount(int count) {
    return '$count overdue';
  }

  @override
  String customerGroupLabel(String group) {
    return '$group group';
  }

  @override
  String customerSince(String date) {
    return 'customer since $date';
  }

  @override
  String get customerEdit => 'Edit';

  @override
  String get customerLimit => 'Credit limit';

  @override
  String get customerDebt => 'Receivable';

  @override
  String get customerRemaining => 'Remaining limit';

  @override
  String get customerReceiveTitle => 'Receive payment';

  @override
  String get customerAmount => 'Amount received';

  @override
  String get customerPayAll => 'Pay in full';

  @override
  String get customerMethod => 'Method';

  @override
  String get customerPaidOn => 'Date';

  @override
  String get customerNoteOptional => 'Note (optional)';

  @override
  String get customerCashDrawerHint =>
      'Cash goes into the open cashier session\'s drawer.';

  @override
  String get customerCashStoreHint =>
      'No open cashier session: cash is recorded as store cash.';

  @override
  String get customerColInvoice => 'Invoice';

  @override
  String get customerColDue => 'Due';

  @override
  String get customerColTotal => 'Total';

  @override
  String get customerColRest => 'Balance';

  @override
  String get customerColAllocation => 'Allocation';

  @override
  String get customerTotalRow => 'Total';

  @override
  String customerDueShort(String date) {
    return 'due $date';
  }

  @override
  String get customerOverdue => 'Overdue';

  @override
  String customerAutoHint(String name, String amount) {
    return 'Allocated to the oldest invoices first. After saving, $name\'s balance will be $amount.';
  }

  @override
  String get customerManualHint =>
      'Manual allocation: enter an amount per invoice. The total must equal the amount received.';

  @override
  String get customerManual => 'Allocate manually';

  @override
  String get customerAuto => 'Allocate automatically';

  @override
  String get customerSaveAndPrint => 'Save & print receipt';

  @override
  String get customerNoDebt => 'This customer has no outstanding receivables.';

  @override
  String get customerPayments => 'Payment history';

  @override
  String get customerNoPayments => 'No receivable payments yet.';

  @override
  String get customerDelete => 'Delete customer';

  @override
  String customerDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get customerDeleteBody =>
      'The customer is removed from the list. Past invoices and payments are kept.';

  @override
  String get customerDeleteAction => 'Delete';

  @override
  String get customerCancel => 'Cancel';

  @override
  String get customerSave => 'Save';

  @override
  String get customerFormNew => 'New customer';

  @override
  String get customerFormEdit => 'Edit customer';

  @override
  String get customerFieldName => 'Name';

  @override
  String get customerFieldPhone => 'Phone (optional)';

  @override
  String get customerFieldGroup => 'Group';

  @override
  String get customerGroupNone => 'No group (14-day term)';

  @override
  String customerGroupOption(String name, int days) {
    return '$name · $days-day term';
  }

  @override
  String get customerGroupNew => '+ New group';

  @override
  String get customerFieldNewGroup => 'New group name';

  @override
  String get customerNewGroupHint => 'e.g. Wholesale';

  @override
  String get customerFieldLimit => 'Credit limit';

  @override
  String get customerLimitHint => '0 = no credit sales allowed.';

  @override
  String get customerFieldAddress => 'Address (optional)';

  @override
  String get customerFieldNote => 'Note (optional)';

  @override
  String customerErrName(int max) {
    return 'Name is required, up to $max characters.';
  }

  @override
  String get customerErrPhone => 'Phone number must be 8–15 digits.';

  @override
  String get customerErrPhoneTaken =>
      'This phone number belongs to another customer.';

  @override
  String customerErrAddress(int max) {
    return 'Address can be up to $max characters.';
  }

  @override
  String customerErrNote(int max) {
    return 'Note can be up to $max characters.';
  }

  @override
  String customerErrGroup(int max) {
    return 'Group name is required, up to $max characters.';
  }

  @override
  String get customerErrLimit => 'Credit limit can\'t be negative.';

  @override
  String get customerErrHasDebt =>
      'This customer still has receivables; settle them before deleting.';

  @override
  String get customerErrNotFound => 'Customer not found.';

  @override
  String get customerErrNotPermitted =>
      'You don\'t have permission for this action.';

  @override
  String get customerErrGeneric => 'Couldn\'t save. Try again.';

  @override
  String get debtErrAmount => 'Enter an amount above 0.';

  @override
  String get debtErrOver => 'The amount exceeds the total receivable.';

  @override
  String get debtErrAllocation =>
      'An allocation can\'t exceed that invoice\'s balance.';

  @override
  String get debtErrAllocationTotal =>
      'Allocations must add up to the amount received.';

  @override
  String get debtErrDate => 'The payment date can\'t be in the future.';

  @override
  String get debtErrMethod =>
      'This method can\'t be used for receivable payments.';

  @override
  String get debtMethodCashDrawer => 'Cash · cash drawer';

  @override
  String get debtMethodCashStore => 'Cash · store cash';

  @override
  String groupErrName(int max) {
    return 'Group name is required, up to $max characters.';
  }

  @override
  String groupErrTerm(int max) {
    return 'Term must be 0–$max days.';
  }

  @override
  String get groupErrTaken => 'A group with this name already exists.';

  @override
  String get groupErrInUse => 'The group still has customers; move them first.';

  @override
  String get groupErrNotFound => 'Group not found.';

  @override
  String get creditNoLimit =>
      'This customer has no credit limit. Set one in Customers.';

  @override
  String get creditErrDownPayment =>
      'The down payment must be 0 or more and less than the invoice total.';

  @override
  String get creditErrDueOn => 'The due date can\'t be before today.';

  @override
  String get creditErrOverLimit =>
      'Current plus new receivable exceeds the credit limit.';

  @override
  String get importTitle => 'Import customers';

  @override
  String get importIntro =>
      'Choose an Excel (.xlsx) or CSV file. Columns: Name (required), Phone, Address, Group, Limit, Note. Headers can be in Indonesian or English.';

  @override
  String get importPick => 'Choose file';

  @override
  String get importTooLarge => 'The file is larger than 2 MB.';

  @override
  String get importUnreadable =>
      'The file can\'t be read. Save it as .xlsx or .csv and try again.';

  @override
  String get importMissingName => 'No Name column found in the header row.';

  @override
  String get importEmpty => 'The file has no customer rows.';

  @override
  String importReady(int count) {
    return '$count rows ready to import.';
  }

  @override
  String get importUpdateNote =>
      'Rows with a registered phone number update that customer; new groups are created automatically.';

  @override
  String importRejected(int count) {
    return '$count rows skipped:';
  }

  @override
  String importRejectLine(int line, String reason) {
    return 'Row $line: $reason';
  }

  @override
  String importMoreRejected(int count) {
    return '…and $count more rows.';
  }

  @override
  String get importReasonName => 'name empty or too long';

  @override
  String get importReasonPhone => 'invalid phone number';

  @override
  String get importReasonLimit => 'limit is not a number';

  @override
  String get importReasonText => 'text too long';

  @override
  String get importReasonDuplicate => 'phone number repeated in the file';

  @override
  String importRun(int count) {
    return 'Import $count customers';
  }

  @override
  String importDone(int created, int updated) {
    return 'Done: $created new customers, $updated updated.';
  }

  @override
  String get importClose => 'Close';

  @override
  String kuitansiCrumb(String number) {
    return 'Receipt $number';
  }

  @override
  String get kuitansiSavedTitle => 'Receivable payment saved';

  @override
  String kuitansiSubtitle(String amount, String customer, int count) {
    return '$amount from $customer allocated to $count invoices';
  }

  @override
  String get kuitansiSaved => 'Saved';

  @override
  String get kuitansiBack => 'Back to customer';

  @override
  String get kuitansiPreviewA5 => 'A5 / PDF preview';

  @override
  String kuitansiPreviewThermal(String paper) {
    return '$paper receipt preview';
  }

  @override
  String get kuitansiPanelTitle => 'Receipt';

  @override
  String get kuitansiPanelSub =>
      'Created automatically when the payment is saved.';

  @override
  String get kuitansiFormat => 'Format';

  @override
  String get kuitansiFormatA5 => 'A5 / PDF';

  @override
  String get kuitansiFormatA5Hint => 'For records & sending via WhatsApp';

  @override
  String kuitansiFormatThermal(String paper) {
    return '$paper receipt';
  }

  @override
  String get kuitansiFormatThermalHint => 'Printed on the cashier printer';

  @override
  String get kuitansiShowDetails => 'Show per-invoice details';

  @override
  String get kuitansiShowBalance => 'Show remaining balance';

  @override
  String get kuitansiCity => 'City by the signature';

  @override
  String get kuitansiCityHint => 'From the branch address';

  @override
  String get kuitansiPrint => 'Print';

  @override
  String get kuitansiShare => 'Share PDF';

  @override
  String get kuitansiPrinted => 'Receipt sent to the printer.';

  @override
  String kuitansiSavedPdf(String path) {
    return 'PDF saved to $path';
  }

  @override
  String get kuitansiReprintNote =>
      'Receipts can be reprinted from Customers › payment history. Reprints are marked \"COPY\".';

  @override
  String get kuitansiErrNotFound => 'Payment not found.';

  @override
  String get kuitansiDocTitle => 'RECEIPT';

  @override
  String get kuitansiCopy => 'COPY';

  @override
  String get kuitansiReceivedFrom => 'Received from';

  @override
  String get kuitansiAmountWords => 'Amount in words';

  @override
  String get kuitansiFor => 'Payment for';

  @override
  String kuitansiForDetails(int count) {
    return 'Receivable, $count invoices (see details)';
  }

  @override
  String kuitansiForShort(int count) {
    return 'Receivable, $count invoices';
  }

  @override
  String get kuitansiMethod => 'Method';

  @override
  String get kuitansiNote => 'Note';

  @override
  String get kuitansiColInvoice => 'Invoice';

  @override
  String get kuitansiColBefore => 'Balance before';

  @override
  String get kuitansiColPaid => 'Paid';

  @override
  String get kuitansiCashier => 'Cashier';

  @override
  String kuitansiFootnote(String customer, String amount) {
    return '$customer\'s balance after this payment: $amount.';
  }

  @override
  String get kuitansiThermalBanner => 'RECEIVABLE RECEIPT';

  @override
  String get kuitansiFrom => 'From';

  @override
  String get kuitansiPaid => 'PAID';

  @override
  String get kuitansiBalance => 'Balance';

  @override
  String get historyStatusUnpaid => 'Unpaid';

  @override
  String get historyCustomer => 'Customer';

  @override
  String get historyDueOn => 'Due date';

  @override
  String get historyCredit => 'Sold on credit';

  @override
  String get historyOutstanding => 'Outstanding';

  @override
  String historyReturnDebtOnly(String amount) {
    return 'This return reduces the receivable by $amount; no refund is due.';
  }

  @override
  String historyReturnDebtSplit(String debt, String refund) {
    return 'Reduces the receivable by $debt, refunds $refund.';
  }

  @override
  String get historyVoidBlockDebtPaid =>
      'This credit invoice already received a receivable payment, so it can\'t be voided. Use a return.';

  @override
  String get receiptCustomer => 'Customer';

  @override
  String get receiptDebt => 'On credit';

  @override
  String get receiptDueOn => 'Due';

  @override
  String get cashRecapCredit => 'Credit sales (receivable)';

  @override
  String get paymentCredit => 'Credit / receivable';

  @override
  String get paymentCreditHint => 'Balance becomes a customer receivable';

  @override
  String get creditTitle => 'Credit / receivable';

  @override
  String get creditSubtitle =>
      'The invoice is saved with the balance as a customer receivable.';

  @override
  String get creditPickCustomer => 'Choose customer';

  @override
  String get creditNoCustomers =>
      'No customers yet. Add customers and their credit limits in Customers.';

  @override
  String get creditLoadFailed => 'Couldn\'t load customers.';

  @override
  String creditTerm(int days) {
    return '$days-day standard term';
  }

  @override
  String get creditChange => 'Change';

  @override
  String get creditRunning => 'Current receivable';

  @override
  String get creditDownPayment => 'Pay now (down payment)';

  @override
  String get creditDownPaymentHint =>
      'Can be 0. Paid in cash into the open session\'s drawer.';

  @override
  String get creditDueOn => 'Due date';

  @override
  String get creditDueOnHint => 'Today + the customer\'s standard term';

  @override
  String get creditInvoiceTotal => 'Invoice total';

  @override
  String get creditPaidNow => 'Paid now';

  @override
  String get creditBecomesDebt => 'Becomes receivable';

  @override
  String get creditRemainingAfter => 'Remaining limit after this';

  @override
  String get creditOverLimitTitle => 'Over the credit limit';

  @override
  String creditOverLimit(String limit) {
    return 'Current plus new receivable exceeds the $limit limit. Lower the amount or raise the down payment.';
  }

  @override
  String get creditFootnote =>
      'The invoice shows as Unpaid in History and joins the customer\'s receivables. A customer is required.';

  @override
  String get creditSave => 'Save as receivable';

  @override
  String successCredit(String name) {
    return 'Receivable for $name';
  }

  @override
  String get masterTabCustomerGroups => 'Customer groups';

  @override
  String get customerGroupsHint =>
      'A group\'s standard term fills in the due date for credit sales. Customers without a group use 14 days.';

  @override
  String get customerGroupsNew => 'Group';

  @override
  String get customerGroupsEmpty => 'No customer groups yet.';

  @override
  String customerGroupsRowSub(int days, int count) {
    return '$days-day term · $count customers';
  }

  @override
  String get customerGroupsNewTitle => 'New customer group';

  @override
  String get customerGroupsEditTitle => 'Edit customer group';

  @override
  String get customerGroupsName => 'Group name';

  @override
  String get customerGroupsTerm => 'Standard term (days)';

  @override
  String get customerGroupsTermHint => '0–365 days. 0 = due the same day.';

  @override
  String get cashSourcePurchase => 'Purchase';

  @override
  String get cashSourceDebtPayment => 'Receivable payment';

  @override
  String get historyMethodCredit => 'Credit';

  @override
  String get suppliersTitle => 'Suppliers & payables';

  @override
  String suppliersSubtitle(int count) {
    return '$count suppliers · payables tracked per purchase';
  }

  @override
  String get suppliersNew => 'Supplier';

  @override
  String get suppliersSearch => 'Search name, category, or phone';

  @override
  String get suppliersColSupplier => 'Supplier';

  @override
  String get suppliersColDebt => 'Payable';

  @override
  String get suppliersEmpty =>
      'No suppliers yet. Add one or record your first purchase.';

  @override
  String get suppliersNoMatch => 'No matching suppliers.';

  @override
  String get suppliersSelectHint =>
      'Pick a supplier to see and pay what you owe.';

  @override
  String get suppliersLoadFailed => 'Could not load suppliers.';

  @override
  String get suppliersTotalDebt => 'Total payables';

  @override
  String suppliersNearestDue(String date) {
    return 'Nearest due date: $date';
  }

  @override
  String get suppliersNoDue => 'Nothing due';

  @override
  String suppliersOverdueCount(int count) {
    return '$count overdue purchases';
  }

  @override
  String supplierPayTitle(String name) {
    return '$name · pay supplier';
  }

  @override
  String supplierContact(String name) {
    return 'Contact: $name';
  }

  @override
  String supplierTerm(int days) {
    return 'standard terms $days days';
  }

  @override
  String get supplierHistory => 'Purchase history';

  @override
  String get supplierEdit => 'Edit';

  @override
  String get supplierNoDebt => 'Nothing owed to this supplier.';

  @override
  String get supplierAmount => 'Amount paid';

  @override
  String get supplierPayAll => 'Pay everything';

  @override
  String get supplierFunding => 'Paid from';

  @override
  String get supplierReference => 'Transfer reference';

  @override
  String get supplierReferenceHint => 'Optional';

  @override
  String get supplierPaidOn => 'Payment date';

  @override
  String get supplierNoteOptional => 'Note (optional)';

  @override
  String get supplierColPurchase => 'Purchase';

  @override
  String get supplierColDue => 'Due';

  @override
  String get supplierColTotal => 'Total';

  @override
  String get supplierColRest => 'Remaining';

  @override
  String get supplierColPay => 'Pay';

  @override
  String get supplierTotalRow => 'Total';

  @override
  String get supplierOverdue => 'Overdue';

  @override
  String supplierDueShort(String date) {
    return 'due $date';
  }

  @override
  String supplierAutoHint(String name, String amount) {
    return 'Allocated to the nearest due date first. After saving, you will owe $name $amount.';
  }

  @override
  String supplierAutoHintDue(String name, String amount, String date) {
    return 'Allocated to the nearest due date first. After saving, you will owe $name $amount (due $date).';
  }

  @override
  String get supplierManualHint =>
      'Fill in Pay per purchase; the sum must equal the amount paid.';

  @override
  String get supplierDrawerHint =>
      'Paying from the cash drawer is recorded as cash out in the open cashier session.';

  @override
  String get supplierDrawerNoSession =>
      'The cash drawer needs an open cashier session on this device.';

  @override
  String get supplierDrawerNotToday =>
      'The cash drawer is only for today\'s payments. Use store cash or bank for other dates.';

  @override
  String get supplierDrawerNotPermitted =>
      'You are not allowed to use the cash drawer.';

  @override
  String get supplierManual => 'Allocate manually';

  @override
  String get supplierAuto => 'Allocate automatically';

  @override
  String get supplierAttachProof => 'Attach proof photo';

  @override
  String get supplierTakePhoto => 'Take photo';

  @override
  String get supplierRemoveProof => 'Remove photo';

  @override
  String get supplierProofTooLarge => 'Proof photo must be 5 MB or less.';

  @override
  String get supplierProofInvalid => 'Choose a PNG, JPG, or WebP image.';

  @override
  String get supplierSavePayment => 'Save payment';

  @override
  String supplierPaid(String number) {
    return 'Payment $number saved.';
  }

  @override
  String get supplierPayments => 'Payment history';

  @override
  String get supplierNoPayments => 'No payments yet.';

  @override
  String supplierProofTitle(String number) {
    return 'Proof $number';
  }

  @override
  String get supplierProofMissing =>
      'The proof photo is not on this device yet.';

  @override
  String get supplierDelete => 'Delete supplier';

  @override
  String supplierDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get supplierDeleteBody => 'Past purchases keep this supplier\'s name.';

  @override
  String get supplierDeleteAction => 'Delete';

  @override
  String get supplierCancel => 'Cancel';

  @override
  String get supplierClose => 'Close';

  @override
  String get supplierFormNew => 'New supplier';

  @override
  String get supplierFormEdit => 'Edit supplier';

  @override
  String get supplierFieldName => 'Supplier name';

  @override
  String get supplierFieldContact => 'Contact person';

  @override
  String get supplierFieldPhone => 'Phone';

  @override
  String get supplierFieldCategory => 'Goods category';

  @override
  String get supplierCategoryHint => 'e.g. Groceries, Drinks';

  @override
  String get supplierFieldTerm => 'Standard terms (days)';

  @override
  String get supplierTermHint => 'Sets the default due date in Purchases.';

  @override
  String get supplierFieldAddress => 'Address';

  @override
  String get supplierFieldNote => 'Note';

  @override
  String get supplierSave => 'Save';

  @override
  String supplierErrName(int max) {
    return 'Name is required, up to $max characters.';
  }

  @override
  String get supplierErrPhone => 'Phone must be 8–15 digits.';

  @override
  String supplierErrContact(int max) {
    return 'Contact up to $max characters.';
  }

  @override
  String supplierErrCategory(int max) {
    return 'Category up to $max characters.';
  }

  @override
  String supplierErrAddress(int max) {
    return 'Address up to $max characters.';
  }

  @override
  String supplierErrNote(int max) {
    return 'Note up to $max characters.';
  }

  @override
  String supplierErrTerm(int max) {
    return 'Terms must be 0–$max days.';
  }

  @override
  String get supplierErrNameTaken => 'That supplier name is already used.';

  @override
  String get supplierErrHasDebt =>
      'This supplier is still owed money. Pay it off before deleting.';

  @override
  String get supplierErrNotFound => 'Supplier not found.';

  @override
  String get supplierErrAmount => 'Enter the amount paid.';

  @override
  String get supplierErrOver => 'The amount is more than you owe.';

  @override
  String get supplierErrAllocation =>
      'A purchase cannot be paid more than its remaining balance.';

  @override
  String get supplierErrAllocationTotal =>
      'The Pay column must add up to the amount paid.';

  @override
  String get supplierErrDate => 'The payment date cannot be in the future.';

  @override
  String get supplierErrNoSession =>
      'Open a cashier session to pay from the cash drawer.';

  @override
  String get supplierErrText => 'The note or reference is too long.';

  @override
  String get supplierErrNotPermitted => 'You are not allowed to do this.';

  @override
  String get supplierErrGeneric => 'Could not save. Please try again.';

  @override
  String supplierHistoryTitle(String name) {
    return 'Purchases from $name';
  }

  @override
  String get supplierHistoryEmpty => 'No purchases from this supplier yet.';

  @override
  String get supplierHistoryPaid => 'Paid';

  @override
  String get cashSourceSupplierPayment => 'Supplier payment';

  @override
  String purchaseDebtPayment(String number) {
    return 'Payment $number';
  }

  @override
  String get expensesTitle => 'Expenses';

  @override
  String get expensesSubtitle => 'Operating costs outside stock purchases';

  @override
  String get expensesExport => 'Export Excel';

  @override
  String get expensesNew => 'Record expense';

  @override
  String get expensesSearch => 'Search expenses';

  @override
  String get expensesEmpty => 'No expenses in this period.';

  @override
  String get expensesNoMatch => 'No matching expenses.';

  @override
  String expensesByCategory(String period) {
    return 'By category · $period';
  }

  @override
  String expensesTotal(String amount) {
    return 'Total $amount';
  }

  @override
  String get expensesByCategoryEmpty => 'No counted expenses yet.';

  @override
  String get expensePeriod30Days => 'Last 30 days';

  @override
  String get expensePeriodThisMonth => 'This month';

  @override
  String get expensePeriodLastMonth => 'Last month';

  @override
  String get expenseColDate => 'Date';

  @override
  String get expenseColNumber => 'Number';

  @override
  String get expenseColDescription => 'Description';

  @override
  String get expenseColCategory => 'Category';

  @override
  String get expenseColFunding => 'Paid from';

  @override
  String get expenseColAmount => 'Amount';

  @override
  String get expenseColReceipt => 'Receipt';

  @override
  String get expenseColStatus => 'Status';

  @override
  String get expenseHasReceipt => 'Has photo';

  @override
  String get expenseNoReceipt => 'No photo';

  @override
  String get expenseVoided => 'Voided';

  @override
  String get expenseActive => 'Recorded';

  @override
  String expenseFundingSession(String funding, String name) {
    return '$funding · $name\'s session';
  }

  @override
  String get expenseFormTitle => 'Record expense';

  @override
  String get expenseDescription => 'Description';

  @override
  String get expenseDescriptionHint => 'e.g. Drinking water refill';

  @override
  String get expenseCategory => 'Expense category';

  @override
  String get expenseCategoryHint => 'Choose a category';

  @override
  String get expenseAmount => 'Amount';

  @override
  String get expenseFunding => 'Paid from';

  @override
  String get expenseFundingDrawerActive => 'Cash drawer (open session)';

  @override
  String get expenseDate => 'Date';

  @override
  String get expenseReceiptPick => 'Attach receipt photo';

  @override
  String get expenseReceiptCamera => 'Take receipt photo';

  @override
  String get expenseReceiptInvalid =>
      'Receipt photo must be a PNG/JPEG/WebP image up to 5 MB.';

  @override
  String get expenseReceiptMissing =>
      'The receipt photo is not on this device yet.';

  @override
  String get expenseCancel => 'Cancel';

  @override
  String get expenseSave => 'Save expense';

  @override
  String get expenseClose => 'Close';

  @override
  String expenseErrDescription(int max) {
    return 'Description is required, up to $max characters.';
  }

  @override
  String get expenseErrCategory => 'Choose an expense category.';

  @override
  String get expenseErrAmount =>
      'Amount must be more than 0 and at most Rp 1,000,000,000.';

  @override
  String get expenseErrDate => 'The date cannot be in the future.';

  @override
  String get expenseErrNotFound => 'Expense not found.';

  @override
  String get expenseErrAlreadyVoided => 'This expense is already voided.';

  @override
  String expenseErrReason(int max) {
    return 'A reason is required, up to $max characters.';
  }

  @override
  String get expenseErrNotPermitted =>
      'You don\'t have permission for this expense.';

  @override
  String get expenseErrGeneric =>
      'The expense couldn\'t be processed. Try again.';

  @override
  String get expenseDrawerNotPermitted =>
      'The cash drawer needs the cash_movements:create permission.';

  @override
  String get expenseDrawerNoSession =>
      'The cash drawer needs an open cash session on this device.';

  @override
  String get expenseDrawerNotToday =>
      'Cash drawer expenses must be dated today.';

  @override
  String get expenseDetailTitle => 'Expense details';

  @override
  String get expenseRecordedBy => 'Recorded by';

  @override
  String expenseVoidInfo(String name, String reason) {
    return 'Voided by $name: $reason';
  }

  @override
  String get expenseVoid => 'Void expense';

  @override
  String get expenseVoidReason => 'Reason';

  @override
  String get expenseVoidReasonHint => 'e.g. Wrong amount, will re-record';

  @override
  String get expenseVoidDrawerHint =>
      'The money goes back to the drawer in the open cash session.';

  @override
  String get expenseVoidConfirm => 'Yes, void';

  @override
  String get masterTabExpenseCategories => 'Expense categories';

  @override
  String get expenseCategoriesNew => 'Category';

  @override
  String get expenseCategoriesHint =>
      'Used on the Expenses screen and the profit & loss report.';

  @override
  String get expenseCategoriesEmpty => 'No expense categories yet.';

  @override
  String expenseCategoriesUsage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses',
      one: '1 expense',
    );
    return '$_temp0';
  }

  @override
  String get expenseCategoriesNewTitle => 'New expense category';

  @override
  String get expenseCategoriesEditTitle => 'Edit expense category';

  @override
  String get expenseCategoriesName => 'Category name';

  @override
  String expenseCategoryErrName(int max) {
    return 'Name is required, up to $max characters.';
  }

  @override
  String get expenseCategoryErrTaken => 'That category name is already used.';

  @override
  String get expenseCategoryErrInUse =>
      'This category is used by expenses, so it can\'t be deleted. Rename it if needed.';

  @override
  String cashExpenseBadge(String name) {
    return 'Expense · $name';
  }

  @override
  String get cashSourceExpense => 'Expense';

  @override
  String get cashSourceExpenseVoid => 'Voided expense';

  @override
  String get cashAsExpense => 'Also record as an expense';

  @override
  String get cashAsExpenseHint =>
      'So it counts in the profit & loss report (1.24)';

  @override
  String get cashAsExpenseNeedsNote =>
      'The note is required and becomes the expense description.';

  @override
  String get expenseCategorySave => 'Save';

  @override
  String get expenseReceiptOpen => 'Open receipt photo';

  @override
  String get expenseFundingDrawer => 'Cash drawer';

  @override
  String get reportsTitle => 'Reports';

  @override
  String reportsSubtitle(String period, String outlet) {
    return '$period · $outlet';
  }

  @override
  String get reportsPeriod => 'Period';

  @override
  String get reportsPeriodToday => 'Today';

  @override
  String get reportsPeriod7Days => 'Last 7 days';

  @override
  String get reportsPeriodThisMonth => 'This month';

  @override
  String get reportsDownloadPdf => 'Download PDF';

  @override
  String get reportsDownloadExcel => 'Download Excel';

  @override
  String get reportsTabSummary => 'Summary';

  @override
  String get reportsTabSales => 'Sales';

  @override
  String get reportsTabTop => 'Best sellers';

  @override
  String get reportsTabProfit => 'Profit & loss';

  @override
  String get reportsKpiSales => 'Sales';

  @override
  String reportsKpiSalesNote(int count) {
    return '$count transactions';
  }

  @override
  String get reportsKpiGrossProfit => 'Gross profit';

  @override
  String get reportsKpiGrossProfitNote => 'From cost at time of sale';

  @override
  String get reportsKpiAverage => 'Average per receipt';

  @override
  String get reportsKpiAverageNote => 'Net sales ÷ transactions';

  @override
  String get reportsKpiOverdue => 'Overdue receivables';

  @override
  String reportsKpiOverdueNote(int count) {
    return '$count customers';
  }

  @override
  String get reportsByMethod => 'Sales by payment method';

  @override
  String get reportsByMethodNote => 'Receipt totals before returns';

  @override
  String get reportsMethodCredit => 'Credit (receivable)';

  @override
  String get reportsEmpty => 'No sales in this period yet.';

  @override
  String get reportsTop => 'Best sellers';

  @override
  String get reportsFull => 'Full reports';

  @override
  String get reportsLinkSalesProduct => 'Sales by product';

  @override
  String get reportsLinkSalesStaff => 'Sales by cashier';

  @override
  String get reportsLinkSalesCategory => 'Sales by category';

  @override
  String get reportsLinkProfit => 'Profit & loss';

  @override
  String get reportsLinkStock => 'Stock card';

  @override
  String get reportsLinkDebts => 'Payables & receivables';

  @override
  String get reportsLinkReturns => 'Returns';

  @override
  String get reportsLinkExpenses => 'Income & expenses';

  @override
  String get reportsLinkSessions => 'Cashier session recap';

  @override
  String get reportsGroupProduct => 'By product';

  @override
  String get reportsGroupStaff => 'By cashier';

  @override
  String get reportsGroupCategory => 'By category';

  @override
  String get reportsColProduct => 'Product';

  @override
  String get reportsColStaff => 'Cashier';

  @override
  String get reportsColCategory => 'Category';

  @override
  String get reportsColQty => 'Quantity';

  @override
  String get reportsColReceipts => 'Receipts';

  @override
  String get reportsColNet => 'Net sales';

  @override
  String get reportsColShare => 'Share';

  @override
  String get reportsColRank => '#';

  @override
  String get reportsColValue => 'Value';

  @override
  String get reportsColLine => 'Description';

  @override
  String get reportsColAmount => 'Amount';

  @override
  String get reportsColMethod => 'Payment method';

  @override
  String get reportsNoCategory => 'Uncategorized';

  @override
  String get reportsTotal => 'Total';

  @override
  String get reportsSalesNote =>
      'By product and category: line value after tier pricing and returns, excluding service and PB1 tax. By cashier: net sales as in profit & loss. Quantities in base units.';

  @override
  String reportsPlTitle(String period) {
    return 'Profit & loss · $period';
  }

  @override
  String reportsPlSubtitle(String outlet) {
    return '$outlet · all cashiers';
  }

  @override
  String get reportsPlGross => 'Gross sales';

  @override
  String get reportsPlDiscount => 'Discounts';

  @override
  String get reportsPlService => 'Service charge';

  @override
  String get reportsPlReturns => 'Sales returns';

  @override
  String get reportsPlNet => 'Net sales';

  @override
  String get reportsPlCogs => 'Cost of goods sold (COGS)';

  @override
  String reportsPlGrossProfit(String margin) {
    return 'Gross profit · margin $margin';
  }

  @override
  String get reportsPlExpensesTotal => 'Total operating expenses';

  @override
  String get reportsPlExpensesNone => 'No expenses yet';

  @override
  String get reportsPlAdjustment => 'Stock adjustments (count, damaged, lost)';

  @override
  String get reportsPlNetProfit => 'Net profit';

  @override
  String reportsPlTax(String amount) {
    return 'PB1 tax collected $amount: not revenue, excluded.';
  }

  @override
  String reportsPlMissingCost(int count) {
    return '$count products sold without a cost price: their COGS counts as 0.';
  }

  @override
  String reportsVsPrevious(String change, String period) {
    return '$change vs $period';
  }

  @override
  String reportsPreviousValue(String period, String amount) {
    return '$period: $amount';
  }

  @override
  String get reportsPrevToday => 'yesterday';

  @override
  String get reportsPrev7Days => 'the previous 7 days';

  @override
  String get reportsMargin => 'Gross margin';

  @override
  String get reportsMarginNote => 'Gross profit ÷ net sales';

  @override
  String get reportsExpenseRatio => 'Expenses / sales';

  @override
  String get reportsHowTitle => 'How it is calculated';

  @override
  String get reportsHowBody =>
      'COGS uses the weighted average cost at the time of sale. Expenses come from the Expenses menu. Automatic payroll arrives in Phase 3.';

  @override
  String reportsDocSubtitle(String outlet, String date) {
    return '$outlet · generated $date';
  }

  @override
  String get reportsNotPermitted =>
      'You do not have permission to view reports.';

  @override
  String get reportsLoadFailed => 'Reports could not be loaded.';

  @override
  String get reportsTabStock => 'Stock';

  @override
  String get reportsTabCash => 'Cash & sessions';

  @override
  String get reportsTabDebts => 'Receivables & payables';

  @override
  String get reportsTabReturns => 'Returns';

  @override
  String get reportsStockValue => 'Stock value';

  @override
  String get reportsStockValueNote => 'At current average cost';

  @override
  String get reportsStockItems => 'Goods items';

  @override
  String get reportsStockItemsNote => 'Variants with tracked stock';

  @override
  String get reportsStockLow => 'Low stock';

  @override
  String get reportsStockLowNote => 'At or below minimum';

  @override
  String get reportsStockOut => 'Out of stock';

  @override
  String get reportsStockOutNote => 'Zero or negative stock';

  @override
  String get reportsStockMovement => 'Stock movement';

  @override
  String get reportsStockNote =>
      'All stock locations of this branch, quantities in base units. In: opening stock, purchases, sales returns, positive adjustments. Out: sales, purchase returns, negative adjustments. Closing value = closing stock × current average cost.';

  @override
  String get reportsStockEmpty =>
      'No goods with stock or movement in this period.';

  @override
  String get reportsColOpening => 'Opening';

  @override
  String get reportsColIn => 'In';

  @override
  String get reportsColOut => 'Out';

  @override
  String get reportsColClosing => 'Closing';

  @override
  String get reportsColClosingValue => 'Closing value';

  @override
  String get reportsCashSessions => 'Cash sessions';

  @override
  String reportsCashSessionsNote(int count) {
    return '$count still open';
  }

  @override
  String get reportsCashDifference => 'Total difference';

  @override
  String get reportsCashDifferenceNote => 'Closed sessions';

  @override
  String get reportsCashIn => 'Other cash in';

  @override
  String get reportsCashOut => 'Cash out';

  @override
  String get reportsCashMovementsNote => 'Excluding sales';

  @override
  String get reportsCashMovements => 'Cash in & out';

  @override
  String get reportsCashOpen => 'Still open';

  @override
  String get reportsCashEmpty => 'No cash sessions active in this period.';

  @override
  String get reportsCashNoMovements => 'No cash in or out besides sales.';

  @override
  String get reportsCashNote =>
      'Expected = opening + net cash sales − cash refunds + cash in − cash out. Open sessions are counted up to now.';

  @override
  String get reportsColOpened => 'Opened';

  @override
  String get reportsColOpeningCash => 'Opening cash';

  @override
  String get reportsColExpected => 'Expected';

  @override
  String get reportsColCounted => 'Counted';

  @override
  String get reportsColDifference => 'Difference';

  @override
  String get reportsColSource => 'Source';

  @override
  String get reportsColEntries => 'Entries';

  @override
  String get reportsSourceManualIn => 'Manual cash in';

  @override
  String get reportsSourceManualOut => 'Manual cash out';

  @override
  String get reportsSourceExpense => 'Expenses';

  @override
  String get reportsSourceExpenseVoid => 'Voided expenses';

  @override
  String get reportsSourceSupplierPayment => 'Supplier debt payments';

  @override
  String get reportsSourcePurchase => 'Purchase payments';

  @override
  String get reportsSourceDebtPayment => 'Receivable payments';

  @override
  String get reportsSourceOther => 'Other';

  @override
  String reportsDebtAsOf(String date) {
    return 'As of $date';
  }

  @override
  String get reportsDebtReceivable => 'Customer receivables';

  @override
  String reportsDebtCustomersNote(int count) {
    return '$count customers';
  }

  @override
  String get reportsDebtPayable => 'Supplier payables';

  @override
  String reportsDebtSuppliersNote(int count) {
    return '$count suppliers';
  }

  @override
  String get reportsDebtOverduePurchases => 'Overdue purchases';

  @override
  String get reportsDebtOverduePurchasesNote => 'Pay from the Suppliers screen';

  @override
  String get reportsDebtCustomers => 'Receivables by customer';

  @override
  String get reportsDebtSuppliers => 'Payables by supplier';

  @override
  String get reportsDebtNoReceivable => 'No customer receivables.';

  @override
  String get reportsDebtNoPayable => 'No supplier payables.';

  @override
  String get reportsDebtNote =>
      'Today\'s position, independent of the selected period.';

  @override
  String get reportsColCustomer => 'Customer';

  @override
  String get reportsColSupplier => 'Supplier';

  @override
  String get reportsColOpenCount => 'Open';

  @override
  String get reportsColOverdueCount => 'Overdue';

  @override
  String get reportsColNearestDue => 'Nearest due';

  @override
  String get reportsColRemaining => 'Remaining';

  @override
  String get reportsReturnsCountNote => 'Sales returns in the period';

  @override
  String get reportsReturnsTotal => 'Returns value';

  @override
  String get reportsReturnsTotalNote => 'Including service and tax share';

  @override
  String get reportsReturnsRestock => 'Back to stock';

  @override
  String get reportsReturnsDamaged => 'Damaged / expired';

  @override
  String reportsReturnsOfCount(int count) {
    return 'of $count returns';
  }

  @override
  String get reportsReturnsByReason => 'By reason';

  @override
  String get reportsReturnsList => 'Returns';

  @override
  String get reportsReturnsEmpty => 'No returns in this period.';

  @override
  String get reportsColTime => 'Time';

  @override
  String get reportsColReturnNo => 'Return no.';

  @override
  String get reportsColReceiptNo => 'Receipt no.';

  @override
  String get reportsColHandledBy => 'Handled by';

  @override
  String get reportsColReason => 'Reason';

  @override
  String get reportsColRestock => 'Restock';

  @override
  String get reportsColRefund => 'Refund';

  @override
  String get reportsYes => 'Yes';

  @override
  String get reportsNo => 'No';

  @override
  String get reportsSourcePurchaseRefund => 'Purchase return refunds';

  @override
  String reportsRefundMixed(String method) {
    return '$method + debt reduction';
  }

  @override
  String get reportsCashOpenNote =>
      'Empty counted and difference = session still open.';

  @override
  String get menuAccount => 'My account';

  @override
  String get usersSubtitle =>
      'Add staff, reset PINs and set permissions per role.';

  @override
  String get usersTabUsers => 'Users';

  @override
  String get usersTabRoles => 'Roles & permissions';

  @override
  String get usersListTitle => 'Outlet users';

  @override
  String usersListCount(String outlet, int count) {
    return '$outlet · $count active users';
  }

  @override
  String get usersAdd => 'Add';

  @override
  String get usersColUser => 'User';

  @override
  String get usersColRole => 'Role';

  @override
  String get usersColOutlet => 'Outlet';

  @override
  String get usersColStatus => 'Status';

  @override
  String get usersPinOnly => 'PIN only';

  @override
  String get usersEmailAndPin => 'Email + PIN';

  @override
  String get usersAllOutlets => 'All';

  @override
  String get usersStatusActive => 'Active';

  @override
  String get usersStatusInactive => 'Inactive';

  @override
  String usersStatusLocked(int seconds) {
    return 'PIN locked ${seconds}s';
  }

  @override
  String get usersUnlock => 'Unlock';

  @override
  String get usersResetHint =>
      'Reset a staff PIN: open the user, enter the new PIN and repeat it. The old PIN is not needed.';

  @override
  String get usersOwnerHint =>
      'The owner changes their PIN and password in My account.';

  @override
  String get usersEmpty => 'No other users yet. Add staff with a PIN.';

  @override
  String get usersFormNewTitle => 'Add user';

  @override
  String get usersFormEditTitle => 'Edit user';

  @override
  String get usersFormPermission => 'Requires users:manage';

  @override
  String get usersFieldName => 'Name';

  @override
  String get usersFieldRole => 'Role';

  @override
  String get usersFieldRoleHint =>
      'Permissions follow the role; set them in Roles & permissions';

  @override
  String get usersFieldPin => 'PIN (6 digits)';

  @override
  String get usersFieldPinHint => 'Staff use this PIN to sign in at the till';

  @override
  String get usersFieldPinRetype => 'Repeat PIN';

  @override
  String get usersFieldActive => 'Active';

  @override
  String get usersFieldActiveHint =>
      'Inactive users do not appear on the sign-in screen';

  @override
  String get usersCancel => 'Cancel';

  @override
  String get usersSave => 'Save user';

  @override
  String get usersResetTitle => 'Reset PIN';

  @override
  String get usersResetPin => 'New PIN';

  @override
  String get usersResetRetype => 'Repeat new PIN';

  @override
  String get usersResetSubmit => 'Reset PIN';

  @override
  String get usersResetDone => 'New PIN saved and the PIN lock cleared.';

  @override
  String get usersErrNameTaken => 'Another user already has this name';

  @override
  String get usersErrOwnerLocked => 'The owner cannot be changed here.';

  @override
  String get usersErrSelf => 'You cannot change your own account or role here.';

  @override
  String get usersErrBeyond => 'You can only grant permissions you have.';

  @override
  String get usersErrRoleNotFound => 'Role not found.';

  @override
  String get usersErrRoleTaken => 'This role name is already used.';

  @override
  String get usersErrRoleInUse =>
      'The role is still assigned to users. Move them first.';

  @override
  String get usersErrNotPermitted =>
      'You do not have permission for this action.';

  @override
  String get usersErrGeneric => 'Something went wrong. Try again.';

  @override
  String usersErrWrongPin(int remaining) {
    return 'Current PIN is wrong. $remaining attempts left.';
  }

  @override
  String get usersErrWrongPassword => 'Current password is wrong.';

  @override
  String usersErrLocked(int seconds) {
    return 'Too many attempts. Try again in $seconds seconds.';
  }

  @override
  String get usersMatrixTitle => 'Permission matrix per role';

  @override
  String get usersMatrixPermission => 'Permission';

  @override
  String get usersMatrixNewRole => 'Custom role';

  @override
  String get usersMatrixSave => 'Save changes';

  @override
  String get usersMatrixDiscard => 'Discard';

  @override
  String get usersMatrixSaved => 'Role permissions saved.';

  @override
  String get usersMatrixNote =>
      'Permissions use the resource:action format. Buttons and pages that are not allowed are hidden automatically. The owner always has every permission. Roles are stored on this device; changes apply the next time staff sign in.';

  @override
  String usersMatrixMembers(int count) {
    return '$count users';
  }

  @override
  String get usersRoleNewTitle => 'New custom role';

  @override
  String get usersRoleRenameTitle => 'Rename role';

  @override
  String get usersRoleName => 'Role name';

  @override
  String get usersRoleNameHint => 'e.g. Barista';

  @override
  String get usersRoleCreate => 'Create role';

  @override
  String get usersRoleRename => 'Rename';

  @override
  String get usersRoleDelete => 'Delete role';

  @override
  String get permSalesCreate => 'Create sales';

  @override
  String get permSalesVoid => 'Void receipts';

  @override
  String get permSalesDiscount => 'Manual discounts';

  @override
  String get permSalesReturn => 'Sales returns';

  @override
  String get permPaymentsConfirm => 'Confirm manual payments (QRIS, card)';

  @override
  String get permOpenBillsManage => 'Manage tables & open bills';

  @override
  String get permCashSessionOpen => 'Open cashier sessions';

  @override
  String get permCashSessionClose => 'Close cashier sessions';

  @override
  String get permCashMovementsCreate => 'Cash in / out of the drawer';

  @override
  String get permProductsManage => 'Manage products & prices';

  @override
  String get permCustomersManage => 'Customers';

  @override
  String get permSuppliersManage => 'Suppliers';

  @override
  String get permPurchasesManage => 'Purchases & purchase returns';

  @override
  String get permStockAdjust => 'Stock adjustments';

  @override
  String get permDebtsManage => 'Receivables & credit';

  @override
  String get permExpensesManage => 'Expenses';

  @override
  String get permReportsView => 'View reports';

  @override
  String get permReportsViewProfit => 'View profit & loss';

  @override
  String get permSettingsManage => 'Store settings';

  @override
  String get permUsersManage => 'Users & roles';

  @override
  String get permBackupManage => 'Backup & restore';

  @override
  String get permSyncManage => 'Sync & hosting';

  @override
  String get accountTitle => 'My account';

  @override
  String accountSubtitle(String name, String role) {
    return '$name · $role · open to every user';
  }

  @override
  String get accountPasswordTitle => 'Change password';

  @override
  String get accountPasswordCurrent => 'Current password';

  @override
  String get accountPasswordNew => 'New password';

  @override
  String get accountPasswordNewHint => 'At least 8 characters';

  @override
  String get accountPasswordRetype => 'Repeat new password';

  @override
  String get accountPasswordSubmit => 'Change password';

  @override
  String get accountPasswordDone => 'New password saved.';

  @override
  String get accountPasswordNone =>
      'This account signs in with a PIN only, without a password.';

  @override
  String get accountPinTitle => 'Change PIN';

  @override
  String get accountPinCurrent => 'Current PIN';

  @override
  String get accountPinNew => 'New PIN';

  @override
  String get accountPinRetype => 'Repeat new PIN';

  @override
  String get accountPinSubmit => 'Change PIN';

  @override
  String get accountPinDone => 'New PIN saved.';

  @override
  String get usersErrStaffNotFound => 'User not found or no longer active.';

  @override
  String get usersErrNoPassword => 'This account does not use a password.';

  @override
  String usersRoleDeleteTitle(String name) {
    return 'Delete role $name?';
  }

  @override
  String get usersRoleDeleteBody =>
      'A role still assigned to users cannot be deleted.';

  @override
  String get usersRoleDeleteConfirm => 'Delete';

  @override
  String get cashierRounding => 'Rounding';

  @override
  String saleErrorStockShort(String names) {
    return 'Not enough stock: $names. Negative stock is turned off in Settings › Sales & stock.';
  }

  @override
  String get reportsPlIncludedTax => 'PB1 included in prices';

  @override
  String get reportsPlRounding => 'Total rounding';

  @override
  String receiptTaxIncluded(String pct) {
    return 'PB1 $pct (included)';
  }

  @override
  String get receiptRounding => 'Rounding';

  @override
  String diningTaxIncluded(String pct) {
    return 'PB1 $pct (included)';
  }

  @override
  String get fnbRatesInclusive => 'Prices include tax';

  @override
  String get fnbRatesInclusiveHint =>
      'PB1 is separated from menu prices and not added to the total.';

  @override
  String get settingsTextSize => 'Display size';

  @override
  String get settingsTextSizeNormal => 'Normal';

  @override
  String get settingsTextSizeLarge => 'Large';

  @override
  String get storeSettingsPhoneInvalid => 'Digits, spaces, + and - only';

  @override
  String get storeSettingsLoadFailed => 'Could not load store settings.';

  @override
  String get storeSettingsBusinessTitle => 'Store profile';

  @override
  String get storeSettingsBusinessSubtitle => 'Applies to all branches';

  @override
  String get storeSettingsBusinessName => 'Business name';

  @override
  String get storeSettingsBusinessType => 'Business type';

  @override
  String get storeSettingsBusinessNote =>
      'Business type and time zone are chosen during setup and cannot be changed because they decide the menu and the date in receipt numbers.';

  @override
  String get storeSettingsBusinessSaved => 'Store profile saved.';

  @override
  String get storeSettingsOutletTitle => 'This branch';

  @override
  String get storeSettingsOutletSubtitle =>
      'Address and phone appear in the default receipt header';

  @override
  String get storeSettingsOutletName => 'Branch name';

  @override
  String get storeSettingsAddress => 'Address';

  @override
  String get storeSettingsPhone => 'Phone';

  @override
  String get storeSettingsOutletCode => 'Branch code';

  @override
  String get storeSettingsDeviceCode => 'Device code';

  @override
  String get storeSettingsOutletNote =>
      'Branch and device codes are part of receipt numbers (e.g. PST-K01-…), so they cannot be changed.';

  @override
  String get storeSettingsOutletSaved => 'Branch details saved.';

  @override
  String get storeSettingsRulesTitle => 'Sales & stock';

  @override
  String get storeSettingsRulesSubtitle =>
      'Applies to every device in this branch';

  @override
  String get storeSettingsNegativeStock => 'Allow negative stock';

  @override
  String get storeSettingsNegativeStockHint =>
      'When off, out-of-stock products cannot be sold';

  @override
  String get storeSettingsRequireSession => 'Require an open cash session';

  @override
  String get storeSettingsRequireSessionHint =>
      'Always on: cash is recorded per cash session';

  @override
  String get storeSettingsRounding => 'Total rounding';

  @override
  String get storeSettingsRoundingHint =>
      'To the nearest multiple, exact halves round up. Applies to every payment method.';

  @override
  String get storeSettingsRoundingNone => 'None';

  @override
  String get storeSettingsRounding100 => 'To the nearest Rp 100';

  @override
  String get storeSettingsRounding500 => 'To the nearest Rp 500';

  @override
  String get storeSettingsRulesSaved => 'Sales rules saved.';

  @override
  String get storeSettingsSave => 'Save';

  @override
  String get storeSettingsSaveFailed => 'Could not save. Try again.';

  @override
  String billSplitTaxIncluded(String pct) {
    return '$pct (included)';
  }

  @override
  String get cashierDiscount => 'Discount';

  @override
  String get cashierDiscountBillTitle => 'Order discount';

  @override
  String get cashierDiscountLineTitle => 'Item discount';

  @override
  String get cashierDiscountHint =>
      'Per order, or long-press a line for an item discount.';

  @override
  String get cashierDiscountPercent => 'Percent (%)';

  @override
  String get cashierDiscountAmount => 'Amount (Rp)';

  @override
  String get cashierDiscountValue => 'Discount value';

  @override
  String cashierDiscountBase(String amount) {
    return 'Of $amount';
  }

  @override
  String cashierDiscountCut(String amount) {
    return 'Discount $amount';
  }

  @override
  String get cashierDiscountApply => 'Apply';

  @override
  String get cashierDiscountRemove => 'Remove discount';

  @override
  String get cashierDiscountTooLarge =>
      'The discount can\'t exceed or use up the total.';

  @override
  String get cashierDiscountInvalid => 'Enter 0.01–100% or a rupiah amount.';

  @override
  String get cashierDiscountNeedsPin =>
      'After Apply, a manager enters their PIN to approve the discount.';

  @override
  String cashierDiscountPct(String pct) {
    return 'Discount $pct';
  }

  @override
  String get cashierLineDiscounts => 'Item discounts';

  @override
  String get cashierBillDiscount => 'Order discount';

  @override
  String cashierBillDiscountPct(String pct) {
    return 'Order discount $pct';
  }

  @override
  String cashierDiscountApprovedBy(String name) {
    return 'approved by $name';
  }

  @override
  String get approvalDiscount =>
      'A manual discount needs the sales:discount permission. Ask a permitted staff member to enter their PIN.';

  @override
  String get saleErrorDiscountNotPermitted =>
      'A manual discount needs permission or a manager\'s PIN approval.';

  @override
  String get saleErrorDiscountTooLarge =>
      'A discount exceeds its line or makes the order total zero.';

  @override
  String get receiptDiscount => 'Discount';

  @override
  String receiptDiscountPct(String pct) {
    return 'Discount $pct';
  }

  @override
  String get storeSettingsDiscountPin => 'Manual discount needs manager PIN';

  @override
  String get storeSettingsDiscountPinHint =>
      'Cashiers without the discount permission can discount after a manager enters their PIN. When off, only permitted staff can discount.';

  @override
  String get settingsSectionBackup => 'Data & backup';

  @override
  String get backupModeLabel => 'Current mode';

  @override
  String get backupModeFree => 'Free · offline';

  @override
  String get backupModeBody =>
      'All data and images are stored on this device only. Back up regularly so nothing is lost if the phone or computer breaks.';

  @override
  String get backupStatSales => 'Transactions';

  @override
  String get backupStatProducts => 'Products';

  @override
  String get backupStatSize => 'Size';

  @override
  String get backupLastNever => 'Never backed up';

  @override
  String get backupLastToday => 'Last backup today';

  @override
  String backupLastDays(int days) {
    return 'Last backup $days days ago';
  }

  @override
  String get backupNow => 'Back up now';

  @override
  String get backupRestore => 'Restore';

  @override
  String get backupFileNote =>
      'The backup file holds the database and all images (.zip). Keep it somewhere safe: it contains your store data.';

  @override
  String backupSavedTo(String path) {
    return 'Backup saved to $path';
  }

  @override
  String get backupShared => 'Backup shared.';

  @override
  String get backupDismissed =>
      'Backup was not shared. Try again and pick where to save it.';

  @override
  String get backupFailed =>
      'Backup failed. Make sure there is enough storage, then try again.';

  @override
  String get backupRestoreTitle => 'Restore from backup';

  @override
  String backupRestoreSummary(String store, String outlet, String device) {
    return '$store · $outlet · device $device';
  }

  @override
  String backupRestoreMade(String date, int sales, int products) {
    return 'Created $date · $sales transactions · $products products';
  }

  @override
  String get backupRestoreWarning =>
      'All data on this device will be replaced by the backup. Current data is moved to a \"sebelum-pulihkan\" folder in the data folder, then the app reloads and you sign in again.';

  @override
  String backupRestoreConfirmLabel(String store) {
    return 'Type \"$store\" to continue';
  }

  @override
  String get backupRestoreConfirm => 'Restore & reload';

  @override
  String get backupRestoreCancel => 'Cancel';

  @override
  String get backupInvalid => 'This file is not a complete Lakuna backup.';

  @override
  String get backupTooNew =>
      'This backup was made by a newer Lakuna version. Update the app first.';

  @override
  String get backupRestoreFailed =>
      'Restore failed. The data on this device was not changed.';

  @override
  String get backupHostingTitle => 'Activate hosted version';

  @override
  String get backupHostingBody =>
      'Sync all branches and devices to your store server.';

  @override
  String get backupHostingServer => 'Server address';

  @override
  String get backupHostingCode => 'Activation code';

  @override
  String get backupHostingConnect => 'Connect & upload data';

  @override
  String get backupHostingSoon => 'Available in the hosted version (phase 2).';

  @override
  String get startupErrorTitle => 'Lakuna could not start';

  @override
  String get startupErrorBody =>
      'The database on this device could not be opened. Your data was not deleted. Copy the details below and contact support.';

  @override
  String startupErrorPath(String path) {
    return 'Data location: $path';
  }

  @override
  String get startupErrorCopy => 'Copy details';

  @override
  String get homeRestoreFailedTitle => 'Restore failed';

  @override
  String get homeRestoreFailedBody =>
      'The database from the backup could not be opened, so your previous data was put back. The failed backup is kept in a pulihkan-gagal folder in the data location.';

  @override
  String homeGreetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String homeGreetingMidday(String name) {
    return 'Good day, $name';
  }

  @override
  String homeGreetingAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String homeGreetingNight(String name) {
    return 'Good evening, $name';
  }

  @override
  String get homeSalesTodayTitle => 'Today\'s sales';

  @override
  String homeSalesTodayDetail(int count, String average) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0 · average $average';
  }

  @override
  String get homeModulesLabel => 'Modules';

  @override
  String get homeAttentionTitle => 'Needs attention';

  @override
  String homeAttentionLowStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
    );
    return '$_temp0 below minimum stock';
  }

  @override
  String homeAttentionPendingQris(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QRIS payments',
      one: '1 QRIS payment',
    );
    return '$_temp0 awaiting confirmation';
  }

  @override
  String homeAttentionBackupToday(String time) {
    return 'Last backup today at $time';
  }

  @override
  String homeAttentionBackupYesterday(String time) {
    return 'Last backup yesterday at $time';
  }

  @override
  String homeAttentionBackupDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Last backup $_temp0 ago';
  }

  @override
  String get homeAttentionBackupNever => 'Data has never been backed up';

  @override
  String get homeAttentionView => 'View';

  @override
  String get homeAttentionClear => 'All good, nothing needs action.';

  @override
  String get homeDeviceTitle => 'Device info';

  @override
  String get guideTitle => 'Guide';

  @override
  String get guideOffline => 'Available offline';

  @override
  String get guideSearchLabel => 'Search the guide';

  @override
  String get guideSearchHint => 'Search: returns, QRIS, backup…';

  @override
  String get guideLanguageLabel => 'Guide language';

  @override
  String get guideContents => 'Contents';

  @override
  String guideResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count search results',
      one: '1 search result',
    );
    return '$_temp0';
  }

  @override
  String get guideNoResults => 'No matching articles';

  @override
  String get guideLoadError => 'The guide could not be loaded';

  @override
  String get guidePrevious => 'Previous';

  @override
  String get guideNext => 'Next';

  @override
  String get guideImageMissing => 'Image not available';

  @override
  String get settingsSectionAbout => 'About Lakuna';

  @override
  String get aboutTagline =>
      'Offline-first point of sale for small businesses, in Retail and F&B modes.';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutOpenGuide => 'Open the guide';

  @override
  String get aboutPrivacyTitle => 'Data privacy';

  @override
  String get aboutPrivacyLocal =>
      'All store data (products, sales, customers, staff and images) is stored on this device. Lakuna does not send data to anyone else and has no ads or trackers.';

  @override
  String get aboutPrivacyHosted =>
      'The hosted version (sync to a server) is not available yet. The privacy policy will be updated before it launches.';

  @override
  String get aboutPrivacyBackup =>
      'Backup files hold all of your store data. Keep them somewhere safe.';

  @override
  String get aboutLicensesTitle => 'Open source licenses';

  @override
  String get aboutLicensesSubtitle =>
      'Lakuna is built with these open source packages and fonts.';

  @override
  String get aboutLicensesShow => 'Show licenses';

  @override
  String get aboutLicensesError => 'Could not load the license list.';

  @override
  String aboutLicenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count licenses',
      one: '1 license',
    );
    return '$_temp0';
  }

  @override
  String get cashierCustomerWalkIn => 'Walk-in customer';

  @override
  String get cashierCustomerPick => 'Choose customer';

  @override
  String get cashierCustomerClear => 'Remove customer from bill';

  @override
  String get cashierCustomerSearch => 'Search name or phone';

  @override
  String get cashierCustomerNone =>
      'No customers yet. Add them from the Customers menu.';

  @override
  String get cashierCustomerNoMatch => 'No matching customers.';

  @override
  String get cashierCustomerLoadFailed => 'Could not load customers.';

  @override
  String cashierCustomerRemaining(String amount) {
    return 'Limit left $amount';
  }

  @override
  String get cashierCustomerOverdue => 'Overdue';

  @override
  String get cashierPark => 'Save';

  @override
  String get cashierParkTitle => 'Save bill';

  @override
  String get cashierParkBody =>
      'The bill is saved unpaid and can be continued later from Saved bills. Stock only goes down when it is paid.';

  @override
  String cashierParkFor(String name) {
    return 'For $name';
  }

  @override
  String get cashierParkNote => 'Note (optional)';

  @override
  String get cashierParkNoteHint => 'e.g. Front table';

  @override
  String cashierParkNoteTooLong(int max) {
    return 'Note can be at most $max characters.';
  }

  @override
  String get cashierParkFailed => 'Could not save the bill. Try again.';

  @override
  String cashierParkedButton(int count) {
    return 'Saved bills ($count)';
  }

  @override
  String get cashierParkedTitle => 'Saved bills';

  @override
  String get cashierParkedEmpty => 'No saved bills yet.';

  @override
  String get cashierParkedNoName => 'Unnamed';

  @override
  String cashierParkedMeta(int count, String time, String staff) {
    return '$count items · saved $time by $staff';
  }

  @override
  String get cashierParkedResume => 'Continue';

  @override
  String get cashierParkedDelete => 'Delete';

  @override
  String get cashierParkedCartBusy => 'Save or clear the cart first.';

  @override
  String get cashierParkedLoadFailed => 'Could not load saved bills.';

  @override
  String get cashierParkedResumeFailed =>
      'The bill can\'t be continued (it may have been paid or deleted).';

  @override
  String get cashierParkedDeleteTitle => 'Delete saved bill?';

  @override
  String cashierParkedDeleteBody(String name) {
    return '$name will be deleted. Stock is unchanged because the bill was not paid.';
  }

  @override
  String get cashierParkedDeleteFailed => 'Could not delete the saved bill.';

  @override
  String get cashierParkedClose => 'Close';

  @override
  String cashierResumeDropped(int count) {
    return '$count items were removed because their products were deleted.';
  }

  @override
  String get cashierResumedFrom => 'From saved bill';

  @override
  String get paymentErrorParked =>
      'This saved bill was already paid or deleted elsewhere. Finish again to record it as a new sale.';

  @override
  String get cashierResumeDiscountDropped =>
      'The saved bill\'s discounts were removed because you don\'t have discount permission.';

  @override
  String get approvalDiscountResumed => 'Discount from a saved bill';

  @override
  String get productsImport => 'Import Excel';

  @override
  String get productImportTitle => 'Import products';

  @override
  String get productImportIntro =>
      'Choose an Excel (.xlsx) or CSV file, one product per row. Columns: Name and Price (required), Category, Type (goods/service/menu), Unit, SKU, Barcode, Cost, Opening stock, Min stock. Headers may be in Indonesian or English.';

  @override
  String get productImportMissingColumns =>
      'The header row has no Name or Price column.';

  @override
  String get productImportEmpty => 'The file has no product rows.';

  @override
  String get productImportSkipNote =>
      'Only adds new products. Rows whose name, SKU, or barcode already exists are skipped; edit those in the product form.';

  @override
  String get productImportReasonPrice => 'price missing or not whole rupiah';

  @override
  String get productImportReasonCost => 'cost is not whole rupiah';

  @override
  String get productImportReasonStock => 'stock is not a number';

  @override
  String get productImportReasonKind => 'type is not goods, service, or menu';

  @override
  String get productImportReasonCode => 'duplicate SKU or barcode in the file';

  @override
  String get productImportReasonName => 'duplicate name in the file';

  @override
  String productImportRun(int count) {
    return 'Import $count products';
  }

  @override
  String get productImportCancel => 'Cancel';

  @override
  String productImportDone(int created, int skipped) {
    return 'Done: $created new products, $skipped skipped because they already exist.';
  }

  @override
  String productImportSkippedLines(String lines) {
    return 'Skipped rows: $lines';
  }

  @override
  String get diningDiscountHint =>
      'For the whole bill. Service charge and tax are applied after the discount.';

  @override
  String get diningDiscountBlocksPay =>
      'The discount uses up the bill total. Change or remove it before paying.';

  @override
  String get cashierCustomerNew => 'New customer';

  @override
  String get productTierGroupMissing =>
      'A customer group in the wholesale prices was deleted. Choose the group again and save.';

  @override
  String get groupErrHasPrices =>
      'The group is still used in product wholesale prices; change those prices first.';

  @override
  String cashierGroupTierNote(String qty) {
    return 'group price ≥ $qty';
  }

  @override
  String get productArchive => 'Archive product';

  @override
  String get productArchiveHint =>
      'For products you no longer sell. Sales and purchase history stay, and the product can be restored.';

  @override
  String productArchiveTitle(String name) {
    return 'Archive $name?';
  }

  @override
  String get productArchiveBody =>
      'The product disappears from the cashier, product list, stock, and purchases. Sales and purchase history stay. You can restore it from the Archived button on the product list.';

  @override
  String productArchiveStockWarning(String stock, String unit) {
    return 'The remaining stock of $stock $unit will no longer count in stock and stock value.';
  }

  @override
  String get productArchiveConfirm => 'Archive';

  @override
  String productsArchived(int count) {
    return 'Archived ($count)';
  }

  @override
  String get productsArchivedTitle => 'Archived products';

  @override
  String get productsArchivedEmpty => 'No archived products yet.';

  @override
  String productsArchivedStock(String stock, String unit) {
    return 'Stock $stock $unit';
  }

  @override
  String get productsRestore => 'Restore';

  @override
  String productsRestored(String name) {
    return '$name is back on the product list.';
  }

  @override
  String productsRestoreTaken(String name) {
    return 'This product\'s barcode or SKU is now used by $name. Change the code on $name first, then restore again.';
  }

  @override
  String get productsArchivedClose => 'Close';

  @override
  String get productsLabels => 'Print labels';

  @override
  String get labelsTitle => 'Print barcode labels';

  @override
  String get labelsSubtitle =>
      'Pick products and label counts. The barcode is used when set, otherwise the SKU.';

  @override
  String get labelsBack => 'Back';

  @override
  String get labelsSearch => 'Search name, SKU or barcode';

  @override
  String labelsSelectedOnly(int count) {
    return 'Selected only ($count)';
  }

  @override
  String get labelsFillStock => 'Match stock';

  @override
  String get labelsNoCode => 'No barcode/SKU';

  @override
  String get labelsBadCode => 'Code can\'t be printed';

  @override
  String get labelsEmpty => 'No matching products.';

  @override
  String get labelsLess => 'Less';

  @override
  String get labelsMore => 'More';

  @override
  String get labelsSettings => 'Label settings';

  @override
  String get labelsPaper => 'Paper';

  @override
  String get labelsPaperA4 => 'A4 · 24 labels (3 × 8)';

  @override
  String get labelsPaperA4Hint => 'A4 sticker sheet, 70 × 37 mm per label.';

  @override
  String labelsPaperRoll(String size) {
    return 'Label $size';
  }

  @override
  String get labelsPaperRollHint => 'Label printer, one label per page.';

  @override
  String get labelsSkip => 'Skip first labels';

  @override
  String get labelsSkipHint => 'For a partly used sheet (0–23).';

  @override
  String get labelsShowPrice => 'Show price';

  @override
  String get labelsPreview => 'Preview';

  @override
  String get labelsPreviewEmpty => 'Pick a product to see a preview.';

  @override
  String labelsTotal(int labels, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      labels,
      locale: localeName,
      other: '$labels labels',
      one: '1 label',
    );
    String _temp1 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '$pages pages',
      one: '1 page',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String labelsOverLimit(int max) {
    return 'At most $max labels per print. Lower the counts.';
  }

  @override
  String get labelsPrint => 'Print';

  @override
  String get labelsSave => 'Save PDF';

  @override
  String labelsSaved(String path) {
    return 'PDF saved to $path';
  }

  @override
  String get productPhotoPick => 'Choose photo';

  @override
  String get productPhotoChange => 'Change photo';

  @override
  String get productPhotoTake => 'Take photo';

  @override
  String get productPhotoRemove => 'Remove photo';

  @override
  String get productPhotoHint =>
      'PNG, JPG or WebP, up to 2 MB. Saved when you press Save.';

  @override
  String get productPhotoUnsupported =>
      'The file isn\'t a PNG, JPG or WebP image.';

  @override
  String get productPhotoTooLarge =>
      'The photo is over 2 MB. Pick a smaller one.';

  @override
  String get productPhotoNotSaved =>
      'The product was saved, but the photo wasn\'t. Try Save again.';

  @override
  String get productPhotoUnreadable =>
      'Couldn\'t open the photo. Check the camera permission or pick another file.';

  @override
  String get recapTitle => 'CASH SESSION RECAP';

  @override
  String get recapDevice => 'Device';

  @override
  String get recapOpened => 'Opened';

  @override
  String get recapOpenedBy => 'Opened by';

  @override
  String get recapClosed => 'Closed';

  @override
  String get recapClosedBy => 'Closed by';

  @override
  String get recapCash => 'Cash';

  @override
  String get recapNonCash => 'Non-cash';

  @override
  String get recapCredit => 'Credit (receivable)';

  @override
  String get recapOpening => 'Opening cash';

  @override
  String get recapInflow => 'Cash in';

  @override
  String get recapOutflow => 'Cash out';

  @override
  String recapNote(String note) {
    return 'Note: $note';
  }

  @override
  String get cashCloseAndPrint => 'Close session & print recap';

  @override
  String get cashRecapPrint => 'Print recap';

  @override
  String get cashRecapPrinted => 'Recap sent to the printer.';

  @override
  String get cashRecapShareError => 'Couldn\'t create the recap PDF.';

  @override
  String get receiptLogo => 'Receipt logo';

  @override
  String get receiptLogoHint =>
      'PNG or JPG up to 1 MB. A black-and-white logo on a white background prints clearest on thermal printers.';

  @override
  String get receiptLogoPick => 'Choose logo';

  @override
  String get receiptLogoChange => 'Change logo';

  @override
  String get receiptLogoRemove => 'Remove logo';

  @override
  String get receiptLogoMissing => 'The logo file isn\'t on this device yet.';

  @override
  String get receiptShowLogo => 'Show logo on receipts';

  @override
  String get receiptLogoUnsupported => 'The logo must be a PNG or JPG.';

  @override
  String get receiptLogoTooLarge =>
      'The logo is over 1 MB. Choose a smaller file.';

  @override
  String get diningMerge => 'Merge tables';

  @override
  String diningMergeTitle(String label) {
    return 'Merge into $label';
  }

  @override
  String get diningMergeHint =>
      'Items, kitchen tickets and guests of the chosen table move to this bill. That table becomes empty.';

  @override
  String get diningMergeNone =>
      'No other table can be merged. The table needs an open bill and “Can be joined with the next table” turned on (floor plan or Master data › Tables & areas), without a split, bill discount, or a different customer.';

  @override
  String diningMergeOption(String label, String total) {
    return '$label · $total';
  }

  @override
  String get diningErrorMergeSplit =>
      'A bill is split or has part payments. Cancel the split first.';

  @override
  String get diningErrorMergeDiscount =>
      'The merged table\'s bill has a bill discount. Remove it first.';

  @override
  String get diningErrorMergeGuests => 'Combined guests exceed 99.';

  @override
  String get diningErrorMergeNotAllowed => 'These tables can\'t be merged.';

  @override
  String get diningSetupCanMergeHint =>
      'This table\'s bill can be merged with another table via Merge tables.';

  @override
  String get diningSetupCanMerge => 'Can merge';

  @override
  String get kitchenPrinterTitle => 'Kitchen printer';

  @override
  String get kitchenPrinterSubtitle =>
      'Kitchen tickets print here automatically on Send to kitchen. Saved on this device only.';

  @override
  String get kitchenPrinterSame => 'Same as receipt printer';

  @override
  String get kitchenPrinterSameNote =>
      'Kitchen tickets print to this device\'s receipt printer with the Print ticket button.';

  @override
  String get kitchenPrinterForget => 'Forget kitchen printer';

  @override
  String get kitchenPaperWidth => 'Ticket paper width';

  @override
  String get kitchenPrinterTest => 'Test print ticket';

  @override
  String get kitchenPrinterTestSent =>
      'Sample ticket sent to the kitchen printer.';

  @override
  String get ticketPrintingKitchen =>
      'Printing the ticket on the kitchen printer…';

  @override
  String get ticketPrintedKitchen => 'Ticket printed on the kitchen printer.';

  @override
  String get ticketReprint => 'Reprint';

  @override
  String get diningCustomerPick => 'Choose customer';

  @override
  String get diningCustomerChange => 'Change';

  @override
  String get diningCustomerClear => 'Remove customer';

  @override
  String diningCustomerLabel(String name) {
    return 'Customer: $name';
  }

  @override
  String diningCustomerGroupLabel(String name, String group) {
    return 'Customer: $name · $group';
  }

  @override
  String diningCustomerTitle(String label) {
    return 'Customer for $label';
  }

  @override
  String get diningCustomerHint =>
      'The customer\'s group prices apply to every item on the bill.';

  @override
  String get diningErrorCustomerBlocked =>
      'The customer can\'t be changed while the bill is split.';

  @override
  String get diningErrorCustomerNotFound =>
      'Customer not found or already deleted.';

  @override
  String get diningErrorMergeCustomer =>
      'The two tables have different customers.';

  @override
  String get cashierErrorBillCustomerMismatch =>
      'Credit must be in the bill customer\'s name. Change the customer on the table panel.';

  @override
  String diningServedWithoutTicket(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return '$count $_temp0 without a kitchen ticket marked as served.';
  }

  @override
  String get productKitchenTitle => 'Kitchen';

  @override
  String get productSendToKitchen => 'Send to kitchen ticket';

  @override
  String get productSendToKitchenHint =>
      'Turn off for items that are not cooked (e.g. bottled water): they are served right away without a kitchen ticket.';

  @override
  String get productAllowNote => 'Allow free-text notes';

  @override
  String get productAllowNoteHint =>
      'Turn off when the item cannot be customised; kitchen notes are ignored.';

  @override
  String get diningNoteNotAllowed => 'Note kept for the next item.';

  @override
  String get debtVoidAction => 'Void payment';

  @override
  String debtVoidTitle(String number) {
    return 'Void $number?';
  }

  @override
  String get debtVoidBodyCustomer =>
      'Its allocations are removed so the outstanding balance returns to what it was before the payment. The payment stays on record marked Void; record it again if needed.';

  @override
  String get debtVoidBodySupplier =>
      'Its allocations are removed so the amount owed returns to what it was before the payment. The payment stays on record marked Void; record it again if needed.';

  @override
  String get debtVoidReason => 'Reason';

  @override
  String get debtVoidReasonHint => 'e.g. Wrong amount, will re-record';

  @override
  String debtVoidErrReason(int max) {
    return 'Enter a reason of at most $max characters.';
  }

  @override
  String debtVoidDrawerOut(String amount) {
    return '$amount is taken out of the drawer in the open cashier session.';
  }

  @override
  String debtVoidDrawerIn(String amount) {
    return '$amount is put back into the drawer in the open cashier session.';
  }

  @override
  String get debtVoidBack => 'Back';

  @override
  String get debtVoidConfirm => 'Yes, void';

  @override
  String get debtVoided => 'Void';

  @override
  String debtVoidedInfo(String reason) {
    return 'Void: $reason';
  }

  @override
  String get debtErrAlreadyVoided => 'This payment is already void.';

  @override
  String get debtErrNoSession =>
      'Open a cashier session first: the drawer cash must be reversed.';

  @override
  String get kuitansiVoidStamp => 'VOID';

  @override
  String get kuitansiVoidReason => 'Void reason';

  @override
  String get reportsSourceDebtPaymentVoid => 'Voided customer payment';

  @override
  String get reportsSourceSupplierPaymentVoid => 'Voided supplier payment';

  @override
  String get cashSourceDebtPaymentVoid => 'Voided receivable payment';

  @override
  String get cashSourceSupplierPaymentVoid => 'Voided supplier payment';

  @override
  String get debtErrNotFound =>
      'Payment not found, or its customer/supplier was deleted.';

  @override
  String get suppliersImport => 'Import Excel';

  @override
  String get supplierImportTitle => 'Import suppliers';

  @override
  String get supplierImportIntro =>
      'Choose an Excel (.xlsx) or CSV file. Columns: Name (required), Contact, Phone, Category, Term days, Address, Note. Headers can be in Indonesian or English.';

  @override
  String supplierImportUpdateNote(int days) {
    return 'Rows with a registered supplier name update that supplier (empty cells keep the old data). New suppliers without a term get $days days.';
  }

  @override
  String get supplierImportEmpty => 'The file has no supplier rows.';

  @override
  String get supplierImportReasonPhone => 'invalid phone number';

  @override
  String get supplierImportReasonTerm => 'term is not 0–365 days';

  @override
  String get supplierImportReasonDuplicate => 'name repeated in the file';

  @override
  String supplierImportRun(int count) {
    return 'Import $count suppliers';
  }

  @override
  String supplierImportDone(int created, int updated, int skipped) {
    return 'Done: $created new suppliers, $updated updated, $skipped rows skipped.';
  }

  @override
  String get onboardingRestoreHint =>
      'Moving to a new device? Install your store\'s backup here instead of creating a new store.';

  @override
  String get onboardingRestoreAction => 'Restore from backup';

  @override
  String get setupRestoreIntro =>
      'Choose a Lakuna backup file (.zip) made in Settings › Data & backup on the old device.';

  @override
  String get setupRestorePick => 'Choose backup file';

  @override
  String get setupRestoreWarning =>
      'The backup is installed on this device, then the app reloads and you sign in with a PIN from the backup. Don\'t use the same backup on two devices at once.';

  @override
  String get setupRestoreAlreadySetUp =>
      'A store already exists on this device. Restore from Settings › Data & backup instead.';

  @override
  String get setupRestoreReopen =>
      'The backup is ready. Close and reopen the app to finish restoring.';

  @override
  String get importTemplateDownload => 'Download template';

  @override
  String importTemplateSaved(String path) {
    return 'Template saved to $path';
  }

  @override
  String get importTemplateFailed =>
      'The template couldn\'t be saved. Try again.';

  @override
  String get importReasonSample =>
      'sample row from the template, replace or delete it';

  @override
  String stockPrintTitle(String location) {
    return 'Stock list · $location';
  }

  @override
  String stockPrintSubtitle(String outlet, String time, String staff) {
    return '$outlet · printed $time · $staff';
  }

  @override
  String get stockPrintColCode => 'SKU / Barcode';

  @override
  String get stockPrintColCounted => 'Counted';

  @override
  String stockPrintCounts(int items, int below, int minus) {
    return '$items items · $below below minimum · $minus negative stock';
  }

  @override
  String get stockPrintNote =>
      'Write the counted quantity in the Counted column, then record the difference in the Stock menu, Adjustment tab.';

  @override
  String get stockPrint => 'Print stock';

  @override
  String stockPrintSaved(String path) {
    return 'Stock list saved to $path';
  }

  @override
  String get stockPrintFailed => 'Could not create the stock list. Try again.';
}
