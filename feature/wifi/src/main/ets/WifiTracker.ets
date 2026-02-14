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
import taskpool from '@ohos.taskpool';
import { BusinessError } from '@ohos.base';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  AccessPoint,
  ApMenu,
  CONNECT_RESULT_EVENT,
  WifiScanResult,
  WifiState
} from './model/WifiModel';
import { WifiUtils } from './WifiUtils';

/* instrument ignore file */
const TAG: string = 'WifiTracker : ';
const TAG_MANAGER: string = 'ApConnectManager : ';
const SCAN_RETRY_COUNT: number = 0;
const WIFI_SEC_TYPE_PSK: number = 3;
const WIFI_SEC_TYPE_SAE: number = 4;

enum ConnectResult {
  // 连接超时
  CONNECT_TIME_OUT,
  // 接口异常
  CONNECT_ERROR,
  // 短距上报连接失败
  CONNECT_FAILED,
  // 连接成功
  CONNECT_SUCCESS,
}

@Concurrent
async function getScanInfo(): Promise<Array<wifiManager.WifiScanInfo>> {
  let res: wifiManager.WifiScanInfo[] = WifiUtils.getScanInfoList();
  return res;
}

@Concurrent
async function getLinkedInfo(): Promise<wifiManager.WifiLinkedInfo> {
  let res = await wifiManager.getLinkedInfo();
  return res;
}

@Concurrent
async function getMultiLinkedInfo(): Promise<Array<wifiManager.WifiLinkedInfo>> {
  let res = await wifiManager.getMultiLinkedInfo();
  return res;
}

@Concurrent
function scanWifi(): boolean {
  return WifiUtils.scanWifi();
}

@Concurrent
function getApConfigMap(): Map<string, Array<wifiManager.WifiDeviceConfig>> {
  let configs: wifiManager.WifiDeviceConfig[] = wifiManager.getDeviceConfigs();
  let configMap: Map<string, Array<wifiManager.WifiDeviceConfig>> =
  new Map<string, Array<wifiManager.WifiDeviceConfig>>();
  for (let config of configs) {
    let key: string = WifiUtils.getApKeyWithConfig(config) as string;
    let configList: wifiManager.WifiDeviceConfig[] = configMap.get(key) as Array<wifiManager.WifiDeviceConfig>;
    if (!configList) {
      configList = [];
    }
    configList.push(config);
    configMap.set(key, configList);
  }
  return configMap;
}

/**
 * 连接结果回调接口
 *
 * @since 2022-03-21
 */
export interface WifiConnectListener {
  /**
   * 连接结果回调
   *
   * @param result 1：连接成功，0：连接失败
   */
  onConnectResult(result: number): void;
}

/**
 * Ap加载回调
 *
 * @since 2022-03-21
 */
export interface WifiTrackerListener {
  /**
   * Ap菜单数据变化回调
   *
   * @param menu 数据变化的Ap菜单
   */
  onApMenuChanged(menu: ApMenu): void;

  /**
   * Ap数据列表加载回调
   *
   * @param menus 加载完的Ap菜单数据列表
   */
  onApMenusChanged(menus: Array<ApMenu>): void;
}

/**
 * 删除结果回调接口
 *
 * @since 2025-01-02
 */
export interface WifiRemoveListener {
  /**
   * 连接结果回调
   *
   * @param result 1：连接成功，0：连接失败
   */
  onRemoveResult(result: boolean): void;
}

/**
 * Wifi 加载后台管理类
 *
 * @since 2022-03-21
 */
export class WifiTracker {
  // Wifi最近一次扫描成功或者失败标记
  public scanActionResult: boolean = false;
  private lastLinkedInfo: wifiManager.WifiLinkedInfo | null = null;
  private lastMultiLinkedInfo: Array<wifiManager.WifiLinkedInfo> | null = null;
  private listeners: WifiTrackerListener[] = [];
  private isRegister: boolean = false;
  private scanResultCache: Map<string, WifiScanResult> = new Map<string, WifiScanResult>();
  private apCache: Map<string, AccessPoint> = new Map<string, AccessPoint>();
  private wifiState: number = 0;
  private nowTimestamp: number = 0;
  private updateCount: number = 0;
  private isListScrolling: boolean = false;
  private connectAccessPoint: AccessPoint | undefined;

  constructor() {
  }

  // Wifi开关状态变化回调
  public onWifiStateChange = (state: number): void => {
    if (!this.isRegister) {
      return;
    }
    LogUtil.info(`${TAG} wifi state change : ${state}`);
    AppStorage.SetOrCreate('wifi_state', state);
    if (state === WifiState.ACTIVE) { // 开启
      this.firstUpdateAndScan();
    }
  };

  // Wifi扫描结果状态变化回调
  public onWifiScanStateChange = (state: number): void => {
    if (!this.isRegister) {
      return;
    }
    LogUtil.info(`${TAG} wifi scan state change : ${state},scroll:${this.isListScrolling}`);
    if (state === 1 && !this.isListScrolling) { // 成功
      this.updateAll();
    }
  };

  //wifi 列表滑动期间不允许刷新页面
  public setListScrolling(isScroll: boolean): void {
    this.isListScrolling = isScroll;
  }

  // Wifi连接状态变化回调
  public onWifiConnectionChange = (state: number): void => {
    if (!this.isRegister) {
      return;
    }
    LogUtil.info(`${TAG} onWifiConnectionChange : ${state}`);
    this.scanAp();
  };

  public setListener(listener: WifiTrackerListener | null): void {
    if (listener) {
      let index = this.listeners.findIndex((item => listener === item));
      if (index === -1) {
        this.listeners.push(listener);
      }
    }
  }

  /**
   * 扫描一次
   *
   * @param retry 失败重试的次数
   */
  public scanAp(retry: number = SCAN_RETRY_COUNT): void {
    new Promise((resolve: (rs: boolean) => void) => {
      LogUtil.info(`${TAG} start scanAp`);
      let result: boolean = false;
      try {
        let scanTask: taskpool.Task = new taskpool.Task(scanWifi);
        taskpool.execute(scanTask, taskpool.Priority.MEDIUM).then((res: Object) => {
          result = res as boolean;
        });
      } catch (err) {
        LogUtil.error(`${TAG} catch exception when scanWifi, code: ${err.code} message: ${err.message}`);
      }
      resolve(result);
    }).then((result: boolean) => {
      LogUtil.info(`${TAG} scanAp result is : ${result}`);
      if (result) {
        this.scanActionResult = true;
        return result;
      }
      if (retry > 0) {
        this.scanAp(--retry);
      } else {
        this.scanActionResult = false;
      }
      return result;
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} scanAp error, error: ${err?.message}`);
    })
  }

  /**
   * 启动工作
   */
  public onStart(): void {
    LogUtil.info(`${TAG} onStart, isRegister: ${this.isRegister}`);
    if (!this.isRegister) {
      LogUtil.info(`${TAG} onStart listen wifi events`);
      WifiUtils.wifiStateChangeOn(TAG, this.onWifiStateChange);
      WifiUtils.wifiScanStateChangeOn(TAG, this.onWifiScanStateChange);
      WifiUtils.wifiConnectionChangeOn(TAG, this.onWifiConnectionChange);
      this.isRegister = true;
      this.firstUpdateAndScan();
    }
  }

  /**
   * 暂停工作
   */
  public onStop(): void {
    LogUtil.info(`${TAG} onStop, isRegister: ${this.isRegister}`);
    if (this.isRegister) {
      LogUtil.info(`${TAG} onStop cancel listen wifi events`);
      WifiUtils.wifiStateChangeOff(TAG, this.onWifiStateChange);
      WifiUtils.wifiScanStateChangeOff(TAG, this.onWifiScanStateChange);
      WifiUtils.wifiConnectionChangeOff(TAG, this.onWifiConnectionChange);
      this.isRegister = false;
    }
  }

  /**
   * 退出，清理数据
   */
  public onQuit(listener?: WifiTrackerListener): void {
    this.onStop();
    this.releaseResource(listener);
  }

  /**
   * 全量刷新：获取连接信息、扫描结果、配置集合来刷新Ap列表
   */
  public async updateAll(): Promise<void> {
    LogUtil.info(`${TAG} updateAll`);
    let scanInfos: wifiManager.WifiScanInfo[] = [];
    try {
      let scanTask: taskpool.Task = new taskpool.Task(getScanInfo);
      scanInfos = await taskpool.execute(scanTask, taskpool.Priority.MEDIUM) as Array<wifiManager.WifiScanInfo>;
    } catch (error) {
      LogUtil.error(`${TAG} catch exception when getScanInfo, errmsg: ${error?.message}`);
    }
    LogUtil.info(`${TAG} taskpool.scanTask success`);
    let scanResults = this.getScanResults(scanInfos);
    this.updateScanResultCache(scanResults);

    let linkedInfo = await this.getLinkedInfoByTaskPool();
    if (linkedInfo && linkedInfo.wifiLinkType && linkedInfo.wifiLinkType === WIFI7_EMLSR) {
      await this.getMultiLinkedInfoByTaskPool();
    }
    let scanResultsMap = this.getScanResultsMap(this.scanResultCache);
    this.updateApList(scanResultsMap);
    LogUtil.info(`${TAG} finished updateAll.`);
  }

  public async getLinkedInfoByTaskPool(): Promise<wifiManager.WifiLinkedInfo | null> {
    try {
      let getLinkTask: taskpool.Task = new taskpool.Task(getLinkedInfo);
      this.lastLinkedInfo = await taskpool.execute(getLinkTask, taskpool.Priority.MEDIUM) as wifiManager.WifiLinkedInfo;
    } catch (e) {
      LogUtil.error(`${TAG} catch exception when getLinkedInfo, errmsg: ${e?.message}`);
    }
    LogUtil.info(`${TAG} taskpool.getLinkTask success`);
    return this.lastLinkedInfo;
  }

  public async getMultiLinkedInfoByTaskPool(): Promise<Array<wifiManager.WifiLinkedInfo> | null> {
    try {
      let getMultiLinkTask: taskpool.Task = new taskpool.Task(getMultiLinkedInfo);
      this.lastMultiLinkedInfo = await taskpool.execute(getMultiLinkTask, taskpool.Priority.MEDIUM) as
      Array<wifiManager.WifiLinkedInfo>;
    } catch (e) {
      LogUtil.error(`${TAG} catch exception when getMultiLinkedInfo, errmsg: ${e?.message}`);
    }
    LogUtil.info(`${TAG} taskpool.getMultiLinkTask success`);
    return this.lastMultiLinkedInfo;
  }
  
  /**
   * 连接Ap
   *
   * @param config 需要连接的Ap信息
   * @param isConfigUpdate 是否需要更新已保存的Ap配置
   */
  public async connectToWifiDevice(config: wifiManager.WifiDeviceConfig, isConfigUpdate: boolean): Promise<boolean> {
    if (!config) {
      return false;
    }
    LogUtil.info(`${TAG} connectToWifiDevice: ${WifiUtils.getLogSsidString(config.ssid)} securityType:${config.securityType}`);

    // 获取已保存的config
    let wifiConfig = WifiUtils.getConfig(config.ssid, config.securityType) as wifiManager.WifiDeviceConfig;

    let networkId: number | undefined = undefined;
    if (!wifiConfig) {
      // 未保存，先保存config
      LogUtil.info(`${TAG} connectToWifiDevice addDeviceConfig.`);
      networkId = await wifiManager.addDeviceConfig(config);
    } else {
      LogUtil.info(`${TAG} connectToWifiDevice wifiConfig is saved isConfigUpdate: ${isConfigUpdate}`);
      if (isConfigUpdate) {
        // 已保存，config需要更新，先删除，再保存
        let result = wifiManager.removeDevice(wifiConfig.netId);
        LogUtil.info(`${TAG} connectToWifiDevice removeDevice result : ${result}`);
        networkId = await wifiManager.addDeviceConfig(config);
      } else {
        // config无需更新，直接用netId去连接
        networkId = wifiConfig.netId;
      }
    }
    LogUtil.info(`${TAG} connectToWifiDevice network is : ${networkId}`);
    if (!WifiUtils.isValidNetworkId(networkId)) {
      LogUtil.error(`${TAG} connectToWifiDevice, network is inValid.`);
      try {
        wifiManager.connectToDevice(wifiConfig);
        return true;
      } catch (error) {
        LogUtil.error(`${TAG} connectToDevice occurs error: ${error?.message}`);
      }
      return false;
    }
    try {
      wifiManager.connectToNetwork(networkId);
      return true;
    } catch (error) {
      LogUtil.error(`${TAG} connectToWifiDevice connectToNetwork error: ${error?.message}`);
      return false;
    }
  }

  /**
   * 释放listener
   *
   * @param listener WifiTrackerListener对象
   */
  public releaseResource(listener?: WifiTrackerListener): void {
    if (this.listeners.length === 0) {
      return;
    }
    if (!listener) {
      this.listeners.splice(0, this.listeners.length);
      this.scanResultCache.clear();
      return;
    }
    let findIndex = this.listeners.findIndex(item => item === listener);
    if (findIndex !== -1) {
      this.listeners.splice(findIndex, 1);
      this.scanResultCache.clear();
    }
  }

  /**
   * 删除已保存的Ap
   *
   * @param config 待删除的Ap信息
   */
  public async removeWifiDevice(config: wifiManager.WifiDeviceConfig, isRefresh?: boolean,
    removeCallback?: WifiRemoveListener): Promise<void> {
    if (!config) {
      LogUtil.warn(`${TAG} removeWifiDevice, config is invalid!`);
      return;
    }
    let wifiConfig = config as wifiManager.WifiDeviceConfig;
    let removeNetId =
      (WifiUtils.getConfig(wifiConfig.ssid, wifiConfig.securityType) as wifiManager.WifiDeviceConfig)?.netId;
    if (!WifiUtils.isValidNetworkId(removeNetId)) {
      LogUtil.info(`${TAG} removeWifiDevice, config can not found, return`);
      return;
    }
    LogUtil.info(`${TAG} removeWifiDevice id: ${removeNetId}`);
    if (isRefresh === undefined) {
      // 默认需要刷新
      isRefresh = true;
    }
    if (wifiManager.isConnected() && isRefresh) {
      let linkedInfo = await wifiTracker.getLinkedInfoByTaskPool();
      LogUtil.info(`${TAG} linkedInfo id: ${linkedInfo?.networkId}`);
      if (linkedInfo?.networkId === removeNetId) {
        LogUtil.info(`${TAG} removeWifiDevice, wifi is Connected`);
        let result = WifiUtils.disconnect();
        LogUtil.info(`${TAG} removeWifiDevice, disconnect result is ${result}`);
      }
    }
    let result = await Promise.resolve(WifiUtils.removeDevice(removeNetId as number));
    LogUtil.info(`${TAG} removeDevice result is : ${result}`);
    if (removeCallback) {
      removeCallback.onRemoveResult(result);
    }
    if (isRefresh) {
      this.updateAll();
    }
    this.apCache.get(WifiUtils.getApKeyWithConfig(config) as string)?.setConfigs(null);
    if (isRefresh) {
      this.scanAp();
    }
  }

  /**
   * 删除已连接ap信息
   *
   * @param network 待删除的ap信息
   */
  public async removeWifiDeviceById(network: number): Promise<void> {
    if (!WifiUtils.isValidNetworkId(network)) {
      LogUtil.error(`${TAG} removeWifiDeviceById, network is ${network}.`);
      return;
    }
    if (wifiManager.isConnected()) {
      LogUtil.info(`${TAG} removeWifiDeviceById, wifi is Connected`);
      let result = WifiUtils.disconnect();
      LogUtil.info(`${TAG} removeWifiDeviceById, disconnect result is ${result}`);
    }
    let result = await Promise.resolve(WifiUtils.removeDevice(network));
    LogUtil.info(`${TAG} removeWifiDeviceById result is : ${result}, network is ${network}`);
    this.updateAll();
    this.scanAp();
  }

  private firstUpdateAndScan(): void {
    this.scanAp();
  }

  private getScanResults(scanInfos: Array<wifiManager.WifiScanInfo>): Array<WifiScanResult> {
    let wifiScanResults: WifiScanResult[] = [];
    for (const info of scanInfos) {
      wifiScanResults.push(new WifiScanResult(info));
    }
    LogUtil.info(`${TAG} get wifiScanResults.length: ${wifiScanResults.length}`);
    return wifiScanResults;
  }

  private filterScanResultsByCapabilities(scanResults: Array<WifiScanResult>): Array<WifiScanResult> {
    return scanResults;
  }

  private updateScanResultCache(scanResults: Array<WifiScanResult>): void {
    if (scanResults && scanResults.length === 0) {
      LogUtil.warn(`${TAG} updateScanResultCache ,scanResults is null `);
      return;
    }
    this.scanResultCache.clear();
    scanResults.forEach(scanResult => {
      if (scanResult && scanResult.ssid && scanResult.bssid) {
        this.scanResultCache.set(scanResult.bssid, scanResult);
      }
    });
    LogUtil.info(`${TAG} updateScanResultCache success ,scanResultCache size: ${this.scanResultCache.size} `);
  }

  private updateAccessPoints(): void {
    LogUtil.info(`${TAG} updateAccessPoints, getRealTime start`);
    this.filterOldScanResultCacheAndUpdate();
  }

  private async filterOldScanResultCacheAndUpdate(): Promise<void> {
    // 当前扫描结果中的时间戳都是一致的，暂没有过滤
    let scanResultsMap = await Promise.resolve(this.getScanResultsMap(this.scanResultCache));
    this.updateApList(scanResultsMap);
  }

  private getScanResultsMap(cache: Map<string, WifiScanResult>): Map<string, Array<WifiScanResult>> {
    let scanResultsMap: Map<string, Array<WifiScanResult>> = new Map<string, Array<WifiScanResult>>();
    for (let item of Array.from(cache.values())) {
      let apKey: string = WifiUtils.getApKeyWithScanResult(item as WifiScanResult) as string;
      let results: WifiScanResult[] = scanResultsMap.get(apKey) as Array<WifiScanResult>;
      if (!results) {
        results = [];
        scanResultsMap.set(apKey, results);
      }
      results.push(item as WifiScanResult);
    }
    LogUtil.info(`${TAG} getScanResultsMap success, scanResultsMap.size:${scanResultsMap.size}`);
    return scanResultsMap;
  }

  private async updateApList(scanResultsMap: Map<string, Array<WifiScanResult>>): Promise<void> {
    let configMap: Map<string, Array<wifiManager.WifiDeviceConfig>> =
    new Map<string, Array<wifiManager.WifiDeviceConfig>>();
    try {
      let getCmTask: taskpool.Task = new taskpool.Task(getApConfigMap);
      configMap = await taskpool.execute(getCmTask, taskpool.Priority.MEDIUM) as
      Map<string, Array<wifiManager.WifiDeviceConfig>>;
    } catch (error) {
      LogUtil.error(`${TAG} catch exception when getCmTask, errmsg: ${error?.message}`);
    }
    LogUtil.info(`${TAG} taskpool.getCmTask success`);
    let apList = this.updateApListInner(scanResultsMap, configMap);
    let menus = this.apListToMenuList(apList);
    // 直接保存最后一次的菜单数据
    AppStorage.setOrCreate('wifiMenusCache', menus);
    LogUtil.info(`${TAG} updateApList scanResultsMap.size:${scanResultsMap.size}, apList.length:${apList.length}`);
    if (this.listeners) {
      LogUtil.info(`${TAG} listener.onApMenusChanged menus.length:${menus.length}`);
      for (let listener of this.listeners) {
        listener.onApMenusChanged(menus);
      }
    }
  }

  /**
   * 获取连接wifi信息
   *
   * @returns AccessPoint 已连接wifi信息
   */
  public getConnectAccessPoint(): AccessPoint | undefined {
    return this.connectAccessPoint;
  }

  // 直接从进程级的缓存刷新菜单
  public loadCacheMenus(): void {
    const menus = AppStorage.get<Array<ApMenu>>('wifiMenusCache') || []
    if (menus.length === 0) {
      this.updateAll();
      return
    }
    if (this.listeners) {
      LogUtil.info(`${TAG} loadCacheMenus listener.onApMenusChanged : ${menus.length}`);
      for (let listener of this.listeners) {
        listener.onApMenusChanged(menus);
      }
    }
  }

  private updateApListInner(scanResultsMap: Map<string, WifiScanResult[]>,
                            configMap: Map<string, wifiManager.WifiDeviceConfig[]>): AccessPoint[] {
    let apList: AccessPoint[] = [];
    for (let scanResults of Array.from(scanResultsMap.values())) {
      let resultApKey: string = WifiUtils.getApKeyWithScanResult(scanResults[0]) as string;
      let ap: AccessPoint = this.apCache.get(resultApKey) as AccessPoint;
      if (!ap) {
        ap = new AccessPoint(scanResults);
        this.apCache.set(resultApKey, ap);
      } else {
        ap.setScanResults(scanResults);
      }
      // 更新
      ap.setConfigs(configMap.get(ap.apKey) as Array<wifiManager.WifiDeviceConfig>);

      // hota升级场景，同一个网络的securityType字段，scanInfo接口返回4 deviceConfig接口返回3，根据约定也判定为同一个网络。
      this.upgradeScene(ap, configMap);

      ap.updateLastLinkedInfo(this.lastLinkedInfo as wifiManager.WifiLinkedInfo);
      apList.push(ap);
    }
    apList.sort(AccessPoint.compare);
    let updateApCache = new Map<string, AccessPoint>();
    for (let ap of apList) {
      updateApCache.set(ap.apKey, ap)
    }
    this.apCache = updateApCache;

    LogUtil.info(`${TAG} updateApListInner success, apList.length:${apList.length} connState:${this.lastLinkedInfo?.connState} networkId: ${this.lastLinkedInfo?.networkId}`);
    return apList;
  }

  private upgradeScene(ap: AccessPoint, configMap: Map<string, wifiManager.WifiDeviceConfig[]>) {
    if (DeviceUtil.isWearable()) {
      return;
    }
    if (!ap || !configMap) {
      return;
    }
    if (!ap.isSaved() && ap.securityType === WIFI_SEC_TYPE_SAE && ap.capabilities.includes('WPA2-PSK')) {
      let config = configMap.get(WifiUtils.getApKey(ap.ssid, ap.bestBssid, WIFI_SEC_TYPE_PSK) ?? '');
      if (config && config.length > 0) {
        LogUtil.info(`${TAG} hota update scene, set configs: ${WifiUtils.getLogSsidString(ap.ssid)}`);
        config[0].securityType = WIFI_SEC_TYPE_SAE;
        ap.setConfigs(config as Array<wifiManager.WifiDeviceConfig>);
        WifiUtils.updateNetwork(config[0]);
      }
    }
  }

  private apListToMenuList(apList: Array<AccessPoint>): Array<ApMenu> {
    let menus: ApMenu[] = [];
    for (let index = 0; index < apList.length; index++) {
      let ap: AccessPoint = apList[index];
      ap.lastIndex = index;
      ap.lastTimestamp = this.nowTimestamp;
      LogUtil.info(`${TAG} apListToMenuList, ${ap?.toString()}`);
      if (ap.isConnected()) {
        this.connectAccessPoint = ap;
      }
      if (!ap.isReachable() || !ap.isValid() || ap.isConnected()) {
        LogUtil.info(`${TAG} apListToMenuList ${WifiUtils.getLogSsidString(ap?.ssid)} invalid`);
        continue;
      }
      let apMenu: ApMenu = this.apToMenu(ap) as ApMenu;
      if (apMenu) {
        menus.push(apMenu);
      }
    }
    LogUtil.info(`${TAG} apListToMenuList success, menus: ${menus.length}`);
    return menus;
  }

  private apToMenu(ap: AccessPoint): ApMenu | void {
    if (!ap.isReachable() || !ap.isValid() || ap.isConnected()) {
      return;
    }
    return new ApMenu({
      key: ap.apKey,
      index: ap.lastIndex,
      title: ap.getTitle(),
      summary: ap.getSummary(),
      stateIcon: ap.getStateIcon(),
      timestamp: ap.lastTimestamp,
      ssid: ap.ssid,
      bssid: ap.bestBssid,
      bssidType: ap.bssidType,
      level: ap.bestLevel,
      scanResults: ap.scanResults,
      securityType: ap.securityType,
      capabilities: ap.capabilities,
      config: ap.getBestConfig() as wifiManager.WifiDeviceConfig,
      supportedWifiCategory: ap.supportedWifiCategory,
      isHiLinkNetwork: ap.isHiLinkNetwork,
      isHiLinkProNetwork: ap.isHiLinkProNetwork
    });
  }
}

export let wifiTracker = new WifiTracker();

/**
 * AP连接管理类
 *
 * @since 2022-03-21
 */
class ApConnectManager {
  public static CONNECT_TIMEOUT: number = 60000;
  public static IDLE: number = 0;
  public static CONNECTING: number = 1;
  public static DISCONNECTING: number = -1;
  public isRegister: boolean = false;
  public isRetry: boolean = false;
  public wifiConnectState: number = ApConnectManager.IDLE;
  public connectConfig: wifiManager.WifiDeviceConfig | null = null;
  public connectApKey: string | null = null;
  public listener: WifiConnectListener | null = null;
  public timerId: number | null = null;
  public isConfigUpdate: boolean = false;

  public onWifiConnectionChange = (state: number): void => {
    LogUtil.info(`${TAG_MANAGER} onWifiConnectionChange : ${state}`);

    if (state === 1) { // 连接上
      this.onConnectResult(1, ConnectResult.CONNECT_SUCCESS);
    } else { // 连接断开、失败
      if (this.wifiConnectState === ApConnectManager.DISCONNECTING) {
        LogUtil.info(`${TAG_MANAGER} Disconnected, start connect`);
        this.connectToWifiDevice(this.isConfigUpdate);
        return;
      }
      this.onConnectResult(0, ConnectResult.CONNECT_FAILED);
    }
  };

  /**
   * hiLink路由器自动连接
   *
   * @param listener 连接结果回调
   */
  public hiLinkConnecting(listener: WifiConnectListener): void {
    this.finishConnect();
    this.wifiConnectState = ApConnectManager.CONNECTING;
    this.listener = listener;
    this.register();
    this.timerId = setTimeout(() => {
      LogUtil.info(`${TAG_MANAGER} connect timeout`);
      this.timerId = null;
      this.onConnectResult(0, ConnectResult.CONNECT_TIME_OUT);
    }, ApConnectManager.CONNECT_TIMEOUT);
  }

  /**
   * 发起一次连接
   *
   * @param config 需要连接的Ap信息
   * @param isConfigUpdate 是否需要更新已保存的Ap配置
   * @param listener 连接结果回调
   * @return 是否启动连接
   */
  public startConnect(config: wifiManager.WifiDeviceConfig, isConfigUpdate: boolean, listener:
    WifiConnectListener, isRetry: boolean = false): boolean {
    if (!isRetry && this.isRepeatConnect(config)) {
      LogUtil.warn(`${TAG_MANAGER} repeat operation: the same network(${config?.netId}) is connecting, try later please.`);
      return false;
    }
    this.resetState(config, isConfigUpdate, listener, isRetry);
    try {
      if (wifiManager.isConnected()) {
        LogUtil.info(`${TAG_MANAGER} wifi is Connected`);
        if (WifiUtils.disconnect()) {
          LogUtil.info(`${TAG_MANAGER} disconnect success`);
          this.wifiConnectState = ApConnectManager.DISCONNECTING;
          return true;
        }
      }
    } catch (error) {
      LogUtil.error(`${TAG} get wifi connect state failed: ${error?.message}`);
    }
    this.connectToWifiDevice(this.isConfigUpdate);
    return true;
  }

  /**
   * 发起一次连接
   *
   * @param config 需要连接的Ap信息
   * @param isConfigUpdate 是否需要更新已保存的Ap配置
   * @param listener 连接结果回调
   * @return 是否启动连接
   */
  public async startConnectAsync(config: wifiManager.WifiDeviceConfig, isConfigUpdate: boolean,
    listener: WifiConnectListener, isRetry: boolean = false): Promise<boolean> {
    if (!isRetry && this.isRepeatConnect(config)) {
      LogUtil.warn(`${TAG_MANAGER} repeat operation: the same network(${config?.netId}) is connecting, try later please.`);
      return false;
    }
    this.resetState(config, isConfigUpdate, listener, isRetry);
    try {
      if (wifiManager.isConnected()) {
        LogUtil.info(`${TAG_MANAGER} wifi is Connected`);
        if (WifiUtils.disconnect()) {
          LogUtil.info(`${TAG_MANAGER} disconnect success`);
          this.wifiConnectState = ApConnectManager.DISCONNECTING;
          return true;
        }
      }
    } catch (error) {
      LogUtil.error(`${TAG} get wifi connect state failed: ${error?.message}`);
    }
    await this.connectToWifiDevice(this.isConfigUpdate);
    return true;
  }

  private resetState(config: wifiManager.WifiDeviceConfig, isConfigUpdate: boolean, listener:
    WifiConnectListener, isRetry: boolean = false): void {
    this.finishConnect();
    this.connectConfig = config as wifiManager.WifiDeviceConfig;
    this.connectApKey = WifiUtils.getApKey(this.connectConfig.ssid, this.connectConfig.bssid ?? '',
      this.connectConfig.securityType);
    this.isConfigUpdate = isConfigUpdate;
    this.listener = listener;
    this.isRetry = isRetry;
    this.register();
    this.timerId = setTimeout(() => {
      LogUtil.info(`${TAG_MANAGER} connect timeout`);
      this.timerId = null;
      this.onConnectResult(0, ConnectResult.CONNECT_TIME_OUT);
    }, ApConnectManager.CONNECT_TIMEOUT);
  }

  private isRepeatConnect(newConfig: wifiManager.WifiDeviceConfig): boolean {
    if (!this.connectConfig || !newConfig) {
      return false;
    }
    let oldKey = WifiUtils.getApKey(this.connectConfig.ssid, this.connectConfig.bssid ?? '',
      this.connectConfig.securityType);
    let newKey = WifiUtils.getApKey(newConfig.ssid, newConfig.bssid ?? '', newConfig.securityType);
    return this.wifiConnectState === ApConnectManager.CONNECTING && oldKey === newKey;
  }

  /**
   * 判断是否是上一个发起连接的的热点
   *
   * @param newConfig 需要判断的Ap信息
   * @returns 不是上一个发起连接的的热点 true
   */
  public isNewConnect(newConfig: wifiManager.WifiDeviceConfig): boolean {
    if (!this.connectConfig || !newConfig) {
      return false;
    }
    let oldKey = WifiUtils.getApKey(this.connectConfig.ssid, this.connectConfig.bssid ?? '',
      this.connectConfig.securityType);
    let newKey = WifiUtils.getApKey(newConfig.ssid, newConfig.bssid ?? '', newConfig.securityType);
    return oldKey !== newKey;
  }

  private onConnectResult(result: number, reason: number): void {
    LogUtil.info(`${TAG_MANAGER} onConnectResult: ${result}, reason: ${reason}`);
    this.listener?.onConnectResult(result);
    if (result === 1 || !WifiUtils.willReconnect(this.connectConfig) || this.isRetry ||
      reason === ConnectResult.CONNECT_ERROR || reason === ConnectResult.CONNECT_TIME_OUT) {
      EventBus.getInstance().emit(CONNECT_RESULT_EVENT, result === 1);
      this.finishConnect();
    }
  }

  private finishConnect(): void {
    LogUtil.info(`${TAG_MANAGER} finishConnect.`);
    if (this.timerId !== null) {
      clearTimeout(this.timerId);
      this.timerId = null;
    }
    this.unRegister();
    this.wifiConnectState = ApConnectManager.IDLE;
    this.connectConfig = null;
    this.isConfigUpdate = false;
    this.isRetry = false;
    this.listener = null;
  }

  private register(): void {
    if (!this.isRegister) {
      LogUtil.info(`${TAG_MANAGER} register`);
      WifiUtils.wifiConnectionChangeOn(TAG_MANAGER, this.onWifiConnectionChange);
      this.isRegister = true;
    }
  }

  private unRegister(): void {
    if (this.isRegister) {
      LogUtil.info(`${TAG_MANAGER} unRegister`);
      WifiUtils.wifiConnectionChangeOff(TAG_MANAGER, this.onWifiConnectionChange);
      this.isRegister = false;
    }
  }

  private async connectToWifiDevice(isConfigUpdate: boolean): Promise<void> {
    LogUtil.info(`${TAG_MANAGER} connectToWifiDevice start`);
    let result = await wifiTracker.connectToWifiDevice(this.connectConfig as wifiManager.WifiDeviceConfig,
      isConfigUpdate);
    LogUtil.info(`${TAG_MANAGER} connectToWifiDevice end , result: ${result}`);
    AppStorage.setOrCreate<Boolean>('isConnectCancel', false);
    if (result) {
      this.wifiConnectState = ApConnectManager.CONNECTING;
    } else {
      this.onConnectResult(0, ConnectResult.CONNECT_ERROR);
    }
  }
}

export let apConnectManager = new ApConnectManager();
export const WIFI7_EMLSR: number = 3;