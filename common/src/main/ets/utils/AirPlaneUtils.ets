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

import connection from '@ohos.net.connection';
import wifiManager from '@ohos.wifiManager';
import Settings from '@ohos.settings';
import lazy { default as sharing } from '@ohos.net.sharing';
import { LogUtil } from './LogUtil';
import { SettingsDataUtils } from './SettingsDataUtils';
import { SatelliteUtils } from './BaseUtils';
import { SystemParamUtil } from './SystemParamUtil';
import { PARAM_AIRPLANE_MODE_DISABLE } from '../constant/EDMConstant';

export const EMERGENCY_KEY: string = 'emergency_rescue_mode';
const AIR_PLANE_MODE: string = 'settings.telephony.airplanemode';
const AIR_PLANE_MODE_DEFAULT_VAL: string = '0';
const PHYSIC_NAVI_HAPTIC_FEEDBACK_ENABLED: string = 'physic_navi_haptic_feedback_enabled';

enum EmcRescueMode {
  EMC_RESCUE_MODE_IN_DEACTIVE = '0', // 应急模式打开，飞行模式操作不禁用
  EMC_RESCUE_MODE_IN_ACTIVE = '1', // 应急模式打开，飞行模式操作禁用
};

const TAG: string = 'AirPlaneUtils: '

export class AirPlaneUtils {
  /**
   * 当前飞行模式开关状态
   */
  static isAirplaneActive(): boolean {
    let value: string = SettingsDataUtils.getSettingsData(AIR_PLANE_MODE, AIR_PLANE_MODE_DEFAULT_VAL);
    return !(value === AIR_PLANE_MODE_DEFAULT_VAL);
  }

  /**
   * 开启飞行模式开关
   */
  static enableAirplaneMode(): boolean {
    try {
      connection.enableAirplaneMode();
      return true;
    } catch (error) {
      LogUtil.error(`${TAG} enableAirplaneMode fail,code: ${error?.code} message:${error?.message}`);
    }
    return false;
  }

  /**
   * 关闭飞行模式开关
   */
  static disableAirplaneMode(): boolean {
    try {
      connection.disableAirplaneMode();
      return true;
    } catch (error) {
      LogUtil.error(`${TAG} disableAirplaneMode fail,code: ${error?.code} message:${error?.message}`);
    }
    return false;
  }

  /**
   * 当前个人热点开关状态
   */
  static isPersonalHotspot(): boolean {
    let isActive: boolean = wifiManager.isHotspotActive();
    return isActive;
  }

  /**
   * 开启个人热点开关
   */
  static async enableHotspot(): Promise<boolean> {
    try {
      await sharing.startSharing(sharing.SharingIfaceType.SHARING_WIFI);
      return true;
    } catch (error) {
      LogUtil.error(`${TAG} enableHotspot fail,code: ${error?.code} message:${error?.message}`);
    }
    return false;
  }

  /**
   * 关闭个人热点开关
   */
  static async disableHotspot(): Promise<boolean> {
    try {
      await sharing.stopSharing(sharing.SharingIfaceType.SHARING_WIFI);
      return true;
    } catch (error) {
      LogUtil.error(`${TAG} disableHotspot fail,code: ${error?.code} message:${error?.message}`);
    }
    return false;
  }

  /**
   * 当前亮度自动调节开关状态
   */
  static isAutoBrightness(): boolean {
    let isAutoBright = SettingsDataUtils.getSettingsData(Settings.display.AUTO_SCREEN_BRIGHTNESS,
      '1') === '1';
    return isAutoBright;
  }

  /**
   * 开启亮度自动调节开关
   */
  static autoSwitchOn(): boolean {
    SettingsDataUtils.setSettingsData(Settings.display.AUTO_SCREEN_BRIGHTNESS, '1');
    return true;
  }

  /**
   * 关闭亮度自动调节开关
   */
  static autoSwitchOff(): boolean {
    SettingsDataUtils.setSettingsData(Settings.display.AUTO_SCREEN_BRIGHTNESS, '0');
    return true;
  }

  /**
   * 当前系统触感反馈开关状态
   */
  static isTouchFeedback(): boolean {
    let isTouchFeedback = SettingsDataUtils.getSettingsData(PHYSIC_NAVI_HAPTIC_FEEDBACK_ENABLED, '1') === '1';
    return isTouchFeedback;
  }

  /**
   * 开启系统触感反馈开关状态
   */
  static openTouchFeedback(): boolean {
    SettingsDataUtils.setSettingsData(PHYSIC_NAVI_HAPTIC_FEEDBACK_ENABLED, '1');
    return true;
  }

  /**
   * 关闭系统触感反馈开关状态
   */
  static closeTouchFeedback(): boolean {
    SettingsDataUtils.setSettingsData(PHYSIC_NAVI_HAPTIC_FEEDBACK_ENABLED, '0');
    return true;
  }

  /**
   * 是否飞行模式开关允许操作
   * @returns true:可操作 false:不可操作
   */
  static isAirPlaneOperateEnable(): boolean {
    return !SatelliteUtils.isCommunicationOpen() &&
      !AirPlaneUtils.isEdmDisableAirplane();
  }

  /**
   * EMD是否禁用飞行模式
   * @returns true:禁用 false:不禁用
   */
  static isEdmDisableAirplane(): boolean {
    return SystemParamUtil.getParam(PARAM_AIRPLANE_MODE_DISABLE, 'false') === 'true';
    }
}