trigger PurchaseItemTrigger on Purchase_Item__c (before insert, before update) {
    
    // Set the Price field
    PurchaseItemTriggerHandler.setPriceTotal(Trigger.new, Trigger.oldMap);

}