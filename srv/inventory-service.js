const cds = require('@sap/cds');

const RX_EMAIL = /^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$/;
const RX_PHONE = /^\+?[1-9]\d{7,14}$/;
const RX_CODE  = /^PROD-[0-9]{4}$/;

module.exports = cds.service.impl(async function () {
  const { Products } = this.entities;

  this.on('restock', Products, async (req) => {
    let test1;
    const id = req.params[0].ID;
    await UPDATE(Products, id).with({ stock: { '+=': req.data.quantity } });
    return SELECT.one.from(Products, id);
  });

  this.on('discontinue', Products, async (req) => {
    
    const id = req.params[0].ID;
    const p = await SELECT.one.from(Products, id);
    if (p.stock > 0) return req.reject(400, `Cannot discontinue: ${p.stock} units still in stock`);
    await UPDATE(Products, id).with({ status: 'DISCONTINUED' });
    return SELECT.one.from(Products, id);
  });

  this.on('applyDiscount', Products, async (req) => {
    const id = req.params[0].ID;
    const p = await SELECT.one.from(Products, id);
    if (p.status === 'DISCONTINUED')
      return req.reject(400, 'Cannot discount a discontinued product');
    await UPDATE(Products, id).with({ discount: req.data.percent });
    return SELECT.one.from(Products, id);
  });

  this.on('stockValue', Products, async (req) => {
    const p = await SELECT.one.from(Products, req.params[0].ID);
    return p.price * p.stock * (1 - (p.discount || 0) / 100);
  });

  // Bound validation function — full record health check
  this.on('validateProduct', Products, async (req) => {
    const p = await SELECT.one.from(Products, req.params[0].ID);
    const errors = [], warnings = [];

    if (p.price > p.listPrice)        errors.push('Price exceeds list price');
    if (p.validFrom && p.validTo && p.validFrom > p.validTo)
                                      errors.push('Valid-from is after valid-to');
    if (p.supplierEmail && !RX_EMAIL.test(p.supplierEmail))
                                      errors.push('Supplier email is malformed');
    if (p.stock < p.reorderLevel)     warnings.push('Stock is below reorder level');
    if (p.discount >= 50)             warnings.push('Discount is unusually high');
    if (p.stock === 0 && p.status === 'ACTIVE')
                                      warnings.push('Active product is out of stock');

    return { valid: errors.length === 0, errors, warnings };
  });

  this.on('lowStock', async (req) =>
    SELECT.from(Products).where({ stock: { '<': req.data.threshold } }));

  this.on('isCodeAvailable', async (req) => {
    const { code } = req.data;
    if (!RX_CODE.test(code)) return false;
    return !(await SELECT.one.from(Products).where({ code }));
  });

  this.on('validateContact', async (req) => {
    const { phone, email } = req.data;
    const errors = [], warnings = [];
    if (phone && !RX_PHONE.test(phone)) errors.push('Invalid phone number format');
    if (email && !RX_EMAIL.test(email)) errors.push('Invalid email format');
    if (!phone && !email) warnings.push('No contact details provided');
    return { valid: errors.length === 0, errors, warnings };
  });

  this.on('bulkPriceIncrease', async (req) => {
    const { categoryID, percent } = req.data;
    const rows = await SELECT.from(Products).where({ category_ID: categoryID });
    if (!rows.length) return req.reject(404, 'No products found for that category');

    let updated = 0;
    for (const p of rows) {
      const newPrice = Number((p.price * (1 + percent / 100)).toFixed(2));
      if (newPrice > p.listPrice) continue;   // respects the same rule as the DB constraint
      await UPDATE(Products, p.ID).with({ price: newPrice });
      updated++;
    }
    return { updated, message: `${updated} of ${rows.length} products updated (rest would exceed list price)` };
  });
});
