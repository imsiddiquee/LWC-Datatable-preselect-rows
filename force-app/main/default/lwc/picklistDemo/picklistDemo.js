import { LightningElement, track, wire } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import INDUSTRY_FIELD from "@salesforce/schema/Account.Industry";
import TYPE_FIELD from "@salesforce/schema/Account.Type";

export default class PicklistDemo extends LightningElement {
  @track selectedIndustryValue;
  @track typeOptionValues;
  @track selectedTypeValue;
  @track errorList;

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: INDUSTRY_FIELD
  })
  industryValueOptions;

  handleIndustryChange(event) {
    this.selectedIndustryValue = event.target.value;
    console.log(`picklist selected value ${this.selectedIndustryValue}`);
  }

  //

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: TYPE_FIELD
  })
  typeValueOptions({ data, error }) {
    if (data) {
      console.log(data.values);
      this.typeOptionValues = data.values;
    }

    if (error) {
      console.log(error);
    }
  }

  handleTypeChange(event) {
    this.selectedTypeValue = event.target.value;
  }
}
