public with sharing class InvoiceController {
  private static final String DOWNLOAD_URL = '/servlet/servlet.FileDownload?file={0}';
  public String logoUrl {get;set;}
  public List<TimesheetReportController.Worksheet> sheets {get;set;}
  public Boolean showTimesheetReport {get;set;}
  public sirenum__Invoice__c invoice;
  public String invoiceText { get;set;}
  
  public InvoiceController(ApexPages.StandardController std) {
    sirenum__TimesheetSettings__c timesheet = sirenum__TimesheetSettings__c.getInstance();
    this.invoiceText = timesheet.sirenum__Invoice_Text__c;

    loadLogo();
    //Load the invoice
        this.invoice = [SELECT Id, sirenum__Week__c FROM sirenum__Invoice__c WHERE Id =: std.getId() LIMIT 1];
        
        showTimesheetReport = false;
        if(timesheet.sirenum__Timesheets_Report_in_Invoice_PDF__c){
          showTimesheetReport = true;
      loadShifts();
        }
  }
  
  private void loadLogo() {
    // Load the logo document
    List<Document> document = [SELECT Id FROM Document WHERE DeveloperName = 'Company_Logo' LIMIT 1];
    
    if (document.size() == 0) {
      logoUrl = null;
      return;
    }
    
    //Create URL to load the image
    logoUrl = String.format(DOWNLOAD_URL, new String[] {document.get(0).Id});
  }
  
  private void loadShifts() {
    try {
      //Initialize data
      // TODO this code should be refactored to remove this secondary controller usage. However note that this code relies on the permissions checks done in the TimesheetReportController.
      TimesheetReportController cont = new TimesheetReportController();
      cont.sheets = new List<TimesheetReportController.Worksheet>();
      cont.allScheduledShifts = true;
      cont.splitBySite = false;
      cont.splitByTeam = true;
      cont.invoicePage = true;

      //Load selected payroll period
      List<sirenum__Week__c> periods = [
                SELECT Id, Name, sirenum__Start_Date__c, sirenum__Week_Ending__c 
                FROM sirenum__Week__c 
                WHERE Id = :invoice.sirenum__Week__c]; // CRUD/FLS False Positive: user permissions are checked in the initialisation of the TimesheetReportController class
      if (periods.size() == 0)
        throw new SirenumException(Label.PayrollPeriodNotFound);

      sirenum__Week__c period = periods.get(0);

      // TODO this code should be refactored to remove this confusing (uncommitted) change to the period
      if (period.sirenum__Start_Date__c == null) {
        period.sirenum__Start_Date__c = period.sirenum__Week_Ending__c.addDays(-6); // CRUD/FLS False Positive
      }

      List<sirenum__Timesheet__c> timesheets = [SELECT Id FROM sirenum__Timesheet__c WHERE sirenum__Invoice__c = :invoice.id AND sirenum__Week__c = :period.id];
      if (timesheets.size() == 0)
        throw new SirenumException(Label.PayrollNoTimesheetsFoundForInvoice);

      Set<Id> timesheetIds = new Set<Id>();
      for (sirenum__Timesheet__c t : timesheets) {
        timesheetIds.add(t.id);
      }

      //Read all relevant shifts (only ones related to timesheets - meaning billed for)
      List<sirenum__Shift__c> allShifts;
      DateTime maxDt = DateTime.newInstance(period.sirenum__Week_Ending__c, Time.newInstance(23, 59, 59, 0));
      DateTime minDt = convertDateToDatetime(period.sirenum__Start_Date__c);

      String query =
          ' SELECT sirenum__Billable_Calculated_Start_Time__c, sirenum__Billable_Calculated_End_Time__c, sirenum__Billable_Calculated_Shift_Length__c, ' +
                  '    sirenum__Break_Length__c, sirenum__Site__r.Name, sirenum__Team__r.Name, sirenum__Team__c, sirenum__Contact__c, sirenum__Site__c, ' +
              '    sirenum__Contact__r.firstName, sirenum__Contact__r.lastName, PO_Number__c ' +
              ' FROM sirenum__Shift__c   ' +
              ' WHERE sirenum__Contact__c != null ' +
              '   AND sirenum__Billable_Calculated_End_Time__c != null ' +
              '   AND sirenum__Timesheet_summaries__c IN :timesheetIds' +
              '   AND sirenum__Cancelled__c = false ' +
              '   ORDER BY sirenum__Team__r.Name, sirenum__Contact__r.firstName, sirenum__Contact__r.lastName, sirenum__Billable_Calculated_Start_Time__c';

      allShifts = (List<sirenum__Shift__c>) Database.query(query); // CRUD/FLS False Positive: user permissions are checked in the initialisation of the TimesheetReportController class

      if (allShifts.size() == 0) {
        throw new SirenumException(String.format(Label.PayrollNoValidShiftsOnWeek, new List<String> {period.name}));
      }

      cont.parse(allShifts);
      sheets = cont.sheets;
    } catch (Exception e) {
      Apexpages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.exception_found + e.getMessage() + ' (' + e.getLineNumber() + ')'));
    }
  }
  
  public static Datetime convertDateToDatetime(Date value) {
        return Datetime.newInstance(value, Time.newInstance(0, 0, 0, 0));
    }

  public with sharing class SirenumException extends Exception {
    public String getM() {
      return getMessage();
    }
  }
}