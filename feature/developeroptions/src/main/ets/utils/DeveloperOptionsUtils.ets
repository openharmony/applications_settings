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
import { bundleManager } from '@kit.AbilityKit';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import {
  SHARED_LIBRARY_METADATA_VALUE,
  SHARED_LIBRARY_METADATA_NAME,
  SHARED_LIBRARY_METADATA_MODULE_NAME,
  SHARED_LIBRARY_BUNDLE_NAME } from '../utils/DeveloperOptionsConsts';

const SWITCH_ENABLE: string = 'true';
const SWITCH_DISABLE: string = 'false';

interface DebugOuterAppReportParams {
  PNAMEID: string;
  PVERSIONID: string;
  VALUE?: string;
}

export class DeveloperOptionUtils {
  private static DEBUG_OUTER_APP_SWITCH: string = 'DEBUG_OUTER_APP_SWITCH';

  /**
   * 返回充电温度限制开关的实时状态
   */
  static isChargeTemperatureOpen(): boolean {
    return SettingsDataUtils.getSettingsData('settings.developer.charge_temperature_control_enable', SWITCH_ENABLE) == SWITCH_ENABLE;
  }
  /**
   * 开启充电温度限制开关
   */
  static isChargeTemperatureOn(): boolean {
    SettingsDataUtils.setSettingsData('settings.developer.charge_temperature_control_enable', SWITCH_ENABLE);
    return true;
  }
  /**
   * 关闭充电温度限制开关
   */
  static isChargeTemperatureOff(): boolean {
    SettingsDataUtils.setSettingsData('settings.developer.charge_temperature_control_enable', SWITCH_DISABLE);
    return true;
  }
  /**
   * 返回自动更新系统开关的实时状态
   */
  static isAutomaticSystemUpdateOpen(): boolean {
    return SettingsDataUtils.getSettingsData('ota_disable_automatic_update', '1') === '1';
  }
  /**
   * 开启自动更新系统开关
   */
  static isAutomaticSystemUpdateOn(): boolean {
    SettingsDataUtils.setSettingsData('ota_disable_automatic_update', '1');
    return true;
  }
  /**
   * 关闭自动更新系统开关
   */
  static isAutomaticSystemUpdateOff(): boolean {
    SettingsDataUtils.setSettingsData('ota_disable_automatic_update', '0');
    return true;
  }
  /**
   * 返回系统trace跟踪开关的实时状态
   */
  static isDebugSystemTraceOpen(): boolean {
    let state: string = SystemParamUtil.getParam('persist.hiview.trace_recorder', SWITCH_DISABLE);
    return state === SWITCH_ENABLE;
  }
  /**
   * 开启系统trace跟踪开关
   */
  static isDebugSystemTraceOn(): boolean {
    SystemParamUtil.setParam('persist.hiview.trace_recorder', SWITCH_ENABLE);
    return true;
  }
  /**
   * 关闭系统trace跟踪开关
   */
  static isDebugSystemTraceOff(): boolean {
    SystemParamUtil.setParam('persist.hiview.trace_recorder', SWITCH_DISABLE);
    return true;
  }
  /**
   * 返回冻屏信息日志开关的实时状态
   */
  static isDebugFreezeDetectOpen(): boolean {
    let state: string = SystemParamUtil.getParam('persist.hiview.freeze_detector', SWITCH_DISABLE);
    return state === SWITCH_ENABLE;
  }
  /**
   * 开启冻屏信息日志开关
   */
  static isDebugFreezeDetectOn(): boolean {
    SystemParamUtil.setParam('persist.hiview.freeze_detector', SWITCH_ENABLE);
    return true;
  }
  /**
   * 关闭冻屏信息日志开关
   */
  static isDebugFreezeDetectOff(): boolean {
    SystemParamUtil.setParam('persist.hiview.freeze_detector', SWITCH_DISABLE);
    return true;
  }
  /**
   * 返回系统资源泄露日志开关的实时状态
   */
  static isDebugLeakDetectOpen(): boolean {
    let state: string = SystemParamUtil.getParam('persist.hiview.leak_detector', 'disable');
    return state === 'disable';
  }
  /**
   * 开启系统资源泄露日志开关
   */
  static isDebugLeakDetectOn(): boolean {
    SystemParamUtil.setParam('persist.hiview.leak_detector', 'enable');
    return true;
  }
  /**
   * 关闭系统资源泄露日志开关
   */
  static isDebugLeakDetectOff(): boolean {
    SystemParamUtil.setParam('persist.hiview.leak_detector', 'disable');
    return true;
  }
  /**
   * 返回显示触摸操作开关的实时状态
   */
  static isShowTouchActionsOpen(): boolean {
    return SettingsDataUtils.getSettingsData('settings.input.show_touch_hint', SWITCH_ENABLE) == SWITCH_ENABLE;
  }
  /**
   * 开启显示触摸操作开关
   */
  static isShowTouchActionsOn(): boolean {
    SettingsDataUtils.setSettingsData('settings.input.show_touch_hint', SWITCH_ENABLE);
    return true;
  }
  /**
   * 关闭显示触摸操作开关
   */
  static isShowTouchActionsOff(): boolean {
    SettingsDataUtils.setSettingsData('settings.input.show_touch_hint', SWITCH_DISABLE);
    return true;
  }
  /**
   * 返回显示指针位置开关的实时状态
   */
  static isTouchActionsTraceOpen(): boolean {
    return SettingsDataUtils.getSettingsData('settings.developer.show_touch_track', SWITCH_ENABLE) == SWITCH_ENABLE;
  }
  /**
   * 开启指针位置开关
   */
  static isTouchActionsTraceOn(): boolean {
    SettingsDataUtils.setSettingsData('settings.developer.show_touch_track', SWITCH_ENABLE);
    return true;
  }
  /**
   * 关闭指针位置开关
   */
  static isTouchActionsTraceOff(): boolean {
    SettingsDataUtils.setSettingsData('settings.developer.show_touch_track', SWITCH_DISABLE);
    return true;
  }

  /**
   * 外屏应用调试开关打点上报
   *
   * @param isOn 是否开启
   */
  static async reportDebugOuterAppSwitchParams(isOn: string): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let param: DebugOuterAppReportParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      VALUE: isOn
    };
    HiSysEventUtil.reportBehaviorEventEx(DeveloperOptionUtils.DEBUG_OUTER_APP_SWITCH, param,
      DeveloperOptionUtils.DEBUG_OUTER_APP_SWITCH, HiSysEventUtil.SETTING_DOMAIN_UE);
  }

  /**
   * 是否显示更新系统共享库
   *
   * @returns 是否显示
   */
  static isSharedLibraryShow(): boolean {
    let metadata: bundleManager.Metadata | null = CommonUtils.getMetadata(SHARED_LIBRARY_BUNDLE_NAME,
      SHARED_LIBRARY_METADATA_MODULE_NAME, SHARED_LIBRARY_METADATA_NAME);
    if (metadata) {
      const num = parseInt(metadata.value)
      if (isNaN(num)) {
        return false;
      }
      return num > SHARED_LIBRARY_METADATA_VALUE;
    }
    return false;
  }
}