import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { csvToArray } from "c/utils";
import getExistAccounts from "@salesforce/apex/ReadCSVFileController.getExistAccounts";

const BASE_URL = `https://${window.location.hostname}/`;
const ACC_COLUMN = "accountName";
const EMAIL_COLUMN = "email";
const COLUMN = [
  {
    label: "Exist Account",
    fieldName: "accountUrl",
    wrapText: true,
    initialWidth: 100,
    type: "url",
    typeAttributes: {
      label: {
        fieldName: ACC_COLUMN
      },
      tooltip: "Acc Name",
      target: "_blank"
    },
    cellAttributes: {
      alignment: "left",
      class: { fieldName: "accountColor" },
      iconName: { fieldName: "accountIconName" },
      iconPosition: "right"
    }
  }
];

export default class ReadCSVFile extends LightningElement {
  @track error;
  @track columns = [];
  @track data;
  @track wrongData;

  @track
  fileData;

  // accepted parameters
  get acceptedFormats() {
    return [".csv"];
  }

  connectedCallback() {
    // this.columns = [{ label: "Name", fieldName: "name" }];
    // this.data = [{ name: "test" }];
    // console.log(this.columns.length);
    // console.log(this.data.length);
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
      console.log(this.fileData);
    };
    reader.readAsDataURL(file);
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

  validateEmail(email) {
    const re =
      /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(String(email).toLowerCase());
  }

  handleSubmit() {
    const { filename, base64 } = this.fileData;

    //get csv file data.
    const csvData = csvToArray(base64);
    this.data = csvData.data;

    //Get wrong data from dublicate email
    let tempWrongData = [];

    if (csvData.columns.some((p) => p === EMAIL_COLUMN)) {
      let uniqueEmails = [
        ...new Set(csvData.data.map((item) => item[EMAIL_COLUMN]))
      ];

      //check null
      const nullEmails = csvData.data.filter(
        (item) => !this.isNotBlank(item[EMAIL_COLUMN])
      );
      tempWrongData = [...tempWrongData, ...nullEmails];
      uniqueEmails = uniqueEmails.filter(Boolean);

      //check valid format email address
      //and check dublicate
      uniqueEmails.forEach((uEmail) => {
        if (!this.validateEmail(uEmail)) {
          const wrongEmailFormatRows = csvData.data.filter(
            (item) => item[EMAIL_COLUMN] === uEmail
          );
          tempWrongData = [...tempWrongData, ...wrongEmailFormatRows];
        } else {
          const dublicateRows = csvData.data.filter(
            (item) => item[EMAIL_COLUMN] === uEmail
          );
          if (dublicateRows.length > 1) {
            tempWrongData = [...tempWrongData, ...dublicateRows];
          }
        }
      });
    }

    this.wrongData = tempWrongData;

    if (csvData.columns.some((p) => p === ACC_COLUMN)) {
      debugger;
      //this.wrongData = tempWrongData;
      // check unique accounts
      let uniqueAccounts = [
        ...new Set(csvData.data.map((item) => item[ACC_COLUMN]))
      ];

      //check null
      const nullAccounts = csvData.data.filter(
        (item) => !this.isNotBlank(item[ACC_COLUMN])
      );
      tempWrongData = [...tempWrongData, ...nullAccounts];
      uniqueAccounts = uniqueAccounts.filter(Boolean);
      this.wrongData = tempWrongData;

      this.getDataBaseAccounts(uniqueAccounts);
    }

    //format columns
    //accountName
    //let tempColumns = this.removeItem(csvData.columns, ACC_COLUMN);

    let tempColumns = csvData.columns.map((item) => {
      let columnLabel = item;
      let columnFieldName = item;

      return {
        label: columnLabel,
        fieldName: columnFieldName
      };
    });
    let tempColumnResult = tempColumns.concat(COLUMN);
    this.columns = tempColumnResult;
    //this.columns = csvData.columns;

    //format data
    this.data = csvData.data;
    console.log(csvData.data);
  }

  getDataBaseAccounts(uniqueAccounts) {
    debugger;
    let tempData = JSON.parse(JSON.stringify(this.data));
    let tempWrongData = JSON.parse(JSON.stringify(this.wrongData));

    getExistAccounts({ accountIds: uniqueAccounts })
      .then((result) => {
        result.forEach((accItem) => {
          debugger;
          const existAccounts = tempData.filter(
            (item) => item[ACC_COLUMN] === accItem.Name
          );

          if (existAccounts.length > 0) {
            tempWrongData = [...tempWrongData, ...existAccounts];
          }
        });
      })
      .catch((error) => {
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
        this.wrongData = tempWrongData;
      });
  }

  handleUniqueAcount() {
    let tempData = Object.values(this.data);

    getExistAccounts({ accountIds: this.data.map((item) => item.accountName) })
      .then((result) => {
        console.log("result", result);

        result.map((item) => {
          debugger;
          let index = tempData.findIndex(
            (aItem) => aItem[ACC_COLUMN] === item.Name
          );
          let temp = tempData[index];

          let accountColor = "slds-text-color_error";

          let accountIconName = "utility:info";
          temp.accountColor = accountColor;
          temp.accountIconName = accountIconName;
          temp.accountUrl = BASE_URL + item.Id;
          tempData[index] = temp;

          return {
            item
          };
        });

        console.log("tempData", tempData);
      })
      .catch((error) => {
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
        this.data = tempData;
      });
  }
}
