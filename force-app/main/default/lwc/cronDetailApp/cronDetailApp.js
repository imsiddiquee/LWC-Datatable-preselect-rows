import { LightningElement, wire } from "lwc";

import GetUserCronJobDetailList from "@salesforce/apex/CronTriggerController.GetUserCronJobDetailList";
import GetAllActiveUsersMap from "@salesforce/apex/CronTriggerController.GetAllActiveUsersMap";
import GetApexJobsCreatedByUser from "@salesforce/apex/CronTriggerController.GetApexJobsCreatedByUser";

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

export default class CronDetailApp extends LightningElement {
  tableData = [];
  apexJobData = [];
  userOptionsList;
  selectedUser;
  columns = COLUMNS;
  apexColumns = APEXJObSCOLUMNS;
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

  @wire(GetUserCronJobDetailList, { userId: "$selectedUser" })
  getCronJobList(response) {
    //this.todoTasksResponse = response;
    let data = response.data;
    let error = response.error;

    if (data || error) {
      //this.processing = false;
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

      console.log(this.tableData);
    } else if (error) {
      console.log("error");
    }
  }

  @wire(GetAllActiveUsersMap)
  retrieveActiveUsers(response) {
    let data = response.data;
    let error = response.error;

    if (data || error) {
      //this.processing = false;
    }

    if (data) {
      let tempArray = [];

      for (let key in data) {
        tempArray.push({ label: data[key], value: key });
      }

      this.userOptionsList = tempArray;

      console.log(this.userOptionsList);
    } else if (error) {
      console.log("error");
    }
  }

  handleUserChange(event) {
    this.selectedUser = event.target.value;
    console.log("selectedUser::", this.selectedUser);
    // this.template.querySelector("[data-id='selectId']").value =
    //   this.selectedUser;
  }

  @wire(GetApexJobsCreatedByUser, { userId: "$selectedUser" })
  getApexJobList(response) {
    //this.todoTasksResponse = response;
    let data = response.data;
    let error = response.error;

    if (data || error) {
      //this.processing = false;
    }

    if (data) {
      this.apexJobData = [];

      console.log("apex data", data);

      data.forEach((item) => {
        this.apexJobData.push({
          id: item.Id,
          className: item.ApexClass.Name,
          jobItemsProcessed: item.JobItemsProcessed,
          jobType: item.JobType,
          status: item.Status,
          numberOfErrors: item.NumberOfErrors,
          methodName: item.MethodName,
          createdById: item.CreatedById
        });
      });

      console.log("apexJobData", this.apexJobData);
    } else if (error) {
      console.log("error");
    }
  }
}
