using { app.inventory as db } from '../db/schema';

service InventoryService @(path:'/inventory') {

  @odata.draft.enabled
  entity Categories as projection on db.Categories;

  @odata.draft.enabled
  entity Products as projection on db.Products actions {
    action restock(quantity: Integer @mandatory @assert.range: [(0), 10000]) returns Products;
    action discontinue()                                                     returns Products;
    action applyDiscount(percent: Decimal @mandatory @assert.range: [0, 90]) returns Products;
    function stockValue()                                                    returns Decimal(12,2);
    function validateProduct()                                               returns ValidationResult;
  };

  function lowStock(threshold: Integer @assert.range: [0, 100000]) returns array of Products;
  function isCodeAvailable(code: String @mandatory)                returns Boolean;

  action validateContact(
    phone : String,
    email : String
  ) returns ValidationResult;

  action bulkPriceIncrease(
    categoryID : UUID    @mandatory,
    percent    : Decimal @mandatory @assert.range: [(0), 50]
  ) returns { updated : Integer; message : String; };

  type ValidationResult {
    valid    : Boolean;
    errors   : array of String;
    warnings : array of String;
  };
}
