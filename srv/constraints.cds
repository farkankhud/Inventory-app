using { InventoryService } from './inventory-service';

annotate InventoryService.Products with {

  // cross-field: selling price cannot exceed list price
  price @assert: (case
    when price > listPrice
      then 'Price must not be higher than the list price'
  end);

  // cross-field: date ordering
  validFrom @assert: (case
    when validFrom > validTo
      then 'Valid-from date must be before valid-to date'
  end);

  // cross-field: an active product must not sit below its reorder level
  stock @assert: (case
    when status = 'ACTIVE' and stock < reorderLevel
      then 'Active product cannot be below its reorder level'
  end);

  // combined discount + price sanity check
  discount @assert: (case
    when discount > 0 and price * (1 - discount / 100) <= 0
      then 'Discount would make the effective price zero or negative'
  end);
};

annotate InventoryService.Categories with {

  // cross-entity: uses an association path with an infix filter
  maxProducts @assert: (case
    when exists products[status = 'ACTIVE'] and maxProducts is null
      then 'Set a product limit for a category that already has active products'
  end);
};
