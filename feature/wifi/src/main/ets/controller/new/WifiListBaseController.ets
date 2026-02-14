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
import wifiManager from '@ohos.wifiManager';
import { controllerCounter } from '@ohos/settings.common/src/main/ets/utils/ControllerCounter';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { Timer } from '@ohos/settings.common/src/main/ets/utils/Timer';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingModalState,
  SettingStateType,
  SettingToggleState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DisplayUtils, SheetDialogStyle } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { apConnectManager, wifiTracker, WifiTrackerListener } from '../../WifiTracker';
import { WlanItemModel } from '../../model/WlanItemModel';
import { ApMenu, ApMenuData, WifiState } from '../../model/WifiModel';
import { WifiUtils } from '../../WifiUtils';
import { WifiPasswordConfigManager } from '../../WifiPasswordConfigManager';

/* instrument ignore file */
const TAG: string = 'WifiListBaseController : ';
const WLAN_SWITCH_ID: string = 'Setting.Wlan.WlanConfig.WlanSwitch.toggle';
const UX_DESIGN_SHEET_HEIGHT_PAD: number = 320;
const NORMAL_WLAN_HEIGHT_RATE: number = 0.76;
const SHEET_DELAY: number = 500;
const CONNECTING: number = 1;

export interface WifiEntryParams {
  config: wifiManager.WifiDeviceConfig;
  isHiLinkNetwork: boolean;
  capabilities?: string;
  needShowModal?: boolean;
  isFromMoreSetting?: boolean;
};

/**
 * Wifi 列表加载控制器基类
 */
export abstract class WifiListBaseController implements WifiTrackerListener, ComponentControl {
  public timer: Timer | null = null;
  public isStarted: boolean = false;
  public loadingTaskId: number | null = null;
  public customState: string = '';
  // 半模态弹出
  public isUserEditing: boolean = false;
  // 控制中心点击 wlan item跳转过来有值
  public jumpConfig: wifiManager.WifiDeviceConfig | null = null;
  private dataSource?: OrderedDataSource;
  private compId: string = '';
  private isVisible: boolean = false;
  private menuCache: WlanItemModel[] = [];
  private displaySync: displaySync.DisplaySync = displaySync.create();
  private index: number = 0;
  // 是否从更多设置、wifi列表跳转过来
  private isFromMoreSetting: boolean = false;
  // 第一次进入wifi页面
  private isFirstEntering: boolean = true;

  private addDataCallback = (intervalInfo: displaySync.IntervalInfo) => {
    this.insertDataToDataSource();
    if (this.index > this.menuCache.length - 1) {
      this.displaySync.stop();
      LogUtil.info(`${TAG} first frame set data.`);
      this.showOrHideHeader(true);
    }
  };

  private insertDataToDataSource() {
    if (this.index < this.menuCache.length) {
      this.dataSource?.insertData(this.index, this.menuCache[this.index]);
      this.index++;
    }
  }
  private onWifiStateChange = (state: number): void => {
    LogUtil.info(`${TAG} wifi state change : ${state} `);
    if (state === WifiState.INACTIVE) {
      this.isVisible = false;
      this.hideOrShowList(false);
      // 停止扫描
      this.stopTimer();
      this.hideApList();
    } else if (state == WifiState.ACTIVE) {
      if (WifiUtils.isWifiActive()) {
        this.isVisible = true;
        this.hideOrShowList(true);
        // 开始扫描
        this.startTimer();
      }
    }
  };
  private onToggleChangeCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleState is invalid`);
      return;
    }
    LogUtil.info(`${TAG} receive toggle state change: ${toggleState.state}`);
    this.isVisible = toggleState.state;
    this.hideOrShowList(this.isVisible);
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} start init`);
    this.dataSource = compParam.dataSource as OrderedDataSource;
    this.compId = compParam.compId as string;
    this.isVisible = compParam.component.visible ?? false;
    // 从更多设置跳转
    let fromMoreSetting: boolean | object = (AppStorage.get<Want>('wantParams') as Want)?.parameters?.fromMoreSetting ??
      false;
    // 从wlan item跳转
    let fromWifiItem: boolean | object = ((AppStorage.get<Want>('wantParams') as Want)?.
      parameters?.pushParams as WifiEntryParams)?.isFromMoreSetting ?? false;
    this.isFromMoreSetting = (fromMoreSetting || fromWifiItem) as boolean;
    this.startWifiTimerAndTracker();
    if (this.isVisible) {
      // 热缓存
      wifiTracker.loadCacheMenus();
    }
    this.registerDataChange();
    controllerCounter.addController(this.compId);
    this.setDisplaySync();
  }

  destroy(): void {
    this.unRegisterDataChange();
    this.disableDisplaySync();
    let isExist: boolean = CommonUtils.isPageExist(NavEntryKey.WIFI_ENTRY);
    LogUtil.info(`${TAG} destroy, isExist: ${isExist}`);
    if (controllerCounter.removeController(this.compId) && !isExist) {
      this.stopWifiTimerAndTracker();
      wifiTracker.onQuit(this);
      return;
    }
    if (isExist) {
      this.stopWifiTimerAndTracker();
      wifiTracker.releaseResource(this);
    }
  }

  onClick?(component: SettingBaseModel): void {
  }

  setDisplaySync() {
    this.displaySync.on('frame', this.addDataCallback);
  }

  disableDisplaySync() {
    this.displaySync.off('frame', this.addDataCallback);
    this.menuCache = [];
  }

  protected registerDataChange(): void {
    EventBus.getInstance().on(WLAN_SWITCH_ID, this.onToggleChangeCallback);
    WifiUtils.wifiStateChangeOn(TAG, this.onWifiStateChange);
  }

  protected unRegisterDataChange(): void {
    EventBus.getInstance().detach(WLAN_SWITCH_ID, this.onToggleChangeCallback);
    WifiUtils.wifiStateChangeOff(TAG, this.onWifiStateChange);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.isStarted = false;
    this.startWifiTimerAndTracker();
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.stopWifiTimerAndTracker();
  }

  private hideOrShowList(isShow: boolean): void {
    let state: Map<SettingStateType, SettingCompState> =
      new Map<SettingStateType, SettingCompState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE,
        { state: isShow } as SettingCompState]]);
    if (isShow && (this.dataSource as OrderedDataSource)?.length > 0) {
      this.showOrHideHeader(true);
    } else {
      this.showOrHideHeader(false);
    }
    notifyCompStateChange('Setting.Wlan.OtherWlan', state);
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

  private stopWifiTimerAndTracker(): void {
    LogUtil.info(`${TAG}  stopWifiTimerAndTracker isStarted:${this.isStarted}`);
    if (this.isStarted) {
      this.stopTimer();
      wifiTracker.onStop();
      this.isStarted = false;
    }
  }

  public startTimer(): void {
    this.getTimer().restart();
    this.startLoading();
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
    this.startLoading();
  }

  private startLoading(): void {
    this.setLoading(true);
    AppStorage.setOrCreate('WlanListLoadingVisible', true);
    LogUtil.info(`${TAG} setLoading`);
    if (this.loadingTaskId != null) {
      clearTimeout(this.loadingTaskId);
      this.loadingTaskId = null;
    }
    this.loadingTaskId = setTimeout(() => {
      LogUtil.info(`${TAG} setLoading false`);
      this.setLoading(false);
      AppStorage.setOrCreate('WlanListLoadingVisible', false);
    }, this.getScanLoadingInternal());
  }

  public hideApList(): void {
    LogUtil.info(`${TAG} hideApList `);
    if (!this.isVisible) {
      LogUtil.info(`${TAG} clear all data.`);
      this.dataSource?.removeDataByIndex(this.dataSource.totalCount() - 1);
    }
  }

  public onApMenuChanged(menu: ApMenu): void {
  }

  public onApMenusChanged(data: Array<ApMenu>): void {
    if (this.isUserEditing) {
      LogUtil.warn(`${TAG} user is editing, will not refresh menu.`);
      return;
    }
    LogUtil.info(`${TAG} onApMenusChanged`);
    if (!this.dataSource) {
      LogUtil.warn(`${TAG} dataSource is null`);
    }
    this.menuCache = [];
    // 过滤出其他wlan
    const arr = data.filter((it) => this.isEncryptedNetwork(it));
    const lastIndex = arr.length - 1;
    // 处理分割线
    arr.forEach((it, index) => {
      this.menuCache.push(this.createApMenu(it, index === lastIndex));
    })
    // 清空旧的数据
    this.dataSource?.splice(0, this.dataSource?.length);
    // 只有首次加载时才进行分帧
    if (this.isFirstEntering && this.index === 0) {
      this.isFirstEntering = false;
      this.displaySync.start();
    } else {
      this.dataSource?.pushDataArray(this.menuCache);
    }
    LogUtil.info(`${TAG} dataSourceTotalCount ${this.dataSource?.totalCount()}`);
    // 没有热点的时候 标题也不要
    this.showOrHideHeader(this.menuCache.length > 0);
    if (this.jumpConfig) {
      LogUtil.error(`${TAG} jumpConfig: ${this.jumpConfig},isUserEditing: ${this.isUserEditing},
        menuCache length:  ${this.menuCache.length}`);
    }
    // 控制中心点击加密wlan、弹出半模态
    if (this.jumpConfig && !this.isUserEditing && this.menuCache.length > 0) {
      let model: WlanItemModel = this.menuCache?.find((item) => (item as WlanItemModel).ssid ===
        this.jumpConfig?.ssid && (item as WlanItemModel).bssid === this.jumpConfig?.bssid &&
        (item as WlanItemModel).securityType === this.jumpConfig?.securityType) as WlanItemModel;
      this.jumpConfig = null;
      if (model) {
        setTimeout(() => {
          this.onItemClick(model);
        }, SHEET_DELAY);
      } else {
        LogUtil.error(`${TAG} no model is found.`);
      }
    }
  }

  private getDetents(securityType: SheetSize): [(SheetSize | Length), (SheetSize | Length)?, (SheetSize | Length)?]
    | undefined {
    if (WifiUtils.isNormalWlan(securityType)) {
      return [DisplayUtils.getScreenHeight() * NORMAL_WLAN_HEIGHT_RATE, SheetSize.LARGE];
    }
    return [SheetSize.LARGE];
  }

  private getSheetHeight(securityType: SheetSize): SheetSize | Length {
    if (WifiUtils.isNormalWlan(securityType)) {
      return DisplayUtils.getSheetStyle() === SheetDialogStyle.BOTTOM_DIALOG_STYLE ?
        DisplayUtils.getScreenHeight() * NORMAL_WLAN_HEIGHT_RATE : UX_DESIGN_SHEET_HEIGHT_PAD;
    }
    return -1;
  }

  private isEncryptedNetwork(model: ApMenu): boolean {
    if (this.isModelLoading(model.key ?? '')) {
      LogUtil.info(`${TAG} ${WifiUtils.getLogSsidString(model?.ssid)} is connecting.`);
      return false;
    }
    if (!model.config && model.securityType !== wifiManager.WifiSecurityType.WIFI_SEC_TYPE_OPEN) {
      return true;
    }
    return false;
  }

  private isModelLoading(key: String): boolean {
    if (apConnectManager.wifiConnectState === CONNECTING && apConnectManager.connectApKey &&
      apConnectManager.connectApKey === key) {
      return true;
    }
    return false;
  }

  private showOrHideHeader(isShow: boolean): void {
    LogUtil.info(`${TAG} showOrHideHeader isShow:${isShow} isVisible:${this.isVisible}`);
    notifyCompStateChange(`${this.compId}.header`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow && this.isVisible } as SettingCompState]]
    ));
  }

  protected onItemClick(item: WlanItemModel): void {
    let instance: WifiPasswordConfigManager = WifiPasswordConfigManager.getInstance();
    instance.initConfig(instance.getDefaultWifiConfig(item), item);
    LogUtil.info(`${TAG} onItemClick,ssid: ${WifiUtils.getLogSsidString(instance.wifiConfig?.ssid)}`);
    // 弹出半模态
    notifyCompStateChange(`Setting.Wlan.EditSheetConfig.EditSheet`,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
        {
          state: true,
          sheetDetents: [SheetSize.LARGE],
          keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
        } as SettingModalState]]
      ));
  }

  protected setLoading(isVisible: boolean): void {
  }

  protected onApChanged(data: Array<ApMenu>): void {
  }

  protected abstract getScanInternal(): number;

  protected abstract getScanLoadingInternal(): number;

  protected abstract createApMenu(item: Partial<ApMenuData>, isLast: boolean): WlanItemModel;
}