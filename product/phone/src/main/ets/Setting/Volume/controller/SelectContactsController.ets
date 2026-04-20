/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* instrument ignore file */
import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import settings from '@ohos.settings';
import { BusinessError } from '@ohos.base';
import { contact } from '@kit.ContactsKit';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ContextUtils } from '@ohos/settings.common/src/main/ets/utils/baseutils/ContextUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  NOT_DISTURB_NUMBER_MINUS,
  NOT_DISTURB_VALUE_DISABLE,
  NOT_DISTURB_VALUE_ENABLE
} from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';
import { ContactObject, ContactsColumns, SpecifiedBean } from '../model/IncomingCallParam';
import { IncomingCallUtils } from '../utils/IncomingCallUtils';
import LooseObject from '../constant/LooseObject'

const TAG = 'SelectContactsController: ';
export const NOT_DISTURB_SELECT_CONTACTS_COUNT: string = 'not_disturb_select_contacts_count';
export const SELECT_CONTACTS_COUNT: string = 'select_contacts_count';

/**
 * 选择联系人菜单控制器
 */
export class SelectContactsController {
  private static sInstance: SelectContactsController;
  private lastSelectContacts: Array<SpecifiedBean> = [];

  static getInstance() {
    if (SelectContactsController.sInstance == null) {
      SelectContactsController.sInstance = new SelectContactsController();
    }
    return SelectContactsController.sInstance;
  }

  onInit(): void {
    LogUtil.info(`${TAG} init.`);
    IncomingCallUtils.getInstance().getSelectContactList((value: SpecifiedBean) => {
      this.lastSelectContacts = IncomingCallUtils.getInstance().dealSelectContactsData(value);
    });
  }

  onDestroy(): void {
    LogUtil.info(`${TAG} destory.`);
  }

  batchSelectContactForResult(data: LooseObject, call: Function) {
    if (data.length > 0) {
      this.dealContactParams(null, JSON.stringify(data), call);
    } else {
      LogUtil.info(`${TAG} no select contact`);
    }
  }

  private async dealContactParams(daHelper: dataShare.DataShareHelper | null, contactObjects: string, call: Function) {
    LogUtil.info(`${TAG} updateSpecified start.`);
    if (daHelper == undefined || daHelper == null) {
      daHelper = await dataShare.createDataShareHelper(ContextUtils.getContext(), ContactsColumns.CONTENT_URI, {});
    }
    try {
      let params: LooseObject[] = [];
      params = JSON.parse(contactObjects);
      let selectContacts: LooseObject[] = [];
      for (let i = 0; i < params.length; i++) {
        let condition = new dataSharePredicates.DataSharePredicates();
        let element: contact.Contact = params[i];
        condition.equalTo('id', element.id);
        this.updateContactMarker(daHelper, condition, true, call);
        LogUtil.info(`${TAG} updateSpecified end.`);
        if (!this.isSameContactsId(selectContacts, element.id!)) {
          selectContacts.push(element);
        }
      }
      await this.dealRepeatContacts(daHelper, selectContacts, call);
      SettingsDataUtils.setSettingsData(NOT_DISTURB_SELECT_CONTACTS_COUNT,
        selectContacts.length.toString(), settings.domainName.USER_PROPERTY);
      EventBus.getInstance().emit(SELECT_CONTACTS_COUNT, selectContacts.length);
    } catch (e) {
      LogUtil.error(`${TAG} dealContactParams failed, return!`);
    }
  }

  isSameContactsId(selectContacts: LooseObject[], id: number): boolean {
    let result: boolean = false;
    selectContacts.forEach(param => {
      if (param.id == id) {
        result = true;
      }
    });
    return result;
  }

  private async dealRepeatContacts(daHelper: dataShare.DataShareHelper | null,
                                   selectContacts: Array<LooseObject>, call: Function) {
    LogUtil.info(`${TAG} dealRepeatContacts start.`);
    if (daHelper == undefined || daHelper == null) {
      daHelper = await dataShare.createDataShareHelper(ContextUtils.getContext(), ContactsColumns.CONTENT_URI, {});
    }

    for (let i = 0; i < this.lastSelectContacts.length; i++) {
      let hasDuplicateContact: boolean = false;
      for (let j = 0; j < selectContacts.length; j++) {
        if (this.lastSelectContacts[i].id == selectContacts[j].id) {
          hasDuplicateContact = true;
          break;
        }
      }
      if (!hasDuplicateContact) {
        let condition = new dataSharePredicates.DataSharePredicates();
        condition.equalTo('id', this.lastSelectContacts[i].id);
        this.updateContactMarker(daHelper, condition, false, call);
      }
    }
    this.lastSelectContacts.splice(0, this.lastSelectContacts.length);
    for (let i = 0; i < selectContacts.length; i++) {
      let params: SpecifiedBean = new SpecifiedBean(0, '', '', '', 0);
      params.id = selectContacts[i].id;
      params.contactId = selectContacts[i].contactId;
      params.displayName = selectContacts[i].contactName;
      params.focusModeList = NOT_DISTURB_VALUE_ENABLE;
      this.lastSelectContacts.push(params);
    }
  }

  private updateContactMarker(daHelper: dataShare.DataShareHelper, condition: dataSharePredicates.DataSharePredicates,
                              isAddMarker: boolean, call: Function) {
    const value: ValuesBucket = {
      FOCUS_MODE_LIST: isAddMarker ? NOT_DISTURB_VALUE_ENABLE : NOT_DISTURB_VALUE_DISABLE,
    }
    daHelper.update(
      ContactsColumns.CONTACT_URI,
      condition,
      value
    ).then((data: number) => {
      if (data === NOT_DISTURB_NUMBER_MINUS) {
        LogUtil.info(`${TAG} updateContactMarker data failed!`);
      }
      daHelper?.notifyChange(ContactsColumns.CONTACT_URI);
      LogUtil.info(`${TAG} updateContactMarker data success!`);
      call();
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} updateContactMarker data failed. Cause: ${err.message}, error.code: ${err.code}`);
    });
  }
}
