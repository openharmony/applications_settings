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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Timer } from '@ohos/settings.common/src/main/ets/utils/Timer';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { MenuGroup } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import {
  PageLifecycleLoadingGroupController
} from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { controllerCounter } from '@ohos/settings.common/src/main/ets/utils/ControllerCounter';
import { ApMenu, ApMenuData, WifiState } from '../model/WifiModel';
import { WIFI_CONNECTED_AP_GROUP, WIFI_SWITCH_KEY, WifiUtils } from '../WifiUtils';
/* instrument ignore file */
import { wifiTracker, WifiTrackerListener } from '../WifiTracker';

/**
 * WiFi列表状态：开始加载
 */
export const STATE_START_LOADING = 'state_start_loading';

/**
 * WiFi列表状态：隐藏列表
 */
export const STATE_HIDE_AP_LIST = 'state_hide_ap_list';

/**
 * WiFi开启状态下，进入WiFi列表界面时，loading状态的广播早于其他controller注册监听，导致其他controller接收不到，
 * 其他controller在注册监听后，发布此广播key，当前controller发布一次当前state广播
 */
export const DATA_CHANGE_KEY_4_STATE = 'data_change_key_4_state';

/**
 * wifi list refresh flag
 */
export const REFRESH_LIST: string = 'refresh';

const TAG: string = 'WifiListBaseController : ';

/**
 * Wifi 列表加载控制器基类
 */
export abstract class WifiListBaseController extends PageLifecycleLoadingGroupController
implements WifiTrackerListener {
  public timer: Timer | null = null;
  public isStarted: boolean = false;
  public targetState: number = WifiState.INACTIVE;
  public loadingTaskId: number | null = null;
  public customState: string = '';

  /**
   * 这里只会接受短距的回调 处理扫描功能
   */
  public onWifiStateChange = (state: number): void => {
    LogUtil.info(`${TAG} onWifiStateChange state:${state}`);
    if (state !== this.targetState) {
      return;
    }
    if (state === WifiState.INACTIVE) { // 关闭
      // 停止扫描
      this.stopTimer();
    } else if (state == WifiState.ACTIVE) { // 开启
      if (WifiUtils.isWifiActive()) {
        // 开始扫描
        this.startTimer();
      }
    }
  }

  /**
   * 这里只会接受按钮的回调 专门处理列表是否显示
   */
  public onSwitchStateChange = (state: number): void => {
    LogUtil.info(`${TAG} onSwitchStateChange state:${state}`);
    if (state !== this.targetState) {
      return;
    }
    if (state === WifiState.INACTIVE) { // 关闭
      this.resetWindowHeight();
      this.hideApList();
    } else if (state == WifiState.ACTIVE) { // 开启
      this.setVisible(true);
    }
  }

  protected registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange`);
    this.registerControllerDataChange(WIFI_SWITCH_KEY);
    this.registerControllerDataChange(DATA_CHANGE_KEY_4_STATE);
    this.registerControllerDataChange(WIFI_CONNECTED_AP_GROUP);
    WifiUtils.wifiStateChangeOn(TAG, this.onWifiStateChange);
  }

  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    this.unRegisterControllerDataChange(WIFI_SWITCH_KEY);
    this.unRegisterControllerDataChange(DATA_CHANGE_KEY_4_STATE);
    this.unRegisterControllerDataChange(WIFI_CONNECTED_AP_GROUP);
    WifiUtils.wifiStateChangeOff(TAG, this.onWifiStateChange);
  }

  public onDataChange(fromKey: string, data: Object): void {
    if (fromKey == WIFI_SWITCH_KEY && typeof data === 'number') {
      LogUtil.info(`${TAG} form switch change ${data} `);
      this.targetState = data;
      this.onSwitchStateChange(data);
    } else if (fromKey === DATA_CHANGE_KEY_4_STATE) {
      this.publishDataChange(this.customState);
    } else if (fromKey === WIFI_CONNECTED_AP_GROUP && typeof data === 'string') {
      this.removeLinkedApMenu(data as string);
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear `);
    super.aboutToAppear();
    wifiTracker.setListener(this);
    this.startWifiTimerAndTracker();
    if (this.isVisibleStatus()) {
      // 热缓存
      wifiTracker.loadCacheMenus();
    } else {
      this.hideApList();
    }
    controllerCounter.addController(this.getKey());
  }

  aboutToDisappear(): void {
    let isExist: boolean = CommonUtils.isPageExist(NavEntryKey.WIFI_ENTRY);
    LogUtil.info(`${TAG} aboutToDisappear, isExist: ${isExist}`);
    super.aboutToDisappear();
    if (controllerCounter.removeController(this.getKey()) && !isExist) {
      this.stopWifiTimerAndTracker();
      wifiTracker.onQuit(this);
      return;
    }
    if (isExist) {
      this.stopWifiTimerAndTracker(true);
      wifiTracker.releaseResource(this);
    }
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow `);
    this.startWifiTimerAndTracker();
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide `);
    // 结束扫描
    let isExist: boolean = CommonUtils.isPageExist(NavEntryKey.WIFI_ENTRY);
    LogUtil.info(`${TAG} onPageHide, isExist: ${isExist}`);
    this.stopWifiTimerAndTracker(isExist);
  }

  private startWifiTimerAndTracker(): void {
    LogUtil.info(`${TAG} startWifiTimerAndTracker isStarted:${this.isStarted}`);
    if (!this.isStarted) {
      wifiTracker.onStart();
      this.startTimer();
      this.isStarted = true;
    }
  }

  private stopWifiTimerAndTracker(isNewIntent?: boolean): void {
    let isFromMoreSetting: boolean | object =
      (AppStorage.get<Want>('wantParams') as Want)?.parameters?.fromMoreSetting ?? false;
    LogUtil.info(`${TAG} stopWifiTimerAndTracker isStarted:${this.isStarted}, isNewIntent: ${isNewIntent}, isFromMoreSetting: ${isFromMoreSetting}`);
    if (this.isStarted) {
      this.stopTimer();
      if (!isNewIntent || !isFromMoreSetting) {
        wifiTracker.onStop();
      }
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

  public resetWindowHeight(): void {
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
    if (this.targetState === WifiState.ACTIVE) {
      this.publishDataChange(this.customState = STATE_START_LOADING);
    }
  }

  public hideApList(): void {
    LogUtil.info(`${TAG} hideApList `);
    if (this.menu instanceof MenuGroup) {
      this.menu.clear();
    }
    this.setVisible(false);
    this.publishDataChange(this.customState = STATE_HIDE_AP_LIST);
  }

  public removeLinkedApMenu(ssid: string): void {
    if (!(this.menu instanceof MenuGroup)) {
      return;
    }
    let removeIndex = this.menu.getMenus().findIndex(item => item instanceof ApMenu && item.ssid === ssid);
    if (removeIndex !== -1) {
      this.menu.getMenus().splice(removeIndex, 1);
      LogUtil.info(`${TAG} removeLinkedApMenu success`);
      this.refreshUi();
    }
  }

  public onApMenuChanged(menu: ApMenu): void {
    if (!menu) {
      return;
    }
    LogUtil.info(`${TAG} onApMenuChanged`);
    this.refreshUi();
  }

  public onApMenusChanged(data: Array<ApMenu>): void {
    LogUtil.info(`${TAG} onApMenusChanged, data length: ${data.length}`);

    if (!(this.menu instanceof MenuGroup)) {
      this.publishDataChange(REFRESH_LIST);
      return;
    }

    // OOBE拉起WiFi列表时，使用的通用component，支持“添加其他网络”入口按钮的menu，不需要占位
    if (typeof this.menu.extra === 'boolean' && !(this.menu.extra as boolean)) {
      // 临时解决可用WiFi为空时，不展示“添加其他网络”按钮的问题，找到其他方式实现时，删除
      if (!data || data.length === 0) {
        data = [new ApMenu({})];
      }
    }

    if (!data || data.length === 0) {
      LogUtil.info(`${TAG} data null`);
      this.menu.clear();
      this.refreshUi();
      this.publishDataChange(REFRESH_LIST);
      return;
    }
    let originMenusMap: Map<string, ApMenu> = new Map<string, ApMenu>();
    for (let item of this.menu.getMenus()) {
      if (item.key && item instanceof ApMenu) {
        originMenusMap.set(item.key, item);
      }
    }
    let menus: ApMenu[] = [];
    for (let item of data) {
      let menu = originMenusMap.get(item.key as string);
      if (!menu) {
        menu = this.createApMenu(item);
      } else {
        originMenusMap.delete(menu.key as string);
        LogUtil.debug(`${TAG} onApMenusChanged menu: ${WifiUtils.getLogSsidString(menu?.ssid)}`);
        menu.update(item);
      }
      LogUtil.debug(`${TAG} onApMenusChanged menu: ${WifiUtils.getLogSsidString(menu?.ssid)}`);
      menus.push(menu);
    }
    LogUtil.info(`${TAG} onApListChanged ${menus.length} isVisible: ${this.menu.isVisible()}`);
    menus = this.truncateSsid(menus);
    if (this.menu instanceof MenuGroup) {
      this.menu.updateMenus(menus);
      this.refreshUi();
    }

    this.publishDataChange(REFRESH_LIST);
    LogUtil.info(`${TAG} onApListChanged end`);
  }

  protected truncateSsid(items: Array<ApMenu>): Array<ApMenu> {
    return items;
  }

  protected abstract getScanInternal(): number;

  protected abstract getScanLoadingInternal(): number;

  protected abstract createApMenu(item: Partial<ApMenuData>): ApMenu;
}
