import { api, LightningElement } from "lwc";

import testLabel from "@salesforce/label/c.testLabel";

import testResouece from "@salesforce/resourceUrl/testResouece";

import userId from "@salesforce/user/Id";

import ACCOUNT_OBJ from "@salesforce/schema/Account";
import NAME_FIELD from "@salesforce/schema/Account.Name";

import lang from "@salesforce/i18n/lang";
import local from "@salesforce/i18n/locale";
import currency from "@salesforce/i18n/currency";
import timezone from "@salesforce/i18n/timeZone";

export default class SalesforceModulesExample extends LightningElement {
  @api
  label = {
    testLabel,
    testResouece,
    userId,
    ACCOUNT_OBJ,
    NAME_FIELD,
    lang,
    local,
    currency,
    timezone
  };
}
