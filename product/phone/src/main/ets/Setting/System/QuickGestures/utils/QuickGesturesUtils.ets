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
import configPolicy from '@ohos.configPolicy';
import fs from '@ohos.file.fs';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BusinessError, systemParameterEnhance } from '@kit.BasicServicesKit';
import { bundleManager } from '@kit.AbilityKit';
import { QuickConstants } from '../Constants/QuickConstants';
import sim from '@ohos.telephony.sim';
import { DeviceUtils } from '../../../../pages/biometricsandpassword/module/privacyPassword/common/utils/DeviceUtils';
import { PageStartReason } from '@ohos/settings.common/src/main/ets/data/types';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';

const SCREEN_SHOW_OR_NOT: string = 'const.swing.swing_gesture_ability';
const SMART_KEY_DATA: string = 'smart_key_data';
const TAG: string = 'QuickGesturesUtils : ';

export class QuickGesturesUtils {
  private static filePath: string = 'etc/hwquickaccessmenu/hw_quickaccessmenu_config.json';
  private static getScreenData(): string {
    let screenModel: string = '';
    try {
      screenModel = systemParameterEnhance.getSync(SCREEN_SHOW_OR_NOT, QuickConstants.SWING_GESTURE_ABILITY);
      LogUtil.info(`${TAG} screenModel is ${screenModel}`);
    } catch (error) {
      LogUtil.info(`${TAG} systemParameter SCREEN_SHOW_OR_NOT error ${(error as BusinessError).message}}`);
    }
    return screenModel;
  }

  public static isSlideSupport(): boolean {
    let isSupport: boolean = false;
    let screenModel: string = QuickGesturesUtils.getScreenData();
    if (screenModel) {
      let arr = screenModel.split(';');
      if (arr?.length > QuickConstants.SCREEN_ARR_NUM) {
        let up = arr[QuickConstants.SWING_GESTURE_ABILITY_UP_INDEX];
        let upArr = up.split(':');
        let down = arr[QuickConstants.SWING_GESTURE_ABILITY_DOWN_INDEX];
        let downArr = down.split(':');
        let left = arr[QuickConstants.SWING_GESTURE_ABILITY_LEFT_INDEX];
        let leftArr = left.split(':');
        let right = arr[QuickConstants.SWING_GESTURE_ABILITY_RIGHT_INDEX];
        let rightArr = right.split(':');
        const flag = upArr[1] === QuickConstants.UP_SUPPORT ||
          downArr[1] === QuickConstants.DOWN_SUPPORT ||
          leftArr[1] === QuickConstants.LEFT_SUPPORT ||
          rightArr[1] === QuickConstants.RIGHT_SUPPORT;
        // 隔空滑动屏幕
        if (flag) {
          isSupport = true;
        }
      }
    }
    return !isSupport;
  }

  public static isShotsSupport(): boolean {
    let isSupport: boolean = false;
    let screenModel: string = QuickGesturesUtils.getScreenData();
    if (screenModel) {
      let arr = screenModel.split(';');
      if (arr?.length > QuickConstants.SCREEN_ARR_NUM) {
        // 隔空截屏：只要f:抓取fetch，1为支持就显示入口
        let fetch = arr[QuickConstants.SWING_GESTURE_ABILITY_FETCH_INDEX];
        let fetchArr = fetch.split(':');
        if (fetchArr[1] === QuickConstants.AIR_ON) {
          isSupport = true;
        }
      }
    }
    return !isSupport;
  }

  public static isShareSupport(): boolean {
    let isSupport: boolean = false;
    let screenModel: string = QuickGesturesUtils.getScreenData();
    if (screenModel) {
      let arr = screenModel.split(';');
      if (arr?.length > QuickConstants.SHARE_ARR_NUM) {
        // 隔空分享
        let sharing = arr[QuickConstants.SWING_GESTURE_ABILITY_SHARE_INDEX];
        let sharingArr = sharing.split(':');
        if (sharingArr[1] === QuickConstants.AIR_ON) {
          isSupport = true;
        }
      }
    }
    return !isSupport;
  }

  public static isFingerprintKeyShortcutsSupport(): boolean {
    let xKeyBundleName: string = QuickConstants.QUICK_ACCESS_MENU_BUNDLE_NAME;
    let funcType: string = SystemParamUtil.getParam(QuickConstants.QUICK_ACCESS_FUNCTION_TYPE,
      QuickConstants.QUICK_ACCESS_FUNCTION_NOT_SUPPORT);
    if (funcType === QuickConstants.QUICK_ACCESS_FUNCTION_NOT_SUPPORT) {
      return true;
    }
    let isSupport: boolean = false;
    try {
      bundleManager.getBundleInfoSync(xKeyBundleName, bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT, 100);
      isSupport = true;
    } catch (err) {
      LogUtil.error(`${TAG} get smart key bundleInfo failed: ${(err as BusinessError).message}`);
    }
    return !isSupport;
  }

  public static isSmartKey(): boolean {
    const funcType: string = SystemParamUtil.getParam(QuickConstants.QUICK_ACCESS_FUNCTION_TYPE,
      QuickConstants.QUICK_ACCESS_FUNCTION_NOT_SUPPORT);
    return funcType === QuickConstants.QUICK_ACCESS_FUNCTION_SMART_KEY;
  }

  /**
   * 是否支持相机智拍
   *
   * @returns true: 支持，false: 不支持
   */
  public static isSupportCameraSmartControl(): boolean {
    try {
      const value: string = systemParameterEnhance.getSync(QuickConstants.QUICK_ACCESS_IS_SUPPORT_CAMERA_SMART);
      LogUtil.info(`${TAG} getSystemParameter is_support_camera_smart, value = ${value}`);
      return value === QuickConstants.QUICK_ACCESS_IS_SUPPORT_FLAG;
    } catch (error) {
      LogUtil.error(`${TAG} getSystemParameter is_support_camera_smart error, message: ${error.message}`);
    }
    let smartKeyData: SmartKeyData | undefined = QuickGesturesUtils.loadSmartKeyData();
    if (smartKeyData) {
      LogUtil.info(`${TAG} isSupportCameraSmartControl is: ${smartKeyData.isSupportCameraSmartControl}`);
      return smartKeyData.isSupportCameraSmartControl;
    }
    LogUtil.error(`${TAG} isSupportCameraSmartControl err, smartKeyData is undefined`);
    return false;
  }

  /**
   * 是否支持滑动
   *
   * @returns true: 支持，false: 不支持
   */
  public static isSupportSlide(): boolean {
    try {
      const value: string = systemParameterEnhance.getSync(QuickConstants.QUICK_ACCESS_IS_SUPPORT_SLIDE);
      LogUtil.info(`${TAG} getSystemParameter is_support_slide, value = ${value}`);
      return value === QuickConstants.QUICK_ACCESS_IS_SUPPORT_FLAG;
    } catch (error) {
      LogUtil.error(`${TAG} getSystemParameter is_support_slide error, message: ${error.message}`);
    }
    let smartKeyData: SmartKeyData | undefined = QuickGesturesUtils.loadSmartKeyData();
    if (smartKeyData) {
      LogUtil.info(`${TAG} isSupportSlide is: ${smartKeyData.isSupportSlide}`);
      return smartKeyData.isSupportSlide;
    }
    LogUtil.error(`${TAG} isSupportSlide err, smartKeyData is undefined`);
    return false;
  }

  private static loadSmartKeyData(): SmartKeyData | undefined {
    try {
      let smartKeyData: SmartKeyData = AppStorage.get<SmartKeyData>(SMART_KEY_DATA) as SmartKeyData;
      if (smartKeyData) {
        return smartKeyData;
      }
      // 未加载过配置文件，加载配置文件
      let filePath: string = configPolicy.getOneCfgFileSync(QuickGesturesUtils.filePath);
      let content: string = fs.readTextSync(filePath);
      if (content) {
        let smartKeyData: SmartKeyData = JSON.parse(content);
        LogUtil.info(`${TAG} loadSmartKeyData success`);
        AppStorage.setOrCreate(SMART_KEY_DATA, smartKeyData);
        return smartKeyData;
      }
    } catch (err) {
      LogUtil.error(`${TAG} loadSmartKeyData err, code:${err?.code}, message:${err?.message}`);
    }
    return undefined;
  }

  public static isGestureControlCallSupport(): boolean {
    let isSupport: boolean = sim.getMaxSimCount() > 0;
    LogUtil.info(`${TAG} isGestureControlCallSupport is ${isSupport}`);
    return !isSupport;
  }

  public static isGestureQuickCallSupport(): boolean {
    let isSupport: boolean = DeviceUtils.isPhone() ? true : false;
    LogUtil.info(`${TAG} isGestureQuickCallSupport is ${isSupport}`);
    return !isSupport;
  }

  /**
   * 判断返回按钮是否隐藏
   *
   * @param params 跳转参数
   * @param navigationMode 设置布局分栏模式
   */
  public static isNeedHideBackButton(params: PushParam | null, navigationMode: NavigationMode): boolean {
    if (params?.startReason === PageStartReason.FROM_SEARCH && navigationMode === NavigationMode.Split) {
      // 设置中搜索跳转时，若设置分栏，则隐藏返回按钮
      return true;
    } else {
      return false;
    }
  }
}

interface SmartKeyData {
  isSupportCameraSmartControl: boolean;
  isSupportSlide: boolean;
}