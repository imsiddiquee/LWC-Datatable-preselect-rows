import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import { exportCSVFileWithDynamicHeader } from "c/utils";
import AbortTheSelectedJob from "@salesforce/apex/CronTriggerController.AbortTheSelectedJob";

export default class ReusableDataTable extends LightningElement {
  processing = false;

  @api cardTitle = "";

  @api columns = [];

  //pre selected row
  @track allSeletedRowCount = 0;

  @track selectedRowsPagesMap = [];
  @track unSelectedRowsPagesMap = [];
  @track prePageSelectedRows = []; //used to dispaly on ui

  @track _originTagRowSelectionLocal = "LIGHTNING-DATATABLE";

  //table check box show/hide base on parent property.
  @track
  isHideChkColumn = true;
  @api
  get hideCheckbox() {
    return this.isHideChkColumn;
  }
  set hideCheckbox(value) {
    this.isHideChkColumn = value === "true" ? true : false;
  }

  //col boarder

  @track
  columnBoarderClass = "";
  @api
  get columnBoarder() {
    return this.columnBoarderClass;
  }
  set columnBoarder(value) {
    this.columnBoarderClass = value === "true" ? "slds-table_col-bordered" : "";
  }

  rowOffset = 0;

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
    this.items = value;
    this.totalRecountCount = value.length; //here it is 23
    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5

    //initial data to be displayed ----------->
    //slice will take 0th element and ends with 5, but it doesn't include 5th element
    //so 0 to 4th rows will be displayed in the table
    this.data = this.items.slice(0, this.pageSize);
    this.getPrePageSelectedRows(1);
    this.endingRecord = this.pageSize;
    this._originTagRowSelectionLocal = "LIGHTNING-DATATABLE";

    // this.error = undefined;
  }

  //confirmation message

  isDialogVisible = false;

  selectedJobId = "";
  selectedUserId = "";

  get confirmationDisplayMessage() {
    return `Do you want to proceed job ${this.selectedJobId}?`;
  }

  // Parent call this event to know data-table selected rows.
  @api getRows() {
    //return this.template.querySelector("lightning-datatable").getSelectedRows();

    let unSelectedRows = [];

    JSON.parse(JSON.stringify(this.unSelectedRowsPagesMap)).forEach(
      (rowsList) => {
        if (rowsList !== null) {
          unSelectedRows = [...unSelectedRows, ...rowsList];
        }
      }
    );

    let result = [];
    result = JSON.parse(JSON.stringify(this.items)).filter(
      (row) => !unSelectedRows.includes(row.id)
    );

    return result;
  }

  isNotBlank(checkString) {
    return (
      checkString !== "" && checkString !== null && checkString !== undefined
    );
  }

  //clicking on previous button this method will be called
  previousHandler() {
    this.processing = true;
    if (this.page > 1) {
      this.page = this.page - 1; //decrease page by 1
      this.displayRecordPerPage(this.page);
    }
    this.decreaseRowOffset();
    this.setDelay();
  }

  //clicking on next button this method will be called
  nextHandler() {
    this.processing = true;
    if (this.page < this.totalPage && this.page !== this.totalPage) {
      this.page = this.page + 1; //increase page by 1
      this.displayRecordPerPage(this.page);
    }
    this.increaseRowOffset();
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
    this.getPrePageSelectedRows(page);
    //increment by 1 to display the startingRecord count,
    //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
    this.startingRecord = this.startingRecord + 1;
  }

  increaseRowOffset() {
    this.rowOffset += this.pageSize;
  }

  decreaseRowOffset() {
    this.rowOffset -= this.pageSize;
  }

  exportToCSV() {
    if (Object.keys(this.items)) {
      exportCSVFileWithDynamicHeader(this.items, "export file");
    }
  }

  handleRowAction(event) {
    const row = event.detail.row;
    console.log(row);
    this.abortTheJob(row.id, row.ownerId);
  }

  abortTheJob(jobId, ownerId) {
    // AbortTheSelectedJob({ jobId: jobId })
    //   .then((response) => {
    //     console.log("successfully job abort", response);
    //   })
    //   .catch((error) => {
    //     console.log("failed job abort", error);
    //   });
    //this.showToastMessage(jobId);

    //let datafromchild = this.template.querySelector("lightning-datatable");

    this.selectedJobId = jobId;
    this.selectedUserId = ownerId;
    this.isDialogVisible = true;
  }

  showToastMessage(messageVariant, messageTitle) {
    const toastEvnt = new ShowToastEvent({
      title: messageTitle,
      message: this.msg,
      variant: messageVariant,
      mode: "dismissable"
    });
    this.dispatchEvent(toastEvnt);
  }

  abotJob() {
    AbortTheSelectedJob({ jobId: this.selectedJobId })
      .then((response) => {
        console.log("successfully job abort", response);
        this.showToastMessage(
          "success",
          `Successfully job ${this.selectedJobId} is abort.`
        );
        this.handleRefresh();
      })
      .catch((error) => {
        console.log("failed job abort", error);
        this.isDialogVisible = false;
      });
  }

  handleConfirmationClick(event) {
    if (event.target.name === "confirmModal") {
      //when user clicks outside of the dialog area, the event is dispatched with detail value  as 1
      if (event.detail !== 1) {
        //you can do some custom logic here based on your scenario
        if (event.detail.status === "confirm") {
          /**
           * below code abort jobs, so off the code for safety.
           */
          /*
           */
          this.abotJob();

          //display toast message

          // this.showToastMessage(
          //   "success",
          //   `Successfully job ${this.selectedJobId} is abort.`
          // );

          // after abort refresh the grid
        } else if (event.detail.status === "cancel") {
          this.showToastMessage("info", `Process cancel successfully`);
        }
      }

      //hides the component
      this.isDialogVisible = false;
    }
  }

  handleRefresh() {
    this.dispatchEvent(
      new CustomEvent("refreshrecords", { payload: this.selectedUserId })
    );
  }

  setDelay() {
    let timer = window.setTimeout(() => {
      this.processing = false;
      window.clearTimeout(timer);
    }, 300);
  }

  getPrePageSelectedRows(page) {
    try {
      let selectedRowsMap = this.data.map((item) => item.id);
      if (!this.isNotBlank(this.selectedRowsPagesMap[page])) {
        this.selectedRowsPagesMap[page] = selectedRowsMap;
      }
      this.prePageSelectedRows = this.selectedRowsPagesMap[page];
      this.getTotalSeletedRows();
      this._originTagRowSelectionLocal = "button";
    } catch (error) {
      console.log(error);
    }
  }

  handleRowSelection(event) {
    try {
      if (this._originTagRowSelectionLocal === "LIGHTNING-DATATABLE") {
        let selectedRowsMap = JSON.parse(
          JSON.stringify(event.detail.selectedRows)
        );

        //unselected

        let unSelectedRowsMap = this.prePageSelectedRows.filter(
          (o1) => !selectedRowsMap.some((o2) => o1 === o2.id)
        );
        this.unSelectedRowsPagesMap[this.page] = unSelectedRowsMap;

        //selected
        this.selectedRowsPagesMap[this.page] = selectedRowsMap.map((p) => p.id);
        this.getTotalSeletedRows();
        this._originTagRowSelectionLocal = event.target.tagName;
      } else {
        this._originTagRowSelectionLocal = event.target.tagName;
      }
    } catch (error) {
      console.log(error);
    }
  }

  getTotalSeletedRows() {
    try {
      let totalCounter = 0;
      Object.values(this.selectedRowsPagesMap).forEach((rowsList) => {
        totalCounter += this.pageSize - rowsList.length;
      });

      this.allSeletedRowCount = this.totalRecountCount - totalCounter;
    } catch (error) {
      console.log(error);
    }
  }
}
