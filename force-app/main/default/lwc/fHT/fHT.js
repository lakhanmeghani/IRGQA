import { LightningElement, wire, api, track } from 'lwc';
import getHistoryRecords from '@salesforce/apex/FieldHistoryController.getHistoryRecords';

const columns = [
    { label: 'Field', fieldName: 'Field' },
    { label: 'Old Value', fieldName: 'OldValue' },
    { label: 'New Value', fieldName: 'NewValue' },
    { label: 'Modified By', fieldName: 'CreatedById', type: 'text' },
    { label: 'Modified Date', fieldName: 'CreatedDate', type: 'date' }
];

export default class FHT extends LightningElement {
    @api recordId; // Record ID of the object to get history
    @api objectApiName; // API Name of the history object to query

    @track historyData = [];
    @track columns = columns;
    @track isLoading = false;

    @wire(getHistoryRecords, { objectApiName: '$objectApiName', recordId: '$recordId' })
    wiredHistory({ error, data }) {
        this.isLoading = true;
        if (data) {
            this.historyData = data;
            this.isLoading = false;
        } else if (error) {
            console.error('Error fetching history records', error);
            this.isLoading = false;
        }
    }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        let cloneData = [...this.historyData];
        cloneData.sort((a, b) => {
            let val1 = a[sortedBy] ? a[sortedBy] : '';
            let val2 = b[sortedBy] ? b[sortedBy] : '';
            return (val1 > val2 ? 1 : -1) * (sortDirection === 'asc' ? 1 : -1);
        });
        this.historyData = cloneData;
    }
}