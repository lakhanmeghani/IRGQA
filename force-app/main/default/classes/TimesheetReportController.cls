public with sharing class TimesheetReportController {
    public List<Worksheet> sheets { get; set; }
    public List<String> headers { get; set; }
    public String contentType { get; set; }
    public String week { get; set; }
    public Id accountManager { get; set; }
    public List<SelectOption> accountManagers { get; set; }
    public List<SelectOption> weeks { get; set; }
    public Boolean isExport { get; set; }
    public Boolean allScheduledShifts { get; set; }
    public Boolean splitBySite { get; set; }
    public Boolean splitByTeam { get; set; }
    public Boolean showBreak { get; set; }
    public Boolean invoicePage;

    public PageReference checkAccess() {
        return null;
    }

    public TimesheetReportController() {
        //checkPermissions();

        contentType = '';
        isExport = false;
        allScheduledShifts = true;
        splitBySite = false;
        splitByTeam = true;
        showBreak = false;
        invoicePage = false;

        loadOptions();
    }

    private void loadOptions() {
        List<AggregateResult> managers = [
                SELECT sirenum__Employee__r.Name n, sirenum__Employee__c i
                FROM sirenum__ProActiveContract__c
                WHERE sirenum__Employee__c != null
                GROUP BY sirenum__Employee__r.Name, sirenum__Employee__c
                ORDER BY sirenum__Employee__r.Name
        ]; // CRUD/FLS False Positive: user permissions are checked in checkPermissions method

        accountManagers = new List<SelectOption>();

        for (AggregateResult r : managers) {
            accountManagers.add(new SelectOption((Id) r.get('i'), (String) r.get('n')));
        }

        Date maxDt = system.now().addDays(7).date();

        List<sirenum__Week__c> weeksList = [
                SELECT Id, sirenum__Week_Ending__c, sirenum__Start_Date__c
                FROM sirenum__Week__c
                WHERE sirenum__Week_Ending__c < :maxDt
                ORDER BY sirenum__Week_Ending__c DESC
                LIMIT 10
        ]; // CRUD/FLS False Positive: user permissions are checked in checkPermissions method

        weeks = new List<SelectOption>();

        for (sirenum__Week__c w : weeksList) {
            if (w.sirenum__Start_Date__c == null) {
                w.sirenum__Start_Date__c = w.sirenum__Week_Ending__c.addDays(-6); // CRUD/FLS False Positive
            }

            weeks.add(new SelectOption(w.Id, w.sirenum__Start_Date__c.format() + ' - ' + w.sirenum__Week_Ending__c.format()));
        }
    }

    public void execute() {
        try {
            //Initialize data
            sheets = new List<Worksheet>();

            // Load selected payroll period
            List<sirenum__Week__c> periods = [
                    SELECT Id, Name, sirenum__Start_Date__c, sirenum__Week_Ending__c
                            FROM sirenum__Week__c
                            WHERE Id = :week
            ]; // CRUD/FLS False Positive: user permissions are checked in checkPermissions method

            if (periods.size() == 0) {
                throw new SirenumException(Label.PayrollTimePeriodNotFound);
            }

            sirenum__Week__c period = periods.get(0);
            if (period.sirenum__Start_Date__c == null) {
                period.sirenum__Start_Date__c = period.sirenum__Week_Ending__c.addDays(-6); // CRUD/FLS False Positive
            }

            //Read all relevant shifts (only ones related to timesheets - meaning billed for)
            List<sirenum__Shift__c> allShifts;
            String query;
            Id periodId = period.Id;
            DateTime maxDt, minDt;

            if (allScheduledShifts) {
                maxDt = DateTime.newInstance(period.sirenum__Week_Ending__c, Time.newInstance(23, 59, 59, 0));
                minDt = convertDateToDatetime(period.sirenum__Start_Date__c);

                /********** ADD ADDITIONAL FIELDS TO THIS QUERY **********/
                query =
                        ' SELECT sirenum__Billable_Calculated_Start_Time__c, sirenum__Billable_Calculated_End_Time__c, ' +
                                '    sirenum__Billable_Calculated_Shift_Length__c, sirenum__Break_Length__c, sirenum__Site__r.Name, ' +
                                '    sirenum__Team__r.Name, sirenum__Team__c, sirenum__Contact__c, sirenum__Site__c, sirenum__Contact__r.firstName, sirenum__Contact__r.lastName ' +
                                ' FROM sirenum__Shift__c   ' +
                                ' WHERE sirenum__Billable_Calculated_Start_Time__c >= :minDt ' +
                                '   AND sirenum__Billable_Calculated_Start_Time__c <= :maxDt ' +
                                '   AND sirenum__Billable_Calculated_End_Time__c != null ' +
                                '   AND sirenum__Team__r.sirenum__Account__r.sirenum__Employee__c = :accountManager ' +
                                '   AND sirenum__Contact__c != null ' +
                                '   AND sirenum__Cancelled__c = false ';

                if (splitBySite && splitByTeam) {
                    query += 'ORDER BY sirenum__Team__r.Name, sirenum__Site__r.Name, sirenum__Contact__r.firstName, sirenum__Contact__r.lastName, sirenum__Billable_Calculated_Start_Time__c';
                } else if (splitByTeam) {
                    query += 'ORDER BY sirenum__Team__r.Name, sirenum__Contact__r.firstName, sirenum__Contact__r.lastName, sirenum__Billable_Calculated_Start_Time__c';
                } else {
                    query += 'ORDER BY sirenum__Site__r.Name, sirenum__Contact__r.firstName, sirenum__Contact__r.lastName, sirenum__Billable_Calculated_Start_Time__c';
                }
            } else {
                /********** ADD ADDITIONAL FIELDS TO THIS QUERY **********/
                query =
                        ' SELECT sirenum__Billable_Calculated_Start_Time__c, sirenum__Billable_Calculated_End_Time__c, sirenum__Billable_Calculated_Shift_Length__c, sirenum__Break_Length__c, ' +
                                '     sirenum__Site__r.Name, sirenum__Timesheet_summaries__r.sirenum__Team__r.Name, sirenum__Timesheet_summaries__r.sirenum__Team__c, ' +
                                '     sirenum__Timesheet_Summaries__r.sirenum__Site__c, Timesheet_Summaries__r.Site__r.Name, sirenum__Contact__c, sirenum__Contact__r.firstName, ' +
                '     sirenum__Contact__r.lastName ' +
                                '  FROM sirenum__Shift__c    ' +
                                '  WHERE sirenum__Timesheet_summaries__c != NULL ' +
                                '    AND sirenum__Timesheet_summaries__r.sirenum__Team__r.sirenum__Account__r.sirenum__Employee__c = :accountManager ' +
                                '    AND sirenum__Timesheet_summaries__r.sirenum__Week__c = :periodId ' +
                                '    AND sirenum__Billable_Calculated_Start_Time__c != null ' +
                                '    AND sirenum__Billable_Calculated_End_Time__c != null ' +
                                '    AND sirenum__Cancelled__c = false ';

                if (splitBySite && splitByTeam) {
                    query += '  ORDER BY sirenum__Timesheet_summaries__r.sirenum__Team__r.Name, sirenum__Timesheet_summaries__r.sirenum__Site__r.Name, sirenum__Contact__r.firstName, ' +
                             '           sirenum__Contact__r.lastName, sirenum__Billable_Calculated_Start_Time__c';
                } else if (splitByTeam) {
                    query += '  ORDER BY sirenum__Timesheet_summaries__r.sirenum__Team__r.Name, sirenum__Contact__r.firstName, sirenum__Contact__r.lastName, sirenum__Billable_Calculated_Start_Time__c';
                } else {
                    query += '  ORDER BY sirenum__Timesheet_summaries__r.sirenum__Site__r.Name, sirenum__Contact__r.firstName, sirenum__Contact__r.lastName, sirenum__Billable_Calculated_Start_Time__c';
                }
            }

            allShifts = (List<sirenum__Shift__c>) Database.query(query); // CRUD/FLS False Positive: user permissions are checked in checkPermissions method

            if (allShifts.size() == 0) {
                throw new SirenumException(String.format(Label.PayrollNoValidShiftsFoundForWeekAndManager, new List<String>{
                        period.name
                }));
            }

            parse(allShifts);
            createHeaders(period);

            isExport = true;
            contentType = 'txt/xml#TimesheetsReport.xls';
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.format(Label.PayrollExceptionFoundOnLineNumber, new List<String>{
                    e.getMessage(), String.valueOf(e.getLineNumber())
            })));
        }
    }

    public void parse(List<sirenum__Shift__c> shifts) {
        String sheetId = null, lastSheetId;
        Worksheet w;
        Set<String> sheetNames = new Set<String>();
        String sheetName;
        Integer cnt;
        Id teamId;
        Id siteId;
        Boolean firstRow = true;

        for (sirenum__Shift__c s : shifts) {
            //Check if a new worksheet needs to be created
            teamId = (allScheduledShifts) ? s.sirenum__Team__c : s.sirenum__Timesheet_summaries__r.sirenum__Team__c;
            siteId = (allScheduledShifts) ? s.sirenum__Site__c : s.sirenum__Timesheet_summaries__r.sirenum__Site__c;

            if (splitBySite && splitByTeam) {
                sheetId = teamId + '_' + siteId;
            } else if (splitByTeam) {
                sheetId = teamId;
            } else {
                sheetId = siteId;
            }

            if (firstRow
                    || !lastSheetId.equals(sheetId)) {
                //Create a sheet name (avoid duplicate names as it causes problems in Excel)
                sheetName = '';
                if (splitByTeam) {
                    sheetName = (allScheduledShifts) ? s.sirenum__Team__r.Name : s.sirenum__Timesheet_summaries__r.sirenum__Team__r.Name;
                    if (sheetName == null || sheetName.length() == 0) {
                        sheetName = Label.PayrollTimeSheetUnknownTeam;
                    }
                }

                if (splitBySite) {
                    if (sheetName.length() > 0) {
                        sheetName += ' - ';
                    }

                    if (siteId != null) {
                        sheetName += ((allScheduledShifts) ? s.sirenum__Site__r.Name : s.sirenum__Timesheet_summaries__r.sirenum__Site__r.Name);
                    } else {
                        sheetName += Label.PayrollStationUnknownSite;
                    }
                }

                if (!invoicePage && sheetName.length() > 30) { //Excel limit is 30 characters
                    sheetName = sheetName.substring(0, 30);
                }

                if (sheetNames.contains(sheetName)) {
                    cnt = 2;
                    String base = sheetName;
                    if (!invoicePage && base.length() > 27) {
                        base = base.substring(27);
                    } //Allow room for numbers
                    while (sheetNames.contains(sheetName)) {
                        sheetName = base + String.valueOf(cnt);
                        cnt++;
                    }
                }

                if (sheetName == null || sheetName.length() == 0) {
                    sheetName = 'Shifts';
                }

                firstRow = false;

                //Create new worksheet with the team name
                sheetNames.add(sheetName);
                w = new Worksheet(sheetName);
                sheets.add(w);
                lastSheetId = sheetId;
            }

            w.addShift(s, showBreak, invoicePage);
        }
    }

    /**
     * Verifies that the user has the required permissions, throwing an exception if this is not the case.
     */
     /*
    private void checkPermissions() {
        SirenumSecurityUtils.mustCreateObject(Schema.SObjectType.sirenum__Shift__c);
        SirenumSecurityUtils.mustCreateObject(Schema.SObjectType.sirenum__Timesheet__c);
        SirenumSecurityUtils.mustCreateObject(Schema.SObjectType.sirenum__ProActiveContract__c);
        SirenumSecurityUtils.mustQueryObject(Schema.SObjectType.sirenum__ProActiveContract__c);
        SirenumSecurityUtils.mustQueryObject(Schema.SObjectType.sirenum__Contact);
        SirenumSecurityUtils.mustQueryObject(Schema.SObjectType.sirenum__Week__c);
        SirenumSecurityUtils.mustAccessField(new DescribeFieldResult[]{
                Schema.SObjectType.sirenum__ProActiveContract__c.fields.sirenum__Employee__c,
                Schema.SObjectType.Contact.fields.Name,
                Schema.SObjectType.Contact.fields.firstName,
                Schema.SObjectType.Contact.fields.lastName,
                Schema.SObjectType.sirenum__Week__c.fields.Name,
                Schema.SObjectType.sirenum__Week__c.fields.sirenum__Week_Ending__c,
                Schema.SObjectType.sirenum__Week__c.fields.sirenum__Start_Date__c,
                Schema.SObjectType.sirenum__Shift__c.fields.sirenum__Billable_Calculated_Start_Time__c,
                Schema.SObjectType.sirenum__Shift__c.fields.sirenum__Billable_Calculated_End_Time__c,
                Schema.SObjectType.sirenum__Shift__c.fields.sirenum__Billable_Calculated_Shift_Length__c,
                Schema.SObjectType.sirenum__Shift__c.fields.sirenum__Timesheet_summaries__c,
                Schema.SObjectType.sirenum__Shift__c.fields.sirenum__Site__c,
                Schema.SObjectType.sirenum__Shift__c.fields.sirenum__Contact__c,
                Schema.SObjectType.sirenum__Shift__c.fields.sirenum__Team__c,
                Schema.SObjectType.sirenum__Shift__c.fields.sirenum__Break_Length__c,
                Schema.SObjectType.sirenum__Timesheet__c.fields.sirenum__Week__c,
                Schema.SObjectType.sirenum__Site__c.fields.Name,
                Schema.SObjectType.sirenum__Team__c.fields.Name
        });
    }
    */
    
    public static Datetime convertDateToDatetime(Date value) {
        return Datetime.newInstance(value, Time.newInstance(0, 0, 0, 0));
    }

    public class Shift {
        public String day { get; set; }
        public String dt { get; set; }
        public String team { get; set; }
        public String station { get; set; }
        public String start { get; set; }
        public String finish { get; set; }
        public String breakTime { get; set; }
        public String poNumber { get; set; }
        public Decimal hours { get; set; }

        public Shift(sirenum__Shift__c s, Boolean showBreak, Boolean invoicePage) {
            sirenum.TemporalFormatter formatter = sirenum.TemporalFormatter.getInstance();
            List<String> daysOfWeekNames = formatter.getDaysOfTheWeekNames(null, true, false);
            this.day = daysOfWeekNames[sirenum.SirenumUtils.getDayNumber(s.sirenum__Billable_Calculated_Start_Time__c)];
            // This requires an explicit output format to work with the Excel XML file format and should
            // not to be localized
            this.dt = s.sirenum__Billable_Calculated_Start_Time__c.format('yyyy-MM-dd');

            // This requires an explicit output format to work with the Excel XML file format and should
            // not to be localized
            this.start = s.sirenum__Billable_Calculated_Start_Time__c.format('HH:mm');

            // This requires an explicit output format to work with the Excel XML file format and should
            // not to be localized
            this.finish = s.sirenum__Billable_Calculated_End_Time__c.format('HH:mm');

            this.hours = s.sirenum__Billable_Calculated_Shift_Length__c;
            this.team = s.sirenum__Team__r.Name;

            if (showBreak) {
                Decimal bLength = (s.sirenum__Break_Length__c != null) ? s.sirenum__Break_Length__c : 0;
                Integer hours = Integer.valueOf(bLength / 60);
                Integer minutes = Math.mod(Integer.valueOf(bLength), 60);
                this.breakTime = hours + ':' + ((minutes < 10) ? '0' : '') + minutes;
                this.hours -= bLength / 60;
            }

            if (s.sirenum__Site__r == null || s.sirenum__Site__r.Name == null || s.sirenum__Site__r.Name.length() == 0) {
                this.station = Label.PayrollStationUnknownSite;
            } else if (!invoicePage) {
                this.station = s.sirenum__Site__r.Name.escapeHtml4();
            } else {
                this.station = s.sirenum__Site__r.Name;
            }

            this.hours = this.hours.setScale(2);
        }
    }

    public class Employee {
        public List<Shift> shifts { get; set; }
        public Decimal total { get; set; }
        public String name { get; set; }

        public Employee(Contact c, Boolean invoicePage) {
            if (!invoicePage) {
                this.name = (c.firstName + ' ' + c.lastName).replace('/', '-').escapeHtml4();
            } else {
                this.name = (c.firstName + ' ' + c.lastName).replace('/', '-');
            }
            this.shifts = new List<Shift>();
            this.total = 0;
        }

        public Shift addShift(sirenum__Shift__c s, Boolean showBreak, Boolean invoicePage) {
            Shift shiftRow = new Shift(s, showBreak, invoicePage);
            shifts.add(shiftRow);
            total += shiftRow.hours;
            return shiftRow;
        }
    }

    /**
     * Represents one sheet in the result file
     */
    public class Worksheet {
        public String name { get; set; }
        public List<Employee> employees { get; set; }
        private Map<Id, Integer> employeePosition;
        public Decimal grandTotal { get; set; }

        public Worksheet(String name) {
            this.name = name.replace('/', '-');
            employees = new List<Employee>();
            grandTotal = 0;
            employeePosition = new Map<Id, Integer>();
        }

        public void addShift(sirenum__Shift__c s, Boolean showBreak, Boolean invoicePage) {
            //Check if the employee is already in the worksheet
            Integer pos;
            Employee e;

            if (employeePosition.containsKey(s.sirenum__Contact__c)) {
                //Employee already exists, load position
                pos = employeePosition.get(s.sirenum__Contact__c);
                e = employees.get(pos);
            } else {
                //Employee does not exist, allocate a new row
                pos = employees.size();
                e = new Employee(s.sirenum__Contact__r, invoicePage);
                employees.add(e);

                employeePosition.put(s.sirenum__Contact__c, pos);
            }

            Shift addedShift = e.addShift(s, showBreak, invoicePage);

            //Update grand total
            grandTotal += addedShift.hours;
        }
    }

    /**
     * Return the XLS Header required for XML-Excel spreadsheets
     */
    public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }

    public void createHeaders(sirenum__Week__c period) {
        headers = new List<String>();
        headers.add(Label.StandardPersonName);
        headers.add(Label.StandardDay);
        headers.add(Label.StandardDate);
        headers.add(Label.StandardJobRoles);
        headers.add(Label.StandardStations);
        headers.add(Label.StandardStart);
        headers.add(Label.StandardFinish);

        if (showBreak) {
            headers.add(Label.StandardBreak);
        }

        headers.add(Label.StandardHours);
    }
    
    public with sharing class SirenumException extends Exception {
        public String getM() {
            return getMessage();
        }
    }
}