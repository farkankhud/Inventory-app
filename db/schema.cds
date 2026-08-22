using { cuid, managed } from '@sap/cds/common';

namespace app.inventory;

entity Categories : cuid {
  name         : String(40)  @mandatory @assert.unique;
  description  : String(200);
  contactEmail : String(100) @assert.format: '^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$'
                             @assert.format.message: 'Enter a valid email address';
  contactPhone : String(20)  @assert.format: '^\+?[1-9]\d{7,14}$'
                             @assert.format.message: 'Enter a valid E.164 phone number, e.g. +14155550101';
  maxProducts  : Integer     @assert.range: [(0), 500]
                             @assert.range.message: 'Must be more than 0 and at most 500';
  products     : Association to many Products on products.category = $self;
}

entity Products : cuid, managed {
  name          : String(100)  @mandatory;

  code          : String(20)   @mandatory
                               @Core.Immutable
                               @assert.unique
                               @assert.format: '^PROD-[0-9]{4}$'
                               @assert.format.message: 'Code must look like PROD-followed by 4 numbers';

  listPrice     : Decimal(10,2) @mandatory @assert.range: [(0), _];
  price         : Decimal(10,2) @mandatory @assert.range: [(0), _];
  discount      : Decimal(5,2)  @assert.range: [0, 90] default 0;

  stock         : Integer @mandatory @assert.range: [0, 100000] default 0;
  reorderLevel  : Integer @assert.range: [(0), _] default 10;

  validFrom     : Date;
  validTo       : Date;

  supplierEmail : String(100) @assert.format: '^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$'
                              @assert.format.message: 'Enter a valid supplier email';

  status        : String(15) @mandatory @assert.range enum {
    ACTIVE;
    DISCONTINUED;
  } default 'ACTIVE';

  category      : Association to Categories @mandatory @assert.target;
}
