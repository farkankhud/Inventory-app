using InventoryService as service from './inventory-service';

annotate service.Products with {
  name          @Common.Label: 'Product Name';
  code          @Common.Label: 'Product Code';
  listPrice     @Common.Label: 'List Price';
  price         @Common.Label: 'Selling Price';
  discount      @Common.Label: 'Discount %';
  stock         @Common.Label: 'Stock Quantity';
  reorderLevel  @Common.Label: 'Reorder Level';
  validFrom     @Common.Label: 'Valid From';
  validTo       @Common.Label: 'Valid To';
  supplierEmail @Common.Label: 'Supplier Email';
  status        @Common.Label: 'Status';
  category      @Common.Label: 'Category';
};

annotate service.Categories with {
  name         @Common.Label: 'Category Name';
  description  @Common.Label: 'Description';
  contactEmail @Common.Label: 'Contact Email';
  contactPhone @Common.Label: 'Contact Phone';
  maxProducts  @Common.Label: 'Max Products';
};

annotate service.Products with @(
  UI: {
    HeaderInfo: {
      TypeName: 'Product', TypeNamePlural: 'Products',
      Title: { Value: name }, Description: { Value: code }
    },
    SelectionFields: [ status, category_ID ],
    LineItem: [
      { Value: code },
      { Value: name },
      { Value: category.name, Label: 'Category' },
      { Value: price },
      { Value: discount },
      { Value: stock },
      { Value: status },
      { $Type: 'UI.DataFieldForAction', Action: 'InventoryService.restock',      Label: 'Restock' },
      { $Type: 'UI.DataFieldForAction', Action: 'InventoryService.discontinue',  Label: 'Discontinue' }
    ],
    Facets: [
      { $Type: 'UI.ReferenceFacet', Label: 'General',   Target: '@UI.FieldGroup#Main' },
      { $Type: 'UI.ReferenceFacet', Label: 'Pricing',   Target: '@UI.FieldGroup#Pricing' },
      { $Type: 'UI.ReferenceFacet', Label: 'Stock',     Target: '@UI.FieldGroup#Stock' },
      { $Type: 'UI.ReferenceFacet', Label: 'Validity',  Target: '@UI.FieldGroup#Validity' }
    ],
    FieldGroup#Main:     { Data: [ { Value: name }, { Value: code }, { Value: status }, { Value: category_ID }, { Value: supplierEmail } ] },
    FieldGroup#Pricing:  { Data: [ { Value: listPrice }, { Value: price }, { Value: discount } ] },
    FieldGroup#Stock:    { Data: [ { Value: stock }, { Value: reorderLevel } ] },
    FieldGroup#Validity: { Data: [ { Value: validFrom }, { Value: validTo } ] },
    Identification: [
      { $Type: 'UI.DataFieldForAction', Action: 'InventoryService.restock',        Label: 'Restock' },
      { $Type: 'UI.DataFieldForAction', Action: 'InventoryService.discontinue',    Label: 'Discontinue' },
      { $Type: 'UI.DataFieldForAction', Action: 'InventoryService.applyDiscount',  Label: 'Apply Discount' },
      { $Type: 'UI.DataFieldForAction', Action: 'InventoryService.validateProduct',Label: 'Validate' }
    ]
  }
) {
  ID @UI.Hidden;
};

annotate service.Products:category with @(
  Common.ValueList: {
    $Type: 'Common.ValueListType', CollectionPath: 'Categories',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut',       LocalDataProperty: category_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' }
    ]
  }
);

annotate service.Categories with @(
  UI: {
    HeaderInfo: { TypeName: 'Category', TypeNamePlural: 'Categories', Title: { Value: name } },
    LineItem: [ { Value: name }, { Value: description }, { Value: contactEmail }, { Value: contactPhone }, { Value: maxProducts } ],
    Facets: [ { $Type: 'UI.ReferenceFacet', Label: 'Details', Target: '@UI.FieldGroup#Contact' } ],
    FieldGroup#Contact: { Data: [ { Value: name }, { Value: description }, { Value: contactEmail }, { Value: contactPhone }, { Value: maxProducts } ] }
  }
) { ID @UI.Hidden };
