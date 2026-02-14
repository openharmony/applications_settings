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

import common from '@ohos.app.ability.common';
import lazy { default as sharing } from '@ohos.net.sharing';
import wifiManager from '@ohos.wifiManager';
import commonEventManager from '@ohos.commonEventManager';
import { BusinessError } from '@kit.BasicServicesKit';
import { NavEntryKey,
  PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  ComparableSettingItemModel,
  ItemResultType,
  ItemType,
  SettingIconType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingContentState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysWlanEvenGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { PADDING_40 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { AvailableWlanBaseController } from './AvailableWlanBaseController';
import { AVAILABLE_WLAN_DETAIL_CLICK_EVENT, WlanItemResultComponent } from '../../component/WlanItemResultComponent';
import { WlanItemModel } from '../../model/WlanItemModel';
import { WifiPasswordConfigManager } from '../../WifiPasswordConfigManager';
import { CONNECTED_AP_KEY, SETTINGS_SWITCH_WLAN_LOGS, WifiUtils } from '../../WifiUtils';
import { apConnectManager, wifiTracker } from '../../WifiTracker';
import { AddOtherWlanConfigManager } from '../../AddOtherWlanConfigManager';
import {
  AccessPoint,
  ApMenu,
  ApMenuData,
  OTHER_WLAN_CONNECT_EVENT,
  OTHER_WLAN_SHEET_SHOW_EVENT,
  AVAILABLE_WLAN_DETAIL_CHANGE_EVENT,
  ApMenuConfigData
} from '../../model/WifiModel';
import { WifiMenuManager } from '../../WifiMenuManager';
import { AdvSecurityModeManager, ConnectScene, IConnectData } from '../../AdvSecurityModeManager';
import { DeviceNameUtil } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';

/* instrument ignore file */
const TAG: string = 'WifiConnectedApController : ';
const CLICK_WLAN_NAME: string = 'click_wlan_name';
const CONNECTING: number = 1;

@Builder
export function wlanItemResultBuilder(param: object): void {
  WlanItemResultComponent({
    itemInfo: param as WlanItemModel,
  })
}

/**
 * 可用WLAN控制器
 *
 * @since 2024-05-29
 */
export default class AvailableWlanController extends AvailableWlanBaseController {
  public isWlanLog: boolean = false;
  // 调用 settingsData 接口标志位 保证初始化只调用一次
  public hasCalled: boolean = false;
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [CommonEventConstant.EVENT_WLAN_UN_SAVE_DIALOG],
    publisherPermission: PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS,
  };
  private closeUnSaveDialogEvent: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, async (err, data) => {
    LogUtil.info(`${TAG} receive close unSave dialog event ${data.parameters?.continueJoin}`);
    let connectData: IConnectData | undefined = AdvSecurityModeManager.getInstance().getConnectData();
    if (connectData?.securityType && connectData?.capabilities) {
      HiSysEventUtil.reportUnsafeWifiDialogButtonEvent(WifiUtils.getUnsafeNetworkType(connectData.securityType,
        connectData.capabilities), data.parameters?.continueJoin);
    }
    if (!data.parameters?.continueJoin) {
      return;
    }
    this.joinUnSavaNet(AdvSecurityModeManager.getInstance().getConnectData());
  });
  private detailClickCallback = (itemInfo: WlanItemModel | undefined) => {
    if (!itemInfo) {
      LogUtil.error(`${TAG} detailClickCallback failed, itemInfo is undefined.`);
      return;
    }
    this.onDetailClick(itemInfo);
  };

  /**
   * 可用wlan详情参数修改回调
   */
  private availableWlanDetailChangeCallback = async (apMenu: ApMenuConfigData) => {
    if (!apMenu) {
      LogUtil.error(`${TAG} apMenu invalid`);
      return;
    }
    LogUtil.info(`${TAG} availableWlanDetailChangeCallback apMenu`);
    wifiManager.updateNetwork(apMenu.config);
    if (AdvSecurityModeManager.getInstance().isNeedShowWifiUnsafeDialog(apMenu.securityType ?? 0,
      apMenu.capabilities ?? '', apMenu.ssid ?? '')) {
      AdvSecurityModeManager.getInstance().setConnectData({
        connectScene: ConnectScene.WLAN_PAGE_AVAILABLE_WLAN,
        ssid: apMenu.ssid,
        securityType: apMenu.securityType,
        config: apMenu.config,
        capabilities: apMenu.capabilities,
      });
      AdvSecurityModeManager.getInstance()
        .showWifiUnsafeDialog(AbilityContextManager.getContext() as common.UIAbilityContext);
      return;
    }
    this.connectAvailableWlan(apMenu.securityType ?? 0, apMenu.ssid ?? '', apMenu?.config);
  };

  private otherWlanClickCallback = async () => {
    // 首次连接
    this.isFirstConnect = true;
    let config: wifiManager.WifiDeviceConfig | undefined = WifiPasswordConfigManager.getInstance().getConfig();
    // 加密WLAN点击连接
    if (config) {
      LogUtil.info(`${TAG} start connect.`);
      // 普通网络和PSK类型的需要重连
      let securityType: number = WifiPasswordConfigManager.getInstance().model?.securityType ?? 0;
      let isReConnected: boolean =
        WifiUtils.isNormalWlan(securityType) || securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_PSK;
      let formattedConfig: wifiManager.WifiDeviceConfig =
        WifiPasswordConfigManager.getInstance().clearAndGetFormattedConfig(config);
      await apConnectManager.startConnectAsync(formattedConfig, isReConnected, this);
      wifiTracker.loadCacheMenus();
    } else {
      // 添加其他WLAN点击连接
      config = AddOtherWlanConfigManager.getInstance().getConfig();
      if (config) {
        apConnectManager.startConnect(AddOtherWlanConfigManager.getInstance().clearAndGetFormattedConfig(config),
          true, this);
      }
    }
  };

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
      isHiLinkProNetwork: item.isHiLinkProNetwork ?? false,
      isLoading: isLoading,
      state: this.isWlanLog ? WifiUtils.getWifiInfoDescription(item) : '',
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
      layout: {
        minHeight: DeviceUtil.isDevicePc() ? 56 : undefined,
        accessibilityGroup: false, accessibilityText: this.announceText(item)
      },
      result: {
        result: undefined,
        type: ItemResultType.RESULT_TYPE_CUSTOM,
        builder: wrapBuilder(wlanItemResultBuilder),
      },
      compControl: {
        init: (compParam: CompCtrlParam) => {},
        destroy: () => {},
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

  /**
   * 整体播报已保存wlan数据
   * @param item wifi数据
   * @returns 无障碍播报的内容
   */
  private announceText(item: Partial<ApMenuData>): string {
    let title = item.title ?? '' as string;
    let iconText = WifiUtils.getIconReadText(false, item.level ?? 0, false,
      item.supportedWifiCategory ?? 0, item.securityType ?? 0) as Resource;
    const description = this.isWlanLog ? WifiUtils.getWifiInfoDescription(item) : '';
    let summary = this.getContent(item?.summary, description);
    return title + ',' + ResourceUtil.getStringSync(iconText) + ',' + ResourceUtil.getStringSync(summary);
  }

  protected getConnectedApMenu(): WlanItemModel | null {
    this.getWlanLogFlag();
    if (!this.accessPoint) {
      LogUtil.info(`${TAG} accessPoint invalid`);
      return null;
    }
    let multiLinkedInfo = WifiUtils.getLastMultiLinkedInfo(this.accessPoint);
    let linkedInfo = WifiUtils.getLastLinkedInfo(this.accessPoint);
    const description = this.isWlanLog ? WifiUtils.getConnectedDescription(multiLinkedInfo, linkedInfo) : '';
    return {
      apKey: CONNECTED_AP_KEY + this.accessPoint.apKey,
      accessPoint: this.accessPoint,
      summary: this.accessPoint.getSummary(),
      stateIcon: this.accessPoint.getStateIcon(),
      id: this.generateConnectedId(this.accessPoint, description),
      compare: (dst: ComparableSettingItemModel) => {
        return 0;
      },
      divider: {
        leftPadding: PADDING_40,
      },
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: this.accessPoint.getTitle(),
        style: {
          fontSize: $r('sys.float.Body_L'),
          fontColor: $r('sys.color.font_emphasize'),
          fontFamily: 'HarmonyHeiTi',
          fontWeight: FontWeight.Medium,
          textAlign: TextAlign.Start,
          wordBreak: WordBreak.BREAK_WORD,
        }
      },
      securityType: this.accessPoint.securityType ?? 0,
      ssid: this.accessPoint.ssid,
      desc: {
        content: this.getContent(this.accessPoint.getSummary(), description),
      },
      icon: {
        icon: this.accessPoint.getStateIcon() ?? $r('app.media.ic_wifi_signal_0'),
        iconType: SettingIconType.ICON_TYPE_TIP,
        style: {
          width: 24,
          height: 24,
          objectFit: ImageFit.Contain,
          draggable: false,
          mirrored: false,
          fillColor: $r('sys.color.icon_primary'),
          accessibilityText: WifiUtils.getIconReadText(this.isNetworkUnavailable, this.accessPoint.bestLevel, true,
            this.accessPoint.supportedWifiCategory, this.accessPoint.securityType) as Resource
        }
      },
      layout: {
        minHeight: DeviceUtil.isDevicePc() ? 56 : undefined,
        accessibilityGroup: true, accessibilityText: this.announceTextConnected(this.accessPoint)
      },
      result: {
        result: undefined,
        type: ItemResultType.RESULT_TYPE_CUSTOM,
        builder: WifiMenuManager.isInOObeStage() ? undefined : wrapBuilder(wlanItemResultBuilder),
      },
      compControl: {
        init: (compParam: CompCtrlParam) => {},
        destroy: () => {},
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

  /**
   * 整体播报已连接wlan数据
   * @param item wifi数据
   * @returns 无障碍播报的内容
   */
  private announceTextConnected(item: Partial<ApMenuData>): string {
    if (!this.accessPoint) {
      LogUtil.info(`${TAG} accessPoint invalid`);
      return '';
    }
    let title = this.accessPoint.getTitle();
    let iconText = WifiUtils.getIconReadText(this.isNetworkUnavailable, this.accessPoint.bestLevel, true,
      this.accessPoint.supportedWifiCategory, this.accessPoint.securityType) as Resource
    const description = this.isWlanLog ? WifiUtils.getWifiInfoDescription(item) : '';
    let isUnsecuredWifi: boolean = this.accessPoint?.isUnsecuredWifiDetect();
    let summary = this.getContent(WifiUtils.getConnectedSummary(this.isPortalUnauthenticated, isUnsecuredWifi), description);
    let detail = $r('app.string.check_the_detail');
    return title + ',' + ResourceUtil.getStringSync(iconText) + ',' + ResourceUtil.getStringSync(summary) + ',' +
    ResourceUtil.getStringSync(detail);
  }

  private generateConnectedId(accessPoint: AccessPoint, description: string): string {
    let key = WifiUtils.getLogSsidString(accessPoint.ssid ?? '') + accessPoint.securityType;
    let summaryId: string = (accessPoint?.getSummary() as Resource)?.id?.toString() || '';
    let stateIconId: string = (accessPoint?.getStateIcon() as Resource)?.id?.toString() || '';
    let isHiLinkNetwork = accessPoint.isHiLinkNetwork;
    return key + summaryId + stateIconId + description + isHiLinkNetwork;
  }

  protected generateId(item: Partial<ApMenuData>, description: string, isLast: boolean, isLoading: boolean): string {
    let key: string = WifiUtils.getLogSsidString(item?.ssid ?? '') + item.securityType;
    let isHiLinkNetwork: boolean | undefined = item?.isHiLinkNetwork;
    let summaryId: string = (item?.summary as Resource)?.id?.toString() || '';
    let stateIconId: string = (item?.stateIcon as Resource)?.id?.toString() || '';
    return `${key}-${WifiUtils.hashCode32(item?.ssid)}${isHiLinkNetwork}${summaryId}${stateIconId}${description}${isLast}${isLoading}`;
  }

  private connectAp(config: wifiManager.WifiDeviceConfig): void {
    this.isFirstConnect = true;
    apConnectManager.startConnect(config, false, this);
    setTimeout(() => {
      wifiTracker.loadCacheMenus();
    });
  }

  protected isModelLoading(key: String): boolean {
    if (apConnectManager.wifiConnectState === CONNECTING && apConnectManager.connectApKey &&
      apConnectManager.connectApKey === key) {
      return true;
    }
    return false;
  }

  protected refreshList(): void {
    setTimeout(() => {
      wifiTracker.loadCacheMenus();
    });
  }

  init(compParam: CompCtrlParam): void {
    super.init(compParam);
    this.getWlanLogFlag();
  }

  protected registerDataChange(): void {
    super.registerDataChange();
    EventBus.getInstance().on(AVAILABLE_WLAN_DETAIL_CLICK_EVENT, this.detailClickCallback);
    EventBus.getInstance().on(AVAILABLE_WLAN_DETAIL_CHANGE_EVENT, this.availableWlanDetailChangeCallback);
    EventBus.getInstance().on(OTHER_WLAN_CONNECT_EVENT, this.otherWlanClickCallback);
    this.closeUnSaveDialogEvent.registerCommonEvent();
  }

  protected unRegisterDataChange(): void {
    super.unRegisterDataChange();
    EventBus.getInstance().detach(AVAILABLE_WLAN_DETAIL_CLICK_EVENT, this.detailClickCallback);
    EventBus.getInstance().detach(OTHER_WLAN_CONNECT_EVENT, this.otherWlanClickCallback);
    EventBus.getInstance().detach(AVAILABLE_WLAN_DETAIL_CHANGE_EVENT, this.availableWlanDetailChangeCallback);
    this.closeUnSaveDialogEvent.unRegisterCommonEvent();
  }

  private joinUnSavaNet(connectData?: IConnectData): void {
    if (connectData?.connectScene === ConnectScene.WLAN_PAGE_AVAILABLE_WLAN) {
      this.connectAvailableWlan(connectData.securityType ?? 0, connectData.ssid ?? '', connectData?.config);
      return;
    }
    if (connectData?.connectScene === ConnectScene.WLAN_PAGE_OTHER_WLAN) {
      notifyCompStateChange('Setting.Wlan.EditSheetConfig.EditSheet',
        new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
          { state: false } as SettingCompState]]));
      // 通知WLAN列表滑动到顶部，避免连接中效果被遮挡
      notifyCompStateChange('Setting.Wlan',
        new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_PAGE_SCROLL_TO_TOP,
          { content: '' } as SettingContentState]]));
      EventBus.getInstance().emit(OTHER_WLAN_SHEET_SHOW_EVENT, false);
      this.otherWlanClickCallback();
    }
    AdvSecurityModeManager.getInstance().clearConnectData();
  }

  protected onMenuClick(item: WlanItemModel): boolean {
    LogUtil.info(`${TAG} onMenuClick`);
    // 正在连接的item
    if (this.isModelLoading(item.key ?? '')) {
      LogUtil.info(`${TAG} current item is connecting.`);
      return false;
    }
    // 点击已连接WLAN
    if (item.accessPoint) {
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysWlanEvenGroup.ENTER_CONNECTED_WLAN_ENTRY);
      if (this.isPortalUnauthenticated) {
        // 点击跳转WLAN认证
        LogUtil.info(`${TAG} onMenuClick: start portal certification.`)
        WifiUtils.startPortalCertification();
        return true;
      }
      if (!WifiMenuManager.isInOObeStage()) {
        LogUtil.info(`${TAG} onMenuClick: start password certification.`)
        PageRouter.push(NavEntryKey.WIFI_MENU_CONFIG_ENTRY, item.accessPoint);
      } else {
        LogUtil.info(`${TAG} current is in oobe stage, will not jump.`)
      }
      return true;
    }
    if (AdvSecurityModeManager.getInstance().isNeedShowWifiUnsafeDialog(item.securityType ?? 0,
      item.capabilities ?? '', item.ssid ?? '')) {
      AdvSecurityModeManager.getInstance().setConnectData({
        connectScene: ConnectScene.WLAN_PAGE_AVAILABLE_WLAN,
        ssid: item?.ssid,
        securityType: item?.securityType,
        config: item?.config,
        capabilities: item?.capabilities,
      });
      AdvSecurityModeManager.getInstance()
        .showWifiUnsafeDialog(AbilityContextManager.getContext() as common.UIAbilityContext);
      return false;
    }
    this.connectAvailableWlan(item.securityType ?? 0, item.ssid ?? '', item?.config);
    HiSysEventUtil.reportButtonEvent(CLICK_WLAN_NAME, '');
    return true;
  }

  private connectAvailableWlan(securityType: number, ssid: string, config?: wifiManager.WifiDeviceConfig): void {
    HiSysEventUtil.reportButtonEvent(CLICK_WLAN_NAME, '');
    let deviceName: string = DeviceNameUtil.getDisplayDeviceName();
    if (deviceName === ssid) {
      LogUtil.info(`${TAG} connectAvailableWlan ssid equals deviceName, shut down hotspot`);
      this.shutdownHotspot();
    }
    // 点击开放网络直接连接
    if (securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_OPEN) {
      LogUtil.info(`${TAG} onMenuClick: start open connect.`)
      this.connectAp({
        ssid: ssid,
        securityType: securityType
      } as wifiManager.WifiDeviceConfig);
      return;
    }
    // 已保存的WLAN，直接连接
    if (!config) {
      LogUtil.info(`${TAG} connectToWifiDevice config null`);
      return;
    }
    LogUtil.info(`${TAG} onMenuClick: start config connect.`);
    this.isFirstConnect = false;
    apConnectManager.startConnect(config, false, this);
    setTimeout(() => {
      wifiTracker.loadCacheMenus();
    });
  }

  private shutdownHotspot(): void {
    sharing.stopSharing(sharing.SharingIfaceType.SHARING_WIFI).then(() => {
      LogUtil.info(`${TAG} shutdownHotspot stopSharing success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} shutdownHotspot stopSharing fail: ${error?.message}`);
    });
  }

  onDetailClick(item: WlanItemModel): boolean {
    if (item.accessPoint) {
      LogUtil.info(`${TAG} click connected detail icon, ssid is: ${WifiUtils.getLogSsidString(item.accessPoint.ssid)},
        securityType is ${item.accessPoint.securityType}, bestLevel is ${item.accessPoint.bestLevel}`);
      PageRouter.push(NavEntryKey.WIFI_MENU_CONFIG_ENTRY, item.accessPoint);
      return true;
    }
    let accessPoint = new AccessPoint(null);
    accessPoint.ssid = item.ssid ?? '';
    if (item.config) {
      accessPoint.configs = [item.config];
      accessPoint.bestLevel = item.level ?? 0;
      accessPoint.securityType = item.securityType ?? 0;
      LogUtil.info(`${TAG} click saved detail icon, ssid is: ${WifiUtils.getLogSsidString(accessPoint.ssid)},
          securityType is ${accessPoint.securityType}, bestLevel is ${accessPoint.bestLevel}`);
      PageRouter.push(NavEntryKey.WIFI_MENU_CONFIG_ENTRY, accessPoint);
      return true;
    }
    if (item.securityType !== wifiManager.WifiSecurityType.WIFI_SEC_TYPE_OPEN) {
      return false;
    }
    if (AdvSecurityModeManager.getInstance().isNeedShowWifiUnsafeDialog(item.securityType ?? 0,
      item.capabilities ?? '', item.ssid ?? '')) {
      AdvSecurityModeManager.getInstance().setConnectData({
        connectScene: ConnectScene.WLAN_PAGE_AVAILABLE_WLAN,
        ssid: item?.ssid,
        securityType: item?.securityType,
        capabilities: item?.capabilities,
      });
      AdvSecurityModeManager.getInstance()
        .showWifiUnsafeDialog(AbilityContextManager.getContext() as common.UIAbilityContext);
      return false;
    }
    this.connectAp({
      ssid: item.ssid ?? '',
      securityType: item.securityType
    } as wifiManager.WifiDeviceConfig);
    return true;
  }
}