import { LightningElement, api } from "lwc";

/**
 * apex class==>FieldSetHelper
 *
 * dependent components
 * lwcSpinner
 * createRecordFromFieldset
 * modalComponentTemplate
 *
 */

const CSS_CLASS = "spinner-hidden";
export default class LwcCreateRecordModalContainer extends LightningElement {
  @api header = "Create Case"; //Create Case
  @api sFDCobjectApiName = "Case"; //Case
  @api fieldSetName = "QuickCaseFS"; //'QuickCaseFS'
  showSpinner;

  //this calls for modal to display
  handleShowModal() {
    this.showSpinner = true;
    this.template.querySelector("c-modal-component-template").show();
  }

  //this makes modal is hidden
  handleCancelModal() {
    this.template.querySelector("c-modal-component-template").hide();
  }

  //This event handler calls the handleSubmit public method of fieldset component
  handleSubmitModal(event) {
    this.template.querySelector("c-create-record-from-fieldset").handleSubmit();
  }

  //This postSuccess event handler closes the modal
  handlePostSuccess(event) {
    event.stopPropagation();
    this.handleCancelModal();
  }

  //This makes spinner to be hidden
  handleCreateRecordCmpLoaded(event) {
    setTimeout(() => {
      this.template.querySelector("c-lwc-spinner").classList.add(CSS_CLASS);
      this.showSpinner = false;
    }, 1200);
  }
}
