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
import settings from '@ohos.settings';
import {
  CompCtrlParam,
  ComponentControl
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { GlobalContext } from '@ohos/settings.common/src/main/ets/utils/GlobalContext';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ContextUtils } from '@ohos/settings.common/src/main/ets/utils/baseutils/ContextUtils';
import { NOT_DISTURB_SELECT_CONTACTS_COUNT, SELECT_CONTACTS_COUNT } from './SelectContactsController';
import { ContactPolicy, CONTACT_POLICY_MAP, SpecifiedBean } from '../model/IncomingCallParam';
import { FOCUS_MODE_CALL_MESSAGE_POLICY } from './ContactPolicyRadioController';
import { IncomingCallUtils } from '../utils/IncomingCallUtils';

const TAG: string = 'IncomingCallSettingController: ';

/**
 * 免打扰来电设置控制器
 */
export class IncomingCallSettingController implements ComponentControl {
  private dataHelper: dataShare.DataShareHelper | null = null;
  private contactNumber = Number(SettingsDataUtils.getSettingsData(NOT_DISTURB_SELECT_CONTACTS_COUNT, '0',
    settings.domainName.USER_PROPERTY));
  public onDataChange = () => {
    LogUtil.info(`${TAG} onDataChange`);
    this.updateStatus();
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    GlobalContext.getInstance().set('CallingContext', ContextUtils.getContext());
    this.registerDataChange();
    this.updateStatus();
    EventBus.getInstance().on(SELECT_CONTACTS_COUNT, (value: number) => {
      this.contactNumber = value;
      this.updateSelectContactShow();
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisAppear(): void {
    LogUtil.info(`${TAG} aboutToDisAppear`);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.updateStatus();
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    this.unRegisterDataChange();
    EventBus.getInstance().off(SELECT_CONTACTS_COUNT);
  }

  private refreshUi(result: ResourceStr): void {
    notifyCompStateChange('Setting.not_disturb_mode.incoming_call_group.incoming_call',
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: result } } as SettingResultState]]));
  }

  registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange`);
    if (this.dataHelper) {
      SettingsDataUtils.registerUserDataChange(this.dataHelper, FOCUS_MODE_CALL_MESSAGE_POLICY, this.onDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(FOCUS_MODE_CALL_MESSAGE_POLICY) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerUserDataChange(
              this.dataHelper, FOCUS_MODE_CALL_MESSAGE_POLICY, this.onDataChange);
          }
        })
    }
  }

  unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    SettingsDataUtils.unRegisterUserDataChange(
      this.dataHelper as dataShare.DataShareHelper, FOCUS_MODE_CALL_MESSAGE_POLICY);
  }

  updateStatus(): void {
    LogUtil.info(`${TAG} updateStatus`);
    let contactPolicyValue: string = '';
    let contactPolicy = SettingsDataUtils.getSettingsData(FOCUS_MODE_CALL_MESSAGE_POLICY,
      ContactPolicy.ALLOW_FAVORITE_CONTACTS, settings.domainName.USER_PROPERTY);
    if (CONTACT_POLICY_MAP.has(contactPolicy)) {
      contactPolicyValue = CONTACT_POLICY_MAP.get(contactPolicy) as string;
      if (contactPolicy === ContactPolicy.ALLOW_SPECIFIED_CONTACTS) {
        this.dealContactsCount();
        this.updateSelectContactShow();
      } else {
        this.refreshUi(IncomingCallUtils.getInstance().setMenuTitle(contactPolicyValue));
      }
    }
  }

  updateSelectContactShow(): void {
    if (this.contactNumber === 0) {
      this.refreshUi($r('app.string.none_selected'));
    } else {
      this.refreshUi($r('app.plural.user_select_contact', this.contactNumber, this.contactNumber));
    }
  }

  private async dealContactsCount() {
    IncomingCallUtils.getInstance().getSelectContactList((value: SpecifiedBean) => {
      let focusModeList = IncomingCallUtils.getInstance().dealSelectContactsData(value);
      if (this.contactNumber != focusModeList.length) {
        this.contactNumber = focusModeList.length;
        SettingsDataUtils.setSettingsData(NOT_DISTURB_SELECT_CONTACTS_COUNT,
          this.contactNumber.toString(), settings.domainName.USER_PROPERTY);
        this.updateStatus();
      }
    });
  }
}


