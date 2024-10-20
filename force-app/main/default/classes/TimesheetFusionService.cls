@RestResource(urlMapping='/timesheet/*')
global class TimesheetFusionService {
    @HttpPost
    global static List<Duty__c> getTimesheet() {
        RestRequest req = RestContext.request;
        
        String jsonString = req.requestBody.toString();
        system.debug('jsonString==='+jsonString);
        Map<String, Object> timesheetData = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        
        // Access the 'ItimesheetRange' list
        List<Object> timesheetRange = (List<Object>) timesheetData.get('timesheetRange');
        
        // Retrieve the fields to be queried from custom metadata
        List<String> fieldList = new List<String>();
        for(Integration_Field__mdt record : [SELECT Field_API_Name__c FROM Integration_Field__mdt WHERE Object_Name__c = 'Duty__c']) {
            fieldList.add(record.Field_API_Name__c);
        }
       // system.debug('fieldList=='+fieldList);

        if (!timesheetRange.isEmpty()) {
            // Access the first object in the list and cast it as a Map
            Map<String, Object> timesheet = (Map<String, Object>) timesheetRange[0];
            
            // Get the startDate and endDate
            date startDate = date.valueOf((String) timesheet.get('startDate'));
            date endDate = date.valueOf((String) timesheet.get('endDate'));
            
            String fieldQueryString = String.join(fieldList, ', ');
            //system.debug('fieldQueryString=='+fieldQueryString);
            String queryString = 'SELECT ' + fieldQueryString + ' FROM Duty__c WHERE RecordType.Name = \'Worker Duty\' ' +
                'AND Date_of_Duty__c >= :startDate ' +
                'AND Date_of_Duty__c <= :endDate ' +
                'AND Status__c = \'Approved\' ' +
                'AND Locked__c = true';
            
            // Execute dynamic query
            List<Duty__c> dutyList = Database.query(queryString);
            
            return dutyList;
        }
        
        return Null;
    }  
    
    // GET method to handle retrieving contact details
    @HttpGet
    global static List<Contact> getContactDetails() {
        List<String> fieldList = new List<String>();
        for(Integration_Field__mdt record : [SELECT Field_API_Name__c FROM Integration_Field__mdt WHERE Object_Name__c = 'Contact']) {
            fieldList.add(record.Field_API_Name__c);
        }
        // Build dynamic SOQL query for Contact
        String fieldQueryString = String.join(fieldList, ', ');
        String queryString = 'SELECT ' + fieldQueryString + ' FROM Contact where Illingworth_HR_ID_Number__c != null';
        
        // Execute dynamic query
        List<Contact> contactList = Database.query(queryString);
        
        // Return the JSON response
        return contactList;
    }
}