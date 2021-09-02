import { LightningElement, api } from "lwc";

export default class ModelComponentTemplate extends LightningElement {
  showModal = false;
  @api
  set header(value) {
    this._headerPrivate = value;
  }
  get header() {
    return this._headerPrivate;
  }

  _headerPrivate;

  @api show() {
    this.showModal = true;
  }

  @api hide() {
    this.showModal = false;
  }
  handleDialogClose() {
    //Let parent know that dialog is closed (mainly by that cross button)
    // so it can set proper variables if needed
    const closedialog = new CustomEvent("closedialog");
    this.dispatchEvent(closedialog);
    this.hide();
  }

  handleSlotFooterChange() {
    console.log("handleSlotFooterChange::");
    // Only needed in "show" state. If hiding, we're removing from DOM anyway
    if (this.showModal === false) {
      return;
    }

    //this.template.querySelector("footer").hide();
  }
}
