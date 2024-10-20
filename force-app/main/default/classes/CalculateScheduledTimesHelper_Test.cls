/*
Copyright Sirenum Ltd 2022
*/

@IsTest
private class CalculateScheduledTimesHelper_Test {
    
    @IsTest
    static void testInsertUpdateStandardShifts(){
        
        //This is a Shift test, and must run with Disable Site Timezones OFF.
        LocalTimeSettingProvider.addSetting('default', false);
        
        Account account = new Account(Name='Test Account');
        insert account;
        
        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = 'test project team';
        insert projectTeam;
        
        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='test project';
        project.sirenum__Client__c = account.Id;
        project.Opportunity_Number__c = '1897';
        project.Illingworth_Protocol_ID__c='12578';
        project.Project_Team__c = projectTeam.Id;
        project.Off_site_Activities__c = 'test off site';
        insert project;
        
        sirenum__Site__c site = new sirenum__Site__c(
            Name='Test Site',
            sirenum__Operating_Company__c=account.Id,
            Project__c = project.Id,
            sirenum__City__c = 'New York',
            sirenum__Country__c = 'USA',
            sirenum__Timezone__c='America/New_York');
        insert site;
        
        sirenum__Shift__c shift = new sirenum__Shift__c(
            sirenum__Site__c = site.Id,
            sirenum__Scheduled_Start_Time__c = Datetime.newInstanceGmt(2022,09,28,23,0,0),//12 (-12)
            sirenum__Scheduled_End_Time__c = Datetime.newInstanceGmt(2022,09,29,22,0,0),//20 (+3)
            Visit_Request_received_from_Site__c = true
        );
        insert shift;
        
        //In the summer, this should be converted to Eastern Daylight Time (UTC-4)
        //In the winter, this should be converted to Eastern Standard Time (UTC-5)
        
        shift = [SELECT Id,
                 sirenum__Scheduled_Start_Time__c,
                 sirenum__Scheduled_End_Time__c,
                 Scheduled_Start_Time_local__c,
                 Scheduled_End_Time_local__c
                 FROM sirenum__Shift__c
                 WHERE Id = :shift.Id
                 LIMIT 1][0];
        
        System.assertEquals(23, shift.sirenum__Scheduled_Start_Time__c.hourGmt());
        System.assertEquals(22, shift.sirenum__Scheduled_End_Time__c.hourGmt());
        
        //Shift was inserted as expected, check the conversion
        TimeZone nyTimezone = TimeZone.getTimeZone('America/New_York');
        Integer nyOffsetHours = nyTimezone.getOffset(shift.sirenum__Scheduled_Start_Time__c)/1000/60/60;
        
        System.assert(nyOffsetHours == -4);
        
        //System.assertEquals(shift.sirenum__Scheduled_Start_Time__c.hourGmt()+nyOffsetHours, Integer.valueOf(shift.Scheduled_Start_Time_local__c.Substring(0,2)));
        //System.assertEquals(shift.sirenum__Scheduled_End_Time__c.hourGmt()+nyOffsetHours, Integer.valueOf(shift.Scheduled_End_Time_local__c.Substring(0,2)));
        
        //Now update locals
        shift.Scheduled_Start_Time_local__c = shift.sirenum__Scheduled_Start_Time__c.addHours(nyOffsetHours).addHours(6).format('HH:mm');
        update shift;
        
        shift = [SELECT Id,
                 sirenum__Scheduled_Start_Time__c,
                 sirenum__Scheduled_End_Time__c,
                 Scheduled_Start_Time_local__c,
                 Scheduled_End_Time_local__c
                 FROM sirenum__Shift__c
                 WHERE Id = :shift.Id
                 LIMIT 1][0];
        
        System.assertEquals(shift.sirenum__Scheduled_Start_Time__c.hourGmt()+nyOffsetHours, Integer.valueOf(shift.Scheduled_Start_Time_local__c.Substring(0,2)));
        
        shift.sirenum__Scheduled_Start_Time__c = shift.sirenum__Scheduled_Start_Time__c.addHours(-1);
        update shift;
        
        shift = [SELECT Id,
                 sirenum__Scheduled_Start_Time__c,
                 sirenum__Scheduled_End_Time__c,
                 Scheduled_Start_Time_local__c,
                 Scheduled_End_Time_local__c
                 FROM sirenum__Shift__c
                 WHERE Id = :shift.Id
                 LIMIT 1][0];
        
        System.assertEquals(shift.sirenum__Scheduled_Start_Time__c.hourGmt()+nyOffsetHours, Integer.valueOf(shift.Scheduled_Start_Time_local__c.Substring(0,2)));
        
    }
    
    @IsTest
    static void testInsertUpdateStandardEmployeeRequests(){
        //This is an Employee Request test, and must run with Disable Site Timezones ON.
        LocalTimeSettingProvider.addSetting('default', true);
        
        //Resource Account
        RecordType resourcePoolRT = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name = 'Resource Pool'];
        Account account = new Account(Name='Test Account', RecordTypeId = resourcePoolRT.Id);
        insert account;
        
        Contact contact = new Contact(
            FirstName = 'Test1',
            LastName = 'Test1',
            AccountId = account.Id,
            Work_Country__c='USA',
            Illing_Licenced_in_States_Province__c='New York',
            MailingCountry = 'USA',
            MailingCity = 'New York',
            MailingState='New York',
            Email='illingworth.test@bullhorn.com.test'
        );
        insert contact;
        
        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = 'test project team';
        insert projectTeam;
        
        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='test project';
        project.sirenum__Client__c = account.Id;
        project.Opportunity_Number__c = '1897';
        project.Illingworth_Protocol_ID__c='12578';
        project.Project_Team__c = projectTeam.Id;
        project.Off_site_Activities__c = 'test off site';
        insert project;
        
        sirenum__Site__c site = new sirenum__Site__c(
            Name='Test Site',
            sirenum__Operating_Company__c=account.Id,
            Project__c = project.Id,
            sirenum__City__c = 'New York',
            sirenum__Country__c = 'USA',
            sirenum__Timezone__c='America/New_York');
        insert site;
        
        Date requestDate = Date.newInstance(2024,03,04);
        Datetime requestStartTime = Datetime.newInstance(requestDate, Time.newInstance(09,0,0,0));
        Datetime requestEndTime = Datetime.newInstance(requestDate, Time.newInstance(17,0,0,0));
        
        sirenum__Employee_Request__c employeeRequest = new sirenum__Employee_Request__c(
            sirenum__Contact__c = contact.Id,
            sirenum__Date__c = requestDate,
            sirenum__Start_Time__c = requestStartTime,
            sirenum__End_Time__c = requestEndTime,
            sirenum__Type__c = 'Holiday',
            sirenum__Description__c = 'test holiday'
        );
        insert employeeRequest;
        
        employeeRequest = [
            SELECT Id, Scheduled_Day_local__c, Scheduled_Start_Time_local__c, Scheduled_End_Time_local__c, sirenum__Start_Time__c, sirenum__End_Time__c
            FROM sirenum__Employee_Request__c
            WHERE Id = :employeeRequest.Id
            LIMIT 1
        ];
        
        //Check that the start time converted to local time as expected
        System.assertEquals(04, employeeRequest.Scheduled_Day_local__c.day());
        System.assertEquals('09:00', employeeRequest.Scheduled_Start_Time_local__c);
        System.assertEquals('17:00', employeeRequest.Scheduled_End_Time_local__c);
        
        //Update standard times
        employeeRequest.sirenum__Start_Time__c = employeeRequest.sirenum__Start_Time__c.addHours(1);
        employeeRequest.sirenum__End_Time__c = employeeRequest.sirenum__End_Time__c.addHours(1);
        update employeeRequest;
        
        employeeRequest = [
            SELECT Id, Scheduled_Day_local__c, Scheduled_Start_Time_local__c, Scheduled_End_Time_local__c, sirenum__Start_Time__c, sirenum__End_Time__c
            FROM sirenum__Employee_Request__c
            WHERE Id = :employeeRequest.Id
            LIMIT 1
        ];
        
        //Check that the start time converted to local time as expected
        System.assertEquals(04, employeeRequest.Scheduled_Day_local__c.day());
        System.assertEquals('10:00', employeeRequest.Scheduled_Start_Time_local__c);
        System.assertEquals('18:00', employeeRequest.Scheduled_End_Time_local__c);
        
        //Now update locals
        employeeRequest.Scheduled_Start_Time_local__c = '09:30';
        employeeRequest.Scheduled_End_Time_local__c = '17:30';
        update employeeRequest;
        
        employeeRequest = [
            SELECT Id, Scheduled_Day_local__c, Scheduled_Start_Time_local__c, Scheduled_End_Time_local__c, sirenum__Start_Time__c, sirenum__End_Time__c
            FROM sirenum__Employee_Request__c
            WHERE Id = :employeeRequest.Id
            LIMIT 1
        ];
        
        System.assertEquals(09, employeeRequest.sirenum__Start_Time__c.hour());
        System.assertEquals(30, employeeRequest.sirenum__Start_Time__c.minute());
        System.assertEquals(17, employeeRequest.sirenum__End_Time__c.hour());
        System.assertEquals(30, employeeRequest.sirenum__End_Time__c.minute());
        
        //Insert new employee request with local times only
        sirenum__Employee_Request__c employeeRequest2 = new sirenum__Employee_Request__c(
            sirenum__Contact__c = contact.Id,
            sirenum__Date__c = requestDate,
            Scheduled_Day_local__c = requestDate,
            Scheduled_Start_Time_local__c = '11:00',
            Scheduled_End_Time_local__c = '16:00',
            sirenum__Type__c = 'Holiday',
            sirenum__Description__c = 'test holiday'
        );
        insert employeeRequest2;
        
        employeeRequest2 = [
            SELECT Id, Scheduled_Day_local__c, Scheduled_Start_Time_local__c, Scheduled_End_Time_local__c, sirenum__Start_Time__c, sirenum__End_Time__c
            FROM sirenum__Employee_Request__c
            WHERE Id = :employeeRequest2.Id
            LIMIT 1
        ];
        
        System.assertEquals(11, employeeRequest2.sirenum__Start_Time__c.hour());
        System.assertEquals(00, employeeRequest2.sirenum__Start_Time__c.minute());
        System.assertEquals(16, employeeRequest2.sirenum__End_Time__c.hour());
        System.assertEquals(00, employeeRequest2.sirenum__End_Time__c.minute());
        
    }
    
    @IsTest
    static void testProviderExistingSetting(){
        //Simply get the setting via the provider to provide coverage
        LocalTimeSettingProvider.getSetting('default');
    }
}