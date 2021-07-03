import { api, LightningElement, wire } from "lwc";

import GetUserCronJobDetailList from "@salesforce/apex/CronTriggerController.GetUserCronJobDetailList";
import GetAllActiveUsersMap from "@salesforce/apex/CronTriggerController.GetAllActiveUsersMap";
import GetApexJobsCreatedByUser from "@salesforce/apex/CronTriggerController.GetApexJobsCreatedByUser";
import GetUserFlowAndProcessBuilderDetailList from "@salesforce/apex/CronTriggerController.GetUserFlowAndProcessBuilderDetailList";
import GetUserApprovalTaskDetailList from "@salesforce/apex/CronTriggerController.GetUserApprovalTaskDetailList";
import GetWorkflowRuleList from "@salesforce/apex/CronTriggerController.GetWorkflowRuleList";

/**
 * CronTriggerController==>apex controller
 * dependent on components are
 * reusableDataTable==>for grid
 * paginator==>grid pagination
 * utils==>export to csv
 */

const CRONCOLUMNS = [
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

const WORKFLOWRULECOLUMNS = [
  { label: "Id", fieldName: "id" },
  { label: "Workflow Label", fieldName: "name" },
  { label: "Type", fieldName: "type" },
  { label: "Where It Used", fieldName: "whereItUsed" },
  { label: "Owner", fieldName: "lastModifiedById" }
];

export default class CronDetailApp extends LightningElement {
  @api componentTitle = "User related jobs";

  workflowData = [];
  approvalData = [];
  flowData = [];
  cronData = [];
  apexJobData = [];
  userOptionsList;
  selectedUser;
  cronColumns = CRONCOLUMNS;
  apexColumns = APEXJObSCOLUMNS;
  flowColumns = FLOWCOLUMNS;
  approvalColumns = APPROVALCOLUMNS;
  workflowColumns = WORKFLOWRULECOLUMNS;
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

  @wire(GetWorkflowRuleList, { userId: "$selectedUser" })
  retrivedWorkflowRuleList(response) {
    let data = response.data;
    let error = response.error;

    if (data || error) {
      this.processing = false;
    }

    if (data && !Object.keys(data).length) {
      this.workflowData = [];
    } else if (data) {
      this.workflowData = [];

      data.records.forEach((item) => {
        this.workflowData.push({
          id: item.Id,
          name: item.Name,
          whereItUsed: item.TableEnumOrId,
          createdById: item.CreatedById,
          lastModifiedById: item.LastModifiedById,
          type: "Workflow"
        });
      });

      //filter
      this.workflowData = this.workflowData.filter(
        (p) => p.lastModifiedById === this.selectedUser
      );
    } else if (error) {
      console.log("error");
    }
  }

  //working
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

      // console.log("retrivedUserApprovalTaskDetailList", this.approvalData);
    } else if (error) {
      console.log("error");
    }
  }

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
      this.cronData = [];

      data.forEach((item) => {
        this.cronData.push({
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
        if (key) {
          tempArray.push({ label: data[key], value: key });
        }
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
      this.apexJobData = [];

      data.forEach((item) => {
        this.apexJobData.push({
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
    } else if (error) {
      console.log("error");
    }
  }

  refreshList() {
    // this.workflowData = [];
    // this.approvalData = [];
    // this.flowData = [];
    // this.cronData = [];
    // this.apexJobData = [];
    this.selectedUser = "";
  }
}
