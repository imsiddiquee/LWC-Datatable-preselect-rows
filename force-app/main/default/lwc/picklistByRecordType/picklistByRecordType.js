import { LightningElement, track, wire } from "lwc";
import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import ACCOUNT_OBJECT from "@salesforce/schema/Account";

export default class PicklistByRecordType extends LightningElement {
  @track picklistValuesByRecordType;
  @track selectedAccountTypeValue;

  @wire(getPicklistValuesByRecordType, {
    objectApiName: ACCOUNT_OBJECT,
    recordTypeId: "0125g000000YcwEAAS"
  })
  wiredRecordTypeValues({ data, error }) {
    if (data) {
      console.log(`picklist values`, data.picklistFieldValues.Type.values);
      this.picklistValuesByRecordType = data.picklistFieldValues.Type.values;
    }
    if (error) {
      console.log(`error picklist values`, error);
    }
  }

  handleAccountTypeChange(event) {
    this.selectedAccountTypeValue = event.target.value;
  }
}
