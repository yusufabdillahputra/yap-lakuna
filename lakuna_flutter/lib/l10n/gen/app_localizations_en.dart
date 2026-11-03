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
  String get homeWelcomeTitle => 'Welcome to Lakuna';

  @override
  String get homeWelcomeBody =>
      'Retail checkout, cash sessions, products, and stock are ready to use. Purchases, history, and reports follow in upcoming releases.';

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
  String get billSplitUnassigned => 'Not assigned';

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
}
