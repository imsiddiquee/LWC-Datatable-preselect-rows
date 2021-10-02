import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import readCSV from "@salesforce/apex/ReadCSVFileController.readCSV";

const COLUMNS = [];

export default class ReadCSVFile extends LightningElement {
  @api recordId = "7011R000000XLBsQAO";
  @track error;
  @track columns;
  @track data;

  // accepted parameters
  get acceptedFormats() {
    return [".csv"];
  }

  connectedCallback() {
    this.columns = [{ label: "Name", fieldName: "name" }];
    this.data = [{ name: "test" }];
    console.log(this.columns.length);
    console.log(this.data.length);
  }

  fileData;
  openfileUpload(event) {
    const file = event.target.files[0];
    var reader = new FileReader();
    reader.onload = () => {
      let base64 = reader.result.split(",")[1];
      let fileContent = base64.replace("data:;base64,", ""); //convert base64 string to a text as a decoded string !
      fileContent = window.atob(fileContent);

      this.fileData = {
        filename: file.name,
        base64: fileContent
      };
      console.log(this.fileData);
    };
    reader.readAsDataURL(file);
  }

  handleSubmit2() {
    const { filename, base64 } = this.fileData;
    let showData = "";
    //console.log("Email ==> " + this.taskRecord.Subject);
    readCSV({ base64: base64 }).then((result) => {
      console.log("result", result);

      if (result.length > 0) {
        //defined columns
        this.columns = result
          .shift()
          .split(",")
          .map((item) => {
            let columnLabel = item;
            let columnFieldName = item;

            return {
              label: columnLabel,
              fieldName: columnFieldName
            };
          });

        let columnLength = this.columns.length;
        let myJson = {};

        showData = result.map((item) => {
          let rawData = item.split(",");

          for (let index = 0; index < columnLength; index++) {
            let rawColumn = Object.values(this.columns[index])[1];
            let rawColumnValue = rawData[index];

            myJson[rawColumn] = rawColumnValue;

            //this.data = [{ name: "test" }];
          }

          return {
            ...myJson
          };
        });
      }

      this.fileData = null;
      console.log("show data", showData);
      this.data = showData;
      //let title = "${filename} uploaded successfully!!";
      //this.toast(title);
    });
  }

  toast(title) {
    const toastEvent = new ShowToastEvent({
      title,
      variant: "success"
    });
    this.dispatchEvent(toastEvent);
  }

  handleSubmit() {
    const { filename, base64 } = this.fileData;

    const csvData = this.csvToArray(base64);
    this.columns = csvData.columns;

    console.log(csvData);

    //format columns
    this.columns = csvData.columns.map((item) => {
      let columnLabel = item;
      let columnFieldName = item;

      return {
        label: columnLabel,
        fieldName: columnFieldName
      };
    });

    //format data
    this.data = csvData.data;
  }

  csvToArray(str, delimiter = ",") {
    // slice from start of text to the first \n index
    // use split to create an array from string by delimiter
    const headers = str.slice(0, str.indexOf("\n")).split(delimiter);

    // slice from \n index + 1 to the end of the text
    // use split to create an array of each csv value row
    const rows = str.slice(str.indexOf("\n") + 1).split("\n");

    // Map the rows
    // split values from each row into an array
    // use headers.reduce to create an object
    // object properties derived from headers:values
    // the object passed as an element of the array
    const arr = rows.map(function (row) {
      const values = row.split(delimiter);
      const el = headers.reduce(function (object, header, index) {
        object[header] = values[index];
        return object;
      }, {});
      return el;
    });

    // return the array
    return {
      columns: headers,
      data: arr
    };
  }
}
