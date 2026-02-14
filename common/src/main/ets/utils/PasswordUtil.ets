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

import util from '@ohos.util';
import { BusinessError } from '@ohos.base';
import buffer from '@ohos.buffer';
import osAccount from '@ohos.account.osAccount'
import window from '@ohos.window';
import settings from '@ohos.settings';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from './LogUtil';
import { HiSysEventUtil } from '../systemEvent/HiSysEventUtil';
import { PRIVACY_PORTRAIT_PAGES, NavEntryKey } from './Consts';
import SecurityContext from '../context/SecurityContext';
import { CheckEmptyUtils } from './CheckEmptyUtils';
import { StringUtil } from './StringUtil';
import { SettingsDataUtils } from './SettingsDataUtils';
import lazy { AccountConstants } from '../constant/AccountConstants';
import lazy { ResourceUtil } from './ResourceUtil';
import lazy { AccountUtil } from './AccountUtil';
import { WalletManageUtils } from './WalletManageUtils';
import { PasswordManager } from '../passwordManager/PasswordManager';
import { HiSysPasswdModificationOccurEvent } from '../systemEvent/BehaviorEventConsts';
import { CommonUtils } from './CommonUtils';

/**
 * 密码最小长度
 */
export const LOCK_SCREEN_PSD_LENGTH_MIN: number = 6;

/**
 * 密码最大长度
 */
export const LOCK_SCREEN_PSD_LENGTH_MAX: number = 32;

/**
 * 倒计时时间单位阈值，以一分钟为界，在分钟和秒之间切换
 */
export const COUNT_DOWN_ONE_MIN: number = 60;

/**
 * 倒计时时间单位阈值，以一小时为界，在分钟和小时之间切换
 */
export const COUNT_DOWN_ONE_HOUR: number = 60 * 60;

/**
 * 毫秒换算为秒的单位换算比例
 */
export const MILE_SECOND_TO_SECOND: number = 1000;

/**
 * 密码合法
 */
export const CHECK_PASSWORD_TYPE_VALID: number = 100;

/**
 * 密码太短
 */
export const CHECK_PASSWORD_TYPE_TOO_SHORT: number = 101;

/**
 * 密码太长
 */
export const CHECK_PASSWORD_TYPE_TOO_LONG: number = 102;

/**
 * 密码包含不合法字符
 */
export const CHECK_PASSWORD_TYPE_CONTAIN_ILLEGAL_CHARACTER: number = 103;

/**
 * 剩余可尝试次数默认值
 */
export const REMAIN_TIMES_DEFAULT: number = 5;

/**
 * 冻结时间默认值，单位：毫秒
 */
export const FREEZING_TIMES_DEFAULT: number = 0;

/**
 * 旧密码有效时间，单位：毫秒
 */
export const VALIDITY_TIMES_DEFAULT: number = 0;

/**
 * 空格站位字符
 */
export const SPACE_PLACE_HOLDER_STRING: ResourceStr = ' ';

/**
 * 指纹凭据类型
 */
export const FINGERPRINT_CRED_TYPE: number = 4;

/**
 * 指纹凭据子类型
 */
export const FINGERPRINT_SUB_CRED_TYPE: number = 10000;

/**
 * 指纹凭据KEY
 */
export const FINGERPRINT_CRED_KEY: [number] = [5];

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
  /**
   * 系统异常
   */
  SERVICE_ERROR = 12300001,
}

/**
 * 密码类型
 */
export enum AuthType {
  /**
   * PIN 密码
   */
  PIN = 1,
  /**
   * 人脸识别密码
   */
  FACE = 2,
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
  /**
   * 4位数PIN码
   */
  PIN_FOUR = 10003,
  /**
   * 图形密码
   */
  PIN_PATTERN = 10004,
}

/**
 * 用户密码类型
 */
export class UserPasswordInfo {
  hasPinPassword: boolean = false;
  authSubType: number = PinSubType.PIN_SIX;
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

const TAG = 'PasswordUtil : ';

/**
 * 正则常量：纯数字
 */
const PASSWORD_NUMBER_ONLY: RegExp = new RegExp('^[0-9]+$');

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
 * 正则常量：六位数字
 */
const PASSWORD_NUMBER_FOUR: RegExp = new RegExp('^[0-9]{4}$');

/**
 * 正则常量：至少包含一个字母
 */
const PASSWORD_INCLUDE_AT_LEAST_ONE_LETTER: RegExp = new RegExp('^.*[a-zA-Z]+.*$');

const CALLBACK_RESULT: number = -1;

interface authData {
  authType: number;
  authSubType: number;
}

export interface oldPasswordInfo {
  credentialId?: Uint8Array;
  hasOldPassword: boolean;
  validityPeriod: number;
  authSubType?: osAccount.AuthSubType;
}

export interface extraInfoI {
  token?: string;
  remainTimes?: number;
  freezingTime?: number;
  credentialId?: string;
  nextPhaseFreezingTime?: number;
}

interface credentialData {
  credentialId: Uint8Array;
  templateId: Uint8Array;
}

/**
 * 工具类（密码相关）
 *
 * @since 2022-05-12
 */
export class PasswordUtil {
  private static userIdentityManager: osAccount.UserIdentityManager = new osAccount.UserIdentityManager();

  /**
   * 将字符串转码为 Uint8Array
   *
   * @return Uint8Array
   */
  static stringToUint8Array(val: string): Uint8Array {
    if (!val) {
      return new Uint8Array([]);
    }
    let textEncoder = new util.TextEncoder();
    return textEncoder.encode(val);
  }

  /**
   * 将hex字符串转码为 Uint8Array
   *
   * @return Uint8Array
   */
  static hexStringToUint8Array(hexString: string): Uint8Array {
    let result: number[] = [];
    for (let i = 0; i < hexString.length; i += 2) {
      result.push(parseInt(hexString.substr(i, 2), 16));
    }
    return new Uint8Array(result);
  }

  /**
   * 将base64转换的字符串转码为 Uint8Array
   *
   * @return Uint8Array
   */
  static base64StringToUint8Array(val: string): Uint8Array {
    if (CheckEmptyUtils.checkStrIsEmpty(val)) {
      return new Uint8Array([]);
    }
    let buf: buffer.Buffer = buffer.from(val, 'base64');
    return Uint8Array.from(buf.values());
  }

  /**
   * 将Uint8Array转换为base64字符串
   *
   * @return Uint8Array
   */
  static uint8ArrayToBase64String(array: Uint8Array): string {
    if (!array || array.length === 0) {
      return '';
    }
    return buffer.from(Array.from(array)).toString('base64');
  }

  /**
   * 将获取到的challenge转码为 pinChallenge
   *
   * @return Uint8Array
   */
  static challengeToPinChallenge(challenge: string): string {
    challenge.replace(/[\r\n\t]/g, '');
    let challengeStr:string = JSON.parse(challenge).nonce;
    let challengeUint8Array = PasswordUtil.hexStringToUint8Array(challengeStr);
    return PasswordUtil.uint8ArrayToString(challengeUint8Array);
  }

  /**
   * 调用安全子系统 api 打开 Session
   *
   * @returns challenge 值
   */
  static openSession(callback: (challenge: string) => void): void {
    LogUtil.info(`${TAG} start open session.`);
    PasswordUtil.userIdentityManager.openSession().then((data) => {
      LogUtil.info(`${TAG} openSession ok.`);
      SecurityContext.getInstance().setChallenge(data);
      callback(PasswordUtil.uint8ArrayToString(data));
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} openSession failed.`);
      callback('0');
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
   * 调用安全子系统 api 关闭 Session
   */
  static closeSession(): void {
    LogUtil.info(`${TAG} start close session.`);
    try {
      PasswordUtil.userIdentityManager?.closeSession();
    } catch (e) {
      LogUtil.error(`${TAG} closeSession failed`);
    }
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
          let u8aPwd = PasswordUtil.stringToUint8Array(SecurityContext.getInstance().getPassword());
          inputData.onSetData(pinSubType, u8aPwd);
        },
      });
    } catch (e) {
      LogUtil.error(`${TAG} registerInputer failed`);
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
      LogUtil.error(`${TAG} unregisterInputer failed`);
    }
  }

  /**
   * 调用安全子系统 api 创建新密码
   *
   * @param pinSubType 密码子类型
   * @param password 密码
   * @param onResultCall 结果回调
   */
  static createPassword(pinSubType: number, password: string, onResultCall: (result: number) => void): void {
    HiSysEventUtil.reportDefaultFaultEvent(HiSysPasswdModificationOccurEvent.EVENT_NAME,
      HiSysPasswdModificationOccurEvent.CREATE_PASSWORD,
      `password type ${pinSubType}`);
    try {
      SecurityContext.getInstance().setPassword(password);
      let callback: osAccount.IIdmCallback = {
        onResult: (result, extraInfo) => {
          onResultCall(result);
        },
      }
      let dataToken = new Uint8Array([]);
      let credentialInfo: osAccount.CredentialInfo = {
        credType: AuthType.PIN,
        credSubType: pinSubType,
        token: dataToken,
      }
      PasswordUtil.userIdentityManager?.addCredential(credentialInfo, callback);
    } catch (e) {
      LogUtil.error(`${TAG} createPassword failed`);
    }
  }

  /**
   * 调用安全子系统 api 判断当前是否有密码已被设置
   *
   * @param callback 结果回调
   */
  static hasPinPassword(callback: (hasPinPassword: boolean) => void): void {
    try {
      PasswordUtil.getPinAuthInfo((data) => {
        let hasPinPassword = false;
        if (data?.length && data.length > 0) {
          hasPinPassword = true;
        }
        callback(hasPinPassword);
      });
    } catch (e) {
      LogUtil.error(`${TAG} get status of hasPinPassword failed`);
    }
  }

  /**
   * 调用安全子系统 api 获取当前的用户信息，从中解析出密码相关的数据
   *
   * @param callback 结果回调
   */
  static getPinAuthInfo(callback: (data: Array<authData>) => void): void {
    PasswordUtil.userIdentityManager.getAuthInfo(AuthType.PIN).then((pinPasswordInfo) => {
      let arrCredInfo: authData[] = [];
      if (!pinPasswordInfo) {
        LogUtil.error(`${TAG} getAuthInfo failed, pinPasswordInfo is null`);
        callback(arrCredInfo);
        return;
      }
      for (let i = 0; i < pinPasswordInfo.length; i++) {
        let credInfo: authData = {
          authType: pinPasswordInfo[i]?.authType,
          authSubType: pinPasswordInfo[i]?.authSubType,
        };
        arrCredInfo.push(credInfo);
      }
      callback(arrCredInfo);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} getAuthInfo failed.`);
    });
  }

  /**
   * 调用安全子系统 api 获取当前的用户pin信息，从中解析出旧密码信息
   *
   * @param callback 结果回调
   */
  static hasOldCredential(callback: (data: oldPasswordInfo) => void): void {
    PasswordUtil.userIdentityManager.getAuthInfo(AuthType.PIN).then((pinPasswordInfo) => {
      let hasOldCredential: oldPasswordInfo = {
        hasOldPassword: false,
        validityPeriod: 0
      };
      if (!pinPasswordInfo) {
        LogUtil.error(`${TAG} getAuthInfo failed, pinPasswordInfo is null`);
        callback(hasOldCredential);
        return;
      }

      for (let i = 0; i < pinPasswordInfo.length; i++) {
        if (pinPasswordInfo[i].isAbandoned) {
          hasOldCredential.hasOldPassword = true;
          hasOldCredential.credentialId = pinPasswordInfo[i].credentialId;
          hasOldCredential.validityPeriod = pinPasswordInfo[i].validityPeriod ?? 0;
          hasOldCredential.authSubType = pinPasswordInfo[i].authSubType;
          SecurityContext.getInstance().setOldPsdCredId(pinPasswordInfo[i].credentialId);
          callback(hasOldCredential)
          return;
        }
      }
      callback(hasOldCredential);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} getAuthInfo failed, err.code: ${err?.code} err.mesage: ${err?.message}.`);
    });
  }

  /**
   * 调用安全子系统 api 校验密码是否正确
   *
   * @param challenge 值
   * @param password 密码
   * @param onResult 结果回调
   */
  static authPin(challenge: string, password: string, onResult: (result: number, extraInfo: extraInfoI) => void): void {
    PasswordUtil.getAuthProperty((data) => {
      if (data?.result === ResultCode.SUCCESS) {
        PasswordUtil.doAuthPin(data.authSubType.toString(), challenge, password, onResult);
        return;
      }
      LogUtil.error(`${TAG} auth pin get auth property error`);
    });
  }

  /**
   * 校验密码是否正确
   *
   * @param pinType 密码类型
   * @param challenge 值
   * @param password 密码
   * @param onResult 结果回调
   */
  static doAuthPin(pinType: string, challenge: string, password: string,
                   onResult: (result: number, extraInfo: extraInfoI) => void): void {
    try {
      SecurityContext.getInstance().setPassword(password);
      let userAuth = new osAccount.UserAuth();
      userAuth?.auth(PasswordUtil.arrayJsonToUint8Array(challenge), AuthType.PIN,
        pinType === PinSubType.PIN_FOUR.toString() ? AuthTrustLevel.ATL3 : AuthTrustLevel.ATL4, {
          onResult: (result, extraInfo) => {
            LogUtil.info(`${TAG} auth result=${result}`);
            try {
              const info: extraInfoI = {
                token: StringUtil.uint8ArrayToStringByJson(extraInfo?.token),
                remainTimes: extraInfo?.remainTimes,
                freezingTime: extraInfo?.freezingTime,
                nextPhaseFreezingTime: extraInfo?.nextPhaseFreezingTime,
              }
              SecurityContext.getInstance().setToken(extraInfo?.token);
              SecurityContext.getInstance().emptyPassword();
              onResult(result, info);
            } catch (e) {
              LogUtil.error(`${TAG} auth failed ${e?.code} ${e?.message}`);
            }
          },
          onAcquireInfo: (acquireModule, acquire, extraInfo: Uint8Array) => {
          }
        });
    } catch (e) {
      LogUtil.error(`${TAG} authPin failed`);
    }
  }

  /**
   * 调用安全子系统 api 校验密码是否正确
   *
   * @param challenge 值
   * @param password 密码
   * @param onResult 结果回调
   */
  static authPinByOutChallenge(authSubType: string, challenge: string, password: string,
                               onResult: (result: number, extraInfo: extraInfoI) => void): void {
    try {
      if (!challenge) {
        LogUtil.error(`${TAG} challenge is null`);
        return;
      }
      LogUtil.info(`${TAG} authPinByOutChallenge ${challenge}`);
      SecurityContext.getInstance().setPassword(password);
      let userAuth: osAccount.UserAuth = new osAccount.UserAuth();
      userAuth?.auth(StringUtil.base64StringToUint8Array(challenge), AuthType.PIN,
        authSubType === PinSubType.PIN_FOUR.toString() ? AuthTrustLevel.ATL3 : AuthTrustLevel.ATL4, {
        onResult: (result, extraInfo) => {
          LogUtil.info(`${TAG} auth result=${result}`);
          try {
            const info: extraInfoI = {
              token: PasswordUtil.uint8ArrayToString(extraInfo?.token),
              remainTimes: extraInfo?.remainTimes,
              freezingTime: extraInfo?.freezingTime,
            }
            SecurityContext.getInstance().setToken(extraInfo?.token);
            SecurityContext.getInstance().emptyPassword();
            onResult(result, info);
          } catch (e) {
            LogUtil.error(`${TAG} auth failed`);
          }
        },
        onAcquireInfo: (acquireModule, acquire, extraInfo: Uint8Array) => {
        }
      });
    } catch (e) {
      LogUtil.error(`${TAG} authPin failed`);
    }
  }

  /**
   * 调用安全子系统 api 修改、更新密码
   *
   * @param pinSubType 密码子类型
   * @param password 新密码
   * @param token token 值
   * @param onResultCall 结果回调
   */
  static updatePassword(pinSubType: number, password: string, token: Uint8Array,
                        onResultCall: (result: number, extraInfo: extraInfoI) => void): void {
    HiSysEventUtil.reportDefaultFaultEvent(HiSysPasswdModificationOccurEvent.EVENT_NAME,
      HiSysPasswdModificationOccurEvent.UPDATE_PASSWORD,
      `password type ${pinSubType}`);
    try {
      SecurityContext.getInstance().setPassword(password);
      let credentialInfo: osAccount.CredentialInfo = {
        credType: AuthType.PIN, credSubType: pinSubType, token: token,
      }
      let callback: osAccount.IIdmCallback = {
        onResult: (result, extraInfo) => {
          let retExtraInfo: extraInfoI = {};
          onResultCall(result, retExtraInfo);
        },
      };
      PasswordUtil.userIdentityManager?.updateCredential(credentialInfo, callback);
    } catch (e) {
      LogUtil.error(`${TAG} updateCredential failed`);
    }
  }

  /**
   * 调用安全子系统 api 删除密码
   *
   * @param token token 值
   * @param password 要删除的密码
   * @param onResultCallback 结果回调
   */
  static deletePassword(token: string, password: string,
                        onResultCallback: (result: number, extraInfo: extraInfoI) => void): void {
    HiSysEventUtil.reportDefaultFaultEvent(HiSysPasswdModificationOccurEvent.EVENT_NAME,
      HiSysPasswdModificationOccurEvent.CLOSE_SCREEN_LOCK_PASSWORD);
    try {
      let callback: osAccount.IIdmCallback = {
        onResult: (result, extraInfo) => {
          let retExtraInfo: extraInfoI = {}
          onResultCallback(result, retExtraInfo);
        },
      };
      let data = PasswordUtil.arrayJsonToUint8Array(token);
      PasswordUtil.userIdentityManager.delUser(data, callback);
      if (WalletManageUtils.checkIfHighSecurity()) {
        WalletManageUtils.startWalletCleanAbility();
      }
    } catch (e) {
      LogUtil.info(`${TAG} delUser failed`);
    }
  }

  /**
   * 删除旧密码
   *
   * @param credId 旧密码凭据
   */
  static deleteOldPassword(callback: osAccount.IIdmCallback): void {
    LogUtil.info(`${TAG} deleteOldPassword start`);
    try {
      let cred = SecurityContext.getInstance().getOldPsdCredId();
      /* instrument ignore if*/
      if (!cred) {
        LogUtil.error(`${TAG} credential not exist, delete failed.`)
        return;
      }
      PasswordUtil.userIdentityManager.delCred(cred, SecurityContext.getInstance().getToken(), callback);
    } catch (e) {
      LogUtil.error(`${TAG} deleteOldPassword exception: ${(e as BusinessError).code}`);
    }
  }

  /**
   * 在弹出“校验密码”的弹窗之前，先获取当前密码校验的操作是否已被冻结
   *
   * @param callback 数据回调
   */
  static getAuthProperty(callback: (data: osAccount.ExecutorProperty) => void): void {
    LogUtil.info(`${TAG} getAuthProperty in.`);
    try {
      const request: osAccount.GetPropertyRequest = {
        authType: AuthType.PIN,
        keys: [GetPropertyType.AUTH_SUB_TYPE, GetPropertyType.REMAIN_TIMES, GetPropertyType.FREEZING_TIME],
      }
      const userAuth: osAccount.UserAuth = new osAccount.UserAuth();
      userAuth?.getProperty(request)
      ?.then((data) => {
        callback(data);
      });
    } catch (e) {
      LogUtil.info(`${TAG} getAuthProperty failed`);
    }
  };

  /**
   * 将 array json 转换为 Uint8Array
   *
   * @param arrayJson array Json 数据
   * @return Uint8Array 数据
   */
  static arrayJsonToUint8Array(arrayJson: string): Uint8Array {
    /* instrument ignore if*/
    if (!arrayJson) {
      return new Uint8Array([]);
    }
    try {
      let arr: number = JSON.parse(arrayJson);
      return new Uint8Array(arr);
    } catch (e) {
      LogUtil.error(`${TAG} arrayJsonToUint8Array parse error`);
    }
    return new Uint8Array([]);
  }

  /**
   * 判断密码是否符合规范
   *
   * @param password 密码
   * @return 返回密码校验结果
   */
  static getPasswordValidStatus(password: string): number {
    if (!password) {
      return CHECK_PASSWORD_TYPE_TOO_SHORT;
    }
    if (PasswordUtil.isContainIllegalCharacter(password)) {
      return CHECK_PASSWORD_TYPE_CONTAIN_ILLEGAL_CHARACTER;
    }
    if (PasswordUtil.isPasswordTooShort(password, LOCK_SCREEN_PSD_LENGTH_MIN)) {
      return CHECK_PASSWORD_TYPE_TOO_SHORT;
    }
    if (PasswordUtil.isPasswordTooLong(password, LOCK_SCREEN_PSD_LENGTH_MAX)) {
      return CHECK_PASSWORD_TYPE_TOO_LONG;
    }
    return CHECK_PASSWORD_TYPE_VALID;
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
   * 判断当前输入密码类型是不是4位数字密码
   *
   * @param password 密码
   */
  static isPinNumber4(password: string): boolean {
    if (!password) {
      return false;
    }
    return PASSWORD_NUMBER_FOUR.test(password);
  }

  /**
   * 判断密码长度是否小于最小阈值
   *
   * @param password 密码
   * @Param passwordMinValue 最小阈值
   * @return true 当密码长度小于最小阈值时
   */
  private static isPasswordTooShort(password: string, passwordMinValue: number): boolean {
    if (!password) {
      return true;
    }
    return password.length < passwordMinValue;
  }

  /**
   * 判断密码长度是否大于最大阈值
   *
   * @param password 密码
   * @param passwordMinValue 最大阈值
   * @return true 当密码长度大于最大阈值时
   */
  private static isPasswordTooLong(password: string, passwordMaxValue: number): boolean {
    if (!password) {
      return false;
    }
    return password.length > passwordMaxValue;
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
   * 校验密码是否合规，如果不合规，返回对应的提示文本
   *
   * @param password 密码
   * @param isJudgeAllRule true：校验所有规则，false：只校验字符是否合法
   */
  static async getFirstWarningMessage(password: string, isJudgeAllRule: boolean): Promise<ResourceStr> {
    if (password === null || password === undefined) {
      return SPACE_PLACE_HOLDER_STRING;
    }
    /* instrument ignore if*/
    if (isJudgeAllRule) {
      if (PasswordManager.hasEdmPolicy()) {
        if (PasswordManager.isMatchEdmPolicy(password)) {
          return SPACE_PLACE_HOLDER_STRING;
        } else {
          return PasswordManager.getEdmPasswordWarningMessage();
        }
      }
      if (PasswordUtil.isContainIllegalCharacter(password)) {
        if (PasswordUtil.isPasswordTooShort(password, LOCK_SCREEN_PSD_LENGTH_MIN)) {
          return await ResourceUtil.getNumberFormatString(
            $r('app.string.password_contain_illegal_character_and_too_short'), (LOCK_SCREEN_PSD_LENGTH_MIN - 1).toString());
        } else if (PasswordUtil.isPasswordTooLong(password, LOCK_SCREEN_PSD_LENGTH_MAX)) {
          return await ResourceUtil.getNumberFormatString(
            $r('app.string.password_contain_illegal_character_and_too_long'), (LOCK_SCREEN_PSD_LENGTH_MAX + 1)
            .toString());
        } else {
          return $r('app.string.password_contain_illegal_character');
        }
      } else {
        if (PasswordUtil.isPasswordTooShort(password, LOCK_SCREEN_PSD_LENGTH_MIN)) {
          return await ResourceUtil.getNumberFormatString(
            $r('app.string.password_too_short'), (LOCK_SCREEN_PSD_LENGTH_MIN - 1).toString());
        } else if (PasswordUtil.isPasswordTooLong(password, LOCK_SCREEN_PSD_LENGTH_MAX)) {
          return await ResourceUtil.getNumberFormatString(
            $r('app.string.password_too_long'), (LOCK_SCREEN_PSD_LENGTH_MAX + 1).toString());
        } else {
          return SPACE_PLACE_HOLDER_STRING;
        }
      }
    } else {
      /* instrument ignore if*/
      if (PasswordUtil.isContainIllegalCharacter(password)) {
        return $r('app.string.password_contain_illegal_character');
      } else {
        return SPACE_PLACE_HOLDER_STRING;
      }
    }
  }

  /**
   * 校验密码是否合规，如果不合规，返回对应的提示文本
   *
   * @param password 密码
   * @param isJudgeForRealTime 是否实时校验
   */
  static getConfirmWarningMessage(pwdFirst: string, pwdConfirm: string): ResourceStr {
    if (pwdFirst === pwdConfirm) {
      return SPACE_PLACE_HOLDER_STRING;
    }
    return $r('app.string.password_input_warning_message_not_equal');
  }

  /**
   * 根据当前剩余时间来获取应该显示的倒计时弹窗提示信息
   *
   * @param millisecondsTime 时间，单位：毫秒
   */
  static getCountDownDialogMessage(millisecondsTime: number): ResourceStr {
    if (!millisecondsTime) {
      LogUtil.info(`${TAG} millisecondsTime is null`);
      return SPACE_PLACE_HOLDER_STRING;
    }
    let secondsTime = millisecondsTime / MILE_SECOND_TO_SECOND;
    let hour: number = Math.floor(secondsTime / COUNT_DOWN_ONE_HOUR);
    if (hour > 0) {
      return ($r('app.plural.password_lockscreen_try_after_hours', hour, hour));
    }
    let min: number = Math.floor(secondsTime / COUNT_DOWN_ONE_MIN);
    /* instrument ignore if*/
    if (min > 0) {
      return ($r('app.plural.password_lockscreen_try_after_minutes', min, min));
    }
    let second: number = secondsTime;
    /* instrument ignore if*/
    if (second > 0) {
      return ($r('app.plural.password_lockscreen_try_after_seconds', second, second));
    }
    return SPACE_PLACE_HOLDER_STRING;
  }

  /**
   * 根据用户输入的密码来匹配对应的密码子类型
   *
   * @param password 密码
   */
  static getPinSubType(password: string): number {
    if (!password) {
      LogUtil.info(`${TAG} getPinSubType password is null`);
      return PinSubType.PIN_MIXED;
    } else if (PasswordUtil.isPinNumber6(password)) {
      return PinSubType.PIN_SIX;
    } else if (PasswordUtil.isOnlyNumber(password)) {
      return PinSubType.PIN_NUMBER;
    } else {
      return PinSubType.PIN_MIXED;
    }
  }

  /**
   * 给窗口设置安全标记
   *
   * @param windowStage Stage模型window容器
   * @param isPrivacyMode 是否设置成隐私模式
   */
  static setWindowPrivacyMode(windowStage: window.WindowStage, isPrivacyMode: boolean): void {
    LogUtil.info(`${TAG} setPrivacyMode enter : ${isPrivacyMode}`);
    windowStage?.getMainWindow().then((window) => {
      window?.setWindowPrivacyMode(isPrivacyMode).then(() => {
        LogUtil.info(`${TAG} setPrivacyMode finish : ${isPrivacyMode}`);
      }).catch((err: BusinessError) => {
        LogUtil.error(`${TAG} Failed to set the window to privacy mode. Cause: ${err.code}`);
      });
    });
  }

  /**
   * 给窗口设置安全标记
   *
   * @param session UIExtensionAbility拉起的窗口
   * @param isPrivacyMode 是否设置成隐私模式
   */
  static setUIExtensionWindowPrivacyMode(session: UIExtensionContentSession, isPrivacyMode: boolean): void {
    LogUtil.info(`${TAG} setPrivacyMode enter : ${isPrivacyMode}`);
    try {
      session?.setWindowPrivacyMode(isPrivacyMode).then(() => {
        LogUtil.info(`${TAG} setPrivacyMode finish : ${isPrivacyMode}`);
      }).catch((err: BusinessError) => {
        LogUtil.error(`${TAG} Failed to set the window to privacy mode. code: ${err?.code}, msg: ${err?.message}`);
      });
    } catch (error) {
      LogUtil.error(`${TAG} Set the window to privacy mode error. code: ${error?.code}, msg: ${error?.message}`);
    }
  }

  /**
   * 给UIExtension组件设置安全标记
   *
   * @param isPrivacyMode 是否设置成隐私模式
   */
  static setSessionPrivacyMode(isPrivacyMode: boolean): void {
    /* instrument ignore if*/
    if (LocalStorage?.getShared()?.has('session')) {
      PasswordUtil.setUIExtensionWindowPrivacyMode(LocalStorage?.getShared().get('session') as
      UIExtensionContentSession, isPrivacyMode);
    }
  }

  /**
   * 给窗口设置非安全标记
   *
   * @param windowStage Stage模型window容器
   * @param pathInfos 页面路由栈信息
   */
  static setWindowNonPrivacyModeIfNeed(windowStage: window.WindowStage, pathInfos: NavPathStack): void {
    let pathNames: string[] = pathInfos?.getAllPathName() ?? [];
    if (pathNames.length <= 0) {
      LogUtil.warn(`${TAG} setWindowNonPrivacyModeIfNeed pathName length invalid`);
      PasswordUtil.setWindowPrivacyMode(windowStage, false);
      return;
    }

    let topNavName: string = pathNames[pathNames.length - 1];
    if (PRIVACY_PORTRAIT_PAGES.indexOf(topNavName) >= 0) {
      LogUtil.info(`${TAG} no need setWindowPrivacyMode false`);
      return;
    }
    LogUtil.info(`${TAG} setWindowNonPrivacyModeIfNeed enter`);
    windowStage?.getMainWindow().then((window) => {
      window?.setWindowPrivacyMode(false).then(() => {
        LogUtil.info(`${TAG} setWindowNonPrivacyModeIfNeed finish : false`);
      }).catch((err: BusinessError) => {
        LogUtil.error(`${TAG} Failed to set the window to privacy mode. Cause: ${err.message}`);
      });
    });
  }

  /**
   * 判断上一个界面是否涉密，重新设置隐私窗口
   *
   * @param windowStage Stage模型window容器
   * @param pathInfos 页面路由栈信息
   */
  static reSetWindowPrivacyModeIfNeed(windowStage: window.WindowStage, pathInfos: NavPathStack): void {
    let pathNames: string[] = pathInfos?.getAllPathName() ?? [];
    /* instrument ignore if*/
    if (pathNames.length <= 0) {
      LogUtil.warn(`${TAG} setWindowNonPrivacyModeIfNeed pathName length invalid`);
      PasswordUtil.setWindowPrivacyMode(windowStage, false);
      return;
    }
    let topNavName: string = pathNames[pathNames.length - 1];
    /* instrument ignore if*/
    if (PRIVACY_PORTRAIT_PAGES.indexOf(topNavName) >= 0) {
      PasswordUtil.setWindowPrivacyMode(windowStage, true);
      return;
    }
    PasswordUtil.setWindowPrivacyMode(windowStage, false);
  }

  /**
   * wifi输入密码弹框不允许截屏
   *
   * @param isPrivacyMode
   */
  public static setPrivacyMode(isPrivacyMode: boolean): void {
    // 其他模块跳转到设置
    if (LocalStorage?.getShared()?.has('externalWindowStage')) {
      PasswordUtil.setWindowPrivacyMode(LocalStorage?.getShared().get('externalWindowStage') as
      window.WindowStage, isPrivacyMode);
    }

    // 设置内部跳转
    if (LocalStorage?.getShared()?.has('windowStage')) {
      PasswordUtil.setWindowPrivacyMode(LocalStorage?.getShared().get('windowStage') as
      window.WindowStage, isPrivacyMode);
    }

    // UIExtensionAbility拉起的场景：例如OOBE-WLAN
    if (LocalStorage?.getShared()?.has('session')) {
      PasswordUtil.setUIExtensionWindowPrivacyMode(LocalStorage?.getShared().get('session') as
      UIExtensionContentSession, isPrivacyMode);
    }
  }

  /**
   * 录入指纹
   *
   * @param credentialInfo 认证参数：{credType: 4, credSubType: 10000, token: ''}
   * @param callback 过程和结果回调
   */
  static enrollFingerprint(callback: osAccount.IIdmCallback, userId?: number): void {
    try {
      const credInfo: osAccount.CredentialInfo = {
        credType: FINGERPRINT_CRED_TYPE,
        credSubType: FINGERPRINT_SUB_CRED_TYPE,
        token: SecurityContext.getInstance().getToken(),
      };
      if (userId) {
        credInfo.accountId = userId;
      }
      LogUtil.info(`${TAG} addCredential userId= ${userId}`);
      PasswordUtil.userIdentityManager?.addCredential(credInfo, callback);
    } catch (e) {
      LogUtil.error(`${TAG} finger.addCredential exception: ${(e as BusinessError).code}`);
    }
  }

  /**
   * 静默认证
   */
  static async silenceAuthPin(): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      try {
        PasswordUtil.unregisterInputer();
        PasswordUtil.closeSession();
        PasswordUtil.openSession((data) => {
          PasswordUtil.getAuthProperty((property: osAccount.ExecutorProperty) => {
            /* instrument ignore next */
            if (property?.result === ResultCode.SUCCESS) {
              PasswordUtil.registerInputer(property?.authSubType);
              PasswordUtil.authPin(data, SecurityContext.getInstance().getPassword(), (result) => {
                PasswordUtil.unregisterInputer();
                if (result == ResultCode.SUCCESS) {
                  LogUtil.info(`${TAG} silenceAuthPin SUCCESS`);
                  resolve();
                } else {
                  LogUtil.info(`${TAG} silenceAuthPin fail`);
                  reject();
                }
              });
            }
          });
        });
      } catch (e) {
        LogUtil.error(`${TAG} silenceAuthPin exception: ${(e as BusinessError).code}`);
        reject();
      }
    });
  }

  /**
   * 外部challenge认证
   *
   * @param challenge 外部challenge
   */
  static async challengeAuthPin(challenge: string): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      PasswordUtil.unregisterInputer();
      PasswordUtil.getAuthProperty((property: osAccount.ExecutorProperty) => {
        PasswordUtil.authWithChallengeAndProperty(challenge, property, resolve, reject);
      });
    });
  }

  /**
   * 使用challenge + property认证
   *
   * @param challenge 外部challenge
   * @param property 当前密码操作合法属性
   * @param resolve 回调函数
   * @param reject 回调函数
   */
  static authWithChallengeAndProperty(challenge: string, property: osAccount.ExecutorProperty,
                                      resolve: (value: void | PromiseLike<void>) => void, reject: () => void) {
    /* instrument ignore if*/
    if (property?.result !== ResultCode.SUCCESS) {
      LogUtil.warn(`${TAG} getAuthProperty error.`);
      reject();
      return;
    }
    PasswordUtil.registerInputer(property?.authSubType);
    PasswordUtil.authPinByOutChallenge(property?.authSubType.toString(),
      challenge, SecurityContext.getInstance().getPassword(), (result) => {
      PasswordUtil.unregisterInputer();
      /* instrument ignore if*/
      if (result == ResultCode.SUCCESS) {
        LogUtil.info(`${TAG} challengeAuthPin SUCCESS`);
        resolve();
        return;
      }
      LogUtil.info(`${TAG} challengeAuthPin fail ${result}`);
      reject();
    });
  }

  /**
   * 取消指纹录入
   */
  static cancelEnrollFingerprint(): void {
    try {
      PasswordUtil.userIdentityManager?.cancel(SecurityContext.getInstance().getChallenge());
    } catch (e) {
      LogUtil.error(`${TAG} finger.cancel exception: ${(e as BusinessError).code}`);
    }
  }

  /**
   * 删除指纹
   *
   * @param credId 指纹凭据
   * @param callback 结果回调
   */
  static deleteCred(credId: Uint8Array, callback: osAccount.IIdmCallback): void {
    try {
      PasswordUtil.userIdentityManager.delCred(credId, SecurityContext.getInstance().getToken(), callback);
    } catch (e) {
      callback.onResult(CALLBACK_RESULT, null);
      LogUtil.error(`${TAG} finger.delCred exception: ${(e as BusinessError).code}`);
    }
  }

  /**
   * 调用安全子系统 api 获取当前的用户指纹信息
   *
   * @param credType 指纹类型
   * @param callback 结果回调
   */
  static getFingerprintAuthInfo(credType: number, callback: (data: Array<string>) => void): void {
    try {
      const dataArray: string[] = [];
      PasswordUtil.userIdentityManager.getAuthInfo(credType, (err, result) => {
        LogUtil.info(`${TAG} finger.authInfo err: ${err === undefined}`);
        LogUtil.info(`${TAG} finger.authInfo result ${result?.length}`);
        /* instrument ignore if*/
        if (!result) {
          LogUtil.error(`${TAG} user fingerprint data is null`);
          return;
        }
        for (const item of result) {
          dataArray.push(PasswordUtil.uint8ArrayToString(item.credentialId));
        }
        callback(dataArray);
      });
    } catch (e) {
      LogUtil.error(`${TAG} finger.authInfo exception: ${(e as BusinessError).code}`);
    }
  }

  /**
   * 调用安全子系统 api 当前在用指纹信息
   *
   * @param credType 指纹类型
   * @param callback 结果回调
   */
  static async getFingerprintAuthInfoInUse(credType: number): Promise<Array<string>> {
    const dataArray: string[] = [];
    try {
      let accountManager = osAccount.getAccountManager();
      let accountArray: osAccount.OsAccountInfo[] = await accountManager.queryAllCreatedOsAccounts();
      /* instrument ignore if*/
      if (CheckEmptyUtils.isEmptyArr(accountArray)) {
        LogUtil.error(`${TAG} accountArray is null`);
        return dataArray;
      }
      for (let account of accountArray) {
        let ret: string[] = await PasswordUtil.getUserCredInfos(credType, account.localId);
        /* instrument ignore if*/
        if (CheckEmptyUtils.isEmptyArr(ret)) {
          continue;
        }
        dataArray.push(...ret);
      }
      return dataArray;
    } catch (e) {
      LogUtil.error(`${TAG} finger.authInfo exception: ${(e as BusinessError).code}`);
      return dataArray;
    }
  }

  static async getUserCredInfos(credType: number, userId: number): Promise<string[]> {
    let ret: string[] = [];
    try {
      let enrolledCredInfos: osAccount.EnrolledCredInfo[] = await PasswordUtil.userIdentityManager
        .getAuthInfo({ authType: credType, accountId: userId })
      /* instrument ignore if*/
      if (CheckEmptyUtils.isEmptyArr(enrolledCredInfos)) {
        LogUtil.warn(`${TAG} getUsersCredInfos is empty ${userId}`);
        return ret;
      }
      for (const item of enrolledCredInfos) {
        ret.push(StringUtil.uint8ArrayToStringByJson(item.credentialId));
      }
      return ret;
    } catch (e) {
      LogUtil.error(`${TAG} getUsersCredInfos error ${(e as BusinessError).code}`);
      return ret;
    }
  }

  /**
   * 判断当前输入密码类型是不是弱密码
   * 区分高安和非高安场景的判断规则
   *
   * @param password 密码
   * @return true 当密码为弱密码时
   */
  static isWeakPasswords(password: string): boolean {
    if (!password) {
      return true;
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
    if (PasswordUtil.isAscendingOrDescendingOrder(arr.length, arr.map(Number))) {
      return true;
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
    if (Math.abs(rank) != 1) {
      return false;
    }
    for (let i: number = 0; i < pwdListLength - 1; i++) {
      if (passwords[i + 1] - passwords[i] != rank) {
        isWeakPwd = false;
        break;
      }
    }
    return isWeakPwd;
  }

  /**
   * 指纹凭据信息排序
   *
   * @param credInfo 指纹凭据
   */
  static getSortedFingerprint(credInfo: Array<credentialData>): Array<credentialData> {
    credInfo.sort((record1: credentialData, record2: credentialData) => {
      LogUtil.info(`${TAG} fingerprint sort`);

      let arrNumber1: number[] = [];
      let arrNumber2: number[] = [];
      for (const element of record1.templateId) {
        arrNumber1.push(element);
      }
      for (const element of record2.templateId) {
        arrNumber2.push(element);
      }

      for (let i = 0; i < arrNumber1.length; i++) {
        /* instrument ignore if*/
        if (arrNumber1[i] !== arrNumber2[i]) {
          return arrNumber1[i] - arrNumber2[i]
        }
      }
      return 0;
    });
    return credInfo;
  }

  /**
   * 调用安全子系统 api 获取当前的用户指纹信息,
   *
   * @param credType 指纹类型
   * @param userId 用户ID
   * @param nameArray 从settings secure中读取的当前用户的指纹名称
   * @param callback 结果回调
   */
  static async getSortFingerprintAuthInfo(credType: number): Promise<Array<string>> {
    let credInfoArray: string[] = [];
    LogUtil.info(`${TAG} getSortFingerprintAuthInfo`);
    let credentials = await PasswordUtil.userIdentityManager.getAuthInfo(credType);
    let arrCredInfo: credentialData[] = [];
    for (let index = 0; index < credentials.length; index++) {
      let credInfo: credentialData = {
        credentialId: credentials[index].credentialId,
        templateId: credentials[index].templateId,
      };
      arrCredInfo.push(credInfo);
    }
    // 按照templateId从小到大排序
    PasswordUtil.getSortedFingerprint(arrCredInfo);
    for (const item of arrCredInfo) {
      credInfoArray.push(PasswordUtil.uint8ArrayToString(item.credentialId));
    }
    LogUtil.info(`${TAG} getSortFingerprintAuthInfo credInfoArray= ${credInfoArray.length}`);
    return credInfoArray;
  }

  /**
   * 调用安全子系统 api 跨用户校验密码是否正确
   *
   * @param challenge 值
   * @param password 密码
   * @param onResult 结果回调
   */
  static crossUserAuthPin(authSubType: number, userId: number, challenge: Uint8Array,
                          onResult: (result: number, extraInfo: extraInfoI) => void): void {
    try {
      let userAuth = new osAccount.UserAuth();
      userAuth?.auth(challenge, AuthType.PIN,
        authSubType === PinSubType.PIN_FOUR ? AuthTrustLevel.ATL3 : AuthTrustLevel.ATL4,
        { authIntent: AccountConstants.SILENT_AUTH, accountId: userId }, {
          onResult: (result, extraInfo) => {
            LogUtil.info(`${TAG} crossUserAuthPin result = ${result}`);
            try {
              const info: extraInfoI = {
                token: StringUtil.uint8ArrayToStringByJson(extraInfo?.token),
                remainTimes: extraInfo?.remainTimes,
                freezingTime: extraInfo?.freezingTime,
              };
              onResult(result, info);
            } catch (e) {
              LogUtil.error(`${TAG} crossUserAuthPin failed`);
            }
          },
          onAcquireInfo: (acquireModule, acquire, extraInfo: Uint8Array) => {
          }
        });
    } catch (e) {
      LogUtil.error(`${TAG} crossUserAuthPin failed`);
    }
  }

  public static checkUserPassword(authSubType: number, userId: number, password: string,
                                  callback: (isSuccess: boolean) => void): void {
    PasswordUtil.unregisterInputer();
    PasswordUtil.registerInput(authSubType, password);
    PasswordUtil.crossUserAuthPin(authSubType, userId, SecurityContext.getInstance().getChallenge(),
      (result, extraInfo) => {
        callback(result === ResultCode.SUCCESS);
      })
  }

  /**
   * 调用安全子系统 api 注册监听用户输入的内容
   *
   * @return 注册成功返回 true，注册失败返回 false
   */
  static registerInput(pinSubType: number, password: string): void {
    try {
      let pinAuth = new osAccount.PINAuth();
      pinAuth?.registerInputer({
        onGetData: (authSubType, inputData) => {
          let u8aPwd = StringUtil.stringToUint8ArrayTextEncoder(password);
          inputData.onSetData(pinSubType, u8aPwd);
        },
      });
    } catch (e) {
      LogUtil.error(`${TAG} registerInput failed`);
    }
  }

  /**
   * 调用隐私空间接口 api 修改密码
   *
   * @param password 新密码
   */
  static updatePrivateSpacePsd(password: string): void {
    /* instrument ignore if*/
    if (CheckEmptyUtils.checkStrIsEmpty(password)) {
      LogUtil.error(`${TAG} password is empty`);
      return;
    }
    LogUtil.info(`${TAG} updatePrivateSpacePsd`);
    try {
      AccountUtil.isCurrentPrivate().then(isCurrentPrivate => {
        LogUtil.info(`${TAG} isCurrentPrivate ${isCurrentPrivate}`);
        let isPrivateProtected: string = SettingsDataUtils.getSettingsDataDomain(AccountConstants.PASSWORD_PROTECT_KEY,
          AccountConstants.NOT_SET_PRIVATE_PASSWORD_PROTECT, settings.domainName.DEVICE_SHARED);
        LogUtil.info(`${TAG} updatePrivateSpacePsd ${isPrivateProtected}`);
        /* instrument ignore if*/
        if (isCurrentPrivate && isPrivateProtected === AccountConstants.ALREADY_SET_PRIVATE_PASSWORD_PROTECT) {
          let credential = StringUtil.stringToUint8ArrayTextEncoder(password);
          // import('@hms.security.privateSpace').then(privateSpace => privateSpace.default.updateCredential(credential));
          LogUtil.info(`${TAG} do updateCredential private user`);
        }
      })
    } catch (e) {
      LogUtil.error(`${TAG} updatePrivateSpacePsd error ${(e as BusinessError)?.code}`);
    }
  }

  /**
   * 获取用户密码类型
   *
   * @param userId 用户id
   * @returns 用户密码类型信息
   */
  static async getUserPasswordInfo(userId: number): Promise<UserPasswordInfo> {
    try {
      let pinPasswordInfo: osAccount.EnrolledCredInfo[] = await PasswordUtil.userIdentityManager
        .getAuthInfo({ authType: AuthType.PIN, accountId: userId });
      let userPasswordInfo: UserPasswordInfo = new UserPasswordInfo();
      /* instrument ignore if*/
      if (pinPasswordInfo && pinPasswordInfo.length > 0) {
        userPasswordInfo.hasPinPassword = true;
        userPasswordInfo.authSubType = pinPasswordInfo[0].authSubType;
      }
      return userPasswordInfo;
    } catch (e) {
      LogUtil.error(`${TAG} getAuthInfo error, error code: ${e?.code}, message: ${e?.message}.`);
      return new UserPasswordInfo();
    }
  }

  static isBiometricsPasswordEntry(): boolean {
    const result = CommonUtils.isPageActive(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
    /* instrument ignore if*/
    if (result) {
      LogUtil.warn(`${TAG} is BiometricsPasswordEntry`);
    }
    return result;
  }
}