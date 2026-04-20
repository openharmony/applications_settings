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

import wifiManager from '@ohos.wifiManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ComparableSettingItemModel,
  ItemResultType,
  ItemType,
  SettingIconType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { WifiListBaseController } from './WifiListBaseController';
import { OTHER_WLAN_CLICK_EVENT, WlanItemResultComponent } from '../../component/WlanItemResultComponent';
import { ApMenuData, OTHER_WLAN_SHEET_SHOW_EVENT, WifiScanResult } from '../../model/WifiModel';
import { WlanItemModel } from '../../model/WlanItemModel';
import { wifiTracker } from '../../WifiTracker';
import { SETTINGS_SWITCH_WLAN_LOGS, WifiUtils } from '../../WifiUtils';
import { WifiMenuManager } from '../../WifiMenuManager';
import { PADDING_40 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';

/* instrument ignore file */
class FrequencyThreshold {
  public freqMin: number = 0;
  public freqMax: number = 0;
}

const TAG: string = 'OtherWifiListController : ';
const FREQ_24GHZ: string = 'frequency_24GHZ';
const FREQ_5GHZ: string = 'frequency_5GHZ';
const FREQ_6GHZ: string = 'frequency_6GHZ';
const FREQ_60GHZ: string = 'frequency_60GHZ';
const SCAN_INTERVAL: number = 10000;
const SCAN_LOADING_INTERVAL: number = 1000;
const MIN_FREQ_24GHZ: number = 2400;
const MAX_FREQ_24GHZ: number = 2500;
const MIN_FREQ_5GHZ: number = 4900;
const MAX_FREQ_5GHZ: number = 5900;
const MIN_FREQ_6GHZ: number = 5925;
const MAX_FREQ_6GHZ: number = 7125;
const MIN_FREQ_60GHZ: number = 58320;
const MAX_FREQ_60GHZ: number = 70200;

@Builder
export function wlanItemResultBuilder(param: object): void {
  WlanItemResultComponent({
    itemInfo: param as WlanItemModel,
  })
}

/**
 * Wifi 列表加载控制器
 *
 * @since 2024-05-29
 */
export class OtherWlanListController extends WifiListBaseController {
  public scanResults: WifiScanResult[] = [];
  public isWlanLog: boolean = false;
  // 调用 settingsData 接口标志位 保证初始化只调用一次
  public hasCalled: boolean = false;
  private frequencyMap: Map<string, FrequencyThreshold> = new Map();
  private detailIconClickCallback = (itemInfo: WlanItemModel | undefined) => {
    if (!itemInfo) {
      LogUtil.error(`${TAG} itemInfo is undefined.`);
      return;
    }
    this.onItemClick(itemInfo);
  };
  private sheetShowCallback = (isShow: boolean) => {
    this.isUserEditing = isShow;
  };

  public scanList(): void {
    LogUtil.info(`${TAG} wifi state refresh.`);
    this.startTimer();
    wifiTracker.scanAp();
  }

  public setListScrolling(isScroll: boolean): void {
    wifiTracker.setListScrolling(isScroll);
  }

  protected getScanInternal(): number {
    return SCAN_INTERVAL;
  }

  protected getScanLoadingInternal(): number {
    return SCAN_LOADING_INTERVAL;
  }

  onScrollStop(): void {
    this.setListScrolling(false);
    this.scanList();
  }

  onScrollStart(): void {
    this.setListScrolling(true);
  }

  protected getWlanLogFlag(): void {
    if (!this.hasCalled) {
      this.hasCalled = true;
      this.isWlanLog = SettingsDataUtils.getSettingsData(SETTINGS_SWITCH_WLAN_LOGS, 'false') === 'true';
      LogUtil.info(`${TAG} getWlanLogFlag isWlanLog:${this.isWlanLog}`);
    }
  }

  protected createApMenu(item: Partial<ApMenuData>, isLast: boolean): WlanItemModel {
    this.getWlanLogFlag();
    const description = this.isWlanLog ? WifiUtils.getWifiInfoDescription(item) : '';
    return {
      id: this.generateId(item, description, isLast),
      isLast: isLast,
      compare: (dst: ComparableSettingItemModel) => {
        return 0;
      },
      divider: {
        leftPadding: PADDING_40,
      },
      key: item.key ?? '',
      wlanName: item.title ?? '',
      securityType: item?.securityType ?? 0,
      ssid: item.ssid,
      summary: item?.summary ?? '',
      stateIcon: item?.stateIcon,
      config: item.config,
      bssid: item.bssid ?? '',
      bssidType: item.bssidType,
      isHiLinkNetwork: item.isHiLinkNetwork ?? false,
      isHiLinkProNetwork: item.isHiLinkProNetwork ?? false,
      supportedWifiCategory: item.supportedWifiCategory,
      isLoading: false,
      capabilities: item?.capabilities ?? '',
      type: ItemType.ITEM_TYPE_STANDARD,
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
        content: this.getContent(item?.summary, description),
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
      compControl: {
        init: () => {
        },
        destroy: () => {
        },
        onClick: (component: SettingBaseModel) => {
          this.onItemClick(component as WlanItemModel);
        }
      },
      layout: {
        minHeight: DeviceUtil.isDevicePc() ? 56 : undefined,
        accessibilityGroup: true, accessibilityText: this.announceText(item)
      },
      result: {
        result: undefined,
        type: ItemResultType.RESULT_TYPE_CUSTOM,
        builder: WifiMenuManager.isInOObeStage() ? undefined : wrapBuilder(wlanItemResultBuilder),
      }
    };
  }

  /**
   * 整体播报其他wlan数据
   * @param item wifi数据
   * @returns 无障碍播报的内容
   */
  private announceText(item: Partial<ApMenuData>): string {
    let title = item.title ?? '' as string;
    let iconText = WifiUtils.getIconReadText(false, item.level ?? 0, false,
      item.supportedWifiCategory ?? 0, item.securityType ?? 0) as Resource;
    const description = this.isWlanLog ? WifiUtils.getWifiInfoDescription(item) : '';
    let summary = this.getContent(item?.summary, description);
    let detail = $r('app.string.check_the_detail');
    return title + ',' + ResourceUtil.getStringSync(iconText) + ',' + ResourceUtil.getStringSync(summary) + ',' +
    ResourceUtil.getStringSync(detail);
  }

  protected frequencyMapInit(): void {
    this.frequencyMap.set(FREQ_24GHZ, { freqMin: MIN_FREQ_24GHZ, freqMax: MAX_FREQ_24GHZ });
    this.frequencyMap.set(FREQ_5GHZ, { freqMin: MIN_FREQ_5GHZ, freqMax: MAX_FREQ_5GHZ });
    this.frequencyMap.set(FREQ_6GHZ, { freqMin: MIN_FREQ_6GHZ, freqMax: MAX_FREQ_6GHZ });
    this.frequencyMap.set(FREQ_60GHZ, { freqMin: MIN_FREQ_60GHZ, freqMax: MAX_FREQ_60GHZ });
  }

  protected registerDataChange(): void {
    super.registerDataChange();
    EventBus.getInstance().on(OTHER_WLAN_CLICK_EVENT, this.detailIconClickCallback);
    EventBus.getInstance().on(OTHER_WLAN_SHEET_SHOW_EVENT, this.sheetShowCallback);
  }

  protected unRegisterDataChange(): void {
    super.unRegisterDataChange();
    EventBus.getInstance().detach(OTHER_WLAN_CLICK_EVENT, this.detailIconClickCallback);
    EventBus.getInstance().detach(OTHER_WLAN_SHEET_SHOW_EVENT, this.sheetShowCallback);
  }

  init(compParam: CompCtrlParam): void {
    super.init(compParam);
    this.frequencyMapInit();
    this.isUserEditing = false;
    this.getWlanLogFlag();
  }

  destroy(): void {
    super.destroy();
    this.setListScrolling(false);
  }

  private getContent(summary: ResourceStr | undefined, description: string): ResourceStr {
    if (this.isWlanLog) {
      return `${ResourceUtil.getStringSync(summary)}\n${description}`;
    }
    return summary || '';
  }

  private generateId(item: Partial<ApMenuData>, description: string, isLast: boolean): string {
    let key: string = WifiUtils.getLogSsidString(item?.ssid ?? '') + item.securityType;
    let isHiLinkNetwork: boolean | undefined = item?.isHiLinkNetwork;
    let summaryId: string = (item?.summary as Resource)?.id?.toString() || '';
    let stateIconId: string = (item?.stateIcon as Resource)?.id?.toString() || '';
    return `${key}-${WifiUtils.hashCode32(item?.ssid)}${isHiLinkNetwork}${summaryId}${stateIconId}${description}${isLast}`;
  }
}