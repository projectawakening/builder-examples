//SPDX-LicenseIdentifier: MIT
pragma solidity >=0.8.21;

interface IItemSellerErrors {
  error ItemSeller_NotSSUOwner(uint256 smartObjectId);
  error ItemSeller_WrongItemArrayLength();
  error ItemSeller_WrongWithdrawType(uint256 expectedItemId, uint256 itemId);
  error ItemSeller_DelegatedERC20TransferUnauthorized();
  error ItemSeller_WithdrawingTooMuch(uint256 smartObjectId);
  error ItemSeller_BuybackPriceNotSet(uint256 smartObjectId);
  error ItemSeller_PurchasePriceNotSet(uint256 smartObjectId);
}
