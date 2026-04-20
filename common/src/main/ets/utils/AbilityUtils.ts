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

import bundleManager from '@ohos.bundle.bundleManager';
import type common from '@ohos.app.ability.common';
import { Context } from '@ohos.abilityAccessCtrl';
import type UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from './LogUtil';
import { AbilityContextManager } from '../ability/AbilityContextManager';
import { CheckEmptyUtils } from './CheckEmptyUtils';
import Want from '@ohos.app.ability.Want';

const TAG: string = 'AbilityUtils : ';

/**
 * Ability工具类
 *
 * @since 2022-06-25
 */
export class AbilityUtils {
  /**
   * 启动Ability
   *
   * @param want 启动参数
   */
  static startAbility(want: Want, callback?: () => void): void {
    if (!want) {
      LogUtil.error(`${TAG} want invalid`);
      return;
    }
    let context: common.UIAbilityContext = AbilityContextManager.getMainAbilityContext() as common.UIAbilityContext;
    if (context === undefined) {
      LogUtil.warn(`${TAG} settingsAbilityContext is undefined`);
      context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext;
    }

    context.startAbility(want).then((data) => {
      LogUtil.info(`${TAG} Succeed to start ability`);
      callback();
    }).catch((err) => {
      LogUtil.error(`${TAG} Fail to start ability for result,errCode:${err?.errorCode}, message:${err?.message}`);
      callback();
    });
  }

  /**
   * 启动extension意图
   *
   * @param want 启动参数
   */
  static startIntentUiExtensionAbility(want: Want, callback?: () => void): void {
    if (!want) {
      LogUtil.error(`${TAG} want invalid`);
      return;
    }
    let context: common.UIExtensionContext | undefined =
      AbilityContextManager.getExtensionIntentContext() as common.UIExtensionContext;
    if (context === undefined) {
      AbilityUtils.startAbility(want);
      return;
    }

    context.startAbility(want).then((data) => {
      LogUtil.info(`${TAG} Succeed to start extension ability`);
      callback();
    }).catch((err) => {
      LogUtil.error(`${TAG} Fail to start extension ability for result,errCode:${err?.errorCode}}`);
      callback();
    });
  }

  /**
   * 通过ServiceExtensionContext启动Ability
   *
   * @param want 启动参数
   * @param callback 回调参数
   */
  static startAbilityByServiceExtensionContext(want: Want, callback: () => void): void {
    if (!want) {
      LogUtil.error(`${TAG} want invalid`);
      return;
    }
    (AppStorage.get<common.ServiceExtensionContext>('NearLinkWindowServiceContext')).startAbility(want).then((data) => {
      LogUtil.info(`${TAG} Succeed to start ability by ServiceExtensionContext`);
      callback();
    }).catch((err) => {
      LogUtil.error(`${TAG} Fail to start ability, errCode:${err?.errorCode}, ${err?.message}`);
      callback();
    });
  }

  /**
   * 启动Ability
   *
   * @param want 启动参数
   * @param callback 回调参数
   */
  static startAbilityForResult(want: Want, callback: () => void): void {
    if (!want) {
      LogUtil.error(`${TAG} want invalid for result`);
      return;
    }
    (AppStorage.get<common.UIAbilityContext>('pageContext') as common.UIAbilityContext)?.startAbility(want)
      .then((data) => {
        LogUtil.info(`${TAG} Succeed to start ability for result`);
        callback();
      })
      .catch((err) => {
        LogUtil.error(`${TAG} Fail to start ability for result,errCode:${err?.errorCode}}`);
        callback();
      });
  };

  /**
   * 启动Ability
   *
   * @param want 启动参数
   * @param callback 回调参数
   */
  static startServiceExtensionForResult(want: Want, callback: () => void): void {
    if (!want) {
      LogUtil.error(`${TAG} want invalid for result`);
      return;
    }
    (AppStorage.get<common.UIAbilityContext>('pageContext') as common.UIAbilityContext)?.startServiceExtensionAbility(want)
      .then((data) => {
        LogUtil.info(`${TAG} Succeed to start ability for result`);
        callback();
      })
      .catch((err) => {
        LogUtil.error(`${TAG} Fail to start ability for result,errCode:${err?.errorCode}}`);
        callback();
      });
  };

  /**
   * 发送数据给UiExtension容器，且成功或返回时关闭uiExtension
   *
   * @param uiExtensionContentSession uiExtension会话
   * @param resultCode 关闭前回传的结果参数，其中0表示成功，-1表示返回，-2表示关闭，其余表示错误
   */
  public static closeUiExtension(uiExtensionContentSession: UIExtensionContentSession | undefined, resultCode : number): void {
    LogUtil.info(`${TAG} closeUiExtension, resultCode is ${resultCode}`);
    if (!!uiExtensionContentSession) {
      try {
        LogUtil.info(`${TAG} uiExtensionContentSession send result.`);
        uiExtensionContentSession.sendData({ 'result': resultCode });
        if (resultCode === 0 || resultCode === -1 || resultCode === -2) {
          LogUtil.info(`${TAG} uiExtensionContentSession terminateSelf.`);
          uiExtensionContentSession.terminateSelf();
          AppStorage.setOrCreate('uiExtensionContentSession', null);
        }
      } catch (error) {
        LogUtil.error(`${TAG} createPin, uiExtensionContentSession send data failed.`);
      }
    }
  }

  /**
   * 发送数据给UiExtension容器，且成功或返回时关闭uiExtension
   *
   * @param uiExtensionContentSession uiExtension会话
   * @param resultCode 关闭前回传的结果参数，其中0表示成功，-1表示失败
   * @param data 发送的数据
   */
  public static closeUiExtensionWithData(uiExtensionContentSession: UIExtensionContentSession | undefined, resultCode : number, data: object): void {
    LogUtil.info(`${TAG} closeUiExtension, resultCode is ${resultCode}`);
    if (uiExtensionContentSession) {
      try {
        LogUtil.info(`${TAG} closeUiExtensionWithData send result.`);
        uiExtensionContentSession.sendData({ 'result': resultCode, 'data': data });
        if (resultCode === 0 || resultCode === -1) {
          LogUtil.info(`${TAG} closeUiExtensionWithData terminateSelf.`);
          uiExtensionContentSession.terminateSelf();
          AppStorage.setOrCreate('uiExtensionContentSession', null);
          AppStorage.setOrCreate<Want>('wantParams', null);
        }
      } catch (error) {
        LogUtil.error(`${TAG} createPin, closeUiExtensionWithData send data failed.`);
      }
    }
  }

  /**
   * 关闭UiExtension，通过terminateSelfWithResult通知容器操作结果
   *
   * @param uiExtensionContentSession uiExtension会话
   * @param resultCode 返回码，100表示成功，101表示返回，其余表示错误
   */
  public static closeUiExtensionWithResult(uiExtensionContentSession: UIExtensionContentSession | undefined, resultCode : number): void {
    LogUtil.info(`${TAG} closeUiExtensionWithResult, resultCode is ${resultCode}`);
    if (!!uiExtensionContentSession) {
      try {
        LogUtil.info(`${TAG} closeUiExtensionWithResult send result.`);
        let abilityResult: common.AbilityResult = {
          resultCode: resultCode,
        };
        LogUtil.info(`${TAG} closeUiExtensionWithResult terminateSelf.`);
        uiExtensionContentSession.terminateSelfWithResult(abilityResult);
        AppStorage.setOrCreate('uiExtensionContentSession', null);
      } catch (error) {
        LogUtil.error(`${TAG} createPin, closeUiExtensionWithResult failed.`);
      }
    }
  }

  /**
   * 应用调用系统接口reportDrawnCompleted报告页面加载完成打点
   *
   * @param tag
   */
  public static pageReportCallback(tag: string): void {
    ((AppStorage.get<common.UIAbilityContext>('pageContext') as common.UIAbilityContext)).reportDrawnCompleted(() => {
      LogUtil.info(`${TAG} ${tag} report callback.`);
    });
  }

  public static timeoutForceGC(delayMs: number, user?: string): void {
    let delay: number = delayMs;
    if (delay < 0) {
      delay = 0;
    }
    // 延时触发GC
    let timerId: number = setTimeout(() => {
      try {
        // @ts-ignore
        ArkTools.hintGC(0);
        clearTimeout(timerId);
        LogUtil.info(`${TAG} user: ${user} call GC`);
      } catch (err) {
        LogUtil.error(`${TAG}, call GC failed, errInfo: ${err?.message}`);
      }
    }, delay);
  }

  public static callerIsLocalSystemApp(want: Want): boolean {
    if (!CheckEmptyUtils.checkStrIsEmpty(want.deviceId)) {
      LogUtil.error(`${TAG} callerDeviceId is not empty, caller is not from local device`);
      return false;
    }
    let caller: string = '';
    Object.entries(want.parameters)?.forEach(
      (value: [key: string, value: string], index: number) => {
        if (value[0] === 'ohos.aafwk.param.callerBundleName') {
          caller = value[1];
        }
      }
    );
    LogUtil.info(`${TAG} caller: ${caller}`);
    if (CheckEmptyUtils.checkStrIsEmpty(caller)) {
      return false;
    }
    let info = bundleManager.getBundleInfoSync(caller,
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    LogUtil.info(`${TAG} is system app: ${info?.appInfo?.systemApp}`);
    return info?.appInfo?.systemApp ?? false;
  }

  public static setCacheProcess(isNeedCache: boolean, context: Context): void {
    if (!context) {
      LogUtil.warn(`${TAG} setCacheProcess context is null`);
      return;
    }
    try {
      const applicationContext = context.getApplicationContext();
      applicationContext.setSupportedProcessCache(isNeedCache);
    } catch (e) {
      LogUtil.error(`SettingsAbilityStage setSupportedProcessCache fail, code: ${e?.code}, msg: ${e?.message}`);
    }
  }
}
