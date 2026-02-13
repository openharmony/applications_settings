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
import wifiManager from '@ohos.wifiManager';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { PADDING_40 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ComparableSettingItemModel,
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingIconType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingModalState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Timer } from '@ohos/settings.common/src/main/ets/utils/Timer';
import { ApMenuData, OPEN_NET_WORK_SHEET_ID, WifiState } from '../../model/WifiModel';
import { WlanItemModel } from '../../model/WlanItemModel';
import { URL_WLAN_DETAIL_PAGE } from '../../WifiPasswordSettingsSheet';
import { wifiTracker } from '../../WifiTracker';
import { SCAN_INTERVAL, WifiUtils } from '../../WifiUtils';
import AvailableWlanController, { wlanItemResultBuilder } from './AvailableWlanController';
import { notifyNetWorkSettingsSheetHeightChange } from './NetWorkSettingsController';

const TAG: string = 'OpenNetWorkListController : ';

export default class OpenNetWorkListController extends AvailableWlanController {
  private timer: Timer | null = null;
  private isStarted: boolean = false;
  protected onWifiStateChange = (state: number): void => {
    LogUtil.info(`${TAG} wifi state change : ${state} `);
    if (state === WifiState.INACTIVE) {
      // 停止扫描
      this.stopTimer();
      return;
    }
    if (state === WifiState.ACTIVE && WifiUtils.isWifiActive()) {
      // 开始扫描
      this.startTimer();
    }
  };
  private onPageShowCallBack = () => {
    this.onPageShow({id: '' });
  }

  private onPageShowHideBack = () => {
    this.onPageHide({id: '' });
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init: ${compParam?.compId}`);
    super.init(compParam);
    this.startWifiTimerAndTracker();
    if (this.isVisible) {
      // 热缓存
      wifiTracker.loadCacheMenus();
    }
    this.isPageShow = true;
    EventBus.getInstance().on('ExternalNetworkPagePageShow', this.onPageShowCallBack);
    EventBus.getInstance().on('ExternalNetworkPagePageHide', this.onPageShowHideBack);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy.`);
    super.destroy();
    this.stopWifiTimerAndTracker(false);
    EventBus.getInstance().detach('ExternalNetworkPagePageShow', this.onPageShowCallBack);
    EventBus.getInstance().detach('ExternalNetworkPagePageHide', this.onPageShowHideBack);
  }

  // 已连接WLAN和可用WLAN不需要分流显示
  protected isNeedDiversionShow(): boolean {
    return false;
  }

  protected hideOrShowList(isShow: boolean): void {
    super.hideOrShowList(isShow);
    notifyNetWorkSettingsSheetHeightChange(isShow);
  }

  private startWifiTimerAndTracker(): void {
    LogUtil.info(`${TAG} startWifiTimerAndTracker isStarted:${this.isStarted}`);
    if (!this.isStarted) {
      wifiTracker.onStart();
      wifiTracker.setListener(this);
      this.startTimer();
      this.isStarted = true;
    }
  }

  private stopWifiTimerAndTracker(isNewIntent?: boolean): void {
    LogUtil.info(`${TAG} stopWifiTimerAndTracker isStarted:${this.isStarted}, isNewIntent: ${isNewIntent}`);
    if (this.isStarted) {
      this.stopTimer();
      if (!isNewIntent) {
        wifiTracker.onStop();
      }
      this.isStarted = false;
    }
  }

  public startTimer(): void {
    this.getTimer().restart();
  }

  public stopTimer(): void {
    if (this.timer) {
      this.timer.stop();
    }
  }

  private getTimer(): Timer {
    if (!this.timer) {
      this.timer = new Timer(this.getScanInternal(), () => {
        LogUtil.info(`${TAG} scanOnce`);
        this.scanOnce();
      })
    }
    return this.timer;
  }

  private scanOnce(): void {
    if (!this.isStarted) {
      return;
    }
    wifiTracker.scanAp();
  }

  protected getScanInternal(): number {
    return SCAN_INTERVAL;
  }

  onPageShow(component: SettingBaseModel): void {
    super.onPageShow(component);
    this.startWifiTimerAndTracker();
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    super.onPageHide(component);
    this.stopWifiTimerAndTracker(false);
    LogUtil.info(`${TAG} onPageHide`);
  }

  protected createApMenu(item: Partial<ApMenuData>, isLast: boolean): WlanItemModel {
    this.getWlanLogFlag();
    const description = this.isWlanLog ? WifiUtils.getWifiInfoDescription(item) : '';
    let isLoading = this.isModelLoading(item.key ?? '');
    return {
      id: this.generateId(item, description, isLast, isLoading),
      isLast: isLast,
      compare: (dst: ComparableSettingItemModel) => {
        return 0;
      },
      divider: {
        leftPadding: PADDING_40,
      },
      key: item.key ?? '',
      wlanName: item.title,
      securityType: item?.securityType ?? 0,
      ssid: item.ssid,
      summary: isLoading ? $r('app.string.wifi_status_connecting') : item?.summary ?? '',
      stateIcon: item?.stateIcon,
      config: item.config,
      bssid: item.bssid ?? '',
      level: item.level ?? 0,
      bssidType: item.bssidType,
      isHiLinkNetwork: item.isHiLinkNetwork ?? false,
      isLoading: isLoading,
      state: this.isWlanLog ? WifiUtils.getWifiInfoDescription(item) : '',
      type: ItemType.ITEM_TYPE_STANDARD,
      capabilities: item.capabilities,
      title: {
        content: item.title ?? '',
        style: {
          fontSize: $r('sys.float.Body_L'),
          fontColor: $r('sys.color.font_primary'),
          fontFamily: 'HarmonyHeiTi',
          fontWeight: FontWeight.Medium,
          textAlign: TextAlign.Start,
          wordBreak: WordBreak.BREAK_WORD,
        }
      },
      desc: {
        content: this.getContent(isLoading ? $r('app.string.wifi_status_connecting') : item?.summary, description),
      },
      icon: {
        icon: item?.stateIcon ?? $r('app.media.ic_wifi_signal_0'),
        iconType: SettingIconType.ICON_TYPE_TIP,
        style: {
          width: 24,
          height: 24,
          objectFit: ImageFit.Contain,
          draggable: false,
          mirrored: false,
          fillColor: $r('sys.color.icon_primary'),
          accessibilityText: WifiUtils.getIconReadText(false, item.level ?? 0, false,
            item.supportedWifiCategory ?? 0, item.securityType ?? 0) as Resource
        }
      },
      detail: this.needEnterWlanInfo(item?.config, item?.securityType) ? {
        type: ItemDetailType.DETAIL_TYPE_MODAL,
        destination: URL_WLAN_DETAIL_PAGE,
      } : undefined,
      result: {
        result: undefined,
        type: ItemResultType.RESULT_TYPE_CUSTOM,
        builder: wrapBuilder(wlanItemResultBuilder),
      },
      compControl: {
        init: (compParam: CompCtrlParam) => {
        },
        destroy: () => {
        },
        onRouterPrepare: (item: SettingBaseModel) => {
          PasswordUtil.setPrivacyMode(true);
          this.changeSheetHeight();
        },
        onClick: (item: SettingBaseModel) => {
          if (!item) {
            LogUtil.error(`${TAG} itemClickCallback failed, itemInfo is undefined.`);
            return;
          }
          let itemInfo: WlanItemModel = item as WlanItemModel;
          this.onMenuClick(itemInfo);
        }
      }
    };
  }

  private changeSheetHeight(): void {
    notifyCompStateChange(OPEN_NET_WORK_SHEET_ID,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
        {
          state: true,
          sheetDetents: [SheetSize.LARGE],
        } as SettingModalState]]
      ));
  }

  private needEnterWlanInfo(config?: wifiManager.WifiDeviceConfig, securityType?: number): boolean {
    if (securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_OPEN) {
      return false;
    }
    return config === undefined;
  }
}