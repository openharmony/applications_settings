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

import { abilityAccessCtrl, bundleManager, common } from '@kit.AbilityKit';
import Want from '@ohos.application.Want';
import settings from '@ohos.settings';
import { Constants } from '../constant/PackagesConstant';
import { SettingsDataUtils } from './SettingsDataUtils';
import { LogUtil } from './LogUtil';

const TAG: string = 'WalletManageUtils : ';
const ACCESS_SYSTEM_SETTINGS = 'ohos.permission.ACCESS_SYSTEM_SETTINGS';

export class WalletManageUtils {

  /**
   * 判断当前应用是否从钱包中启动
   *
   * @return {boolean} 如果当前应用是从钱包中启动的，返回true，否则返回false
   */
  public static isFromWallet(): boolean {
    // 从AppStorage中获取'wantParams'的值，并将其转换为Want类型
    let params = AppStorage.get<Want>('wantParams')?.parameters as Record<string, string>;
    if (params === undefined || params === null) {
      LogUtil.error(`isFromWallet wantParams is invalid`)
      return false;
    }
    let caller: string = '';
    // 遍历params对象的所有键值对
    Object.entries(params)?.forEach(
      // 对每个键值对，如果键为'ohos.aafwk.param.callerBundleName'，则将其值赋给caller
      (value: [key: string, value: string], index: number) => {
        if (value[0] === 'ohos.aafwk.param.callerBundleName') {
          caller = value[1];
        }
      }
    );
    // 如果caller的值为'com.ohos.wallet'，则表示当前应用是从钱包中启动的，返回true
    if (caller === 'com.ohos.wallet') {
      return true;
    }
    LogUtil.info(`${TAG} isNotFromWallet`);
    return false;
  }

  /**
   * 被调用Ability结束后返回结果
   *
   * @param tag
   */
  public static sendAbilityResultToWallet(result: number): void {
    /* instrument ignore if*/
    if (this.isFromWallet()) {
      let want: Want = {
        bundleName: 'com.ohos.wallet',
        abilityName: 'sendResult',
        parameters: { 'bundleName': 'com.ohos.settings' }
      };
      let resultCode = result;
      // 返回给接口调用方AbilityResult信息
      let abilityResult: common.AbilityResult = { want, resultCode };
      try {
        let context = AppStorage.get<common.UIAbilityContext>('pageContext') as common.UIAbilityContext;
        context?.terminateSelfWithResult(abilityResult)
          .catch((err) => {
            LogUtil.info(`${TAG} terminateSelfWithResult failed, code is ${err?.code}, message is ${err?.message}`);
          });
        LogUtil.info(`${TAG} terminateSelfWithResult success, code is ${resultCode}`);
      } catch (err) {
        LogUtil.info(`${TAG} terminateSelfWithResult failed, code is ${err?.code}, message is ${err?.message}`);
      }
    }
  }

  /**
   * 启动钱包清理能力
   * 通过调用服务扩展能力，启动钱包的清理服务
   *
   * @throws 如果启动服务扩展能力失败，将抛出错误
   */
  public static startWalletCleanAbility(): void {
    LogUtil.info(`${TAG} startWalletCleanAbility begin`);
    try {
      let want: Want = {
        bundleName: 'com.ohos.wallet',
        abilityName: 'DisableScreenLockSrvExtAbility',
        parameters: {
          'isFrom': 'com.ohos.settings',
          'operator': 'deletePassWord'
        },
      };
      // 获取页面上下文
      let context = AppStorage.get<common.UIAbilityContext>('pageContext') as common.UIAbilityContext;
      context?.startServiceExtensionAbility(want).then(() => {
        LogUtil.info(`${TAG} Succeeded in starting startWalletCleanAbility.`);
      }).catch((err) => {
        LogUtil.error(`${TAG} Failed to start startWalletCleanAbility. Code is ${err?.code}, message is ${err?.message}`);
      });
    } catch (e) {
      LogUtil.error(`${TAG} Failed to start startWalletCleanAbility, message is ${e?.message}`);
    }
  }

  /**
   * 校验钱包ACCESS_SYSTEM_SETTINGS权限
   *
   * @returns {boolean} 如果钱包有ACCESS_SYSTEM_SETTINGS权限，返回true，否则返回false
   */
  public static checkWalletPermission(): boolean {
    let atManager = abilityAccessCtrl.createAtManager();
    let info = bundleManager.getApplicationInfoSync('com.ohos.wallet',
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO);
    let callerTokenId: number = info?.accessTokenId;
    /* instrument ignore next */
    try {
      let grantStatus = atManager?.verifyAccessTokenSync(callerTokenId, ACCESS_SYSTEM_SETTINGS);
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        LogUtil.info(`${TAG} isFromWallet`);
        return true;
      }
    } catch (err) {
      LogUtil.showError(TAG, `${TAG} errInfo: ${err?.message}`);
      return false;
    }
    LogUtil.info(`${TAG} isNotFromWallet`);
    return false;
  }

  /**
   * 校验钱包appIdentifier
   *
   * @returns {boolean} 如果id校验为钱包，返回true，否则返回false
   */
  public static checkWalletAppIdentifier(): boolean {
    let info = bundleManager.getBundleInfoSync('com.ohos.wallet',
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO);
    /* instrument ignore next */
    if (Constants.WALLET_IDENTIFIER === info.signatureInfo.appIdentifier) {
      LogUtil.info(`${TAG} wallet is installed`);
      return true;
    } else {
      LogUtil.warn(`${TAG} wallet is forged`);
      return false;
    }
  }

  /**
   * 检查是否为高安全级别
   *
   * @return {boolean} 如果是高安全级别，返回true，否则返回false
   * @throws {Error} 如果获取安全级别值失败，将抛出错误
   */
  public static checkIfHighSecurity(): boolean {
    try {
      // 从设置数据中获取安全级别的值
      let highSecurityLevel = SettingsDataUtils.getSettingsData('payment_security_level', '', settings.domainName.USER_SECURITY);
      // 记录获取到的安全级别值
      LogUtil.info(`${TAG} get high security flag successfully, the value is ${highSecurityLevel}.`);
      // 如果安全级别值为true或1，则返回true
      return highSecurityLevel === 'true' || highSecurityLevel === '1';
    } catch (error) {
      // 如果获取安全级别值失败，记录错误信息并返回false
      LogUtil.error(`${TAG} get highSecurityLevel Failed`);
      return false;
    }
  }

  /**
   * 判断是否三位连续相同。
   *
   * @param str 密码
   * @returns true 当密码三位连续相同时
   */
  public static hasThreeSameCharts(str: string): boolean {
    let strLength: number = str.length;
    for (let i = 0; i <= strLength - 3; i++) {
      if (str.charCodeAt(i) === str.charCodeAt(i + 1) && str.charCodeAt(i + 1) === str.charCodeAt(i + 2)) {
        return true;
      }
    }
    return false;
  }

  /**
   * 判断是否连续三位递增递减。
   *
   * @param str 密码
   * @returns true 连续三位递增递减
   */
  public static hasThreeContinousCharts(str: string): boolean {
    let strLength: number = str.length;
    for (let i = 0; i <= strLength - 3; i++) {
      const first = str.charCodeAt(i);
      const second = str.charCodeAt(i + 1);
      const third = str.charCodeAt(i + 2);
      if ((second === first + 1 && third === second + 1) || (second === first - 1 && third === second - 1)) {
        return true;
      }
    }
    return false;
  }
}