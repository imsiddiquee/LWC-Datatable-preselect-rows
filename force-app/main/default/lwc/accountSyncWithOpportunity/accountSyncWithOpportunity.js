import { api, LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getLatestOpportunityRelatedAccounts from "@salesforce/apex/AccountSyncWithOpportunityController.getLatestOpportunityRelatedAccounts";
import syncLatestOpportunityWithAccounts from "@salesforce/apex/AccountSyncWithOpportunityController.syncLatestOpportunityWithAccounts";

const COLUMNS = [
  {
    label: "Acc Id",
    fieldName: "accountId",
    initialWidth: 80
  },
  {
    label: "Name",
    fieldName: "accountName",
    initialWidth: 80,
    wrapText: true
  },
  {
    label: "Amount",
    fieldName: "accountAmount",
    type: "currency",
    initialWidth: 140,
    cellAttributes: {
      alignment: "left",
      class: { fieldName: "amountColor" },
      iconName: { fieldName: "amountIconName" },
      iconPosition: "right"
    }
  },
  {
    label: "MRR",
    fieldName: "accountMRR",
    type: "currency",
    initialWidth: 140,
    cellAttributes: {
      alignment: "left",
      class: { fieldName: "mrrColor" },
      iconName: { fieldName: "mrrIconName" },
      iconPosition: "right"
    }
  },
  {
    label: "ARR",
    fieldName: "accountARR",
    type: "currency",
    initialWidth: 140,
    cellAttributes: {
      alignment: "left",
      class: { fieldName: "arrColor" },
      iconName: { fieldName: "arrIconName" },
      iconPosition: "right"
    }
  },
  { label: "Is Active", fieldName: "accountActive", initialWidth: 100 },

  { label: "Opp Id", fieldName: "opportunityId", initialWidth: 80 },
  {
    label: "Name",
    fieldName: "opportunityName",
    initialWidth: 100,
    wrapText: true
  },
  { label: "Stage", fieldName: "opportunityStageName", initialWidth: 80 },
  {
    label: "Amount",
    fieldName: "opportunityAmount",
    type: "currency",
    initialWidth: 140,
    cellAttributes: {
      alignment: "left",
      class: { fieldName: "amountColor" },
      iconName: { fieldName: "amountIconName" },
      iconPosition: "right"
    }
  },
  {
    label: "MRR",
    fieldName: "opportunityMRR",
    type: "currency",
    initialWidth: 140,
    cellAttributes: {
      alignment: "left",
      class: { fieldName: "mrrColor" },
      iconName: { fieldName: "mrrIconName" },
      iconPosition: "right"
    }
  },
  {
    label: "ARR",
    fieldName: "opportunityARR",
    type: "currency",
    initialWidth: 140,
    cellAttributes: {
      alignment: "left",
      class: { fieldName: "arrColor" },
      iconName: { fieldName: "arrIconName" },
      iconPosition: "right"
    }
  },
  { label: "Close Date", fieldName: "opportunityCloseDate", initialWidth: 100 },
  {
    label: "Last Modified Date",
    fieldName: "opportunityLastModifiedDate",
    initialWidth: 150
  },
  { label: "Created By", fieldName: "CreatedBy", initialWidth: 120 },
  { label: "Modified By", fieldName: "LastModifiedBy", initialWidth: 120 }
];
export default class AccountSyncWithOpportunity extends LightningElement {
  @api componentTitle = "Account Sync";

  @track
  accountData = [];

  @track preSelectedRows;

  accountColumns = COLUMNS;
  syncMessage = "";
  processing = false;

  showToastMessage(variant, message) {
    const toastEvnt = new ShowToastEvent({
      title: "Sync process complete",
      message: message,
      variant: variant
    });
    this.dispatchEvent(toastEvnt);
  }

  handleSync() {
    this.processing = true;

    syncLatestOpportunityWithAccounts({ accounts: this.accountData })
      .then((response) => {
        if (response === "Success") {
          this.showToastMessage(
            "success",
            `With success,total sync ${this.accountData.length} records.`
          );
        } else {
          this.showToastMessage("error", `With errors reason for ${response}`);
        }
      })
      .catch((error) => {
        console.log(error.body.message);
      })
      .finally(() => {
        //this.processing = false;
        this.handleLoadAccountRelatedLatestOpportunity();
      });

    // call child component event to show selectd rows
    // const selectedRows = this.template
    //   .querySelector('[data-id="overview"]')
    //   .getRows();

    // let selectedRows = this.template
    //   .querySelector("c-reusable-data-table")
    //   .getRows();
    // console.log("selectedRows::", JSON.stringify(selectedRows));
  }

  handleLoadAccountRelatedLatestOpportunity() {
    this.processing = true;
    this.accountData = [];

    getLatestOpportunityRelatedAccounts()
      .then((data) => {
        if (data) {
          this.preSelectedRows = data.selectedIdSet;
          //console.log(JSON.stringify(this.preSelectedRows));

          this.accountData = data.accList.map((item) => {
            let amountColor =
              item.accountAmount !== item.opportunityAmount
                ? "slds-text-color_error"
                : "slds-text-color_success";

            let mrrColor =
              item.accountMRR !== item.opportunityMRR
                ? "slds-text-color_error"
                : "slds-text-color_success";

            let arrColor =
              item.accountARR !== item.opportunityARR
                ? "slds-text-color_error"
                : "slds-text-color_success";

            let amountIconName =
              item.accountAmount !== item.opportunityAmount
                ? "utility:info"
                : "utility:success";

            let mrrIconName =
              item.accountMRR !== item.opportunityMRR
                ? "utility:info"
                : "utility:success";

            let arrIconName =
              item.accountARR !== item.opportunityARR
                ? "utility:info"
                : "utility:success";

            return {
              ...item,
              id: item.accountId,
              amountColor: amountColor,
              mrrColor: mrrColor,
              arrColor: arrColor,
              amountIconName: amountIconName,
              mrrIconName: mrrIconName,
              arrIconName: arrIconName
            };
          });
          //console.log(this.accountData);
        }
      })
      .catch((error) => {
        console.log(error.body.message);
      })
      .finally(() => {
        this.processing = false;
      });
  }
}
