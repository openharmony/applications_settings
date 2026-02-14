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
import { util } from '@kit.ArkTS';
import account_osAccount from '@ohos.account.osAccount';
import osAccount from '@ohos.account.osAccount';
import { settings } from '@kit.BasicServicesKit';
import Log from './Log';
import SecurityManager from '../../security/SecurityManager';
import { getCredentials } from '../PrivacyPassword';

const TAG = 'PasswordUtils';

/**
 * extraInfo类型
 */
export interface extraInfoI {
  token?: string;
  remainTimes?: number;
  freezingTime?: number;
  credentialId?: Uint8Array;
}

/**
 * 密码子类型
 */
export enum PinSubType {
  /**
   * 六位数字密码
   */
  PIN_SIX = 10000,
  /**
   * 纯数字密码
   */
  PIN_NUMBER = 10001,
  /**
   * 混合密码
   */
  PIN_MIXED = 10002,
}

/**
 * 属性列表
 */
enum GetPropertyType {
  /**
   * 鉴权子类型
   */
  AUTH_SUB_TYPE = 1,
  /**
   * 鉴权剩余次数
   */
  REMAIN_TIMES = 2,
  /**
   * 鉴权冻结时间
   */
  FREEZING_TIME = 3,
}

/**
 * 认证结果的可信度
 */
enum AuthTrustLevel {
  /**
   * 可信度一级
   */
  ATL1 = 10000,
  /**
   * 可信度二级
   */
  ATL2 = 20000,
  /**
   * 可信度三级
   */
  ATL3 = 30000,
  /**
   * 可信度四级
   */
  ATL4 = 40000,
}

/**
 * 正则常量：纯数字
 */
const PASSWORD_NUMBER_ONLY: RegExp = new RegExp('^[0-9]+$');

const PRIVATE_PASSWORD_PROTECT = 'private_password_protect';

/**
 * 正则常量：不合法字符
 */
const PASSWORD_ILLEGAL: RegExp =
  new RegExp('^(?=.*[^0-9a-zA-Z\\\\/\:\;\(\)\$\&\@\"\\]\\[\}\{\#\%\^\*\+\_\\-\`\?\!\'\.\,])');

/**
 * 正则常量：六位数字
 */
const PASSWORD_NUMBER_SIX: RegExp = new RegExp('^[0-9]{6}$');

/**
 * 正则常量：至少包含一个字母
 */
const PASSWORD_INCLUDE_AT_LEAST_ONE_LETTER: RegExp = new RegExp('^.*[a-zA-Z]+.*$');

/**
 * 密码增删改查的结果枚举值
 */
export enum ResultCode {
  /**
   * 操作成功
   */
  SUCCESS = 0,
  /**
   * 操作失败
   */
  FAIL = 1,
  /**
   * token超时
   */
  INVALID_TOKEN = 12300101,
}

export class PasswordUtils {
  private static SecurityManagerInstance = SecurityManager.getInstance();
  private static userIdentityManager: account_osAccount.UserIdentityManager =
    new account_osAccount.UserIdentityManager();

  /**
   * 调用安全子系统 api 打开 Session
   *
   * @param tag 调用方
   * @returns challenge 值
   */
  static async openSession(tag: string): Promise<string> {
    Log.info(TAG, `start open session, called by ${tag}`);
    try {
      let data = await PasswordUtils.userIdentityManager.openSession();
      Log.info(TAG, `openSession ok.`);
      SecurityManager.getInstance().setChallenge(data);
      return PasswordUtils.uint8ArrayToString(data);
    } catch (e) {
      Log.error(TAG, `openSession error, error code: ${e?.code}, message: ${e?.message}.`);
      return '';
    }
  }

  /**
   * 调用安全子系统 api 关闭session
   *
   * @param tag 调用方
   * @returns
   */
  static closeSession(tag: string): void {
    Log.info(TAG, `start close session, called by ${tag}`);
    try {
      return PasswordUtils.userIdentityManager.closeSession();
    } catch (error) {
      Log.error(TAG, `close session failed, error: ${error.code}`);
      return;
    }
  }

  /**
   * 判断当前输入密码类型是不是6位数字密码
   *
   * @param password 密码
   */
  static isPinNumber6(password: string): boolean {
    if (!password) {
      return false;
    }
    return PASSWORD_NUMBER_SIX.test(password);
  }

  /**
   * 将字符串转码为 Uint8Array
   *
   * @return Uint8Array
   */
  static stringToUint8Array(val: string): Uint8Array {
    if (!val) {
      return new Uint8Array([]);
    }
    let textEncoder: util.TextEncoder = new util.TextEncoder();
    return textEncoder.encode(val);
  }

  /**
   * 调用安全子系统 api 注册监听用户输入的内容
   *
   * @return 注册成功返回 true，注册失败返回 false
   */
  static registerInputer(pinSubType: number): void {
    let result = false;
    try {
      let pinAuth = new osAccount.PINAuth();
      pinAuth?.registerInputer({
        onGetData: (authSubType, inputData) => {
          try {
            let u8aPwd = PasswordUtils.stringToUint8Array(SecurityManager.getInstance().getPassword());
            Log.info(TAG, 'register input subType' + pinSubType);
            inputData.onSetData(pinSubType, u8aPwd);
          } catch (err) {
            Log.error(TAG, `registerInputer onSetData failed`);
          }
        },
      });
    } catch (e) {
      Log.error(TAG, `registerInputer failed`);
    }
  }

  /**
   * 调用安全子系统 api 注册监听用户输入的内容
   *
   * @return
   */
  static registerPriPwdInputer(pinSubType: number, inputData: string): void {
    try {
      let pinAuth = new osAccount.PINAuth();
      pinAuth?.registerInputer({
        onGetData: (authSubType, inputCallback, options) => {
          try {
            if (authSubType == osAccount.AuthSubType.PIN_QUESTION) {
              Log.info(TAG, `register callback pin question`);
            } else {
              Log.info(TAG, `register callback authSubType: ${authSubType}`);
            }
            inputCallback.onSetData(pinSubType, PasswordUtils.stringToUint8Array(inputData));
          } catch (e) {
            Log.error(TAG, `registerInputer onSetData failed`);
          }
        }
      });
    } catch (e) {
      Log.error(TAG, `registerInputer failed`);
    }
  }

  /**
   * 验证密保问题答案
   *
   * @param challenge openSession获取的challenge
   * @param onResult callback
   * @return
   */
  static authQuestion(challenge: Uint8Array, onResult: (result: number, extraInfo: extraInfoI) => void): void {
    try {
      let options: osAccount.AuthOptions = {
        authIntent: osAccount.AuthIntent.QUESTION_AUTH
      };
      let userAuth = new osAccount.UserAuth();
      userAuth.auth(challenge, osAccount.AuthType.PRIVATE_PIN,
        osAccount.AuthTrustLevel.ATL4, options, {
          onResult: (result, extraInfo) => {
            let info: extraInfoI = {
              token: PasswordUtils.uint8ArrayToString(extraInfo.token),
              remainTimes: extraInfo.remainTimes,
              freezingTime: extraInfo.freezingTime
            }
            SecurityManager.getInstance().setToken(extraInfo.token);
            onResult(result, info);
          }
        })
    } catch (error) {
      Log.error(TAG, `auth failed, errorCode: ${error?.code}, error message:${error?.message}`);
    }
  }

  /**
   * 更新隐私密码
   *
   * @param pwdSubType 隐私密码SubType
   * @param token 认证时获取的token
   * @param onResultCall callback
   * @return
   */
  static updatePriPwd(pwdSubType: number, token: Uint8Array,
    onResultCall: (result: number, extraInfo: extraInfoI) => void): void {
    try {
      let credentialInfo: osAccount.CredentialInfo = {
        credType: osAccount.AuthType.PRIVATE_PIN,
        credSubType: pwdSubType,
        token: token
      }
      let callback: osAccount.IIdmCallback = {
        onResult: (result, extraInfo) => {
          let retExtraInfo: extraInfoI = {
            credentialId: extraInfo.credentialId
          };
          onResultCall(result, retExtraInfo);
        }
      }
      PasswordUtils.userIdentityManager?.updateCredential(credentialInfo, callback);
    } catch (error) {
      Log.error(TAG, `updateCredential failed, errorCode: ${error?.code}, error message: ${error?.message}`);
    }
  }

  /**
   * 查询隐私密码类型及状态
   *
   * @return 查询成功返回ExecutorProperty，失败返回null
   */
  static async queryPriPwdType(): Promise<account_osAccount.ExecutorProperty | null> {
    let keys = [osAccount.GetPropertyType.AUTH_SUB_TYPE, osAccount.GetPropertyType.REMAIN_TIMES,
      osAccount.GetPropertyType.FREEZING_TIME];
    let request: osAccount.GetPropertyRequest = {
      authType: osAccount.AuthType.PRIVATE_PIN,
      keys: keys
    };
    let userAuth = new osAccount.UserAuth();
    try {
      let result = await userAuth.getProperty(request);
      return result;
    } catch (error) {
      Log.error(TAG, `query private pwd type failed, error: ${error.code}`);
      return null;
    }
  }

  /**
   * 查询密保问题状态
   *
   * @return 查询成功返回ExecutorProperty，失败返回null
   */
  static async queryQuestionStatus(): Promise<osAccount.ExecutorProperty | null> {
    try {
      let userAuth = new osAccount.UserAuth();
      let credentials = await PasswordUtils.userIdentityManager.getAuthInfo(osAccount.AuthType.PRIVATE_PIN);
      for (let i = 0; i < credentials.length; i++) {
        if (credentials[i].authSubType === osAccount.AuthSubType.PIN_QUESTION) {
          let keys = [osAccount.GetPropertyType.AUTH_SUB_TYPE, osAccount.GetPropertyType.REMAIN_TIMES,
            osAccount.GetPropertyType.FREEZING_TIME];
          let res = await userAuth.getPropertyByCredentialId(credentials[i].credentialId, keys);
          return res;
        }
      }
      return null;
    } catch (error) {
      Log.error(TAG, `query question status failed, errorCode: ${error?.code}, error message: ${error?.message}`);
      return null;
    }
  }

  /**
   * 调用安全子系统 api 解注册
   */
  static unregisterInputer(): void {
    try {
      let pinAuth: osAccount.PINAuth = new osAccount.PINAuth();
      pinAuth?.unregisterInputer();
    } catch (e) {
      Log.error(TAG, `unregisterInputer failed`);
    }
  }

  /**
   * 删除隐私密码
   *
   * @return boolean
   */
  static async deletePassword(): Promise<boolean> {
    try {
      const c = await getCredentials();
      Log.info(TAG, 'getCredentials:' + c.length);
      const results = await Promise.all(c.map(p => PasswordUtils.deletePasswordProm(p.credentialId)));
      return results.every(p => p === 0);
    } catch (e) {
      Log.error(TAG, `deletePassword error, error code: ${e?.code}, message: ${e?.message}.`);
      return false;
    }
  }

  /**
   * 通过 credentialId 将 凭据 删除
   *
   * @param credentialId Uint8Array
   * @return result 值
   */
  static async deletePasswordProm(credentialId: Uint8Array): Promise<number> {
    return new Promise((r, j) => {
      let callback: osAccount.IIdmCallback = {
        onResult: (result, extraInfo) => {
          r(result);
        },
      };
      PasswordUtils.userIdentityManager?.delCred(credentialId, SecurityManager.getInstance().getToken(), callback);
    })
  }

  /**
   * 将 Uint8Array 转码为字符串
   *
   * @param val Uint8Array
   * @return 字符串
   */
  static uint8ArrayToString(val: Uint8Array): string {
    if (!val) {
      return '';
    }

    let arrNumber: number[] = [];
    for (const element of val) {
      arrNumber.push(element);
    }

    return JSON.stringify(arrNumber);
  }

  /**
   * 调用安全子系统 api 校验密码是否正确
   *
   * @param challenge 值
   * @param password 密码
   * @param onResult 结果回调
   */
  static authPin(challenge: Uint8Array, password: string,
    onResult: (result: number, extraInfo: extraInfoI) => void): void {
    try {
      SecurityManager.getInstance().setPassword(password);
      let userAuth = new osAccount.UserAuth();
      userAuth?.auth(challenge, osAccount.AuthType.PRIVATE_PIN,
        AuthTrustLevel.ATL4, {
          onResult: (result, extraInfo) => {
            const info: extraInfoI = {
              token: PasswordUtils.uint8ArrayToString(extraInfo?.token),
              remainTimes: extraInfo?.remainTimes,
              freezingTime: extraInfo?.freezingTime,
              credentialId: extraInfo.credentialId
            };
            if (result === ResultCode.SUCCESS) {
              SecurityManager.getInstance().setToken(extraInfo?.token);
            } else {
              Log.error(TAG, `auth failed`);
            }
            onResult(result, info);
          },
          onAcquireInfo: (acquireModule, acquire, extraInfo: Uint8Array) => {
          }
        });
    } catch (e) {
      Log.error(TAG, `authPin failed`);
    }
  }

  /**
   * 判断当前输入密码类型是不是弱密码
   *
   * @param password 密码
   * @return true 当密码为弱密码时
   */
  static isWeakPasswords(password: string): boolean {
    if (!password) {
      return false;
    }
    let arr: string[] = password.split('');
    let item: string;
    let isAllSame: boolean = true;
    for (item of arr) {
      if (arr[0] !== item) {
        isAllSame = false;
        break;
      }
    }
    if (isAllSame) {
      return true;
    }
    if (PasswordUtils.isAscendingOrDescendingOrder(arr.length, arr.map(Number))) {
      return true;
    }
    return false;
  }

  /**
   * 在弹出“校验密码”的弹窗之前，先获取当前密码校验的操作是否已被冻结
   *
   * @param callback 数据回调
   */
  static getAuthProperty(callback: (data: osAccount.ExecutorProperty) => void): void {
    Log.info(TAG, `getAuthProperty in.`);
    try {
      const request: osAccount.GetPropertyRequest = {
        authType: osAccount.AuthType.PRIVATE_PIN,
        keys: [GetPropertyType.AUTH_SUB_TYPE, GetPropertyType.REMAIN_TIMES, GetPropertyType.FREEZING_TIME],
      };
      const userAuth: osAccount.UserAuth = new osAccount.UserAuth();
      userAuth?.getProperty(request)
      ?.then((data) => {
        callback(data);
      });
    } catch (e) {
      Log.error(TAG, `getAuthProperty failed`);
    }
  };

  /**
   * 判断密码是不是纯数字
   *
   * @param password 密码
   */
  static isOnlyNumber(password: string): boolean {
    if (!password) {
      return false;
    }
    return PASSWORD_NUMBER_ONLY.test(password);
  }

  /**
   * 判断密码是否包含非法字符，不在下面合法字符范围内的字符均是非法字符： 0-9、a-z、A-Z 、'\'、'/'、':'、';'、'('、')'、
   * '$'、'&'、'@'、'"'、'['、']'、'{'、'}'、'#'、'%'、'^'、'*'、'+'、'_'、'-'、'`'、'?'、'!'、'''、'.'、','
   *
   * @param password 密码
   * @return true 当密码包含非法字符时
   */
  static isContainIllegalCharacter(password: string): boolean {
    if (!password) {
      return false;
    }
    return PASSWORD_ILLEGAL.test(password);
  }

  /**
   * 判断密码是否至少包含一个字母
   *
   * @param password 密码
   */
  static isIncludeAtLeastOneLetter(password: string): boolean {
    if (!password) {
      return false;
    }
    return PASSWORD_INCLUDE_AT_LEAST_ONE_LETTER.test(password);
  }

  /**
   * 清除settings数据库中的密保问题
   *
   * @return true 删除成功, false 删除失败
   */
  static clearQuestionInDb(context: Context): boolean {
    try {
      let result =
        settings.setValueSync(context, PRIVATE_PASSWORD_PROTECT, '', settings.domainName.USER_SECURITY);
      if (!result) {
        Log.error(TAG, 'clear password protect question fail');
        return false;
      }
      Log.info(TAG, `clear password protect question success`);
      return true;
    } catch (error) {
      Log.error(TAG,
        `clear password protect question fail, errorCode: ${error?.code}, error message: ${error?.message}`);
    }
    return false;
  }

  /**
   * 判断密码是否等差数列
   *
   * @param password 密码
   * @Param pwdListLength 密码长度
   * @return true 当密码为等差数列时
   */
  private static isAscendingOrDescendingOrder(pwdListLength: number, passwords: number[]): boolean {
    let isWeakPwd: boolean = true;
    let rank: number = passwords[1] - passwords[0];
    if (Math.abs(rank) !== 1) {
      return false;
    }
    for (let i: number = 0; i < pwdListLength - 1; i++) {
      if (passwords[i + 1] - passwords[i] !== rank) {
        isWeakPwd = false;
        break;
      }
    }
    return isWeakPwd;
  }
}