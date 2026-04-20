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

import { LogUtil } from './LogUtil';
import { BusinessError } from '@ohos.base';
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import { SystemParamUtil } from './SystemParamUtil';
import { DeviceUtil } from './BaseUtils';

const TAG = 'CapabilitySupportUtils: ';
const NEAR_LINK_CCM_CONFIG = 'const.nearlink.enable';
const INTELLIGENT_SCENE_ENABLE_CCM_CONFIG = 'const.intelligentscene.enable';
const DISTRIBUTED_CONNECT_CCM_CONFIG = 'const.booster.virtual_modem_switch';
const SOUND_QUALITY_CCM_KEY: string = 'const.multimedia.audio.show_sound_effect_model';
const LICENSE_ENABLE_CCM_CONFIG = 'const.pc_security.license_enable';
const ITSEC_EDITION_NUMBER_CCM_CONFIG = 'persist.pc_security.itsec_edition_number';

/**
 * 开机铃声开关CCM配置字段(取值0-15，代表音量大小，0即表示无铃声)
 */
const BOOT_SOUND_SWITCH_KEY: string = 'const.bootanimation.bootsound';

/**
 * 音量1 此处仅用来作为默认值，表示支持显示开机铃声开关，并非代表开机铃声的真实音量大小
 */
const BOOT_SOUND_VOLUME_1: string = '1';

/**
 * 音量0 表示不支持显示开机铃声开关
 */
const BOOT_SOUND_VOLUME_0: string = '0';

/**
 * 是否支持强制横屏CCM配置字段
 */
const FORCIBLE_LANDSCAPE_ENABLE_CCM_CONFIG: string = 'const.settings.forcible_landscape_enable';

/**
 * 是否支持视频HDR增强配置字段
 */
const SUPPORT_AIHDR_VIDEO: string = 'const.display.support_aihdr_video';

/**
 * 判断能力是否支持工具类
 */
export class CapabilitySupportUtils {
  /**
   * 通过CCM配置判断是否支持星闪
   *
   * @returns true表示支持，false表示不支持
   */
  static isSupportNearLink(): boolean {
    let isSupport: string = 'false';
    try {
      isSupport = systemParameterEnhance.getSync(NEAR_LINK_CCM_CONFIG, 'false');
    } catch (err) {
      LogUtil.error(`${TAG} get isSupportNearLink fail, errCode: ${(err as BusinessError).code}, errMsg: ${(err as BusinessError).message}`);
    }

    return isSupport === 'true';
  }

  /**
   * 判断是否支持星闪蓝牙融合接口
   *
   * @returns true表示支持，false表示不支持
   */
  static isSupportFusion(): boolean {
    return canIUse('SystemCapability.Communication.FusionConnectivityExt') &&
      !DeviceUtil.isDeviceEmulator();
  }

  /**
   * 通过CCM配置和是否属于主用户来判断是否支持通信共享
   *
   * @returns true表示支持，false表示不支持
   */
  static isSupportDistributeConnect(): boolean {
    let isMainAccount: boolean = CapabilitySupportUtils.isMainAccount();
    LogUtil.info(`isSupportDistributeConnect isMainAccount ${isMainAccount}.`);
    if (!isMainAccount) {
      return false;
    }
    let isSupport: string = 'false';
    try {
      isSupport = systemParameterEnhance.getSync(DISTRIBUTED_CONNECT_CCM_CONFIG, 'true');
    } catch (err) {
      LogUtil.error(`${TAG} get isSupportDistributeConnect fail, errCode: ${(err as BusinessError).code},
       errMsg: ${(err as BusinessError).message}`);
    }
    return isSupport === 'true';
  }

  private static isMainAccount(): boolean {
    return AppStorage.get('isMainAccount') === undefined || AppStorage.get('isMainAccount') === true;
  }

  /**
   * 通过CCM配置和是否属于主用户来判断是否支持显示开机铃声开关
   *
   * @returns true表示支持  false表示不支持
   */
  static isSupportBootSoundSwitch(): boolean {
    let isMainAccount: boolean = CapabilitySupportUtils.isMainAccount();
    if (!isMainAccount) {
      LogUtil.info(`${TAG}isSupportBootSoundSwitch not main account, return false`)
      return false;
    }
    let bootSoundVolume: string = SystemParamUtil.getParam(BOOT_SOUND_SWITCH_KEY, BOOT_SOUND_VOLUME_1);
    LogUtil.info(`${TAG}isSupportBootSoundSwitch bootSoundVolume: ${bootSoundVolume}`)
    return bootSoundVolume !== BOOT_SOUND_VOLUME_0;
  }

  /**
   * 通过CCM配置判断是否支持情景模式
   *
   * @returns true表示支持，false表示不支持
   */
  static isSupportIntelligentScene(): boolean {
    if (SystemParamUtil.isSimulatorMode) {
      LogUtil.info(`${TAG} current is simulator mode.`);
      return false;
    }
    let isSupport: string = 'true';
    try {
      isSupport = systemParameterEnhance.getSync(INTELLIGENT_SCENE_ENABLE_CCM_CONFIG, 'true');
      LogUtil.info(`${TAG} isSupportIntelligentScene: ${isSupport}`);
    } catch (err) {
      LogUtil.error(`${TAG} get isSupportIntelligentScene fail, errCode: ${err?.code}, errMsg: ${err?.message}`);
    }

    return isSupport === 'true';
  }

  /**
   * 通过CCM配置判断是否支持音质音效
   *
   * @returns true表示支持，false表示不支持
   */
  static isSupportSoundQuality(): boolean {
    let isSupport: string = 'false';
    try {
      //未直接放开显示
      isSupport = systemParameterEnhance.getSync(SOUND_QUALITY_CCM_KEY, 'false');
      LogUtil.info(`${TAG} isSupportSoundQuality: ${isSupport}`);
    } catch (err) {
      LogUtil.error(`${TAG} get isSupportSoundQuality fail, errCode: ${err?.code}, errMsg: ${err?.message}`);
    }
    return isSupport === 'true';
  }

  /**
   * 通过CCM配置判断是否支持强制横屏
   *
   * @returns true表示支持，false表示不支持
   */
  static isSupportForcedLandscape(): boolean {
    if (DeviceUtil.isDevicePad()) {
      return true;
    }
    let isSupport: string = 'false';
    try {
      isSupport = systemParameterEnhance.getSync(FORCIBLE_LANDSCAPE_ENABLE_CCM_CONFIG, 'true');
    } catch (err) {
      LogUtil.error(`${TAG} get isSupportForcedLandscape fail, errCode: ${err?.code}, errMsg: ${err?.message}`);
    }
    return isSupport === 'true';
  }


  /**
   * 通过CCM配置判断是否支持视频HDR增强
   *
   * @returns true表示支持，false表示不支持
   */
  static isSupportAiHDRVideo(): boolean {
    try {
      let isSupport: string = systemParameterEnhance.getSync(SUPPORT_AIHDR_VIDEO, 'true');
      return isSupport === 'true';
    } catch (err) {
      LogUtil.error(`${TAG} get isSupportAiHDRVideo fail, errCode: ${err?.code}, errMsg: ${err?.message}`);
      return false;
    }
  }

  /**
   * 通过CCM配置判断是否支持国测版本名称展示
   *
   * @returns true表示支持，false表示不支持
   */
  static isSupportItsecVersionName(): boolean {
    let versionName: string = '';
    try {
      versionName = systemParameterEnhance.getSync(ITSEC_EDITION_NUMBER_CCM_CONFIG, 'true');
    } catch (err) {
      LogUtil.showError(TAG, `get itsec_edition_number failed, code: ${err?.code}, msg: ${err?.message}`);
    }
    return versionName.length !== 0;
  }

  /**
   * 通过CCM配置判断是否支持版本类型
   *
   * @returns true表示支持，false表示不支持
   */
  static isSupportVersionType(): boolean {
    let isSupport: string = 'false';
    try {
      isSupport = systemParameterEnhance.getSync(LICENSE_ENABLE_CCM_CONFIG, 'true');
    } catch (err) {
      LogUtil.error(`${TAG} get isSupportVersionType fail, errCode: ${(err as BusinessError).code}, errMsg: ${(err as BusinessError).message}`);
    }
    return isSupport === 'true';
  }
}