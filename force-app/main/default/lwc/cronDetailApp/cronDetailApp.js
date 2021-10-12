import { api, LightningElement, wire } from "lwc";

import GetUserCronJobDetailList from "@salesforce/apex/CronTriggerController.GetUserCronJobDetailList";
import GetAllActiveUsersMap from "@salesforce/apex/CronTriggerController.GetAllActiveUsersMap";
import GetApexJobsCreatedByUser from "@salesforce/apex/CronTriggerController.GetApexJobsCreatedByUser";
import GetUserFlowAndProcessBuilderDetailList from "@salesforce/apex/CronTriggerController.GetUserFlowAndProcessBuilderDetailList";
import GetUserApprovalTaskDetailList from "@salesforce/apex/CronTriggerController.GetUserApprovalTaskDetailList";
import GetWorkflowRuleList from "@salesforce/apex/CronTriggerController.GetWorkflowRuleList";
import getUserDetail from "@salesforce/apex/CronTriggerController.getUserDetail";
import getUserReports from "@salesforce/apex/CronTriggerControllerReport.getUserReports";

/**
 * apex return data must have id column
 * PageSession.page==>visual-force page
 * SessionHelper==> apex class
 * CronTriggerController==>apex controller
 * CronTriggerControllerReport==>apex controller
 * dependent on components are
 * confirmationDialog==>confirmation message
 * userDetail
 * paginator==>grid pagination
 * utils==>export to csv
 * reusableDataTable==>for grid
 
 
 * confirmation dialog
 */

const CRONCOLUMNS = [
    {
        label: "Abort",
        type: "button-icon",
        initialWidth: 75,
        typeAttributes: {
            iconName: "utility:delete",
            title: "Abort",
            variant: "border-filled",
            alternativeText: "Abort"
        }
    },
    { label: "Job Id", fieldName: "jobId" },
    { label: "Job Name", fieldName: "jobName" },
    { label: "JobType", fieldName: "jobType" },
    { label: "State", fieldName: "state" },
    { label: "PreviousFireTime", fieldName: "previousFireTime" },
    { label: "NextFireTime", fieldName: "nextFireTime" },
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

const REPORTCOLUMNS = [
    { label: "Report", fieldName: "name" },
    { label: "Owner", fieldName: "owner" },
    { label: "Created By", fieldName: "createdBy" },
    { label: "Created Date", fieldName: "createdDate" },
    { label: "Last Modified By", fieldName: "lastModifiedBy" },
    { label: "Last Modified Date", fieldName: "lastModifiedDate" },
    { label: "Last Run Date", fieldName: "lastRunDate" },
    { label: "Last Viewed Date", fieldName: "lastViewedDate" }
];

export default class CronDetailApp extends LightningElement {
    @api componentTitle = "User related jobs";

    workflowData = [];
    approvalData = [];
    flowData = [];
    cronData = [];
    apexJobData = [];
    reportData = [];
    userOptionsList;
    selectedUser;
    userDetail = {};
    cronColumns = CRONCOLUMNS;
    apexColumns = APEXJObSCOLUMNS;
    flowColumns = FLOWCOLUMNS;
    approvalColumns = APPROVALCOLUMNS;
    workflowColumns = WORKFLOWRULECOLUMNS;
    reportColumns = REPORTCOLUMNS;
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

    //process user details
    @wire(getUserDetail, { userId: "$selectedUser" })
    retrivedUserDetail(response) {
        let data = response.data;
        let error = response.error;

        if (data || error) {
            this.processing = false;
        }
        if (data) {
            this.userDetail = data;
            //console.log("user detail", JSON.stringify(data));
            //console.log(data);
        } else if (error) {
            console.log("getUserDetail", error);
        }
    }

    @wire(GetWorkflowRuleList, { userId: "$selectedUser" })
    retrivedWorkflowRuleList(response) {
        let data = response.data;
        let error = response.error;

        if (data || error) {
            this.processing = false;
        }

        this.workflowData = [];

        if (data) {
            let userflowData = [];

            data.records.forEach((item) => {
                userflowData.push({
                    id: item.Id,
                    name: item.Name,
                    whereItUsed: item.TableEnumOrId,
                    createdById: item.CreatedById,
                    lastModifiedById: item.LastModifiedById,
                    type: "Workflow"
                });
            });

            if (userflowData.length) {
                //filter

                let userflow = userflowData.filter((p) => p.lastModifiedById === this.selectedUser);

                this.workflowData = userflow || [];
            }
        } else if (error) {
            console.log("GetWorkflowRuleList", error);
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
            console.log("GetUserApprovalTaskDetailList", error);
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
                    ...item,

                    jobType:
                        this.JOBTYPEMAP[item.jobType] === undefined || this.JOBTYPEMAP[item.jobType] === null
                            ? item.CronJobDetail.jobType
                            : this.JOBTYPEMAP[item.jobType].jobName
                });
            });

            //console.log(this.cronData);
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
                    className: Object.keys(item).includes("ApexClass") ? item.ApexClass.Name : "",
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

    //process reports
    @wire(getUserReports, { userId: "$selectedUser" })
    retrivedUserReports(response) {
        let data = response.data;
        let error = response.error;

        if (data || error) {
            this.processing = false;
        }

        if (data) {
            this.reportData = data;
        } else if (error) {
            console.log("getUserReports");
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

    refreshFromChild(event) {
        this.selectedUser = "";
        //console.log("refresh from child");
        this.selectedUser = event.payload;
    }
}
