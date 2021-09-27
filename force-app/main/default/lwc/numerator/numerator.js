import { api, LightningElement } from "lwc";

export default class Numerator extends LightningElement {
  //@api counter = 0;

  _currentCount = 0;
  priorCount = 0;

  @api
  maximizeCounter() {
    console.log("maximizeCounter");
    this._currentCount += 1000000;
  }

  @api
  get counter() {
    return this._currentCount;
  }
  set counter(value) {
    this.priorCount = this._currentCount;
    this._currentCount = value;
    console.log(this.priorCount);
  }
}
