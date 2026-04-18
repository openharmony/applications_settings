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
// import authentication from '@hms.core.authentication';
import common from '@ohos.app.ability.common';
import Updater from '@ohos.update';
import rpc from '@ohos.rpc';
import { BusinessError } from '@ohos.base';
import { eSIM } from '@kit.TelephonyKit';
// import enhanced from '@hms.telephony.enhanced';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import {
  SIM_LABEL_INDEX_ONE,
  SIM_LABEL_INDEX_TWO,
  SIM_TYPE_PSIM,
  SIM_TYPE_ESIM
} from '@ohos/settings.common/src/main/ets/constant/SimConstant';
import { SimLabel } from '@ohos/settings.common/src/main/ets/data/types';
import { AccountManagerServiceProxy } from '../idl/idl_meetime_service_proxy';

/* instrument ignore file */
const TAG: string = 'ResetFactoryManager: ';
/**
 * 上下文类型通用定义
 */
type ContextF = common.UIExtensionContext | common.ServiceExtensionContext | common.UIAbilityContext;
const RESET_FACTORY_BUTTON: string = 'reset_factory_button';
const DELAY_TIMEOUT: number = 5000;
const DELAY_LOGOUT_RESET_ESIM_TIMEOUT_MS: number = 10 * 1000;
const DELAY_RESET_ESIM_TIMEOUT_MS: number = 1000;
const SERVICE_BUNDLE_NAME = 'com.ohos.meetimeservice';
const ACCOUNT_MANAGER_SERVICE_ABILITY_NAME = 'AccountManagerServiceExtension';

/**
 * 恢复出厂共用逻辑管理类
 *
 * @since 2025-03-17
 */
export class ResetFactoryManager {
  private static manager: ResetFactoryManager | undefined = undefined;
  private isResettingEsim: boolean = false;
  private isFactoryResetting: boolean = false;

  /**
   * 获取管理类实例
   *
   * @returns 管理类实例
   */
  public static getInstance(): ResetFactoryManager {
    if (ResetFactoryManager.manager) {
      return ResetFactoryManager.manager;
    }
    ResetFactoryManager.manager = new ResetFactoryManager();
    return ResetFactoryManager.manager;
  }

  /**
   *
   * @param context 上下文
   * @returns 管理类实例
   */
  public async LogoutAndReset(context: ContextF, isResetAll: boolean = false): Promise<void> {
    LogUtil.info(`${TAG} logout account start.`);
    this.showLoading(context);
    try {
      const logoutPromise = (async () => {
        try {
          // 退登畅连帐号
          await this.logoutMeetAccount(context);
          LogUtil.info(`${TAG} Logout success.`);
        } catch (error) {
          LogUtil.error(`${TAG} Logout failed: ${error?.code}:${error?.message}`);
          throw new Error('Logout failed');
        }
      })();
      await this.executeWithTimeout(logoutPromise, DELAY_TIMEOUT);
    } catch (error) {
      LogUtil.warn(`${TAG} Logout failed or timed out, starting factory reset...`);
    } finally {
      if (isResetAll) {
        // 重置eSIM
        await this.safeResetEsim();
      }
      // 恢复出厂
      await this.safeFactoryReset();
    }
  }

  private factoryReset(): void {
    HiSysEventUtil.reportButtonEvent(RESET_FACTORY_BUTTON, '');
    LogUtil.info(`${TAG} system reset start.`);
    let restorer: Updater.Restorer = Updater.getRestorer();
    restorer.factoryReset();
    LogUtil.info(`${TAG} system reset finish.`);
  }

  private async showLoading(context: ContextF): Promise<void> {
    LogUtil.showInfo(TAG, 'showLoading');
    if (!context) {
      LogUtil.warn(`${TAG} the context is invalid, showLoading return.`);
      return;
    }
    let sysDialogWant: Want = {
      bundleName: 'com.ohos.sceneboard',
      abilityName: 'com.ohos.sceneboard.systemdialog'
    }
    let options: common.ConnectOptions = {
      onConnect(elementName, remote): void {
        LogUtil.showInfo(TAG, 'onConnect callback');
        if (remote === null) {
          LogUtil.showWarn(TAG, 'onConnect remote is null');
          return;
        }
        let option = new rpc.MessageOption();
        let data = new rpc.MessageSequence();
        let reply = new rpc.MessageSequence();
        data.writeInt(3);
        data.writeString('bundleName');
        data.writeString('com.ohos.settings');
        data.writeString('abilityName');
        data.writeString('ResetLogoutLoadingAbility');
        data.writeString('parameters');
        data.writeString(`{"ability.want.params.uiExtensionType":"sysDialog/common","sysDialogZOrder": 1 }`);

        remote.sendMessageRequest(1, data, reply, option).then((ret) => {
          let msg = reply.readInt();
          LogUtil.showInfo(TAG, `sendMessageRequest msg: ${msg}`);
        }).catch((error: BusinessError) => {
          LogUtil.showError(TAG, `sendMessageRequest failed err: ${error?.message}`);
        }).finally(() => {
          data.reclaim();
          reply.reclaim();
        });
      },
      onDisconnect(elementName): void {
        LogUtil.showInfo(TAG, 'onDisconnect callback');
      },
      onFailed(code): void {
        LogUtil.showInfo(TAG, `onFailed, code: ${code}`);
      }
    }

    try {
      let connectionId =
        (context as common.ServiceExtensionContext).connectServiceExtensionAbility(sysDialogWant, options);
      LogUtil.showInfo(TAG, `connectionId: ${connectionId}`);
    } catch (err) {
      LogUtil.showError(TAG, `err code: ${err?.code} message: ${err?.message}`);
    }
  }

  private async beforeRequestLogin(context: ContextF):
    Promise<null | Record<string, number | AccountManagerServiceProxy | string>> {
    if (!context) {
      LogUtil.info(`${TAG} the context is invalid, beforeRequestLogin return.`);
      return null;
    }
    // 获取调用方abilityName
    let callerAbilityName =
      (context as common.UIExtensionContext | common.ServiceExtensionContext)?.extensionAbilityInfo?.name;
    if (StringUtil.isEmpty(callerAbilityName)) {
      callerAbilityName = (context as common.UIAbilityContext)?.abilityInfo.name;
    }
    // 获取公共服务访问代理
    let result = await this.connectAccountService(context);
    if (result === null) {
      LogUtil.error(`${TAG}  the accountServiceProxy is invalid when ability ${callerAbilityName} calling.`);
      return null;
    }
    (result as Record<string, number | AccountManagerServiceProxy | string>).callerAbility = callerAbilityName;
    LogUtil.info(`${TAG} start to request with ${result?.connectId}.`);
    // 获取公共服务访问句柄
    return result;
  }

  /**
   * 获取与accountService的一个连接，如果有现成的链接，则返回proxy句柄。
   *
   * @param context - 上下文
   * @returns 返回proxy句柄对象
   */
  private async connectAccountService(context: ContextF):
    Promise<null | Record<string, number | AccountManagerServiceProxy>> {
    return new Promise((resolve, reject) => {
      let want: Want = {
        bundleName: SERVICE_BUNDLE_NAME,
        abilityName: ACCOUNT_MANAGER_SERVICE_ABILITY_NAME
      };
      let options: common.ConnectOptions = {
        onConnect: (elementName, remote): void => {
          LogUtil.info(`${TAG} onConnect callback.`);
          if (remote === null) {
            LogUtil.error(`${TAG} onConnect remote is null.`);
          }
          let proxy = new AccountManagerServiceProxy(remote);
          let record: Record<string, AccountManagerServiceProxy | number> = {
            'proxy': proxy,
            'connectId': connectId
          };
          resolve(record);
        },
        onDisconnect(): void {
          LogUtil.info(`${TAG} onDisconnect callback.`);
          resolve(null);
        },
        onFailed(): void {
          LogUtil.error(`${TAG} onFailed callback.`);
          resolve(null);
        }
      };
      let connectId = context?.connectServiceExtensionAbility(want, options);
      LogUtil.showInfo(TAG, `connectAccountService connectId: ${connectId}`);
    });
  }

  private async logoutMeetAccount(context: ContextF): Promise<void> {
    LogUtil.info(`${TAG} logoutMeetAccount before.`);
    let result = await this.beforeRequestLogin(context);
    if (result === null) {
      LogUtil.error(`${TAG} logoutMeetAccount is error when create login proxy.`);
      return;
    }
    let accountServiceProxy = result.proxy as AccountManagerServiceProxy;
    LogUtil.info(`${TAG} logoutMeetAccount start.`);
    await accountServiceProxy?.logout().then(() => {
      LogUtil.info(`${TAG} logoutMeetAccount meetime end.`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} logoutMeetAccount failed: ${error?.code}:${error?.message}`);
    });
  }

  private async logoutHwAccount(): Promise<void> {
    // try {
    //   LogUtil.info(`${TAG} logoutHwAccount start.`);
    //   const provider = new authentication.HuaweiIDProvider();
    //   const logoutRequest: authentication.LogoutRequest = {
    //     logoutType: authentication.LogoutType.RESET
    //   };
    //   await provider.logout(getContext(this), logoutRequest).then(() => {
    //     LogUtil.info(`${TAG} logoutHwAccount end.`);
    //   }).catch((error: BusinessError) => {
    //     LogUtil.error(`${TAG} logoutHwAccount logout failed: ${error?.code}:${error?.message}`);
    //   });
    // } catch (error) {
    //   LogUtil.error(`${TAG} logoutHwAccount error: ${error?.code}:${error?.message}`);
    // }
  }

  private executeWithTimeout<T>(promise: Promise<T>, timeoutMs: number): Promise<T> {
    return Promise.race([
      promise,
      new Promise<never>((_, reject) =>
      setTimeout(() => {
        reject(new Error(`Operation timed out after ${timeoutMs}ms`));
      }, timeoutMs)
      )
    ]);
  }

  public async safeFactoryReset(): Promise<void> {
    if (this.isFactoryResetting) {
      return;
    }
    this.isFactoryResetting = true;
    try {
      LogUtil.info(`${TAG} [FACTORY] factory reset...`);
      this.factoryReset();
    } catch (error) {
      LogUtil.error(`${TAG} [FACTORY] Factory reset failed: ${error?.code}:${error?.message}`);
    } finally {
      this.isFactoryResetting = false;
    }
  }

  private async safeResetEsim(): Promise<void> {
    if (this.isResettingEsim) {
      return;
    }
    this.isResettingEsim = true;
    try {
      if (DeviceUtil.isDevicePhone() && DeviceUtil.isSupportEsim()) {
        LogUtil.info(`${TAG} [ESIM] Starting reset with 10s timeout...`);
        await this.executeWithTimeout(this.resetEsim(), DELAY_LOGOUT_RESET_ESIM_TIMEOUT_MS);
        LogUtil.info(`${TAG} [ESIM] Reset completed.`);
      }
    } catch (error) {
      LogUtil.error(`${TAG} [ESIM] Reset failed or timed out: ${error?.code}:${error?.message}`);
    } finally {
      this.isResettingEsim = false;
    }
  }

  private delayExecute(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  private async resetEsim(): Promise<void> {
    try {
      LogUtil.info(`${TAG} reset eSIM start.`);
      const sim1: SimLabel = {
        simType: SIM_TYPE_PSIM,
        index: SIM_LABEL_INDEX_ONE,
      };
      const sim2: SimLabel = {
        simType: SIM_TYPE_PSIM,
        index: SIM_LABEL_INDEX_TWO,
      };
      const esim: SimLabel = {
        simType: SIM_TYPE_ESIM,
        index: SIM_LABEL_INDEX_ONE,
      };

      LogUtil.info(`${TAG} step1: enable sim. enable label is sim1 & esim.`);
      // const isEnabledSuccess: boolean = await enhanced.enableSim(sim1, esim);
      // LogUtil.info(`${TAG} enable sim result is ${isEnabledSuccess}.`);

      await this.delayExecute(DELAY_RESET_ESIM_TIMEOUT_MS);

      LogUtil.info(`${TAG} step2: reset eSIM.`);
      let resetResultCode: eSIM.ResultCode;
      let retryCount = 0;
      do {
        resetResultCode = await eSIM.resetMemory(SIM_LABEL_INDEX_ONE);
        LogUtil.info(`${TAG} reset eSIM result is ${resetResultCode === eSIM.ResultCode.RESULT_OK}.`);
        if (resetResultCode !== eSIM.ResultCode.RESULT_OK) {
          retryCount++;
          if (retryCount < 2) {
            LogUtil.warn(`${TAG} reset eSIM failed, retrying...`);
          } else {
            LogUtil.error(`${TAG} reset eSIM failed after 2 retries.`);
          }
        }
      } while (resetResultCode !== eSIM.ResultCode.RESULT_OK && retryCount < 2);

      LogUtil.info(`${TAG} step3: enable sim. enable label is sim1 & sim2.`);
      // const isReEnabledSuccess: boolean = await enhanced.enableSim(sim1, sim2);
      // LogUtil.info(`${TAG} enable sim result is ${isReEnabledSuccess}.`);
    } catch (error) {
      LogUtil.error(`${TAG} reset eSIM error: ${error?.code}:${error?.message}`);
    }
  }
}