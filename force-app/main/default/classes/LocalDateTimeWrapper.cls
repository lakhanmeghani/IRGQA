/**
 * IRG2-80 Provide a mechanism of converting between a date & time (in Shift.Site timezone) and UTC
 */

public with sharing class LocalDateTimeWrapper {
    public Date localDate;
    public String localHour;
    public String localMinute;

    public LocalDateTimeWrapper(Date localDate, String localHour, String localMinute){
        this.localDate = localDate;
        this.localHour = localHour;
        this.localMinute = localMinute;
    }
}