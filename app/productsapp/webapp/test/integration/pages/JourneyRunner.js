sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"inventory/productsapp/test/integration/pages/ProductsList.gen",
	"inventory/productsapp/test/integration/pages/ProductsObjectPage.gen"
], function (JourneyRunner, ProductsListGenerated, ProductsObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('inventory/productsapp') + '/test/flpSandbox.html#inventoryproductsapp-tile',
        pages: {
			onTheProductsListGenerated: ProductsListGenerated,
			onTheProductsObjectPageGenerated: ProductsObjectPageGenerated
        },
        async: true
    });

    return runner;
});

