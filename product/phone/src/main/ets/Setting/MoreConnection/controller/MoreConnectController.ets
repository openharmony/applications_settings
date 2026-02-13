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
import bundleManager from '@ohos.bundle.bundleManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { DynamicGroupDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicGroupDataSource';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import { DeviceUtil, SatelliteUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { HiSysMoreConnectionEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { VpnTypeModel } from '@ohos/settings.vpn/src/main/ets/model/VpnTypeModel';
import {
  SuperLauncherStateController
} from '@ohos/settings.moreconnection/src/main/ets/controller/new/SuperLauncherStateController';
import {
  PadCockpitStateController
} from '@ohos/settings.moreconnection/src/main/ets/controller/new/PadCockpitStateController';
import { NFCStateController } from '@ohos/settings.moreconnection/src/main/ets/controller/new/NFCStateController';
import {
  WirelessProjectionController
} from '@ohos/settings.moreconnection/src/main/ets/controller/new/WirelessProjectionController';
import { VpnGroupController } from '@ohos/settings.moreconnection/src/main/ets/controller/new/VpnGroupController';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { EthernetUtil } from '@ohos/settings.network/src/main/ets/util/EthernetUtil';
const DEFAULT_USER_ID = 100;
const MAX_LINES_10: number = 10;
const DELAY_FRAME: number = 1;

export class MoreConnectController implements ComponentControl {
  private readonly tag: string = 'MoreConnectController : ';
  private hasCast: boolean = true;
  private hasPadCockpit: boolean = false;
  private vpnGroupController = new VpnGroupController();
  private dataSource: DynamicGroupDataSource = new DynamicGroupDataSource();
  private displaySync: displaySync.DisplaySync = displaySync.create();
  private displaySyncCount: number = 0;
  private addDataCallback = (intervalInfo: displaySync.IntervalInfo) => {
    if (this.displaySyncCount === DELAY_FRAME) {
      LogUtil.info(`${this.tag} second frame to show MoreConnectGroups.`);
      // 无线投屏 超级桌面 hicar
      this.addSuperLauncherGroup();
      // 星闪、NFC菜单
      this.addNfcGroup();
    }
    this.displaySyncCount++;
    if (this.displaySyncCount > DELAY_FRAME) {
      this.displaySync.stop();
    }
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} init`);
    HiSysEventUtil.reportDefaultBehaviorEvent(HiSysMoreConnectionEventGroup.ENTER_MORE_CONNECTION_ENTRY);
    this.dataSource = compParam.dataSource as DynamicGroupDataSource;
    this.initBundleInfo();
    this.setDisplaySync();
    // vpn
    if (!EthernetUtil.useNewNetworkPage()) {
      this.addVpnGroup();
    }
  }

  onPageShow(component: SettingBaseModel): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysMoreConnectionEventGroup.INTO_MORE_CONNECTIONS);
    this.vpnGroupController?.setVpnState();
  }

  onPageHide(component: SettingBaseModel): void {
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    this.disableDisplaySync();
  }

  private setDisplaySync() {
    this.displaySync.on('frame', this.addDataCallback);
    this.displaySync.start();
  }

  private disableDisplaySync() {
    this.displaySync.off('frame', this.addDataCallback);
  }

  initBundleInfo(): void {
    const castBundleName = 'com.ohos.cast';
    try {
      bundleManager.getBundleInfoSync(castBundleName,
        bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT, DEFAULT_USER_ID);
    } catch (err) {
      this.hasCast = false;
      LogUtil.error(`${this.tag} get key mouse share bundleInfo failed: ${err.message}`);
    }
    if (DeviceUtil.isDevicePad()) {
      const padCockpitBundleName = 'com.ohos.cardistributedassist';
      try {
        bundleManager.getBundleInfoSync(padCockpitBundleName,
          bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT, DEFAULT_USER_ID);
        if (this.getPadCockpitEnable()) {
          this.hasPadCockpit = true;
        }
      } catch (err) {
        LogUtil.error(`${this.tag} get pad cockpit bundleInfo failed: ${err?.message}`);
      }
    }
    LogUtil.info(`${this.tag} get pad cockpit enable: hasPadCockpit = ${this.hasPadCockpit}}`);
  }

  getPadCockpitEnable(): boolean {
    return SettingsDataUtils.getSettingsData('pad_cockpit_model_enable', '0') === '1';
  }


  createNfcItem(): SettingItemModel {
    return {
      id: 'nfc_settings',
      type: ItemType.ITEM_TYPE_STANDARD,
      compControl: new NFCStateController(),
      title: {
        content: $r('app.string.nfc_quick_toggle_title')
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: ''
        },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.NFC_ENTRY,
      }
    };
  }

  createPadCockpitItem(): SettingItemModel {
    return {
      id: 'pad_cockpit_setting',
      type: ItemType.ITEM_TYPE_STANDARD,
      compControl: new PadCockpitStateController(),
      title: {
        content: $r('app.string.car_collaboration_toggle_title'),
        style: {
          maxLines: MAX_LINES_10,
          wordBreak: WordBreak.BREAK_WORD,
        },
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: '',
          style: {
            maxLines: MAX_LINES_10,
            wordBreak: WordBreak.BREAK_WORD,
          },
        }
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.PAD_COCKPIT_ENTRY,
      }
    }
  }

  addSuperLauncherGroup(): void {
    if (!this.hasCast && !this.hasPadCockpit) {
      return;
    }
    let items: SettingItemModel[] = [];
    if (this.hasPadCockpit) {
      items.push(this.createPadCockpitItem());
    }
    let model: SettingGroupModel = {
      id: 'hicar_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      cached: false,
      visible: true,
      items: [
        ...items
      ]
    };
    this.dataSource.pushData(model);
  }

  addNfcGroup(): void {
    let isSupportNfc = canIUse('SystemCapability.Communication.NFC.Core');
    let isSupportNearLink = CapabilitySupportUtils.isSupportNearLink() && !CapabilitySupportUtils.isSupportFusion();
    if (!isSupportNfc && !isSupportNearLink && !(DeviceUtil.isDevicePhone())) {
      return;
    }
    let items: SettingItemModel[] = [];
    if (isSupportNfc) {
      items.push(this.createNfcItem());
    }
    let model: SettingGroupModel = {
      id: 'connect_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      cached: false,
      visible: true,
      items: [
        ...items
      ]
    };
    this.dataSource.pushData(model);
  }

  addVpnGroup(): void {
    // let isSupportVpn = VpnTypeModel.getInstance().isSupportVpn();
    // if (!isSupportVpn) {
    //   LogUtil.info('isSupportVpn false, return');
    //   return;
    // }
    let model: SettingGroupModel = {
      id: 'vpn_group_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      cached: false,
      visible: true,
      items: [
        {
          id: 'vpn_settings',
          type: ItemType.ITEM_TYPE_STANDARD,
          compControl: this.vpnGroupController,
          title: {
            content: $r('app.string.VPN')
          },
          detail: {
            type: ItemDetailType.DETAIL_TYPE_CUSTOM,
            icon: $r('sys.symbol.chevron_right'),
            isSymbolIcon: true,
            onItemClick: () => {
              this.vpnGroupController.onClick();
            }
          }
        }
      ]
    };
    this.dataSource.pushData(model);
  }
}
