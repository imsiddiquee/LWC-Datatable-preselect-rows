import { api, LightningElement, wire } from "lwc";

import GetUserCronJobDetailList from "@salesforce/apex/CronTriggerController.GetUserCronJobDetailList";
import GetAllActiveUsersMap from "@salesforce/apex/CronTriggerController.GetAllActiveUsersMap";
import GetApexJobsCreatedByUser from "@salesforce/apex/CronTriggerController.GetApexJobsCreatedByUser";
import GetUserFlowAndProcessBuilderDetailList from "@salesforce/apex/CronTriggerController.GetUserFlowAndProcessBuilderDetailList";
import GetUserApprovalTaskDetailList from "@salesforce/apex/CronTriggerController.GetUserApprovalTaskDetailList";

const COLUMNS = [
  { label: "Job Id", fieldName: "jobId" },
  { label: "Job Name", fieldName: "jobName" },
  { label: "JobType", fieldName: "jobType" },
  { label: "State", fieldName: "state" },
  { label: "PreviousFireTime", fieldName: "previousFireTime", type: "date" },
  { label: "NextFireTime", fieldName: "nextFireTime", type: "date" },
  { label: "OwnerId", fieldName: "ownerId" }
];

const APEXJObSCOLUMNS = [
  { label: "Apex Job Id", fieldName: "id" },
  { label: "Class Name", fieldName: "className" },
  { label: "Job Items Processed", fieldName: "jobItemsProcessed" },
  { label: "Job Type", fieldName: "jobType" },
  { label: "Status", fieldName: "status" },
  { label: "Number Of Errors", fieldName: "numberOfErrors" },
  { label: "Method Name", fieldName: "methodName" },
  { label: "Created By Id", fieldName: "createdById" }
];

const FLOWCOLUMNS = [
  { label: "Flow Id", fieldName: "id" },
  { label: "Flow Label", fieldName: "label" },
  { label: "Process Type", fieldName: "processType" },
  { label: "Builder", fieldName: "builder" },
  { label: "Is Active", fieldName: "isActive" },
  { label: "Owner", fieldName: "lastModifiedBy" }
];

const APPROVALCOLUMNS = [
  { label: "Approval Id", fieldName: "id" },
  { label: "Approval Label", fieldName: "name" },
  { label: "Type", fieldName: "type" },
  { label: "Where It Used", fieldName: "whereItUsed" },
  { label: "status", fieldName: "status" },
  { label: "Owner", fieldName: "owner" }
];

export default class CronDetailApp extends LightningElement {
  @api componentTitle = "User related jobs";
  page = 1; //this will initialize 1st page
  items = []; //it contains all the records.
  // data = []; //data to be displayed in the table

  startingRecord = 1; //start record position per page
  endingRecord = 0; //end record position per page
  pageSize = 5; //default value we are assigning
  totalRecountCount = 0; //total record count received from all retrieved records
  totalPage = 0; //total number of page is needed to display all records

  //

  approvalData = [];
  flowData = [];
  tableData = [];
  apexJobData = [];
  userOptionsList;
  selectedUser;
  columns = COLUMNS;
  apexColumns = APEXJObSCOLUMNS;
  flowColumns = FLOWCOLUMNS;
  approvalColumns = APPROVALCOLUMNS;
  userId = "";
  JOBTYPEMAP = {
    1: { jobName: "Data Export" },
    3: { jobName: "Dashboard Refresh" },
    4: { jobName: "Reporting Snapshot" },
    6: { jobName: "Scheduled Flow" },
    7: { jobName: "Scheduled Apex" },
    8: { jobName: "Report Run" },
    9: { jobName: "Batch Job" },
    A: { jobName: "Reporting Notification" }
  };

  processing = true;

  @wire(GetUserApprovalTaskDetailList, { userId: "$selectedUser" })
  retrivedUserApprovalTaskDetailList(response) {
    let data = response.data;
    let error = response.error;

    if (data || error) {
      this.processing = false;
    }

    if (data) {
      this.approvalData = [];

      data.forEach((item) => {
        this.approvalData.push({
          id: item.Id,
          name: item.Name,
          type: item.Type,
          whereItUsed: item.TableEnumOrId,
          status: item.State,
          owner: item.CreatedById
        });
      });

      console.log("retrivedUserApprovalTaskDetailList", this.approvalData);
    } else if (error) {
      console.log("error");
    }
  }

  //working
  @wire(GetUserFlowAndProcessBuilderDetailList, { userId: "$selectedUser" })
  retrivedUserFlowAndProcessBuilderDetailList(response) {
    let data = response.data;
    let error = response.error;

    if (data || error) {
      this.processing = false;
    }

    if (data) {
      this.flowData = [];

      data.forEach((item) => {
        this.flowData.push({
          id: item.Id,
          label: item.Label,
          isActive: item.IsActive,
          lastModifiedBy: item.LastModifiedBy,
          processType: this.formatProcessType(item.ProcessType),
          builder: item.Builder
        });
      });

      // console.log("retrivedUserFlowAndProcessBuilderDetailList", this.flowData);
    } else if (error) {
      console.log("error");
    }
  }

  formatProcessType(processType) {
    switch (processType.toLowerCase()) {
      case "workflow":
        return "Process Builder";
      case "flow":
        return "Flow";
      case "autolaunchedflow":
        return "Flow";
      default:
        return processType;
    }
  }

  @wire(GetUserCronJobDetailList, { userId: "$selectedUser" })
  getCronJobList(response) {
    //this.todoTasksResponse = response;
    let data = response.data;
    let error = response.error;

    if (data || error) {
      this.processing = false;
    }

    if (data) {
      this.tableData = [];

      data.forEach((item) => {
        this.tableData.push({
          id: item.Id,
          jobId: item.CronJobDetail.Id,
          jobName: item.CronJobDetail.Name,
          jobType:
            this.JOBTYPEMAP[item.CronJobDetail.JobType] === undefined ||
            this.JOBTYPEMAP[item.CronJobDetail.JobType] === null
              ? item.CronJobDetail.JobType
              : this.JOBTYPEMAP[item.CronJobDetail.JobType].jobName,
          state: item.State,
          previousFireTime: item.PreviousFireTime,
          nextFireTime: item.NextFireTime,
          ownerId: item.OwnerId
        });
      });

      //console.log(this.tableData);
    } else if (error) {
      console.log("error");
    }
  }

  @wire(GetAllActiveUsersMap)
  retrieveActiveUsers(response) {
    let data = response.data;
    let error = response.error;

    if (data || error) {
      this.processing = false;
    }

    if (data) {
      let tempArray = [];

      for (let key in data) {
        tempArray.push({ label: data[key], value: key });
      }

      this.userOptionsList = tempArray;

      //console.log(this.userOptionsList);
    } else if (error) {
      console.log("error");
    }
  }

  handleUserChange(event) {
    this.processing = true;

    this.selectedUser = event.target.value;
    //console.log("selectedUser::", this.selectedUser);
    // this.template.querySelector("[data-id='selectId']").value =
    //   this.selectedUser;
  }

  @wire(GetApexJobsCreatedByUser, { userId: "$selectedUser" })
  getApexJobList(response) {
    //this.todoTasksResponse = response;
    let data = response.data;
    let error = response.error;

    if (data || error) {
      this.processing = false;
    }

    if (data) {
      let formatApexJobsDate = [];

      // console.log(data);

      data.forEach((item) => {
        formatApexJobsDate.push({
          id: item.Id,
          className: Object.keys(item).includes("ApexClass")
            ? item.ApexClass.Name
            : "",
          jobItemsProcessed: item.JobItemsProcessed,
          jobType: item.JobType,
          status: item.Status,
          numberOfErrors: item.NumberOfErrors,
          methodName: item.MethodName,
          createdById: item.CreatedById
        });
      });

      //c/configurationCustomize

      this.items = formatApexJobsDate;
      this.totalRecountCount = formatApexJobsDate.length; //here it is 23
      this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5

      //initial data to be displayed ----------->
      //slice will take 0th element and ends with 5, but it doesn't include 5th element
      //so 0 to 4th rows will be displayed in the table
      this.apexJobData = this.items.slice(0, this.pageSize);
      this.endingRecord = this.pageSize;
      //this.columns = columns;

      this.error = undefined;

      // console.log("apexJobData", this.data);
    } else if (error) {
      console.log("error");
    }
  }

  //clicking on previous button this method will be called
  previousHandler() {
    if (this.page > 1) {
      this.page = this.page - 1; //decrease page by 1
      this.displayRecordPerPage(this.page);
    }
  }
  //clicking on next button this method will be called
  nextHandler() {
    //console.log("test");
    if (this.page < this.totalPage && this.page !== this.totalPage) {
      this.page = this.page + 1; //increase page by 1
      this.displayRecordPerPage(this.page);
    }
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

    this.apexJobData = this.items.slice(this.startingRecord, this.endingRecord);

    //increment by 1 to display the startingRecord count,
    //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
    this.startingRecord = this.startingRecord + 1;
  }
}
