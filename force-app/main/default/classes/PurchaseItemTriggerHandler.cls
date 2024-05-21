public class PurchaseItemTriggerHandler {

    
    
    // Initialize the Company Owner's favorite days
    public static Map<String, Decimal> favoriteDays = new Map<String,Decimal>();

    // Set the favorite days and their discount amounts
    static {
        favoriteDays.put('10-03', 0.6); // The Company Owner's Girlfriend's birthday
        favoriteDays.put('07-13', 0.3); // The Company Owner's birthday
        favoriteDays.put('08-24', 0.4); // The Company Owner's Mom's birthday
        favoriteDays.put('05-20', 0.2); // Today's Date
    }

    // Calculate price total
    public static void setPriceTotal(List<Purchase_Item__c> newPurchaseItemList, Map<ID, Purchase_Item__c> oldPurchaseItemMap) {

        // Query for related Product__r fields
        Set<Id> productIds = new Set<Id>();
        for (Purchase_Item__c item : newPurchaseItemList) {
            if (item.Product__c != null) {
                productIds.add(item.Product__c);
            }
        }

        // Store product information in a map
        Map<Id, Product2> productMap = new Map<Id, Product2>([
            SELECT Id, Unit_Price__c 
            FROM Product2 
            WHERE Id IN :productIds
        ]);

        // Loop through the purchase items
        for (Purchase_Item__c purchaseItem : newPurchaseItemList) {
            
            // Ensure Product__r and Quantity__c are not null
            if (productMap.containsKey(purchaseItem.Product__c) && purchaseItem.Quantity__c != null) {
                Product2 product = productMap.get(purchaseItem.Product__c);

                // Set the purchase price
                Decimal purchasePrice = product.Unit_Price__c * purchaseItem.Quantity__c;
                purchasePrice = applyDiscount(purchaseItem, purchasePrice); // Apply any discount as necessary
    
                // Determine if the price has changed or was null
                if ( oldPurchaseItemMap?.get(purchaseItem.Id)?.Price__c != purchasePrice) {
                    purchaseItem.Price__c = purchasePrice; // Set the purchase price to the item
                }
            }
        }
    }

    public static Decimal applyDiscount(Purchase_Item__c purchaseItem, Decimal purchasePrice) {
        
        // Grab the created date or today if null
        Datetime createdDate = (purchaseItem.CreatedDate != null) ? purchaseItem.CreatedDate : Datetime.now();

        // Format the date into a string
        String formattedDate = String.valueOf(createdDate.month()).leftPad(2, '0') + '-' + String.valueOf(createdDate.day()).leftPad(2, '0');

        if (favoriteDays.containsKey(formattedDate)) {

            // Apply discount and return adjusted price
            Decimal discount = favoriteDays.get(formattedDate);
            Decimal adjustedPrice = purchasePrice * (1 - discount);
            return adjustedPrice;
        }

        // If the there is no discount to apply, return the original price
        return purchasePrice;
    }
}