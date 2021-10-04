import { LightningElement } from "lwc";
import { exportCSVFileWithDynamicHeader } from "c/ldsUtils";

export default class CsvExportApp extends LightningElement {
  userData = [
    {
      username: "Nikhil",
      age: 25,
      title: "Developer"
    },
    {
      username: "Salesforcetroop",
      age: 2,
      title: "Youtube channel"
    },
    {
      username: "Friends",
      age: 20,
      title: "Netflix series"
    }
  ];

  headers = {
    username: "User Name",
    age: "Age",
    title: "Title"
  };

  downloadUserDetails() {
    console.log("download triggered.");
    exportCSVFileWithDynamicHeader(this.userData, "user detail");
  }
}
