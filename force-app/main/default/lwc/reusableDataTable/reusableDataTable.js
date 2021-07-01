import { LightningElement, api, track } from "lwc";

export default class ReusableDataTable extends LightningElement {
  processing = false;
  @api cardTitle = "";

  @api columns = [];
  @api rowOffset = 0;

  @track page = 1; //this will initialize 1st page
  @track items = []; //it contains all the records.
  @track data = []; //data to be displayed in the table

  @track startingRecord = 1; //start record position per page
  @track endingRecord = 0; //end record position per page
  @track pageSize = 5; //default value we are assigning
  @track totalRecountCount = 0; //total record count received from all retrieved records
  @track totalPage = 0; //total number of page is needed to display all records

  @api
  get sourceData() {
    return this.data;
  }

  set sourceData(value) {
    console.log("sourceData", value);
    this.items = value;
    this.totalRecountCount = value.length; //here it is 23
    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5

    //initial data to be displayed ----------->
    //slice will take 0th element and ends with 5, but it doesn't include 5th element
    //so 0 to 4th rows will be displayed in the table
    this.data = this.items.slice(0, this.pageSize);
    this.endingRecord = this.pageSize;

    // this.error = undefined;
  }

  //clicking on previous button this method will be called
  previousHandler() {
    this.processing = true;
    if (this.page > 1) {
      this.page = this.page - 1; //decrease page by 1
      this.displayRecordPerPage(this.page);
    }
    this.setDelay();
  }

  //clicking on next button this method will be called
  nextHandler() {
    this.processing = true;
    if (this.page < this.totalPage && this.page !== this.totalPage) {
      this.page = this.page + 1; //increase page by 1
      this.displayRecordPerPage(this.page);
    }

    this.setDelay();
  }

  //this method displays records page by page
  displayRecordPerPage(page) {
    /*let's say for 2nd page, it will be => "Displaying 6 to 10 of 23 records. Page 2 of 5"
        page = 2; pageSize = 5; startingRecord = 5, endingRecord = 10
        so, slice(5,10) will give 5th to 9th records.
        */
    this.startingRecord = (page - 1) * this.pageSize;
    this.endingRecord = this.pageSize * page;

    this.endingRecord =
      this.endingRecord > this.totalRecountCount
        ? this.totalRecountCount
        : this.endingRecord;

    this.data = this.items.slice(this.startingRecord, this.endingRecord);

    //increment by 1 to display the startingRecord count,
    //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
    this.startingRecord = this.startingRecord + 1;
  }

  setDelay() {
    let timer = window.setTimeout(() => {
      this.processing = false;
      window.clearTimeout(timer);
    }, 300);
  }
}
