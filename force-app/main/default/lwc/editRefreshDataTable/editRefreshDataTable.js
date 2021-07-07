import { LightningElement, wire } from "lwc";
import { updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";

import GetContactList from "@salesforce/apex/EditRefreshContactController.GetContactList";

/**
 * How to fetch the data.
 * How to create data table with inline editing
 * How to update record using ui-record-api
 * How to refresh record without pare refresh
 *
 * how to create a list of promise.
 * how to refresh dataTable.
 * */

const COLUMNS = [
  { label: "First Name", fieldName: "FirstName", editable: true },
  { label: "Last Name", fieldName: "LastName", editable: true },
  { label: "Email", fieldName: "Email", editable: true }
];

export default class EditRefreshDataTable extends LightningElement {
  @wire(GetContactList)
  contact;

  columns = COLUMNS;
  draftValues = [];

  handleSave(event) {
    console.log(event.detail.draftValues);
    //create a clone
    const recordInputs = event.detail.draftValues.slice().map((draft) => {
      const fields = Object.assign({}, draft);
      return { fields };
    });

    console.log("recordInputs", recordInputs);

    try {
      //list of promise.
      const recordPromises = recordInputs.map((item) => updateRecord(item));

      Promise.all(recordPromises)
        .then((result) => {
          this.showToastMsg("Success", "Contacts updated");
          this.draftValues = [];
          return refreshApex(this.contact);
        })
        .catch((error) => {
          this.showToastMsg("Error creating record", error.body.message, error);
        });
    } catch (error) {
      console.log(error);
    }
  }

  showToastMsg(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant || "success"
      })
    );
  }
}
