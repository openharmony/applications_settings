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

import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import {
  NavEntryKey,
  PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  ItemDetailType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import commonEventManager from '@ohos.commonEventManager';
import { KeyboardSettingsManager } from '../KeyboardSettingsManager';
import { keyboardInfoItemBuilder } from '../view/KeyboardInfoItemComponment';
import componentConfig from '../utils/ComponentConfig';

const REQUEST_KEYBOARD_INFO_EVENT: string = 'accessory.manager.event.REQUEST_KEYBOARD_INFO';
const RESPONSE_KEYBOARD_INFO_EVENT: string = 'accessory.manager.event.RESPONSE_KEYBOARD_INFO';
const HWKEYBOARD_CONNECTION_STATE_CHANGED: string = 'accessory.manager.event.HWKEYBOARD_CONNECTION_STATE_CHANGED';
const KEYBOARD_CONNECT_STATUS: string = '1';

export enum ConnectStatue {
  OFF = 'off',
  ON = 'on',
}

export class KeyboardSettingsController implements ComponentControl {
  private tag: string = 'KeyboardSettingsController : '
  private connectStatus: boolean = false;
  private compId: string = '';
  private dataSource: DynamicDataSource = new DynamicDataSource();
  private keyboardTimer: number = 0;
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [HWKEYBOARD_CONNECTION_STATE_CHANGED, RESPONSE_KEYBOARD_INFO_EVENT],
    publisherPermission: PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS
  };
  private keyboardCommonEvent: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    if (err.code) {
      LogUtil.error(`${this.tag} subscribe failed ${err.message}`);
    } else {
      if (data === null || data.parameters === null) {
        LogUtil.error(`${this.tag} subscribe data failed, data is null`);
        return;
      }
      LogUtil.info(`${this.tag} subscribe success keyboard status ${data.data}`);
      this.connectStatus = data.data === KEYBOARD_CONNECT_STATUS;
      this.updateKeyboardInfo(data);
      this.updateKeyboardState();
    }
  });

  private updateKeyboardInfo(data: commonEventManager.CommonEventData) {
    try {
      let macId: string = data?.parameters?.macId;
      let keyboardName: string = data?.parameters?.name;
      if (typeof keyboardName === 'undefined' || keyboardName === macId) {
        keyboardName = SystemParamUtil.getParam(componentConfig.spKeyboardName, '');
      }
      KeyboardSettingsManager.getInstance().setKeyboardName(keyboardName);
      KeyboardSettingsManager.getInstance().setMacId(macId);
      KeyboardSettingsManager.getInstance().setModel(data?.parameters?.model);
      KeyboardSettingsManager.getInstance().setSoftwareVersion(data?.parameters?.softwareVersion);
      KeyboardSettingsManager.getInstance().setHardwareVersion(data?.parameters?.hardwareVersion);
      KeyboardSettingsManager.getInstance().setSerialId(data?.parameters?.serialId);
    } catch (error) {
      LogUtil.error(`${this.tag} subscribe parse data failed`);
    }
  }

  private requestKeyboardInfo(): void {
    LogUtil.info(`${this.tag} request keyboard info`);
    try {
      // 发布公共事件
      commonEventManager.publish(REQUEST_KEYBOARD_INFO_EVENT, (err) => {
        if (err) {
          LogUtil.error(`${this.tag} PublishCallBack err=${err.message}`);
        } else {
          LogUtil.info(`${this.tag} Publish success`);
        }
      })
    } catch (err) {
      LogUtil.error(`${this.tag} PublishCallBack err=${err.message}`);
    }
  }

  private updateKeyboardState(): void {
    LogUtil.info(`${this.tag} state: ${this.connectStatus}`);
    this.dataSource.removeData(this.createKeyboardInfoItem());
    this.dataSource.removeData(this.createKeyboardFirmwareUpgradeItem());
    if (this.connectStatus) {
      this.dataSource.pushData(this.createKeyboardInfoItem());
      this.dataSource.pushData(this.createKeyboardFirmwareUpgradeItem());
    }
    this.showOrHideGroup(this.connectStatus);
    // 搜索项控制
    SearchDataController.getInstance().updateSearchItemStatus('product_info', this.connectStatus);
    SearchDataController.getInstance().updateSearchItemStatus('firmware_upgrade', this.connectStatus);
    SearchDataController.getInstance().updateChildItemSearchStatus('product_info', this.connectStatus);
    SearchDataController.getInstance().updateChildItemSearchStatus('firmware_upgrade', this.connectStatus);
  }

  private showOrHideGroup(isShow: boolean): void {
    LogUtil.info(`${this.tag} showOrHideGroup: ${isShow}`);
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }

  private createKeyboardInfoItem(): SettingItemModel {
    return {
      id: 'KeyboardInfomationItem',
      type: ItemType.ITEM_TYPE_CUSTOM,
      builder: wrapBuilder(keyboardInfoItemBuilder)
    }
  }

  private createKeyboardFirmwareUpgradeItem(): SettingItemModel {
    return {
      id: 'KeyboardFirmwareUpgradeItem',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.firmware_upgrade') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.PAD_KEYBOARD_FIRMWARE_UPGRADE,
      }
    }
  }

  init(compParam: CompCtrlParam): void {
    this.compId = compParam.compId;
    this.dataSource = compParam.dataSource as DynamicDataSource;
    this.keyboardCommonEvent.registerCommonEvent();
    try {
      let connectStatus = SystemParamUtil.getParam(componentConfig.spStateKey, ConnectStatue.OFF);
      this.connectStatus = connectStatus === ConnectStatue.ON;
      LogUtil.info(`${this.tag} ConnectStatue` + this.connectStatus);
    } catch (error) {
      LogUtil.error(`${this.tag} get connect info fail`);
      this.connectStatus = false;
    }
    this.updateKeyboardState();
    this.keyboardTimer = setTimeout(() => {
      this.requestKeyboardInfo();
    }, componentConfig.delayTime);
  }

  destroy(): void {
    this.keyboardCommonEvent.unRegisterCommonEvent();
    clearTimeout(this.keyboardTimer);
  }
}