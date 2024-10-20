public with sharing class FieldHistoryController {
    
    // Method to fetch history records for any object based on recordId
    @AuraEnabled(cacheable=true)
    public static List<sObject> getHistoryRecords(String objectApiName, Id recordId) {
        try {
            // Construct the query dynamically for standard or custom object history
            String query = 'SELECT Field, OldValue, NewValue, CreatedById, CreatedDate FROM ' + 
                            objectApiName + ' WHERE ParentId = :recordId ORDER BY CreatedDate DESC';
            return Database.query(query);
        } catch (Exception e) {
            // Handle any exceptions
            throw new AuraHandledException('Error fetching history: ' + e.getMessage());
        }
    }
}