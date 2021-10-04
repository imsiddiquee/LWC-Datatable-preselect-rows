import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { csvToArray } from "c/ldsUtils";
import getExistAccounts from "@salesforce/apex/ReadCSVFileController.getExistAccounts";

/**
 * deploy==>ldsUtils.js
 */

const ACC_COLUMN = "accountName";
const EMAIL_COLUMN = "email";

export default class ReadCSVFile extends LightningElement {
  processing = false;
  @track error;
  @track columns = [];
  _csvData = [];
  @track data = [];
  _csvWrongData = [];
  @track wrongData;

  @track
  fileData;

  // accepted parameters
  get acceptedFormats() {
    return [".csv"];
  }

  openfileUpload(event) {
    const file = event.target.files[0];
    var reader = new FileReader();
    reader.onload = () => {
      let base64 = reader.result.split(",")[1];
      //convert base64 string to a text as a decoded string !
      let fileContent = base64.replace("data:;base64,", "");
      fileContent = window.atob(fileContent);

      this.fileData = {
        filename: file.name,
        base64: fileContent
      };
    };
    reader.readAsDataURL(file);
    this.toast("File uplodad successfully!");
  }

  toast(title) {
    const toastEvent = new ShowToastEvent({
      title,
      variant: "success"
    });
    this.dispatchEvent(toastEvent);
  }

  removeItem(arr, item) {
    return arr.filter((f) => f !== item);
  }

  isNotBlank(checkString) {
    return (
      checkString !== "" && checkString !== null && checkString !== undefined
    );
  }

  handleSubmit() {
    this.processing = true;
    const { filename, base64 } = this.fileData;

    //get csv file data.

    this._csvData = csvToArray(base64);
    this._csvWrongData = this._csvData.wrongData;

    this.getWrongEmailData();
    this.getWrongAccountData();
    this.getExistAccountData();

    this.data = this._csvData.alldata;
    this.formatColumns();
  }

  getWrongEmailData() {
    const allCSVData = this._csvData.data;
    const allCSVColumns = this._csvData.columns;
    let tempWrongData = this._csvWrongData;

    if (allCSVColumns.some((p) => p === EMAIL_COLUMN)) {
      let uniqueEmails = [
        ...new Set(allCSVData.map((item) => item[EMAIL_COLUMN]))
      ];

      //check null
      const nullEmails = allCSVData.filter(
        (item) => !this.isNotBlank(item[EMAIL_COLUMN])
      );
      tempWrongData = [...tempWrongData, ...nullEmails];
      uniqueEmails = uniqueEmails.filter(Boolean);

      //check valid format email address
      //and check dublicate
      uniqueEmails.forEach((uEmail) => {
        if (!this.validateEmail(uEmail)) {
          const wrongEmailFormatRows = allCSVData.filter(
            (item) => item[EMAIL_COLUMN] === uEmail
          );
          tempWrongData = [...tempWrongData, ...wrongEmailFormatRows];
        } else {
          const dublicateEmails = allCSVData.filter(
            (item) => item[EMAIL_COLUMN] === uEmail
          );
          if (dublicateEmails.length > 1) {
            tempWrongData = [...tempWrongData, ...dublicateEmails];
          }
        }
      });
    }

    this._csvWrongData = tempWrongData;
  }

  validateEmail(email) {
    const re =
      /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(String(email).toLowerCase());
  }

  getWrongAccountData() {
    const allCSVData = this._csvData.data;
    const allCSVColumns = this._csvData.columns;
    let tempWrongData = this._csvWrongData;

    if (allCSVColumns.some((p) => p === ACC_COLUMN)) {
      //check null/blank accounts
      const nullAccounts = allCSVData.filter(
        (item) => !this.isNotBlank(item[ACC_COLUMN])
      );
      tempWrongData = [...tempWrongData, ...nullAccounts];
    }

    this._csvWrongData = tempWrongData;
  }

  getExistAccountData() {
    const allCSVData = this._csvData.data;
    const allCSVColumns = this._csvData.columns;

    if (allCSVColumns.some((p) => p === ACC_COLUMN)) {
      let uniqueAccounts = [
        ...new Set(allCSVData.map((item) => item[ACC_COLUMN]))
      ];
      uniqueAccounts = uniqueAccounts.filter(Boolean);
      this.getDataBaseAccounts(uniqueAccounts);
    }
  }

  getDataBaseAccounts(uniqueAccounts) {
    let allCSVData = this._csvData.data;
    let tempWrongData = this._csvWrongData;

    getExistAccounts({ accountIds: uniqueAccounts })
      .then((result) => {
        result.forEach((accItem) => {
          const existAccounts = allCSVData.filter(
            (item) => item[ACC_COLUMN] === accItem.Name
          );

          if (existAccounts.length > 0) {
            tempWrongData = [...tempWrongData, ...existAccounts];
          }
        });
      })
      .catch((error) => {
        this.handleRefresh();
        this.error = error;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error!!",
            message: JSON.stringify(error),
            variant: "error"
          })
        );
      })
      .finally(() => {
        this.processing = false;
        this.wrongData = tempWrongData;
      });
  }

  formatColumns() {
    let tempColumns = this._csvData.columns.map((item) => {
      let columnLabel = item;
      let columnFieldName = item;

      return {
        label: columnLabel,
        fieldName: columnFieldName
      };
    });

    this.columns = tempColumns;
  }

  handleRefresh() {
    this.fileData = null;
    this.data = [];
    this.wrongData = [];
  }
}
