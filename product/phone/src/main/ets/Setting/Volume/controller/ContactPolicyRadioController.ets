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
import emitter from '@ohos.events.emitter';
import settings from '@ohos.settings';
import { EVENT_ID_ALLOW_CONTACTS } from '@ohos/settings.common/src/main/ets/event/types';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import { CONTACT_POLICY_KEY_MAP, ContactPolicy } from '../model/IncomingCallParam';
import { IncomingCallUtils } from '../utils/IncomingCallUtils';

const TAG: string = 'ContactPolicyRadioController';
export const FOCUS_MODE_CALL_MESSAGE_POLICY: string = 'focus_mode_call_message_policy';
export const INCOMING_CALL_SELECT_CONTACTS: string = 'incoming_call_select_contacts';

/**
 * 免打扰来电策略选择控制器
 */
export class ContactPolicyRadioController {
  public isChecked: boolean = false;
  public menuTitle: string = '';
  private menuKey: string = '';
  private settingsValue: string = '';
  private isShowSelect: boolean = false;
  private isShowRepeat: boolean = false;

  constructor(compId: string, value: string, isSelected: boolean) {
    this.menuKey = compId;
    this.settingsValue = value;
    this.isChecked = isSelected;
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  init(): void {
    LogUtil.info(`${TAG} init`);
    let contactPolicy: string = ResourceUtil.getStringSync($r('app.string.forbid_everyone'));
    if (CONTACT_POLICY_KEY_MAP.has(this.menuKey)) {
      contactPolicy = CONTACT_POLICY_KEY_MAP.get(this.menuKey) as string;
    }
    this.menuTitle = IncomingCallUtils.getInstance().setMenuTitle(contactPolicy);
    this.isShowSelect = this.settingsValue === ContactPolicy.ALLOW_SPECIFIED_CONTACTS;
    emitter.on({
      eventId: EVENT_ID_ALLOW_CONTACTS,
    }, (eventData: emitter.EventData) => {
      let settingsValue: string = eventData.data?.settingsValue;
      this.isShowSelect = settingsValue === ContactPolicy.ALLOW_SPECIFIED_CONTACTS;
      this.isShowRepeat = settingsValue != ContactPolicy.ALLOW_EVERYONE;
      this.showOrHideRepeat(this.isShowRepeat);
      EventBus.getInstance().emit(INCOMING_CALL_SELECT_CONTACTS, { state: this.isShowSelect } as SettingCompState);
    });
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    emitter.off(EVENT_ID_ALLOW_CONTACTS);
  }

  public onRadioChange(isChecked: boolean): void {
    LogUtil.info(`${TAG} onRadioChange ${isChecked} value:${this.settingsValue}`);
    this.setRadio(isChecked);
    SettingsDataUtils.setSettingsData(FOCUS_MODE_CALL_MESSAGE_POLICY,
      this.settingsValue, settings.domainName.USER_PROPERTY);
    SearchDataController.getInstance().updateSearchItemStatus('repeat_call_ringing', (this.settingsValue !== '2'));
    this.isShowSelect = this.settingsValue === ContactPolicy.ALLOW_SPECIFIED_CONTACTS;
    this.isShowRepeat = this.settingsValue != ContactPolicy.ALLOW_EVERYONE;
    this.showOrHideRepeat(this.isShowRepeat);
    EventBus.getInstance().emit(INCOMING_CALL_SELECT_CONTACTS, { state: this.isShowSelect } as SettingCompState);
    if (isChecked) {
      AccessibilityUtils.announceRadioSelected();
    }
  }

  private showOrHideRepeat(isShow: boolean): void {
    notifyCompStateChange(`Setting.IncomingCall.repeat_ringing_group`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
    notifyCompStateChange(`Setting.IncomingCall.repeat_ringing_group.footer`,
      new Map<SettingStateType, SettingBaseState>(
        [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
      ));
  }

  private setRadio(isChecked: boolean): void {
    if (this.isChecked !== isChecked) {
      this.isChecked = isChecked;
    }
  }
}
