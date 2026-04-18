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

import settings from '@ohos.settings';
import emitter from '@ohos.events.emitter';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { EVENT_ID_ALLOW_CONTACTS } from '@ohos/settings.common/src/main/ets/event/types';
import { NotDisturbUtils } from './NotDisturbUtils';

const TAG: string = 'NotDisturbIntent';
const ON: string = '1';
const OFF: string = '0';
const FOCUS_MODE_ENABLED: string = 'focus_mode_enable';
const FOCUS_MODE_REPEAT_CALLERS_ENABLE: string = 'focus_mode_repeate_callers_enable';
export enum ContactPolicy {
  FORBID_EVERYONE = '1',
  ALLOW_EVERYONE = '2',
  ALLOW_EXISTING_CONTACTS = '3',
  ALLOW_FAVORITE_CONTACTS = '4',
  ALLOW_SPECIFIED_CONTACTS = '5',
}
export const FOCUS_MODE_CALL_MESSAGE_POLICY: string = 'focus_mode_call_message_policy';

/*
 * 设置->声音和振动->免打扰
 * */
export class NotDisturbIntent {
  /**
   * 查询“立即开启”的开关状态
   */
  static getTurnOnNowStatus(): boolean {
    LogUtil.info(`${TAG} getTurnOnNowStatus`);
    return SettingsDataUtils.getSettingsData(FOCUS_MODE_ENABLED, OFF, settings.domainName.USER_SECURITY) === '1';
  }

  /**
   * 打开-立即开启
   */
  static openTurnOnNow(): boolean {
    LogUtil.info(`${TAG} openTurnOnNow`);
    NotDisturbUtils.setModeStatus(true);
    return true;
  }

  /**
   * 关闭-立即开启
   */
  static closeTurnOnNow(): boolean {
    LogUtil.info(`${TAG} closeTurnOnNow`);
    NotDisturbUtils.setModeStatus(false);
    return true;
  }

  /**
   * 查询“重复来电响铃”的开关状态
   */
  static getRepeatStatus(): boolean {
    LogUtil.info(`${TAG} getRepeatStatus`);
    return SettingsDataUtils.getSettingsData(FOCUS_MODE_REPEAT_CALLERS_ENABLE,
      ON, settings.domainName.USER_PROPERTY) === ON;
  }

  /**
   * 打开-重复来电响铃
   */
  static openRepeat(): boolean {
    LogUtil.info(`${TAG} openRepeat`);
    SettingsDataUtils.setSettingsData(FOCUS_MODE_REPEAT_CALLERS_ENABLE, ON, settings.domainName.USER_PROPERTY);
    return true;
  }

  /**
   * 关闭-重复来电响铃
   */
  static closeRepeat(): boolean {
    LogUtil.info(`${TAG} closeRepeat`);
    SettingsDataUtils.setSettingsData(FOCUS_MODE_REPEAT_CALLERS_ENABLE, OFF, settings.domainName.USER_PROPERTY);
    return true;
  }

  /**
   * 获取“允许联系人”选中的值
   */
  static getDisturb(): string {
    let contactPolicy: string = SettingsDataUtils.getSettingsData(
      FOCUS_MODE_CALL_MESSAGE_POLICY, ContactPolicy.ALLOW_FAVORITE_CONTACTS, settings.domainName.USER_PROPERTY);
    LogUtil.info(`${TAG} getDisturb ${contactPolicy}`);
    let contactStr: string = '';
    switch (contactPolicy) {
      case '1':
        contactStr = 'forbid_everyone';
        break;
      case '2':
        contactStr = 'allow_everyone';
        break;
      case '3':
        contactStr = 'allow_only_existing_contacts';
        break;
      case '4':
        contactStr = 'allow_only_favorite_contacts';
        break;
      case '5':
        contactStr = 'allow_only_specified_contacts';
        break;
      default:
        break;
    }
    return contactStr;
  }

  /**
   * 设置：允许联系人
   */
  static setDisturb(value: string): void {
    let settingsValue: string = '';
    switch (value) {
      case 'forbid_everyone':
        settingsValue = '1';
        break;
      case 'allow_everyone':
        settingsValue = '2';
        break;
      case 'allow_only_existing_contacts':
        settingsValue = '3';
        break;
      case 'allow_only_favorite_contacts':
        settingsValue = '4';
        break;
      case 'allow_only_specified_contacts':
        settingsValue = '5';
        break;
      default:
          break;
    }
    SettingsDataUtils.setSettingsData(FOCUS_MODE_CALL_MESSAGE_POLICY,
      settingsValue, settings.domainName.USER_PROPERTY);
    emitter.emit({
      eventId: EVENT_ID_ALLOW_CONTACTS,
    }, {
      data: {
        settingsValue,
      }
    });
    LogUtil.info(`${TAG} settingsValue: ${settingsValue}`);
  }

  /**
   * 允许联系人--展示的title
   */
  static getDisturbTitle(): string {
    let contactPolicy: string = SettingsDataUtils.getSettingsData(
      FOCUS_MODE_CALL_MESSAGE_POLICY, ContactPolicy.ALLOW_FAVORITE_CONTACTS, settings.domainName.USER_PROPERTY);
    LogUtil.info(`${TAG} contactPolicy is ${contactPolicy}`);
    let menuTitle = '';
    switch (contactPolicy) {
      case ContactPolicy.ALLOW_EVERYONE:
        menuTitle = ResourceUtil.getStringSync($r('app.string.allow_everyone'));
        break;
      case ContactPolicy.ALLOW_EXISTING_CONTACTS:
        menuTitle = ResourceUtil.getStringSync($r('app.string.allow_only_existing_contacts'));
        break;
      case ContactPolicy.ALLOW_FAVORITE_CONTACTS:
        menuTitle = ResourceUtil.getStringSync($r('app.string.allow_only_favorite_contacts'));
        break;
      case ContactPolicy.ALLOW_SPECIFIED_CONTACTS:
        menuTitle = ResourceUtil.getStringSync($r('app.string.allow_only_specified_contacts'));
        break;
      default:
        menuTitle = ResourceUtil.getStringSync($r('app.string.forbid_everyone'));
        break;
    }
    LogUtil.info(`${TAG} getDisturbTitle ${menuTitle}`);
    return menuTitle;
  }
}