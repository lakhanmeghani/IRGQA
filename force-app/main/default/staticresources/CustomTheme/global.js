if (window.getShiftBackgroundColor) {
  var getShiftBackgroundColor_orig = window.getShiftBackgroundColor;

  window.getShiftBackgroundColor = function(shift) {
    // L2SUP-727 Link Shift Tile Colour to Illingworth Status field
    // Sirenum 2.4 introduces getShiftBackgroundColor function and starts using this theme solution.
    if (shift.params.Calculated_Colour_Code__c != null) {
      return shift.params.Calculated_Colour_Code__c;
    } else {
      return getShiftBackgroundColor_orig(shift);
    }
  }
}

if (window.setShiftDivColor) {
    var setShiftDivColor_orig = setShiftDivColor;
    setShiftDivColor = function(shift, div) {
        // L2SUP-727 Link Shift Tile Colour to Illingworth Status field
        // When upgraded to Sirenum 2.4 the getContrastColor function no longer exists
        // So this code augmentation won't do anything
        if (window.getContrastColor && shift.params.Calculated_Colour_Code__c != null) {
            var color = shift.params.Calculated_Colour_Code__c;
            div.style.backgroundColor = color;
            div.setAttribute("color", getContrastColor(color));
        } else {
            setShiftDivColor_orig(shift, div);
        }
    }
}

if (window.ObjectRendering) {
    ObjectRendering.addRenderer(
        ObjectRendering.contextTypes.TABLE_CELL_SHIFT,
        function (renderingContext) {
            var shiftDiv = renderingContext.element;
            var shift = renderingContext.object;

            //PS-904 if the rendered shift is freshly created, try to populate sirenum__Site__c ASAP
            if (shift.id.startsWith('new') && shift.site == '*'){
                if (shift.params.Participant_Location__c && !shift.params.Clinical_Site__c){
                    shift.site = shift.params.Participant_Location__c;
                } else if (!shift.params.Participant_Location__c && shift.params.Clinical_Site__c) {
                    shift.site = shift.params.Clinical_Site__c;
                }
            }

            // L2SUP-727 alter info displayed in Shift Tile

            // Add 'Comments Present' flag to status header
            let statusElements = shiftDiv.getElementsByClassName("status");
            let commentsPresent = !!shift.params.sirenum__Scheduling_Comments__c;
            let isAssigned = !!shift.params.sirenum__Contact__c;
            let firstStatusDiv = statusElements[0];

            //L2SUP-1329 Hide fill rate percentage
            let fillRateDivList = firstStatusDiv.querySelectorAll('.shiftDemandBadge.sirenum-inverse');
            if (fillRateDivList.length > 0){
                fillRateDivList[0].style.display = 'none';
            }

            if (statusElements.length == 1 && commentsPresent == true) {
                let badgeElements = shiftDiv.getElementsByClassName("shiftDemandBadge");
                const commentsDiv = document.createElement('div');
                commentsDiv.innerText = '©';
                firstStatusDiv.insertBefore(commentsDiv, badgeElements[0]);
            }

            // Change info being displayed for non-demand shifts

            let shiftTop = shiftDiv.querySelector('.shiftTop');

            // Remove standard fields in the 'top' section
            const shiftDetailSite = shiftDiv.querySelector('.shiftDetailSite');

            if (shiftDetailSite) {
              shiftDetailSite.remove();
            }

            const shiftAddress = shiftDiv.querySelector('.shiftAddress');

            if (shiftAddress) {
              shiftAddress.remove();
            }

            const shiftDetailTeam = shiftDiv.querySelector('.shiftDetailTeam');

            if (shiftDetailTeam) {
              shiftDetailTeam.remove();
            }

            // Replace with new fields
            if (shiftTop) {
                if (shift.params.sirenum__Contract__r) {
                    if (shift.params.sirenum__Contract__r.Name) {
                        const projectName = document.createElement('div');
                        projectName.className = 'projectName';
                        projectName.innerHTML = shift.params.sirenum__Contract__r.Name;
                        shiftTop.appendChild(projectName);
                    }
                }
                if (shift.params.Participant__r) {
                    if (shift.params.Participant__r.Name) {
                        const participantNumber = document.createElement('div');
                        participantNumber.className = 'participantNumber';
                        participantNumber.innerHTML = shift.params.Participant__r.Name;
                        shiftTop.appendChild(participantNumber);
                    }
                }
                if (shift.params.sirenum__Team__r) {
                    if (shift.params.sirenum__Team__r.Name) {
                        const visitType = document.createElement('div');
                        visitType.className = 'visitType';
                        visitType.innerHTML = shift.params.sirenum__Team__r.Name;
                        shiftTop.appendChild(visitType);
                    }
                }
                if (shift.params.Visit_Number__c) {
                    const visitNo = document.createElement('div');
                    visitNo.className = 'visitNo';
                    visitNo.innerHTML = shift.params.Visit_Number__c;
                    shiftTop.appendChild(visitNo);
                }
                if (shift.params.Illingworth_City__c) {
                    const visitCity = document.createElement('div');
                    visitCity.className = 'visitCity';
                    visitCity.innerHTML = shift.params.Illingworth_City__c;
                    shiftTop.appendChild(visitCity);
                }
            }


            // Remove 'Notes' section containing comments
            const shiftNotes = shiftDiv.querySelector('.shiftNotes');

            if (shiftNotes) {
              shiftNotes.remove();
            }
        }
    )

    // PS-969 - Use local start/end times for Employee Request
    ObjectRendering.addRenderer(
        ObjectRendering.contextTypes.TABLE_CELL_REQUEST,
        function (renderingContext) {
            var requestDiv = renderingContext.element;
            var request = renderingContext.object;
            if (request.params.Scheduled_Start_Time_local__c != null &&
                request.params.Scheduled_End_Time_local__c != null) {
                var requestTimeDetail = requestDiv.getElementsByClassName("requestTimeDetail")[0];
                if (requestTimeDetail != null) {
                    requestTimeDetail.innerText =
                        request.params.Scheduled_Start_Time_local__c + " - " +
                        request.params.Scheduled_End_Time_local__c;
                }
            }
        }
    )
}

/* L2SUP-939 Suppress timezone error */
if (window.showMessage) {
    const showMessage_orig = window.showMessage;
    showMessage = function (contents, messageType, duration) {
        if (contents != Label.DifferentTimezone) {
            showMessage_orig(contents, messageType, duration);
        }
    }
}

// Hide "Other Project" requests if corresponding shift is visible
if (window.generateTable) {
    generateTable_orig = generateTable;
    generateTable = function() {
        generateTable_orig();
        hideOtherProjectRequests();
    }
}

if (window.pasteItems) {
    pasteItems_orig = pasteItems;
    pasteItems = function(cell) {
        pasteItems_orig(cell);
        hideOtherProjectRequests();
    }
}

if (window.onPublishComplete) {
    onPublishComplete_orig = onPublishComplete;
    onPublishComplete = function(result) {
        onPublishComplete_orig(result);
        hideOtherProjectRequests();
    }
}

if (window.processSaveResults) {
    processSaveResults_orig = processSaveResults;
    processSaveResults = function(results) {
        processSaveResults_orig(results);
        hideOtherProjectRequests();
    }
}

if (window.onRuleEngineComplete) {
    onRuleEngineComplete_orig = onRuleEngineComplete;
    onRuleEngineComplete = function(result) {
        onRuleEngineComplete_orig(result);
        hideOtherProjectRequests();
    }
}

if (window.createPlacementsFromTemplate) {
    createPlacementsFromTemplate_orig = createPlacementsFromTemplate;
    createPlacementsFromTemplate = function(requirementTemplate, button) {
        createPlacementsFromTemplate_orig(requirementTemplate, button);
        hideOtherProjectRequests();
    }
}

function hideOtherProjectRequests() {
    _hideOtherProjectRequests();
    // Ensure requests are hidden whenever the filters are changed
    let filterOptions = document.getElementsByClassName("filterOption");
    for (let filterOption of filterOptions) {
        filterOption.addEventListener("click", hideOtherProjectRequests);
    }
}

function _hideOtherProjectRequests() {
    requests.forEach(request => {
        if (request.params.Other_Project_Employee_Request__c &&
            request.shift != null &&
            shiftsById[request.shift] &&
            shiftsById[request.shift].div.style.display != "none") {
            request.div.style.display = "none";
        }
    });
}

//PS-881 custom filter for Site.RecordType.Name
/*
ObjectFiltering.registerFilter({
    name: "siteType",
    label: "Site Type",
    items: function () {
        let distinctSiteTypes = {};

        //mapSites is not enumerable, so create an enumerable array from it
        let sites = Object.keys(mapSites).map(id => {
            return {
                site: mapSites[id]
            }
        });

        //Loop through rendered Sites and ensure we have captured all unique record types
        sites.forEach(site => {
            if (site.site &&
                site.site.sObject &&
                site.site.sObject.RecordType &&
                site.site.sObject.RecordType.Name &&
                !distinctSiteTypes[site.site.sObject.RecordType.Name]) {
                    distinctSiteTypes[site.site.sObject.RecordType.Name] = site.site.sObject.RecordType.Name;
            }
        });

        let items = Object.keys(distinctSiteTypes).map(id => {
            return {
                name: id,
                label: distinctSiteTypes[id]
            }
        }).sort((a, b) => a.label.localeCompare(b.label));

        return items;
    },
    matchesObjectType: function (objectType) {
        // Return true for object types that this filter is filtering
        return objectType === ObjectFiltering.ObjectType.SHIFT;
    },
    matchesItems: function (scheduleObject, filterItems) {
        return filterItems.some(filterItem => {
            const typeSiteValue = (scheduleObject.params &&
                mapSites[scheduleObject.params.sirenum__Site__c] &&
                mapSites[scheduleObject.params.sirenum__Site__c].sObject &&
                mapSites[scheduleObject.params.sirenum__Site__c].sObject.RecordType.Name) || null;
            return typeSiteValue === filterItem.name;
        });
    }
});
*/
/**
 * IRG2-70 Remove Cancel option from scheduler context menu
 */
if (window.showContextMenu) {
    const showContextMenu_orig = showContextMenu;
    showContextMenu = function (div, e) {
        // Call the product code to generate the context menu
        showContextMenu_orig(div, e);
        // This is the Staff View, and the context menu is either for a shift or employee request or requirement)
        if (view.type == 1) {
            //Get Context menu structure
            const menu = document.getElementById("sirenumContextMenu");
            const menuItems = menu.getElementsByClassName("sirenumContextMenuItem");

            //Find the 'Cancel' menu item
            const menuItem = Array.from(menuItems).find(element => {
                return element.innerText === 'Cancel'
            });
            //If the menu item was found, remove it
            if (menuItem) {
                menuItem.parentElement.removeChild(menuItem);
            }

            //SPS-983 Find the "Reject Employee Request" Menu Item
            const menuItemRejectRequest = Array.from(menuItems).find(element => {
                return element.innerText === 'Reject Employee Request'
            });
            //If the menu item was found, remove it
            if (menuItemRejectRequest) {
                menuItemRejectRequest.parentElement.removeChild(menuItemRejectRequest);
            }

            //SPS-983 Find the "Approve Employee Request" Menu Item
            const menuItemApproveRequest = Array.from(menuItems).find(element => {
                return element.innerText === 'Approve Employee Request'
            });
            //If the menu item was found, relabel to "Acknowledge"
            if (menuItemApproveRequest) {
                menuItemApproveRequest.innerHTML = "Acknowledge"
            }

            //SPS-983 Find Employee Request menu item and its children
            const requestMenuItem = Array.from(menuItems).find(element => {
                return element.innerText === 'Employee Request'
            });
            const requestMenuItems = !requestMenuItem ? null : requestMenuItem.childNodes[1].children;
            //SPS-983 Remove "Other" Request Type and relabel all other Request Types to "Create"
            if (requestMenuItems) {
                for (const item of requestMenuItems) {
                    if (item.innerHTML != 'Other') {
                        item.innerHTML = 'Create'
                    } else {
                        item.setAttribute('data-customformat', 'employeeRequestHidden');
                    }
                }
            }
        }
    }
}

//SPS-983 Display miniform for non-"other" Request Types after Employee Request transient object created
if (window.createDynamicRequestFunction) {
    window.createDynamicRequestFunction = function (cells, name, available, approved, payCode) {
        return function () {
            const dirtyRequests_before_length = dirtyRequests.length;
            createRequest(cells, name, available, approved, payCode);

            // If a new request has been created, open the miniform for it, if it is not of "Other" type
            if (dirtyRequests.length > dirtyRequests_before_length) {
                const request = dirtyRequests[dirtyRequests.length - 1];

                if (request.type !== 'Other') {
                    newSchedulingMiniForm([request], sObjectAPINames.request, request.div, window.saveMiniFormRequest);
                }
            }
        }
    }
}