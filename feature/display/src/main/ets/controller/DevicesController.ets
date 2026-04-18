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
import settings from '@ohos.settings';
import screen from '@ohos.screen';
import display from '@ohos.display';
import { BusinessError } from '@ohos.base';
import colorSpaceManager from '@ohos.graphics.colorSpaceManager';
import image from '@ohos.multimedia.image';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import { DragController } from './DragController';
import { DEFAULT_CARD_HEIGHT, DEFAULT_CARD_WIDTH } from '../constant/DisplayConstant';
import { DeviceType, RemoteDeviceInfo } from '../utils/DeviceUtil';
import { RemoteDevicesController } from './RemoteDevicesController';
import { DisplayConstants as Constants } from '../constant/DisplayConstant';

/**
 * 设备类型
 */
export enum DeviceDisplayType {
  BUILTIN, // 内置显示器
  EXTENDED, // 拓展显示器
  MIRROR, // 镜像
  OTHERS // 其他设备
}

/**
 * 设备用于
 */
export enum DeviceUserType {
  MAIN_SCREEN = screen.ScreenSourceMode.SCREEN_MAIN, // 主显示器
  MIRROR = screen.ScreenSourceMode.SCREEN_MIRROR, // 镜像
  EXTENDED = screen.ScreenSourceMode.SCREEN_EXTEND, // 拓展显示器
  MIRROR_TO_B = 3, // 镜像B面
  MIRROR_TO_C = 4, // 镜像C面
  OTHERS = 5,
  ONLY_SCREEN = 10, // 仅该屏
}

// 设备机模图片参数
export interface DeviceModelValue {
  icon: ResourceStr,
  width: number,
  height: number,
  wallpaperWidth: number,
  wallpaperHeight: number,
  top?: number,
  left?: number,
  radius?: number,
}

// 设备机模图片以及尺寸
export const DEVICES_MODEL_ICON: DeviceModelValue[] = [
  {icon: $r('app.media.illustration_hopper'), width: 957, height: 973, wallpaperWidth: 727, wallpaperHeight: 953, top: 2},
  {icon: $r('app.media.illustration_hopper_landscape'), width: 1285, height: 747, wallpaperWidth: 920, wallpaperHeight: 710,
    top: 4, left: 1, radius: 4},
  {icon: $r('app.media.illustration_tablet'), width: 1204, height: 747, wallpaperWidth: 968, wallpaperHeight: 658, top: 2},
  {icon: $r('app.media.illustration_screen'), width: 1285, height: 747, wallpaperWidth: 1048, wallpaperHeight: 610,
    top: 2, left: -1},
  {icon: $r('app.media.illustration_screen_big'), width: 1395, height: 812, wallpaperWidth: 1300, wallpaperHeight: 750,
    top: 2, left: -1},
  {icon: $r('app.media.illustration_phone'), width: 522, height: 747, wallpaperWidth: 297, wallpaperHeight: 636, top: 2},
  {icon: $r('app.media.illustration_pad'), width: 1260, height: 747, wallpaperWidth: 1016, wallpaperHeight: 636, top: 2},
]

const INCH_TO_MM: number = 254;
// 默认模式
const DEFAULT_MODE: DeviceUserType = DeviceUserType.EXTENDED;
// 用户连接外接显示器唯一标识
const USER_SET_DEVICE: string = 'user_set_recovery_resolution';
// 用户设置模式
const USER_SET_DEVICE_MODE: string = 'user_set_last_screen_mode';
// 用户设置EDID数据
export const USER_SET_DEVICE_MODE_EDID: string = 'user_set_screen_mode_edid';
// 用户插入设备事件
const USER_CONNECT_DEVICE_EVENT: string = 'DISPLAY_CONNECT_CHANGE';
// 用户模式切换事件
const USER_MODE_CHANGE_EVENT: string = 'DISPLAY_MODE_CHANGE';
// PC可折叠设备C面display默认ID
const DISPLAY_ID_ENABLE: number = 999;
// PC可折叠设备数据库参数个数
const DEVICE_DATA_LEN_FOLDABEL = 3;
// PC设备数据库参数个数
const DEVICE_DATA_LEN = 2;
// 镜像模式集合
export const MIRROR_MODE = [DeviceUserType.MIRROR, DeviceUserType.MIRROR_TO_B, DeviceUserType.MIRROR_TO_C];
// 允许存放的设备信息列表长度
const MAX_DATALIST_LEN = 30;
// 字串分割符
const DELIMITER: string = ';';
// 使能搜索项
const SEARCH_ITEMS: string[] = [
  'display_extended', 'extended_display_mode', 'display_screen_settings'
];

/**
 * 设备信息
 */
export default class DeviceInfo {
  /** 设备区分键值 */
  public key: number | string = 0;

  /** SN号 */
  public serialNumber: string | undefined = '';

  /** 设备名称 */
  public name: string | ResourceStr = '';

  /** 设备品牌名称 */
  public brand: string | ResourceStr = '';

  /** 主副屏判断 */
  public deviceUserFor: DeviceUserType = DeviceUserType.MAIN_SCREEN;

  /** 设备类型 */
  public deviceType: DeviceDisplayType = DeviceDisplayType.BUILTIN;

  /** 刷新率 */
  public refreshRate?: number | string = 60;

  /** 逻辑宽 - 分辨率宽 */
  public width: number = 0;

  /** 逻辑高 - 分辨率高 */
  public height: number = 0;

  /** 物理宽 */
  public physicalWidth?: number = 0;

  /** 物理高 */
  public physicalHeight?: number = 0;

  /** 物理X方向dpi */
  public XDPI?: number = 0;

  /** 物理Y方向dpi */
  public YDPI?: number = 0;

  /** dpi */
  public densityDPI?: number = 0;

  /** 色域 */
  public colorSpaces?: colorSpaceManager.ColorSpace[] = [];

  /** HDR */
  public hdrFormats?: number[] = [];

  /** 缩放比例 */
  public zoomRatio?: number | string = '100%';

  /** 壁纸图片 */
  public wallpaper?: image.PixelMap | Resource | null;

  /** 设备类型：PC\手机\PAD */
  public deviceModel?: number = 0;

  constructor(key: string | number, name: string | ResourceStr, deviceType: DeviceDisplayType, width: number,
    height: number) {
    this.key = key;
    this.name = name;
    this.deviceType = deviceType;
    this.width = width;
    this.height = height;
  }

  /**
   * 根据显示设备创建设备信息
   * @param newDisplay 显示设备display信息
   * @param rsId 屏幕物理ID
   * @param mode 屏幕模式
   * @param serialNumber 屏幕设备唯一标识
   * @return 返回设备信息
   */
  public static createDeviceInfoByDisplay(newDisplay: display.Display, rsId: number | string, mode: DeviceUserType,
    serialNumber: string): DeviceInfo | undefined {
    if (!newDisplay || mode === undefined) {
      LogUtil.error(`create device error by undefinded or null`);
      return undefined;
    }
    let newDevice: DeviceInfo = new DeviceInfo((rsId ?? newDisplay.id),
      (rsId ?? newDisplay.id) === 0 ? $r('app.string.display_machine') : newDisplay.name,
      (rsId ?? newDisplay.id) === 0 ? DeviceDisplayType.BUILTIN : DeviceDisplayType.EXTENDED,
      newDisplay.width, newDisplay.height);
    newDevice.serialNumber = serialNumber;
    newDevice.refreshRate = newDisplay.refreshRate;
    newDevice.colorSpaces = newDisplay.colorSpaces;
    newDevice.hdrFormats = newDisplay.hdrFormats;
    newDevice.XDPI = newDisplay.xDPI;
    newDevice.YDPI = newDisplay.yDPI;
    newDevice.densityDPI = newDisplay.densityDPI;
    // DPI反算显示器物理宽高度
    if (newDisplay.xDPI !== 0) {
      newDevice.physicalWidth = INCH_TO_MM * newDisplay.width / newDisplay.xDPI;
    }
    if (newDisplay.yDPI !== 0) {
      newDevice.physicalHeight = INCH_TO_MM * newDisplay.height / newDisplay.yDPI;
    }
    newDevice.deviceUserFor = mode;
    newDevice.brand = $r('app.string.display_machine');
    newDevice.wallpaper = null;
    return newDevice;
  }
}

const TAG = 'DevicesController';
const DOMAIN_NAME: string = settings.domainName.USER_PROPERTY;
export const FOLD_STATUS_CHANGE: string = 'foldStatus_change';

export class DevicesController {
  private static controller: DevicesController | undefined;

  private devices: DeviceInfo[] = [];
  private currentDevice: DeviceInfo = DeviceInfo.createDeviceInfoByDisplay(
      display.getDefaultDisplaySync(), 0, DeviceUserType.MAIN_SCREEN, '') as DeviceInfo;
  private localDeviceCount: number = 0;
  private otherDeviceCount: number = 0;
  private isStartService: boolean = false;
  private deviceDataList: string[] = ['0 0'];
  // EDID 数据列表信息
  private deviceEDIDList: string[] = [];
  private connectDeviceInfoList: string[] = [];
  private defaultDisplay?: display.Display;
  private foldStatus: display.FoldStatus = display.FoldStatus.FOLD_STATUS_UNKNOWN;
  private isStartFoldableService: boolean = false;
  private timer: number | undefined = undefined;
  private _isProcessScreenModeChange: boolean = false;

  private onDevicesChange?: (devices: DeviceInfo[], refresh: boolean) => void;
  private onCurrentDeviceChange?: (device: DeviceInfo) => void;
  private deviceChangeEvent?: () => void;

  private displayModeChange = () => {
    LogUtil.info(`${TAG} display_mode_change start`);
    this.initDevices(false);
  };

  constructor() {
    LogUtil.info(`create controller`);
    try {
      let settingsData = SettingsDataUtils.getSettingsDataDomain(USER_SET_DEVICE_MODE,
        '', DOMAIN_NAME);
      if (settingsData !== '') {
        this.deviceDataList = JSON.parse(settingsData);
      }
      this.registUserSetDeviceModeEdidChange();
      this.connectDeviceInfoList =
        JSON.parse(SettingsDataUtils.getSettingsDataDomain(USER_SET_DEVICE, '[]', DOMAIN_NAME));
      this.deviceEDIDList =
        JSON.parse(SettingsDataUtils.getSettingsDataDomain(USER_SET_DEVICE_MODE_EDID, '[]', DOMAIN_NAME));
    } catch (error) {
      LogUtil.error(`${TAG} pushDevices JSON.parse error: ${error.code}`);
    }
    this.init();
    // 存在外部引起的模式变化，监听数据库事件并更新当前controller数据
    EventBus.getInstance().on('display_mode_change', this.displayModeChange);
  }

  public static getInstance() {
    if (!DevicesController.controller) {
      DevicesController.controller = new DevicesController();
    }
    return DevicesController.controller;
  }

  public set isProcessScreenModeChange(value: boolean) {
    LogUtil.showInfo(TAG, `isProcessScreenModeChange = ${value}`);
    this._isProcessScreenModeChange = value;
  }

  public get isProcessScreenModeChange(): boolean {
    return this._isProcessScreenModeChange;
  }

  public registUserSetDeviceModeEdidChange() {
    LogUtil.showInfo(TAG, `registUserSetDeviceModeEdidChange`);
    SettingsDataUtils.registerKeyObserverWithDomain(USER_SET_DEVICE_MODE_EDID, DOMAIN_NAME, () => {
      if (this.isProcessScreenModeChange) {
        LogUtil.showInfo(TAG, 'registUserSetDeviceModeEdidChange data change')
        try {
          this.deviceEDIDList =
            JSON.parse(SettingsDataUtils.getSettingsDataDomain(USER_SET_DEVICE_MODE_EDID, '[]', DOMAIN_NAME));
        } catch (error) {
          LogUtil.showError(TAG, `parse edid data error, code: ${error?.code} - message: ${error?.message}`);
        }
      }
    })
  }

  /**
   * 初始化参数
   */
  public init(): void {
    try {
      this.foldStatus = display.getFoldStatus();
    } catch (error) {
      LogUtil.error(`${TAG} init foldStatus error code: ${error.code} - message: ${error.message}`);
    }
    this.setDefaultDisplay();
    this.initDevices().then(() => {
      if (this.onDevicesChange) {
        this.onDevicesChange(this.devices, false);
      }
      LogUtil.info(`${TAG} create currentDevices length: ${this.devices.length}`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} init devices error code: ${error?.code} - message: ${error?.message}`);
    });
    this.startService();
    if (this.isFoldablePC()) {
      this.startFoldableService();
    }
  }

  public destroy(): void {
    LogUtil.info(`${TAG} controller destory strart`);
    DevicesController.controller = undefined;
    EventBus.getInstance().detach('display_mode_change', this.displayModeChange);
    LogUtil.info(`${TAG} controller destory end`);
  }

  /**
   * 启动可折叠设备监听服务
   */
  public startFoldableService(): void {
    if (this.isStartFoldableService) {
      return;
    }
    LogUtil.info(`${TAG} startFoldableService`);
    try {
      display.on('change', (id: number) => {
        LogUtil.info(`${TAG} on foldable change display: ${id}`);
        if (!this.timer) {
          LogUtil.info(`${TAG} change display start: ${id}`);
          this.onDisplayChange(id);
          this.timer = setTimeout(() => {
            clearTimeout(this.timer);
            this.timer = undefined;
          }, 50);
        }
        LogUtil.info(`${TAG} foldable onChange end`);
      });
      display.on('foldStatusChange', (foldStatus: display.FoldStatus) => {
        LogUtil.info(`${TAG} on foldStatusChange : ${foldStatus}`);
        if (this.foldStatus !== display.FoldStatus.FOLD_STATUS_EXPANDED && !this.hasDisplayC()) {
          this.onFoldStatusWithKeyBoard();
        }
        EventBus.getInstance().emit(FOLD_STATUS_CHANGE);
        LogUtil.info(`${TAG} on foldStatusChange end`);
      });
      this.isStartFoldableService = true;
    } catch (error) {
      LogUtil.error(`${TAG} startFoldableService error code: ${error?.code} - message: ${error?.message}`);
    }
  }

  /**
   * 专用于可折叠设备悬停态盖键盘的场景
   */
  private onFoldStatusWithKeyBoard() {
    try {
      let mainIndex = this.devices.findIndex((d) => {
        return d.deviceUserFor === DeviceUserType.MAIN_SCREEN;
      });
      if (mainIndex === -1) {
        LogUtil.error(`${TAG} foldStatusChange find main_screen error`);
        return;
      }
    } catch (error) {
      LogUtil.error(`${TAG} foldStatusChange error code: ${error?.code} - message: ${error?.message}`);
      return;
    }
  }

  private onFoldStatusChange(foldStatus: display.FoldStatus) {
    let previousFoldStatus = this.foldStatus;
    this.foldStatus = foldStatus;
    LogUtil.info(`${TAG} foldStatusChange previousFoldStatus:${previousFoldStatus} currentfoldStatus:${foldStatus}`);
    let mainIndex = this.devices.findIndex((d) => {
      return d.deviceUserFor === DeviceUserType.MAIN_SCREEN;
    });
    if (mainIndex === -1) {
      LogUtil.error(`${TAG} foldStatusChange find main_screen error`);
      return;
    }
    this.setSettingsData(true);
    EventBus.getInstance().emit(FOLD_STATUS_CHANGE);
    if (this.foldStatus !== previousFoldStatus) {
      EventBus.getInstance().emit('deviceInfoChangePositions');
    }
    this.handleChangeEvent(true, false, false);
  }

  private onDisplayChange(id: number) {
    let deviceIndex = this.devices.findIndex((d) => {
      return d.key === id;
    });
    if (deviceIndex === -1) {
      LogUtil.error(`${TAG} displayChange find device error`);
      return;
    }
    try {
      let changeDisplay = display.getDisplayByIdSync(id);
      let changeDevice = DeviceInfo.createDeviceInfoByDisplay(changeDisplay, this.devices[deviceIndex].key,
        this.devices[deviceIndex].deviceUserFor, this.devices[deviceIndex].serialNumber!);
      if (changeDevice !== undefined) {
        this.devices[deviceIndex] = changeDevice;
        LogUtil.info(`${TAG} this.devices[${deviceIndex}] changed`);
      } else {
        LogUtil.error(`${TAG} change device error`);
      }
      if (this.currentDevice?.key === id) {
        this.currentDevice = this.devices[deviceIndex];
        this.handleChangeEvent(false, false, true);
      }
      this.setSettingsData(true);
      this.handleChangeEvent(true, false, false);
      this.onFoldStatusChange(display.getFoldStatus());
      // 存在扩展模式设备
      let extendDevice = this.devices.find((d) => d.deviceUserFor === DeviceUserType.EXTENDED);
      if (extendDevice) {
        LogUtil.info(`${TAG} device exist extended, positions init`);
        EventBus.getInstance().emit('positions_init');
      }
      DragController.getInstance().setRemoteDevicePosition();
      EventBus.getInstance().emit('ImageListDeviceLocationOrderChange');
    } catch (error) {
      LogUtil.error(`${TAG} displayChange error code: ${error.code} - message: ${error.message}`);
    }
  }

  public getDevices(): DeviceInfo[] {
    return this.devices;
  }

  public getCurrentDevice(): DeviceInfo {
    let device = this.devices.find((d) => d.key === this.currentDevice.key);
    // 确保当前设备属于已构建的设备信息
    if (device) {
      this.currentDevice = device;
    } else {
      this.currentDevice = this.devices[0];
    }
    return this.currentDevice;
  }

  public getLocalDeviceCount(): number {
    return this.localDeviceCount;
  }

  public getOtherDeviceCount(): number {
    return this.otherDeviceCount;
  }

  /**
   * 启动设备监听服务
   */
  public startService(): void {
    if (this.isStartService) {
      return;
    }
    screen.on('connect', (id: number) => {
      LogUtil.info(`${TAG} onConnect start device: ${id}`);
      this.onScreenConnect(id);
      LogUtil.info(`${TAG} onConnect end`);
    });
    screen.on('disconnect', (id: number) => {
      LogUtil.info(`${TAG} onDisConnect start device: ${id}`);
      this.onScreenDisconnect(id);
      LogUtil.info(`${TAG} onDisConnect end`);
    });
    screen.on('change', (id: number) => {
      LogUtil.info(`${TAG} onChange start device: ${id}`);
      this.onScreenChange(id);
      LogUtil.info(`${TAG} onChange end`);
    });
    display.on('add', (id: number) => {
      LogUtil.info(`${TAG} display onAdd start device: ${id}`);
      if (this.isExternalMonitorID(id)) {
        this.screensCountChange();
      }
    })
    display.on('remove', (id: number) => {
      LogUtil.info(`${TAG} display onRemove start device: ${id}`);
      if (this.isExternalMonitorID(id)) {
        this.screensCountChange();
      }
    })
    this.isStartService = true;
  }

  public stopService(): void {
    if (this.isFoldablePC()) {
      this.isStartFoldableService = false;
      try {
        display.off('change', () => {
          LogUtil.info(`${TAG} foldable onChange off`);
        });
        display.off('foldStatusChange', () => {
          LogUtil.info(`${TAG} on foldStatusChange off`);
        });
      } catch (error) {
        LogUtil.error(`${TAG} stopFoldableService error code: ${error.code} - message: ${error.message}`);
      }
    }
    this.isStartService = false;
    screen.off('connect', () => {
      LogUtil.info(`${TAG} onConnect end`);
    });
    screen.off('disconnect', () => {
      LogUtil.info(`${TAG} onDisConnect end`);
    });
    screen.off('change', () => {
      LogUtil.info(`${TAG} onChange end`);
    });
    display.off('remove', () => {
      LogUtil.info(`${TAG} display onRemove end`);
    });
    display.off('add', () => {
      LogUtil.info(`${TAG} display onAdd end`);
    })
  }

  /**
   * 根据当前设备连接状况动态修改搜索项使能
   * @param status 使能状态
   */
  private searchStatusChange(status: boolean) {
    SEARCH_ITEMS.forEach((itemName) => {
      LogUtil.info(`${TAG} search item: ${itemName} change status: ${status}`);
      SearchDataController.getInstance().updateSearchItemStatus(itemName, status);
    });
    if (this.isFoldablePC()) {
      SearchDataController.getInstance().updateSearchItemStatus('display_use_as_foldable', status);
    } else {
      SearchDataController.getInstance().updateSearchItemStatus('display_use_as', status);
    }
  }

  /**
   * 屏幕数量变化处理（一般用于拔插、开合盖场景）
   */
  private screensCountChange() {
    let isExtended: boolean = false;
    screen.getAllScreens((err, allScreens) => {
      if (err.code !== 0) {
        LogUtil.error(`${TAG} get all screens error code: ${err.code} - message: ${err.message}`);
        return;
      }
      LogUtil.info(`${TAG} screens count change: ${allScreens.length}`);
      allScreens.forEach((newScreen) => {
        if (this.isExternalMonitorID(newScreen.id)) {
          try {
            let newDisplay = display.getDisplayByIdSync(newScreen.id);
            let mode = this.getRealMode(newScreen, allScreens);
            LogUtil.info(`${TAG} get newDevice mode: ${mode}`);
            let newDevice = DeviceInfo.createDeviceInfoByDisplay(
              newDisplay, newScreen.rsId, mode, newScreen.serialNumber!);
            if (newDevice) {
              let index = this.devices.findIndex((device) => device.key === newDevice?.key);
              if (index !== -1) {
                this.devices[index] = newDevice;
              }
              if (this.currentDevice.key === newDevice.key) {
                this.currentDevice = newDevice;
              }
            } else {
              LogUtil.error(`${TAG} create new device error`);
            }
            if (mode === DeviceUserType.EXTENDED) {
              isExtended = true;
            }
          } catch (err) {
            LogUtil.error(`${TAG} create device info error: ${err?.code} - ${err?.message}`);
          }
        }
      })
      if (isExtended) {
        LogUtil.info(`${TAG} push device extended, positions init`);
        EventBus.getInstance().emit('positions_init');
      }
      // screens中不存在当前设备（即内置屏不存在时），需要变更当前设备信息
      if (!(allScreens.find((s) => s.rsId === this.currentDevice.key))) {
        let exDevice = this.devices.find((device) =>
        device.deviceType !== DeviceDisplayType.BUILTIN && device.deviceType !== DeviceDisplayType.OTHERS);
        if (exDevice) {
          this.currentDevice = exDevice;
        }
      }
      this.checkDevice();
      this.handleChangeEvent(true, false, false);
      EventBus.getInstance().emit('ImageListDeviceLocationOrderChange');
    })
  }

  /**
   * 连接外接设备，添加设备信息
   * @param id 设备id
   */
  public onScreenConnect(id: number): void {
    try {
      let settingsData = SettingsDataUtils.getSettingsDataDomain(USER_SET_DEVICE_MODE,
        '', DOMAIN_NAME);
      if (settingsData !== '') {
        this.deviceDataList = JSON.parse(settingsData);
      }
    } catch (error) {
      LogUtil.error(`${TAG} parse error code: ${error.code} - message: ${error.message}`);
    }
    LogUtil.info(`${TAG} start add device`);
    if (!this.isExternalMonitorID(id)) {
      LogUtil.error(`${TAG} it's not approved device`);
      return;
    }
    screen.getAllScreens((err, allScreens) => {
      if (err?.code !== 0) {
        LogUtil.error(`${TAG} get all screens error: ${err.code}`);
        return;
      }
      allScreens.forEach((newScreen) => {
        // 当前连接设备信息 || 内置屏信息 更新
        if (newScreen.id === id || newScreen.rsId === 0) {
          let newDisplay = display.getDisplayByIdSync(id);
          let mode: number = this.getRealMode(newScreen, allScreens);
          LogUtil.info(`${TAG} get new device mode: ${mode}`);
          let newDevice = DeviceInfo.createDeviceInfoByDisplay(
            newDisplay, newScreen.rsId, mode, newScreen.serialNumber!);
          if (newDevice) {
            let index = this.devices.findIndex((d) => d.key === newScreen.rsId);
            // 内置屏下标
            let mainIndex = this.devices.findIndex((d) => d.deviceType === DeviceDisplayType.BUILTIN);
            if (index === -1 || index >= this.devices.length) {
              // 从内置屏后插入
              this.devices.splice(mainIndex + 1, 0, newDevice);
            } else {
              this.devices[index] = newDevice;
            }
            if (newScreen.rsId === 0) {
              LogUtil.info(`${TAG} refresh built_in device info`);
              return;
            }
            if (mode === DeviceUserType.ONLY_SCREEN) {
              this.currentDevice = newDevice;
            }
            HiSysEventUtil.reportDefaultBehaviorEventByUE(USER_CONNECT_DEVICE_EVENT,
              `${newDevice.deviceUserFor}-${newDevice.serialNumber}-${newDevice.name}`);
            this.pushBuiltIn();
            this.checkDevice();
            this.setSettingsData(true);
            if (mode === DeviceUserType.EXTENDED || mode === DeviceUserType.MAIN_SCREEN) {
              LogUtil.info(`${TAG} add device extended, positions init`);
              EventBus.getInstance().emit('positions_init');
            }
            this.handleChangeEvent(true, true, false);
          } else {
            LogUtil.error(`${TAG} create new device error`);
          }
        }
      });
      EventBus.getInstance().emit('deviceInfoChangePositions');
    });
  }

  /**
   * 拔出设备，移除该设备信息
   * @param id 设备信息
   */
  public onScreenDisconnect(id: number): void {
    LogUtil.info(`${TAG} start remove device`);
    if (!this.isExternalMonitorID(id)) {
      LogUtil.error(`${TAG} it's not approved device`);
      return;
    }
    let index = this.devices.findIndex((d) => {
      return d.key === id;
    });
    try {
      if (index !== -1 && index < this.devices.length) {
        let removeId = this.devices[index].key;
        LogUtil.info(`${TAG} remove devices id: ${removeId}`);
        this.setSettingsData(true); //////移除之前，设备信息保存到数据库持久化
        HiSysEventUtil.reportDefaultBehaviorEventByUE(USER_CONNECT_DEVICE_EVENT,
          `0-${this.devices[index].serialNumber}-${this.devices[index].name}`);
        this.devices.splice(index, 1);
        this.checkDevice();
        DragController.getInstance().initPositions();
        // 移除的设备为当前设备时，当前设备变更
        if (this.currentDevice?.key === removeId) {
          this.currentDevice = this.devices[0];
          this.handleChangeEvent(true, true, false);
        } else {
          this.handleChangeEvent(false, true, false);
        }
      } else {
        LogUtil.error(`${TAG} remove device id is nonexistent`);
      }
      EventBus.getInstance().emit('deviceInfoChangePositions');
    } catch (err) {
      LogUtil.error(`${TAG} remove device error: ${err?.code}`);
    }
  }

  /**
   * 设备改变(屏幕转向、DPI修改等)
   * @param id 设备id
   */
  public onScreenChange(id: number): void {
    try {
      let settingsData = SettingsDataUtils.getSettingsDataDomain(USER_SET_DEVICE_MODE,
        '', DOMAIN_NAME);
      if (settingsData !== '') {
        this.deviceDataList = JSON.parse(settingsData);
      }
    } catch (error) {
      LogUtil.error(`${TAG} parse error code: ${error.code} - message: ${error.message}`);
    }
    if (!this.isExternalMonitorID(id)) {
      LogUtil.error(`${TAG} not allowed screen change`);
      return;
    }
    screen.getAllScreens((err, allScreens) => {
      if (err.code !== 0) {
        LogUtil.error(`${TAG} get all screens error: ${err.code}`);
        return;
      }
      allScreens.forEach((newScreen) => {
        try {
          if (this.isExternalMonitorID(newScreen.id)) {
            let newDisplay = display.getDisplayByIdSync(newScreen.id);
            let mode = this.getRealMode(newScreen, allScreens);
            LogUtil.info(`${TAG} refresh device data change mode: ${mode}`);
            let newDevice = DeviceInfo.createDeviceInfoByDisplay(
              newDisplay, newScreen.rsId, mode, newScreen.serialNumber!);
            let deviceIndex = this.devices.findIndex((d) => d.key === newScreen.rsId);
            if (newDevice && deviceIndex !== -1) {
              this.devices[deviceIndex] = newDevice;
            } else {
              LogUtil.error(`${TAG} create new device error`);
            }
          }
          if (this.currentDevice?.key === newScreen.rsId) {
            let currentDeviceIndex = this.devices.findIndex((d) => d.key === newScreen.rsId);
            if (currentDeviceIndex !== -1) {
              this.currentDevice = this.devices[currentDeviceIndex];
            }
            this.handleChangeEvent(true, false, true);
          }
        } catch (err) {
          LogUtil.error(`${TAG} change device error: ${err?.code}`);
        }
      });
      this.pushBuiltIn();
      this.setSettingsData(true);
      EventBus.getInstance().emit('deviceInfoChangePositions');
    });
  }

  /**
   * 初始化设备列表 以及 当前选中设备信息
   *
   * @param refresh true = 重启强制页面刷新 false = 例外刷新，不改变当前设备
   */
  public async initDevices(refresh: boolean = true): Promise<void> {
    LogUtil.info(`${TAG} start init devices`);
    await screen.getAllScreens().then((newScreens) => {
      this.pushDevices(newScreens);
      LogUtil.info(`${TAG} init ${this.devices.length} devices`);
      // 外部跳转到扩展屏页面
      let isExternalDevice: boolean = (AppStorage.get<Want>('wantParams') as Want).parameters?.externalDevice as boolean ?? false;
      let extendDeviceIndex = this.devices.findIndex((d) =>
        d.deviceType === DeviceDisplayType.EXTENDED || d.deviceType === DeviceDisplayType.MIRROR);
      if (extendDeviceIndex !== -1 && isExternalDevice) {
        // 存在扩展屏且外部跳转时，当前设备为扩展屏
        this.currentDevice = this.devices[extendDeviceIndex];
      } else {
        this.currentDevice = refresh ? this.devices[0] : this.currentDevice ?? this.devices[0];
      }
      this.checkDevice();
      this.handleChangeEvent(true, true, false);
      LogUtil.info(`create currentDevice: ${this.currentDevice.key}`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} get all displays error: ${err.code}`);
      return;
    });
  }

  private pushDevices(allScreens: screen.Screen[]): void {
    this.devices = [];
    let isExtended: boolean = false;
    LogUtil.info(`${TAG} satrt push devices`);
    allScreens.forEach((newScreen) => {
      if (this.isExternalMonitorID(newScreen.id)) {
        let newDisplay = display.getDisplayByIdSync(newScreen.id);
        let mode = this.getRealMode(newScreen, allScreens);
        LogUtil.info(`${TAG} push newDevice mode: ${mode}`);
        let newDevice = DeviceInfo.createDeviceInfoByDisplay(
          newDisplay, newScreen.rsId, mode, newScreen.serialNumber!);
        if (newDevice) {
          this.devices.push(newDevice);
        } else {
          LogUtil.error(`${TAG} create new device error`);
        }
        LogUtil.info(`${TAG} get new device end`);
        if (mode === DeviceUserType.EXTENDED) {
          isExtended = true;
        }
      }
    });
    this.pushBuiltIn();
    this.setSettingsData(true);
    if (isExtended) {
      LogUtil.info(`${TAG} push device extended, positions init`);
      DragController.getInstance();
      EventBus.getInstance().emit('positions_init');
    }
  }

  // 判断是否是外接显示器id
  private isExternalMonitorID(id: number | string): boolean {
    // 目前接口会监听到 录屏 等行为创建的 虚拟屏 接入，具体数据也会混在一起
    // 为确保接入并获取的是外部显示器信息，暂时通过id进行判断，后续会跟进底层接口进行更改
    // 0为内置显示器 ， 1为录屏的残留数据 ， 1000及以上为录屏产生的虚拟屏
    if (typeof id === 'number') {
      return id < DISPLAY_ID_ENABLE && id >= 0;
    }
    return true;
  }

  /**
   * 改变当前选中设备信息
   * @param id 设备id
   */
  public onChangeCurrentDevice(id: number | string): void {
    if (id === null || id === undefined || !this.isExternalMonitorID(id)) {
      LogUtil.error(`${TAG} id is unacceptably`);
      return;
    }
    let device = this.devices.find((d) => d.key === id) as DeviceInfo;
    if (device) {
      this.currentDevice = device;
      LogUtil.info(`${TAG} current device: ${this.currentDevice.key}`);
      this.handleChangeEvent(true, false, false);
    } else {
      LogUtil.error(`${TAG} there is no such device`);
    }
  }

  /**
   * 设备变更事件通知统一处理
   * @param currentChange 当前选中设备是否变化
   * @param devicesChange 当前设备列表是否变化
   * @param attributeChange 当前设备属性是否变化
   */
  public handleChangeEvent(currentChange: boolean, devicesChange: boolean, attributeChange: boolean): void {
    LogUtil.info(`${TAG} current device change: ${currentChange} | devices change: ${devicesChange} | device info change: ${attributeChange}`);
    if (this.onCurrentDeviceChange && currentChange) {
      SettingsDataUtils.setSettingsDataAsync('display_current_device_id', String(this.currentDevice?.key), DOMAIN_NAME);
      this.onCurrentDeviceChange(this.currentDevice as DeviceInfo);
    }
    if (this.onDevicesChange && devicesChange) {
      this.onDevicesChange(this.devices, true);
    }
    if (this.deviceChangeEvent && attributeChange) {
      this.deviceChangeEvent();
    }
  }

  /**
   * 检查设备列表
   */
  public checkDevice(): void {
    this.otherDeviceCount = this.devices.filter((device) => {
      return device.deviceType === DeviceDisplayType.OTHERS;
    }).length;
    this.localDeviceCount = this.devices.length - this.otherDeviceCount;
    DragController.getInstance().setDeviceLocationOrder(this.devices.map((item) => item.key));
    this.searchStatusChange(this.localDeviceCount > 1);
    SearchDataController.getInstance().updateSearchItemStatus('location_set',
      this.localDeviceCount > 1 || this.otherDeviceCount > 0);
    LogUtil.info(`${TAG} current localDeviceCount: ${this.localDeviceCount} | hasOtherDevice: ${this.otherDeviceCount}`);
  }

  /**
   * 将当前设备信息保存到数据库中
   * 信息如：屏幕ID、屏幕模式
   * @param screenConnect 屏幕连接场景 选填 默认为false
   */
  public setSettingsData(screenConnect: boolean = false) {
    // 保存当前内置屏设备信息
    let builtInDevice = this.devices.find((d) => d.deviceType === DeviceDisplayType.BUILTIN);
    SettingsDataUtils.setSettingsDataAsync('use_built_in_device', JSON.stringify(builtInDevice), DOMAIN_NAME);
    // 多设备情况下必须确保存在一个主显示器
    let mainDevice = this.devices.find((d) => d.deviceUserFor === DeviceUserType.MAIN_SCREEN ||
      d.deviceUserFor === DeviceUserType.ONLY_SCREEN);
    if (!mainDevice && this.localDeviceCount > 1) {
      LogUtil.info(`${TAG} main screen is not exist, the default is the build_in`);
      this.devices[0].deviceUserFor = DeviceUserType.MAIN_SCREEN;
    }
    LogUtil.info(`${TAG} setSettingsData devices length: ${this.devices.length}`);
    this.devices.forEach((d) => {
      let index = this.deviceDataList.findIndex((data) => Number(data.split(' ')[0]) === d.key);
      let dataStr = `${d.key} ${d.deviceUserFor}`;
      if (index !== -1) {
        this.deviceDataList[index] = dataStr;
      } else {
        this.deviceDataList.push(dataStr);
      }
      if (d.key !== 0) {
        // 保存当前连接显示器的信息，作为外接屏标识
        let setDeviceInfo = `${d.key}`;
        let connectIndex = this.connectDeviceInfoList.findIndex((data) => {
          return data.split(' ')[0] === String(d.key);
        })
        if (connectIndex !== -1) {
          this.connectDeviceInfoList[connectIndex] = setDeviceInfo;
        } else {
          this.connectDeviceInfoList.push(setDeviceInfo);
        }
      }
    });
    SettingsDataUtils.setSettingsDataAsync(USER_SET_DEVICE_MODE, JSON.stringify(this.deviceDataList), DOMAIN_NAME);
    SettingsDataUtils.setSettingsDataAsync(USER_SET_DEVICE,
      JSON.stringify(this.connectDeviceInfoList), DOMAIN_NAME);
    this.setSettingsEDIDMode(screenConnect);
  }

  /**
   * EDID字段保存, 结构为SN号;内屏模式 外屏模式;内屏方位;外屏方位
   * @param screenConnect 屏幕连接场景 默认为false
   */
  private setSettingsEDIDMode(screenConnect: boolean = false) {
    let builtinDevice = this.devices.find((d) => d.deviceType === DeviceDisplayType.BUILTIN);
    LogUtil.info(`${TAG} setSettingsDataMode devices length: ${this.devices.length}`);
    this.devices.forEach((d) => {
      let dataKey = d.serialNumber;
      let mode = d.deviceUserFor === DeviceUserType.ONLY_SCREEN ? 0 : d.deviceUserFor;
      let dataMode = `${builtinDevice?.deviceUserFor} ${mode}`;
      let dataIndex = this.deviceEDIDList.findIndex((data) => data.split(DELIMITER)[0] === dataKey);
      if (dataIndex !== -1) {
        if (screenConnect) { // 屏幕插入场景，且已存在该数据，不做数据库修改
          LogUtil.error(`${TAG} screen connect but key existed`);
          return;
        }
        let dataStr = this.deviceEDIDList[dataIndex].split(DELIMITER);
        if (dataStr.length <= 1) {
          LogUtil.error(`${TAG} dataStr has no mode`);
          dataStr.push(dataMode);
        } else {
          dataStr[1] = dataMode;
        }
        this.deviceEDIDList[dataIndex] = dataStr.join(DELIMITER);
      } else if (d.deviceType === DeviceDisplayType.EXTENDED) {
        let dataStr = `${dataKey};${dataMode}`;
        // 超出预存长度，删掉最早的记录
        if (this.deviceEDIDList.length >= MAX_DATALIST_LEN) {
          this.deviceEDIDList.splice(0, 1);
        }
        this.deviceEDIDList.push(dataStr);
      }
    });
    SettingsDataUtils.setSettingsDataAsync(
      USER_SET_DEVICE_MODE_EDID, JSON.stringify(this.deviceEDIDList), DOMAIN_NAME
    );
  }

  private pushBuiltIn() {
    try {
      LogUtil.info(`${TAG} push built in start`);
      let builtInDevice: DeviceInfo = JSON.parse(
        SettingsDataUtils.getSettingsData('use_built_in_device', JSON.stringify(this.currentDevice), DOMAIN_NAME)
      );
      LogUtil.info(`${TAG} get built in device: ${builtInDevice.deviceType} - ${builtInDevice.deviceUserFor}`);
      if (!this.devices.find((d) => d.key === builtInDevice.key)) {
        LogUtil.info(`${TAG} push built in device`);
        builtInDevice.deviceUserFor = DeviceUserType.MAIN_SCREEN;
        builtInDevice.name = $r('app.string.display_machine');
        this.devices.push(builtInDevice);
      }
    } catch (error) {
      LogUtil.error(`${TAG} get built in device error: ${error?.code}`);
    }
  }

  public setCurrentDeviceData() {
    SettingsDataUtils.setSettingsDataAsync('display_current_device_id', String(this.currentDevice?.key), DOMAIN_NAME);
  }

  listenCurrentDeviceChange(handle: (device: DeviceInfo) => void, event?: () => void): void {
    this.onCurrentDeviceChange = handle;
    this.deviceChangeEvent = event;
  }

  listenDevicesChange(handle: (devices: DeviceInfo[], refresh: boolean) => void): void {
    this.onDevicesChange = handle;
  }

  /**
   * 切换设备模式
   * @param mainId 用作主屏设备id
   * @param secondId 用作副屏设备id
   * @param currentMode 副屏设备应用模式
   */
  public onDeviceModeChange(mainId: number, secondId: number, currentMode: DeviceUserType): void {
    try {
      this.devices.forEach((d) => {
        LogUtil.info(`${TAG} create device id: ${d.key} - type: ${d.deviceUserFor} before`);
        if (d.deviceType === DeviceDisplayType.OTHERS) {
          d.deviceUserFor = DeviceUserType.OTHERS;
          return;
        }
        if (d.key === mainId) {
          // 主屏设备切换为主显示器
          d.deviceUserFor = DeviceUserType.MAIN_SCREEN;
        } else if (d.key === secondId || currentMode === DeviceUserType.ONLY_SCREEN) {
          // 副屏设备切换为当前模式 或 当前模式为仅一屏模式
          d.deviceUserFor = currentMode;
        }
        if (d.key === this.currentDevice?.key) {
          // 当前选中展示设备更新
          this.currentDevice = d;
        }
      });
      LogUtil.info(`${TAG} after current device : ${this.currentDevice?.key} - ${this.currentDevice?.deviceUserFor}`);
      this.handleChangeEvent(true, false, true);
      this.setSettingsData();
      HiSysEventUtil.reportDefaultBehaviorEventByUE(USER_MODE_CHANGE_EVENT, JSON.stringify({
        main: mainId + '-0',
        second: secondId + '-' + currentMode
      }));
      setTimeout(() => {
        let currentScreenMode: screen.MultiScreenMode = currentMode === DeviceUserType.MIRROR ?
        screen.MultiScreenMode.SCREEN_MIRROR : screen.MultiScreenMode.SCREEN_EXTEND;
        screen.setMultiScreenMode(mainId as number, secondId as number, currentScreenMode);
        RemoteDevicesController.getInstance().setScreenSourceMode(currentScreenMode);
        if (currentScreenMode === screen.MultiScreenMode.SCREEN_EXTEND && mainId !== secondId) {
          LogUtil.info(`${TAG} positions init info`);
          EventBus.getInstance().emit('positions_init', true);
        }
      }, 150);
    } catch (e) {
      LogUtil.error(`${TAG} set mode error`);
    }
  }

  /**
   * 可折叠设备切换设备模式
   * @param mainId 用作主屏设备id
   * @param secondId 用作副屏设备id
   * @param currentMode 副屏设备应用模式
   */
  public onFoldableDeviceModeChange(mainId: number, secondId: number, currentMode: DeviceUserType): void {
    try {
      this.setCurrentMode(currentMode, mainId, secondId);
      let currentScreenMode: screen.MultiScreenMode = currentMode === DeviceUserType.EXTENDED ?
      screen.MultiScreenMode.SCREEN_EXTEND : screen.MultiScreenMode.SCREEN_MIRROR;
      LogUtil.info(`${TAG} set foldable device mode: ${currentMode}`);
      RemoteDevicesController.getInstance().setScreenSourceMode(currentScreenMode);
      this.devices.forEach((device) => {
        if (device.key === mainId) {
          // 主屏设备切换为主显示器
          device.deviceUserFor = DeviceUserType.MAIN_SCREEN;
        } else if (device.key === secondId) {
          // 副屏设备切换为当前模式
          device.deviceUserFor = currentMode;
        }
        if (device.key === this.currentDevice?.key) {
          // 当前选中展示设备更新
          this.currentDevice = device;
        }
      });
      LogUtil.info(`${TAG} after current device : ${this.currentDevice?.key} - ${this.currentDevice?.deviceUserFor}`);
      this.handleChangeEvent(true, false, true);
      this.setSettingsData();
      HiSysEventUtil.reportDefaultBehaviorEventByUE(USER_MODE_CHANGE_EVENT, JSON.stringify({
        main: mainId + '-0',
        second: secondId + '-' + currentMode
      }));
      if (currentMode === DeviceUserType.EXTENDED) {
        LogUtil.info(`${TAG} positions init info`);
        EventBus.getInstance().emit('positions_init', true);
      }
    } catch (error) {
      LogUtil.error(`${TAG} onFoldableDeviceModeChange error code: ${error.code} - message: ${error.message}`);
    }
  }

  private setCurrentMode(currentMode: DeviceUserType, mainId: number, secondId: number) {
    try {
      if (currentMode !== DeviceUserType.EXTENDED) { // 选择模式暂不考虑主副屏的情况，要么镜像，要么扩展
        let mainScreenDevice = this.devices.find((d) => { return d.deviceUserFor === DeviceUserType.MAIN_SCREEN;});
        if (mainScreenDevice === undefined) {
          LogUtil.error(`${TAG} find mainScreenDevice error`);
          return;
        }
        let result: Record<string, number> = this.getWidthHeight();
        let rect: display.Rect = {left: 0, top: 0, width: result['width'], height: result['height']};//默认半屏尺寸
        switch (currentMode) {
          case DeviceUserType.MIRROR_TO_B:
            screen.makeMirrorWithRegion(mainScreenDevice?.key as number, [secondId as number], rect);
            LogUtil.info(`${TAG} MIRRORToB`);
            break;
          case DeviceUserType.MIRROR_TO_C:
            rect.top = rect.height;
            screen.makeMirrorWithRegion(mainScreenDevice?.key as number, [secondId as number], rect);
            LogUtil.info(`${TAG} MIRRORToC`);
            break;
          case DeviceUserType.MIRROR:
            LogUtil.info(`${TAG} set multi screen mode with SCREEN_MIRROR`);
            screen.setMultiScreenMode(mainId as number, secondId as number, screen.MultiScreenMode.SCREEN_MIRROR);
            break;
          default:
            screen.makeMirrorWithRegion(mainScreenDevice?.key as number, [secondId as number], rect);
            LogUtil.info(`${TAG} default MIRRORToB`);
            break;
        }
      } else {
        LogUtil.info(`${TAG} set multi screen mode with SCREEN_EXTEND`);
        screen.setMultiScreenMode(mainId as number, secondId as number, screen.MultiScreenMode.SCREEN_EXTEND);
      }
    } catch (error) {
      LogUtil.error(`${TAG} makeCurrentMode error code: ${error.code} - message: ${error.message}`);
    }
  }

  public refreshDevices(remoteDevices: RemoteDeviceInfo[]): void {
    LogUtil.showInfo(TAG, `refreshDevices start`);
    this.devices = this.devices.filter((deviceItem: DeviceInfo) => deviceItem.deviceType !== DeviceDisplayType.OTHERS);
    const tempDevice: DeviceInfo[] = [];
    for (const device of remoteDevices) {
      if (device.isLocalDevice) {
        tempDevice.push(...this.devices);
      } else {
        const addDevice: DeviceInfo = new DeviceInfo(device.mDeviceId, device.mDeviceName,
          DeviceDisplayType.OTHERS, DEFAULT_CARD_WIDTH, DEFAULT_CARD_HEIGHT);
        addDevice.wallpaper = $r('app.media.keymouse_wallpaper');
        addDevice.deviceUserFor = DeviceUserType.OTHERS;
        addDevice.deviceModel = device.mDeviceType;
        this.setDeviceSizeByDeviceType(device, addDevice)
        tempDevice.push(addDevice);
      }
    }
    this.devices = tempDevice;
    if (!this.devices.some((item) => item.key === this.currentDevice?.key)) {
      this.currentDevice = this.devices.find((item) => item.deviceUserFor === DeviceUserType.MAIN_SCREEN) as DeviceInfo;
      this.handleChangeEvent(true, false, false);
    }
    this.checkDevice();
    DragController.getInstance().initPositions();
    if (this.onDevicesChange) {
      this.onDevicesChange(this.devices, false);
    }
    EventBus.getInstance().emit('deviceInfoChangePositions');
  }

  public setDeviceSizeByDeviceType(remoteDevice: RemoteDeviceInfo, imageDevice: DeviceInfo): void {
    const defaultDisplay: display.Display = this.getDefaultDisplay();
    if (this.isFoldablePC() && this.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED &&
      defaultDisplay.width < defaultDisplay.height) {
      defaultDisplay.height = defaultDisplay.height / 2;
    }
    switch (remoteDevice.mDeviceType) {
      case DeviceType.TYPE_PC:
      case DeviceType.TYPE_2IN1:
        imageDevice.width = defaultDisplay.width;
        imageDevice.height = defaultDisplay.height;
        imageDevice.physicalWidth = INCH_TO_MM * defaultDisplay.width / defaultDisplay.xDPI;
        imageDevice.physicalHeight = INCH_TO_MM * defaultDisplay.height / defaultDisplay.yDPI;
        break;
      case DeviceType.TYPE_PHONE:
        imageDevice.height = defaultDisplay.height * 0.875;
        imageDevice.width = imageDevice.height * 0.5;
        imageDevice.physicalWidth = INCH_TO_MM * imageDevice.height / defaultDisplay.xDPI * 0.5;
        imageDevice.physicalHeight = INCH_TO_MM * defaultDisplay.height / defaultDisplay.yDPI * 0.875;
        break;
      case DeviceType.TYPE_TABLET:
        imageDevice.width = defaultDisplay.width * 0.875;
        imageDevice.height = defaultDisplay.height * 0.875;
        imageDevice.physicalWidth = INCH_TO_MM * defaultDisplay.width / defaultDisplay.xDPI * 0.875;
        imageDevice.physicalHeight = INCH_TO_MM * defaultDisplay.height / defaultDisplay.yDPI * 0.875;
        break;
      default:
        imageDevice.width = defaultDisplay.width;
        imageDevice.height = defaultDisplay.height;
        imageDevice.physicalWidth = INCH_TO_MM * defaultDisplay.width / defaultDisplay.xDPI;
        imageDevice.physicalHeight = INCH_TO_MM * defaultDisplay.height / defaultDisplay.yDPI;
        break;

    }
  }

  private setDefaultDisplay(): void {
    LogUtil.showInfo(TAG, `setDefaultDisplay`);
    try {
      this.defaultDisplay = display.getDefaultDisplaySync();
    } catch (e) {
      LogUtil.error(`${TAG} get DefaultDisplaySync error`);
    }
  }

  /**
   * 获取本机display对象
   * @returns
   */
  public getDefaultDisplay(): display.Display {
    if (this.defaultDisplay === undefined) {
      this.setDefaultDisplay();
      return display.getDefaultDisplaySync();
    }
    return this.defaultDisplay;
  }

  public getDeviceEDIDList(): string[] {
    return this.deviceEDIDList;
  }

  /**
   * 查询C面是否存在
   * @returns
   */
  public hasDisplayC(): boolean {
    try {
      let bottomDisplay = display.getDisplayByIdSync(DISPLAY_ID_ENABLE);
      if (bottomDisplay.id === DISPLAY_ID_ENABLE) {
        LogUtil.info(`${TAG} Has C Display`);
      }
      return bottomDisplay.id === DISPLAY_ID_ENABLE;
    } catch (error) {
      LogUtil.error(`${TAG} isHasCDisplay error code: ${error.code} - message: ${error.message}`);
      return false;
    }
  }

  /**
   * 实际设备模式和镜像类型下发
   * @param id 外接屏ID
   * @param mode 设备模式
   */
  public setDeviceMode(id : number, mode : DeviceUserType) {
    try {
      let mainScreenDevice = this.devices.find((d)=>{ return d.deviceUserFor === DeviceUserType.MAIN_SCREEN });
      if (mainScreenDevice === undefined) {
        LogUtil.error(`${TAG} makeDeviceMode find mainScreenDevice error`);
        return;
      }
      if (!this.isFoldablePC()) { //用于harden设备的模式下发
        let currentScreenMode: screen.MultiScreenMode = mode === DeviceUserType.MIRROR ?
        screen.MultiScreenMode.SCREEN_MIRROR : screen.MultiScreenMode.SCREEN_EXTEND;
        LogUtil.info(`${TAG} set device mode: ${mode}`);
        screen.setMultiScreenMode(mainScreenDevice?.key as number, id as number, currentScreenMode);
        return;
      }
      this.setMode(mainScreenDevice, mode, id);
    } catch (error) {
      LogUtil.error(`${TAG} makeDeviceMode error code: ${error.code} - message: ${error.message}`);
      return;
    }
  }

  private setMode(mainScreenDevice: DeviceInfo, mode: DeviceUserType, id: number) {
    try {
      let result = this.getWidthHeight();
      let rect: display.Rect = {left: 0, top: 0, width: result['width'], height: result['height']};//默认半屏尺寸
      if (mode !== DeviceUserType.EXTENDED) {
        if (this.foldStatus === display.FoldStatus.FOLD_STATUS_EXPANDED) {
          screen.setMultiScreenMode(mainScreenDevice?.key as number, id, screen.MultiScreenMode.SCREEN_MIRROR);
          LogUtil.info(`${TAG} makeMode setMultiScreenMode full for display ${id}`);
        } else if (this.hasDisplayC() && mode === DeviceUserType.MIRROR_TO_C) {
          rect.top = rect.height;
          screen.makeMirrorWithRegion(mainScreenDevice?.key as number, [id], rect);
          LogUtil.info(`${TAG} makeMirrorWithRegion c for display ${id}`);
        } else if (this.hasDisplayC() && mode === DeviceUserType.MIRROR) {
          rect.height = rect.height * 2;
          screen.makeMirrorWithRegion(mainScreenDevice?.key as number, [id], rect);
          LogUtil.info(`${TAG} makeMirrorWithRegion full for display ${id}`);
        } else {
          screen.makeMirrorWithRegion(mainScreenDevice?.key as number, [id], rect);
          LogUtil.info(`${TAG} makeMirrorWithRegion B for display ${id}`);
        }
      } else {
        screen.setMultiScreenMode(mainScreenDevice?.key as number, id as number, screen.MultiScreenMode.SCREEN_EXTEND);
      }
      HiSysEventUtil.reportDefaultBehaviorEventByUE(USER_MODE_CHANGE_EVENT, JSON.stringify({
        main: mainScreenDevice?.key + '-0',
        second: id + '-' + mode
      }));
    } catch (error) {
      LogUtil.error(`${TAG} makeMode error code: ${error.code} - message: ${error.message}`);
    }
  }

  public isFoldPcAndPortrait(): boolean {
    if (!this.isFoldablePC()) {
      LogUtil.showInfo(TAG, `isFoldPcAndPortrait is not FoldablePc`);
      return false;
    }
    let mainScreenDevice = this.devices.find((d) => {
      return d.deviceUserFor === DeviceUserType.MAIN_SCREEN;
    });
    if (mainScreenDevice === undefined) {
      LogUtil.showError(TAG, `isFoldPcAndPortrait find mainScreenDevice error`);
      return false;
    }
    LogUtil.showInfo(TAG, `isFoldPcAndPortrait mainScreenDevice.key = ${mainScreenDevice.key}`);
    let mainDispaly: display.Display | undefined = undefined;
    try {
      mainDispaly = display.getDisplayByIdSync(mainScreenDevice?.key as number);
    } catch (error) {
      LogUtil.showError(TAG, `getDisplayByIdSync error code: ${error.code} - message: ${error.message}`);
      return false;
    }
    if (this.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED) {
      if (mainDispaly.orientation === display.Orientation.PORTRAIT ||
        mainDispaly.orientation === display.Orientation.PORTRAIT_INVERTED) {
        return true;
      }
    }
    return false;
  }

  /**
   * 获取半屏尺寸
   * @returns
   */
  public getWidthHeight(): Record<string, number> {
    let mainScreenDevice = this.devices.find((d) => {
      return d.deviceUserFor === DeviceUserType.MAIN_SCREEN;
    });
    let result: Record<string, number> = {
      'width': 0, 'height': 0
    };
    if (mainScreenDevice === undefined) {
      LogUtil.error(`${TAG} getWidthHeight find mainScreenDevice error`);
      return result;
    }
    try {
      let width: number = mainScreenDevice.width;
      let height: number = mainScreenDevice.height;
      LogUtil.info(`${TAG} before getWidthHeight width: ${width}, height: ${height}`);
      let mainDispaly = display.getDisplayByIdSync(mainScreenDevice?.key as number);
      if (this.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED) {
        if (mainDispaly.orientation === display.Orientation.PORTRAIT ||
          mainDispaly.orientation === display.Orientation.PORTRAIT_INVERTED) {
          width = mainScreenDevice.width;
          height = mainScreenDevice.height / 2;
        } else {
          width = mainScreenDevice.height;
          height = mainScreenDevice.width / 2;
        }
      }
      result = { 'width': width, 'height': height };
      LogUtil.info(`${TAG} after getWidthHeight width: ${width}, height: ${height}`);
      return result;
    } catch (error) {
      LogUtil.error(`${TAG} getWidthHeight find mainScreenDevice error`);
      return result;
    }
  }

  private getDefaultModeData(id: number) : string {
    let result = `${id} ${DEFAULT_MODE}`;
    LogUtil.info(`${TAG} get default mode: ${result}`);
    return result;
  }

  /**
   * 判断设备是否处于横屏状态
   * @returns
   */
  public isDisplayLandscape() {
    let defaultDisplay = display.getDefaultDisplaySync();
    return this.foldStatus === display.FoldStatus.FOLD_STATUS_EXPANDED &&
      (defaultDisplay.orientation === display.Orientation.LANDSCAPE ||
      defaultDisplay.orientation === display.Orientation.LANDSCAPE_INVERTED);
  }

  /**
   * 可折叠设备获取当前折叠状态
   * @returns
   */
  public getFoldStatus(): display.FoldStatus {
    return this.foldStatus;
  }

  /**
   * 查询本机设备是否可折叠
   * @returns
   */
  public isFoldablePC(): boolean {
    try {
      return display.isFoldable() && DeviceUtil.isDevicePc();
    } catch (error) {
      LogUtil.error(`${TAG} isFoldablePC error code: ${error.code} - message: ${error.message}`);
      return false;
    }
  }

  /**
   * 查询设备是否为本机可折叠设备，且处于悬停态
   * @param deviceType 设备类型
   * @returns
   */
  public isHoverState(deviceType: DeviceDisplayType): boolean {
    return this.isFoldablePC() && deviceType === DeviceDisplayType.BUILTIN &&
      DevicesController.getInstance().getFoldStatus() !== display.FoldStatus.FOLD_STATUS_EXPANDED;
  }

  /**
   * 可折叠设备的镜像类型
   * @param deviceUserFor 设备模式
   */
  public setCurrentDevice(deviceUserFor: DeviceUserType): void {
    if (this.currentDevice === undefined) {
      LogUtil.error(`${TAG} setCurrentDevice currentDevice undefined`);
      return;
    }
    try {
      this.currentDevice.deviceUserFor = deviceUserFor;
      let changeDisplay = display.getDisplayByIdSync(this.currentDevice.key as number);
      let deviceIndex = this.devices.findIndex((d)=>{ return d.key === this.currentDevice?.key as number});
      if (deviceIndex === -1) {
        LogUtil.error(`${TAG} find deviceIndex error`);
        return;
      }
      let changeDevice = DeviceInfo.createDeviceInfoByDisplay(
        changeDisplay, this.devices[deviceIndex].key, deviceUserFor, this.devices[deviceIndex].serialNumber!);
      if (changeDevice !== undefined) {
        this.devices[deviceIndex] = changeDevice;
      } else {
        LogUtil.error(`${TAG} change device error`);
      }
      this.setSettingsData();
      this.handleChangeEvent(false, false, true);
    } catch (error) {
      LogUtil.error(`${TAG} setCurrentDevice error code: ${error.code} - message: ${error.message}`);
    }
  }

  /**
   * 获取实际的显示器模式
   * @param newScreen 显示器实例对象
   * @param allScreens 当前所有接入屏幕实例对象
   * @returns 实际模式
   */
  private getRealMode(newScreen: screen.Screen, allScreens: screen.Screen[]): number {
    // RSID与id不匹配,认定为发生主副切换,需判断是否为单一屏幕
    if (newScreen.rsId !== newScreen.id) {
      LogUtil.info(`${TAG} main screen change`);
      // screen不为内置屏
      if (newScreen.rsId !== 0) {
        LogUtil.info(`${TAG} get mode rsid: ${newScreen.rsId} - displayid: ${newScreen.id}`);
        if (allScreens.filter((screen) => this.isExternalMonitorID(screen.id)).length === 1) {
          LogUtil.info(`${TAG} only one screen`);
          return DeviceUserType.ONLY_SCREEN;
        }
      }
    }
    return newScreen.sourceMode as number;
  }

  public getBorderRadius(deviceInfo: DeviceInfo | null): number {
    if (deviceInfo?.deviceModel !== DeviceType.TYPE_PHONE) {
      return Constants.DEFAULT_BORDER_RADIUS;
    }
    if (!this.isFoldablePC()) {
      return Constants.DEFAULT_BORDER_RADIUS;
    }
    const defaultDisplay: display.Display = this.getDefaultDisplay();
    LogUtil.info(`getBorderRadius curOrientation = ${defaultDisplay.orientation}`);
    if (defaultDisplay.orientation === display.Orientation.LANDSCAPE ||
      defaultDisplay.orientation === display.Orientation.LANDSCAPE_INVERTED) {
      return Constants.DEFAULT_BORDER_RADIUS;
    }
    return Constants.PHONE_BORDER_RADIUS;
  }
}

export { DeviceInfo };