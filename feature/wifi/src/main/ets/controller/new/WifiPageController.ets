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

import displaySync from '@ohos.graphics.displaySync';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { DynamicGroupDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicGroupDataSource';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import {
  HiSysWlanEvenGroup,
  HiSysWlanEventGroup
} from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { WifiSwitchController } from './WifiSwitchController';
import { OtherWlanListController } from './OtherWlanListController';
import AvailableWlanController from './AvailableWlanController';
import SharedNetworkController from './SharedNetworkController';
import { AddOtherWlanGroupController } from './AddOtherWlanGroupController';
import { WifiMenuManager } from '../../WifiMenuManager';
import { OtherWlanHeaderComponent } from '../../component/OtherWlanHeaderComponent';
import { ShareWlanController } from './ShareWlanController';
import { WlanSecurityCheckComponent } from '../../component/WlanSecurityCheckComponent';
import { WifiSecurityCheckGroupController } from './WifiSecurityCheckGroupController';

const TAG: string = 'WifiPageController : ';

const DELAY_FRAME: number = 1;

const URL_WLAN_PAGE: string = 'wifi_entry';

@Builder
export function otherWlanHeader(param: object) {
  OtherWlanHeaderComponent();
}

@Builder
function wlanSecurityCheckFooter(param: object): void {
  WlanSecurityCheckComponent();
}

export class WifiPageController implements ComponentControl {
  private sharedNetworkController: SharedNetworkController = new SharedNetworkController();

  private otherWlanListController: OtherWlanListController = new OtherWlanListController();

  private availableWlanController: AvailableWlanController = new AvailableWlanController();

  private shareWlanController: ShareWlanController = new ShareWlanController();

  private wifiSwitchController?: WifiSwitchController;

  private dataSource: DynamicGroupDataSource = new DynamicGroupDataSource();

  private displaySync: displaySync.DisplaySync = displaySync.create();

  private displaySyncCount: number = 0;

  private isWifiActive: boolean = false;

  private addDataCallback = (intervalInfo: displaySync.IntervalInfo) => {
    if (this.displaySyncCount === DELAY_FRAME) {
      LogUtil.info(`${TAG} second frame to show wifiGroups.`);
      this.addGroups();
    }
    this.displaySyncCount++;
    if (this.displaySyncCount > DELAY_FRAME) {
      this.displaySync.stop();
    }
  };

  public setWifiActive(value: boolean) {
    this.isWifiActive = value;
  }

  public setWifiSwitchController(wifiSwitchController: WifiSwitchController) {
    this.wifiSwitchController = wifiSwitchController;
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    this.shareWlanController.init();
    HiSysEventUtil.reportDefaultBehaviorEvent(HiSysWlanEvenGroup.ENTER_WLAN_ENTRY);
    this.dataSource = compParam.dataSource as DynamicGroupDataSource;
    this.setDisplaySync();
  }

  destroy(): void {
    this.disableDisplaySync();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.wifiSwitchController?.onPageShow(component);
    this.availableWlanController.onPageShow(component);
    this.otherWlanListController.onPageShow(component);
    this.shareWlanController.onPageShow();
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysWlanEventGroup.INTO_WLAN);
    AbilityUtils.pageReportCallback(URL_WLAN_PAGE);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.wifiSwitchController?.onPageHide(component);
    this.availableWlanController.onPageHide(component);
    this.otherWlanListController.onPageHide(component);
    this.shareWlanController.onPageHide();
  }

  private setDisplaySync() {
    this.displaySync.on('frame', this.addDataCallback);
    this.displaySync.start();
  }

  private disableDisplaySync() {
    this.displaySync.off('frame', this.addDataCallback);
  }

  private addGroups(): void {
    let isInOObeStage: boolean = WifiMenuManager.isInOObeStage();
    let borderRadius: Length | undefined = isInOObeStage ? '16vp' : undefined;
    let groups = [
      {
        id: 'SharedNetwork',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        cached: false,
        visible: false,
        layout: {
          borderRadius: borderRadius,
        },
        header: {
          id: 'SharedNetworkHeader',
          content: $r('app.string.shared_network_ap_group'),
          style: {
            height: 40,
            fontSize: $r('sys.float.Subtitle_S'),
            fontColor: $r('sys.color.font_secondary'),
            fontWeight: FontWeight.Medium,
          }
        },
        compControl: this.sharedNetworkController,
      } as SettingGroupModel,
      {
        id: 'AvailableWlan',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        cached: false,
        visible: this.isWifiActive,
        layout: {
          borderRadius: borderRadius,
        },
        header: {
          id: 'AvailableWlanHeader',
          content: $r('app.string.wifi_available_ap_group'),
          style: {
            height: isInOObeStage ? 24 : 40,
            fontSize: $r('sys.float.Subtitle_S'),
            fontColor: $r('sys.color.font_secondary'),
            fontWeight: FontWeight.Medium,
          }
        },
        compControl: this.availableWlanController,
      } as SettingGroupModel,
      {
        id: 'OtherWlan',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        cached: false,
        visible: this.isWifiActive,
        layout: {
          borderRadius: borderRadius,
        },
        header: {
          id: 'AvailableDeviceHeader',
          builder: wrapBuilder(otherWlanHeader),
          // -1表示不使用框架默认高度
          style: {
            height: -1,
          }
        },
        compControl: this.otherWlanListController,
      } as SettingGroupModel,
      {
        id: 'AddOtherWlan',
        // 这里需要动态显示隐藏，因此用GROUP_TYPE_DYNAMIC
        type: GroupType.GROUP_TYPE_DYNAMIC,
        visible: this.isWifiActive,
        layout: {
          borderRadius: borderRadius,
        },
        compControl: new AddOtherWlanGroupController(),
      } as SettingGroupModel,
      {
        id: 'WlanSecurityCheck',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        visible: !isInOObeStage && this.isWifiActive,
        footer: {
          id: 'WlanSecurityCheckFooter',
          builder: wrapBuilder(wlanSecurityCheckFooter),
        },
        compControl: new WifiSecurityCheckGroupController(),
      } as SettingGroupModel,

    ];
    this.dataSource.pushData(...groups);
  }
}
