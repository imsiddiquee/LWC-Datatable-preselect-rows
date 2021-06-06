import { api, LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class NavigationExample extends NavigationMixin(
  LightningElement
) {
  @api greet;
  @api handling;

  navigateToList() {
    let pageReference = {
      type: "standard__objectPage",
      attributes: {
        actionName: "list",
        objectApiName: "Account"
      },
      state: {
        filterName: "Recent"
      }
    };
    this[NavigationMixin.Navigate](pageReference, true);
  }
  navigateToRecord() {
    let pageReferenceRecord = {
      type: "standard__recordPage",
      attributes: {
        actionName: "view",
        recordId: "001O000001QKJMXIA5",
        objectApiName: "Account"
      },
      state: {}
    };
    this[NavigationMixin.Navigate](pageReferenceRecord, true);
  }
  navigateToObjectHome() {
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Case",
        actionName: "home"
      }
    });
  }
  navigateToNewRecordPage() {
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Account",
        actionName: "new"
      }
    });
  }
  navigateToRecordEditPage() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: "001O000001QKJMXIA5",
        objectApiName: "Account", // objectApiName is optional
        actionName: "edit"
      }
    });
  }
  navigateToRelatedList() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordRelationshipPage",
      attributes: {
        recordId: "001O000001QKJMXIA5",
        objectApiName: "Account",
        relationshipApiName: "Contacts",
        actionName: "view"
      }
    });
  }
  navigateToTabPage() {
    this[NavigationMixin.Navigate]({
      type: "standard__navItemPage",
      attributes: {
        // CustomTabs from managed packages are identified by their
        // namespace prefix followed by two underscores followed by the
        // developer name. E.g. 'namespace__TabName'
        apiName: "LWC_Recipes"
      }
    });
  }
  navigateToWebPage() {
    this[NavigationMixin.Navigate](
      {
        type: "standard__webPage",
        attributes: {
          url: "http://salesforce.com"
        }
      },
      {
        replace: true
      }
    );
  }
}
