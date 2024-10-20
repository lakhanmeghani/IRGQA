/**
 * IRG2-80 Provide a mechanism of converting between a date & time (in Shift.Site timezone) and UTC
 */

public without sharing class CalculateScheduledTimesHelper {
    public static Map<Id, sirenum__Site__c> sitesById;

    /**
     * @param dateValue The local date to convert
     * @param timeString The local time to convert in the format {hh:mm}
     * @param sourceTimezone The Timezone to convert from
     *
     * @return a UTC datetime
     */
    public static Datetime CalculateStandardTimeFromLocalTime(Date dateValue, String timeString, TimeZone sourceTimezone){
        //Create a Time from a String in the format {hh:mm}
        Time timeValue = Time.newInstance(Integer.valueOf(timeString.substring(0,2)),
                Integer.valueOf(timeString.substring(3,5)),
                0,
                0);

        // Convert this into a UTC date/time value
        Datetime utcDatetime = Datetime.newInstanceGmt(dateValue, timeValue);

        // Figure out the offset at this UTC "moment"
        Integer offsetAtUTC = sourceTimezone.getOffset(utcDatetime);

        // Adjust the date/time value to be in the target time zone
        Datetime localDatetime = utcDatetime.addSeconds(-offsetAtUTC / 1000);

        // Now it is in the target time zone, we have a new "moment". If the UTC and local "moments" are
        // either side of a DST transition the calculation will be adrift
        Integer offsetAtLocal = sourceTimezone.getOffset(localDatetime);

        if (offsetAtLocal != offsetAtUTC) {
            // There's a discrepancy because of a DST transition that probably needs
            // correction. Work out an adjusted date/time based on the two offsets
            Datetime adjustedDatetime = localDatetime.addSeconds((offsetAtUTC - offsetAtLocal) / 1000);
            Integer offsetAtAdjusted = sourceTimezone.getOffset(adjustedDatetime);

            // If the adjusted date/time, looking to correct for a DST transition, is not on the same side of the
            // transition as the planned correction then the correction is probably unnecessary. However, a
            // correction must be applied when "leaping forward"
            if (offsetAtAdjusted == offsetAtLocal ||
                    adjustedDatetime > localDatetime) {
                localDatetime = adjustedDatetime;
            }
        }

        return localDatetime;
    }

    /**
     * @param standardStartTime The datetime (sirenum__Scheduled_Start_Time__c) to convert from
     * @param standardEndTime The datetime (sirenum__Scheduled_End_Time__c) to convert from
     * @param targetTimezone The timezone to convert the UTC datetime to
     *
     * @return a list of LocalDateWrappers consisting of {Date localDate, String localHour, String localMinute} ...
     * ... whereby [0] = Start Datetime [1] = End Datetime
     */
    public static List<LocalDateTimeWrapper> CalculateLocalTimesFromStandardTimes(Datetime standardStartTime, Datetime standardEndTime, String targetTimezone){
        //Convert to target timezone
        //Note: Not using sirenum.DateTimeUtils.fromUserToTZone because it removes the offset hours rather than adds

        Integer startTimeOffsetHours = TimeZone.getTimeZone(targetTimezone).getOffset(standardStartTime)/1000/60/60;
        Integer endTimeOffsetHours = TimeZone.getTimeZone(targetTimezone).getOffset(standardEndTime)/1000/60/60;

        Datetime localStartTime = standardStartTime.addHours(startTimeOffsetHours);
        Datetime localEndTime = standardEndTime.addHours(endTimeOffsetHours);

        Integer startTimeOffsetHoursLocal = TimeZone.getTimeZone(targetTimezone).getOffset(localStartTime)/1000/60/60;
        Integer endTimeOffsetHoursLocal = TimeZone.getTimeZone(targetTimezone).getOffset(localEndTime)/1000/60/60;

        if (startTimeOffsetHoursLocal != startTimeOffsetHours){
            // There's a discrepancy because of a DST transition that probably needs
            // correction. Work out an adjusted date/time based on the two offsets
            Datetime adjustedDateTime = localStartTime.addHours(startTimeOffsetHoursLocal - startTimeOffsetHours); //TODO: may need reversing
            Integer offsetAdjusted = TimeZone.getTimeZone(targetTimezone).getOffset(adjustedDateTime)/1000/60/60;

            // If the adjusted date/time, looking to correct for a DST transition, is not on the same side of the
            // transition as the planned correction then the correction is probably unnecessary. However, a
            // correction must be applied when "leaping forward"
            if (offsetAdjusted != startTimeOffsetHoursLocal || adjustedDateTime > localStartTime){
                localStartTime = adjustedDateTime;
            }
        }

        if (endTimeOffsetHoursLocal != endTimeOffsetHours){
            // There's a discrepancy because of a DST transition that probably needs
            // correction. Work out an adjusted date/time based on the two offsets
            Datetime adjustedDateTime = localEndTime.addHours(endTimeOffsetHoursLocal - endTimeOffsetHours); //TODO: may need reversing
            Integer offsetAdjusted = TimeZone.getTimeZone(targetTimezone).getOffset(adjustedDateTime)/1000/60/60;

            // If the adjusted date/time, looking to correct for a DST transition, is not on the same side of the
            // transition as the planned correction then the correction is probably unnecessary. However, a
            // correction must be applied when "leaping forward"
            if (offsetAdjusted != endTimeOffsetHoursLocal || adjustedDateTime > localEndTime){
                localEndTime = adjustedDateTime;
            }
        }

        return new List<LocalDateTimeWrapper>{
                new LocalDateTimeWrapper(localStartTime.date(), localStartTime.format('HH', 'GMT'), localStartTime.format('mm')),
                new LocalDateTimeWrapper(localEndTime.date(), localEndTime.format('HH', 'GMT'), localEndTime.format('mm'))
        };
    }

    /**
     * @param oldShifts Map of shifts before update. Will be null when handling an insert.
     * @param newShifts List of shifts in their current state.
     */
    public static void HandleConversion(Map<Id, sirenum__Shift__c> oldShifts, List<sirenum__Shift__c> newShifts){
        //Retrieve site timezones
        Set<Id> siteIds = new Set<Id>();
        for (sirenum__Shift__c shift :newShifts){
            siteIds.add(shift.sirenum__Site__c);
        }
        sitesById = new Map<Id, sirenum__Site__c>([SELECT Id, sirenum__Timezone__c FROM sirenum__Site__c WHERE Id IN :siteIds]);

        Boolean gmtMode = LocalTimeSettingProvider.getSetting('default').Disable_Site_Timezone_Conversion__c;
        //Handle inserted Shifts
        if (oldShifts == null){
            for (sirenum__Shift__c shift : newShifts){
                //Skip shifts for which we cannot calculate local time, if we are not in GMT mode
                if ((sitesById.get(shift.sirenum__Site__c) == null || sitesById.get(shift.sirenum__Site__c).sirenum__Timezone__c == null) && gmtMode == false){
                    continue;
                }
                //Local time set, Standard time NOT set
                if (shift.Scheduled_Day_local__c != null &&
                        shift.Scheduled_Start_Time_local__c != null && shift.Scheduled_End_Time_local__c != null &&
                        shift.sirenum__Scheduled_Start_Time__c == null && shift.sirenum__Scheduled_End_Time__c == null){
                    shift.sirenum__Scheduled_Start_Time__c = CalculateStandardTimeFromLocalTime(
                            shift.Scheduled_Day_local__c,
                            shift.Scheduled_Start_Time_local__c,
                            gmtMode == true ? TimeZone.getTimeZone('Europe/London') : TimeZone.getTimeZone(sitesById.get(shift.sirenum__Site__c).sirenum__Timezone__c)
                    );
                    shift.sirenum__Scheduled_End_Time__c = CalculateStandardTimeFromLocalTime(
                            shift.Scheduled_End_Time_local__c < shift.Scheduled_Start_Time_local__c ? shift.Scheduled_Day_local__c.addDays(1) : shift.Scheduled_Day_local__c,
                            shift.Scheduled_End_Time_local__c,
                            gmtMode == true ? TimeZone.getTimeZone('Europe/London') : TimeZone.getTimeZone(sitesById.get(shift.sirenum__Site__c).sirenum__Timezone__c)
                    );
                } else if (shift.sirenum__Scheduled_Start_Time__c != null && //Standard time set, Local time NOT set
                        shift.sirenum__Scheduled_End_Time__c != null &&
                        shift.Scheduled_Day_local__c == null &&
                        shift.Scheduled_Start_Time_local__c == null &&
                        shift.Scheduled_End_Time_local__c == null){
                    List<LocalDateTimeWrapper> localDatetimes = CalculateLocalTimesFromStandardTimes(
                            shift.sirenum__Scheduled_Start_Time__c,
                            shift.sirenum__Scheduled_End_Time__c,
                            gmtMode == true ? 'Europe/London' : sitesById.get(shift.sirenum__Site__c).sirenum__Timezone__c);
                    shift.Scheduled_Day_local__c = localDatetimes[0].localDate;
                    shift.Scheduled_Start_Time_local__c = localDatetimes[0].localHour + ':' + localDatetimes[0].localMinute;
                    shift.Scheduled_End_Time_local__c = localDatetimes[1].localHour + ':' + localDatetimes[1].localMinute;
                }
                //Replace a flow
                if (shift.sirenum__Absolute_Start_Time__c != null && shift.Original_Visit_Date__c == null){
                    shift.Original_Visit_Date__c = shift.sirenum__Absolute_Start_Time__c.date();
                }
            }
        } else { //Handle updated shifts
            for (sirenum__Shift__c shift : newShifts){
                //Local time changed, standard time NOT changed
                if (((shift.Scheduled_Day_local__c != oldShifts.get(shift.Id).Scheduled_Day_local__c && shift.Scheduled_Day_local__c != null) ||
                        (shift.Scheduled_Start_Time_local__c != oldShifts.get(shift.Id).Scheduled_Start_Time_local__c && shift.Scheduled_Start_Time_local__c != null) ||
                        (shift.Scheduled_End_Time_local__c != oldShifts.get(shift.Id).Scheduled_End_Time_local__c && shift.Scheduled_End_Time_local__c != null)) &&
                        shift.sirenum__Scheduled_Start_Time__c == oldShifts.get(shift.Id).sirenum__Scheduled_Start_Time__c &&
                        shift.sirenum__Scheduled_End_Time__c == oldShifts.get(shift.Id).sirenum__Scheduled_End_Time__c){
                    shift.sirenum__Scheduled_Start_Time__c = CalculateStandardTimeFromLocalTime(
                            shift.Scheduled_Day_local__c,
                            shift.Scheduled_Start_Time_local__c,
                            gmtMode == true ? TimeZone.getTimeZone('Europe/London') : TimeZone.getTimeZone(sitesById.get(shift.sirenum__Site__c).sirenum__Timezone__c)
                    );
                    shift.sirenum__Scheduled_End_Time__c = CalculateStandardTimeFromLocalTime(
                            shift.Scheduled_Day_local__c,
                            shift.Scheduled_End_Time_local__c,
                            gmtMode == true ? TimeZone.getTimeZone('Europe/London') : TimeZone.getTimeZone(sitesById.get(shift.sirenum__Site__c).sirenum__Timezone__c)
                    );
                } else if (((shift.sirenum__Scheduled_Start_Time__c != oldShifts.get(shift.Id).sirenum__Scheduled_Start_Time__c && //Standard time changed, local time NOT changed
                        shift.sirenum__Scheduled_Start_Time__c != null) ||
                        (shift.sirenum__Scheduled_End_Time__c != oldShifts.get(shift.Id).sirenum__Scheduled_End_Time__c && shift.sirenum__Scheduled_End_Time__c != null)) &&
                        shift.Scheduled_Day_local__c == oldShifts.get(shift.Id).Scheduled_Day_local__c &&
                        shift.Scheduled_Start_Time_local__c == oldShifts.get(shift.Id).Scheduled_Start_Time_local__c &&
                        shift.Scheduled_End_Time_local__c == oldShifts.get(shift.Id).Scheduled_End_Time_local__c){
                    List<LocalDateTimeWrapper> localDatetimes = CalculateLocalTimesFromStandardTimes(
                            shift.sirenum__Scheduled_Start_Time__c,
                            shift.sirenum__Scheduled_End_Time__c,
                            gmtMode == true ? 'Europe/London' : sitesById.get(shift.sirenum__Site__c).sirenum__Timezone__c);
                    shift.Scheduled_Day_local__c = localDatetimes[0].localDate;
                    shift.Scheduled_Start_Time_local__c = localDatetimes[0].localHour + ':' + localDatetimes[0].localMinute;
                    shift.Scheduled_End_Time_local__c = localDatetimes[1].localHour + ':' + localDatetimes[1].localMinute;
                }
                //Replace flow "Assign Original Shift Date", since this must happen AFTER the rest of the trigger
                if (shift.sirenum__Absolute_Start_Time__c != null && shift.Original_Visit_Date__c == null){
                    shift.Original_Visit_Date__c = shift.sirenum__Absolute_Start_Time__c.date();
                }
            }
        }
    }

    /**
     * @param oldEmployeeRequests Map of Employee Requests before update. Will be null when handling insert.
     * @param newEmployeeRequests List of EmployeeRequests in their current state
     */
    public static void HandleConversion(Map<Id, sirenum__Employee_Request__c> oldEmployeeRequests, List<sirenum__Employee_Request__c> newEmployeeRequests){
        //Retrieve Local Time Trigger Setting and only proceed if GMT mode is enabled
        Local_Time_Trigger_Setting__mdt setting = LocalTimeSettingProvider.getSetting('default');
        if (setting.Disable_Site_Timezone_Conversion__c == true){
            Time zeroTime = Time.newInstance(0,0,0,0); //Use to check Employee Requests
            //Handle new employee Requests
            if (oldEmployeeRequests == null){
                for (sirenum__Employee_Request__c employeeRequest : newEmployeeRequests) {
                    //Standard time set, Local time not set
                    if (employeeRequest.sirenum__Start_Time__c != null && employeeRequest.sirenum__End_Time__c != null &&
                            employeeRequest.Scheduled_Start_Time_local__c == null && employeeRequest.Scheduled_End_Time_local__c == null) {
                        List<LocalDateTimeWrapper> localDatetimes = CalculateLocalTimesFromStandardTimes(
                                employeeRequest.sirenum__Start_Time__c,
                                employeeRequest.sirenum__End_Time__c,
                                'Europe/London'); //timezone is always europe/london as this can only be reached if we are in GMT mode
                        employeeRequest.Scheduled_Day_local__c = localDatetimes[0].localDate;
                        employeeRequest.Scheduled_Start_Time_local__c = localDatetimes[0].localHour + ':' + localDatetimes[0].localMinute;
                        employeeRequest.Scheduled_End_Time_local__c = localDatetimes[1].localHour + ':' + localDatetimes[1].localMinute;
                    //Local time set, standard time not set
                    } else if (employeeRequest.Scheduled_Start_Time_local__c != null && employeeRequest.Scheduled_End_Time_local__c != null &&
                            (employeeRequest.sirenum__Start_Time__c == null  || employeeRequest.sirenum__Start_Time__c.time() == zeroTime) &&
                            (employeeRequest.sirenum__End_Time__c == null || employeeRequest.sirenum__End_Time__c.time() == zeroTime)) {
                        employeeRequest.sirenum__Start_Time__c = CalculateStandardTimeFromLocalTime(
                                employeeRequest.Scheduled_Day_local__c,
                                employeeRequest.Scheduled_Start_Time_local__c,
                                TimeZone.getTimeZone('Europe/London')
                        );
                        employeeRequest.sirenum__End_Time__c = CalculateStandardTimeFromLocalTime(
                                employeeRequest.Scheduled_End_Time_local__c < employeeRequest.Scheduled_Start_Time_local__c ? employeeRequest.Scheduled_Day_local__c.addDays(1) : employeeRequest.Scheduled_Day_local__c,
                                employeeRequest.Scheduled_End_Time_local__c,
                                TimeZone.getTimeZone('Europe/London')
                        );
                    }
                    CheckAllDayFlag(employeeRequest); //After custom processing done, check/reset All Day flag
                }
            //Handle updated Employee Requests
            } else {
                for (sirenum__Employee_Request__c employeeRequest : newEmployeeRequests) {
                    //Standard time changed, local time not changed
                    if (((employeeRequest.sirenum__Start_Time__c != oldEmployeeRequests.get(employeeRequest.Id).sirenum__Start_Time__c &&
                            employeeRequest.sirenum__Start_Time__c != null) ||
                            (employeeRequest.sirenum__End_Time__c != oldEmployeeRequests.get(employeeRequest.Id).sirenum__End_Time__c &&
                            employeeRequest.sirenum__End_Time__c != null)) &&
                            employeeRequest.Scheduled_Day_local__c == oldEmployeeRequests.get(employeeRequest.Id).Scheduled_Day_local__c &&
                            employeeRequest.Scheduled_Start_Time_local__c == oldEmployeeRequests.get(employeeRequest.Id).Scheduled_Start_Time_local__c &&
                            employeeRequest.Scheduled_End_Time_local__c == oldEmployeeRequests.get(employeeRequest.Id).Scheduled_End_Time_local__c) {
                        List<LocalDateTimeWrapper> localDatetimes = CalculateLocalTimesFromStandardTimes(
                                employeeRequest.sirenum__Start_Time__c,
                                employeeRequest.sirenum__End_Time__c,
                                'Europe/London');
                        employeeRequest.Scheduled_Day_local__c = localDatetimes[0].localDate;
                        employeeRequest.Scheduled_Start_Time_local__c = localDatetimes[0].localHour + ':' + localDatetimes[0].localMinute;
                        employeeRequest.Scheduled_End_Time_local__c = localDatetimes[1].localHour + ':' + localDatetimes[1].localMinute;
                    //Local time changed, standard time not changed
                    } else if (((employeeRequest.Scheduled_Day_local__c != oldEmployeeRequests.get(employeeRequest.Id).Scheduled_Day_local__c && employeeRequest.Scheduled_Day_local__c != null) ||
                            (employeeRequest.Scheduled_Start_Time_local__c != oldEmployeeRequests.get(employeeRequest.Id).Scheduled_Start_Time_local__c && employeeRequest.Scheduled_Start_Time_local__c != null) ||
                            (employeeRequest.Scheduled_End_Time_local__c != oldEmployeeRequests.get(employeeRequest.Id).Scheduled_End_Time_local__c && employeeRequest.Scheduled_End_Time_local__c != null)) &&
                            employeeRequest.sirenum__Start_Time__c == oldEmployeeRequests.get(employeeRequest.Id).sirenum__Start_Time__c &&
                            employeeRequest.sirenum__End_Time__c == oldEmployeeRequests.get(employeeRequest.Id).sirenum__End_Time__c){
                        employeeRequest.sirenum__Start_Time__c = CalculateStandardTimeFromLocalTime(
                                employeeRequest.Scheduled_Day_local__c,
                                employeeRequest.Scheduled_Start_Time_local__c,
                                TimeZone.getTimeZone('Europe/London')
                        );
                        employeeRequest.sirenum__End_Time__c = CalculateStandardTimeFromLocalTime(
                                employeeRequest.Scheduled_Day_local__c,
                                employeeRequest.Scheduled_End_Time_local__c,
                                TimeZone.getTimeZone('Europe/London')
                        );
                    }
                    CheckAllDayFlag(employeeRequest); //After custom processing done, check/reset All Day flag
                }
            }
        }
    }

    /**
     * @param employeeRequest The request to check and if necessary reset the All Day flag
     *
     * This is needed because the product expects Employee Requests to be created with a start time, whereas IRG are
     * setting custom Local Time variants; since the product processing happens first, it sets the All Day flag
     * as only a Date is found, THEN custom processing runs to set the standard times.
     *
     * With the All Day flag now (incorrectly) set, the product will force times to 00:00. Therefore it is necessary to
     * check and potentially revert the flag.
     */
    public static void CheckAllDayFlag(sirenum__Employee_Request__c employeeRequest){
        if (employeeRequest.sirenum__Start_Time__c == null && employeeRequest.sirenum__End_Time__c == null){
            employeeRequest.sirenum__All_Day__c = true;
        } else {
            employeeRequest.sirenum__All_Day__c = false;
        }
    }


}