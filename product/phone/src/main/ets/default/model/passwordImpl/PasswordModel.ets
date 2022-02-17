/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import BaseModel from '../../../../../../../../common/utils/src/main/ets/default/model/BaseModel.ets';
import ConfigData from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import LogUtil from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import util from '@ohos.util';
import UserIDM from '@ohos.useridm'
import UserAuth from '@ohos.userauth'
import PinAuth from '@ohos.pinauth'

/**
  * Credential type for authentication
  */
export enum AuthType {
  /**
   * Authentication type pin.
   */
  PIN = 1,
  /**
   * Authentication type face.
   */
  FACE = 2
}

export enum PinSubType {
  /**
   * Authentication sub type six number pin.
   */
  PIN_SIX = 10000,
  /**
   * Authentication sub type self defined number pin.
   */
  PIN_NUMBER = 10001,
  /**
   * Authentication sub type self defined mixed pin.
   */
  PIN_MIXED = 10002,
}

/**
 * Result code
 */
export enum ResultCode {
  /**
   * success
   */
  SUCCESS = 0,
  /**
   * fails
   */
  FAIL = 1,
}

/**
 * Authentication method
 */
export enum AuthMethod {
  /**
   * Authentication method PIN.
   */
  PIN_ONLY = 0xF,
  /**
   * Authentication method face.
   */
  FACE_ONLY = 0xF0
}

/**
  * Credibility level of certification results
  */
enum AuthTrustLevel {
  /**
   * Authentication result trusted level 1.
   */
  ATL1 = 10000,
  /**
   * Authentication result trusted level 2.
   */
  ATL2 = 20000,
  /**
   * Authentication result trusted level 3.
   */
  ATL3 = 30000,
  /**
   * Authentication result trusted level 4.
   */
  ATL4 = 40000
}

/**
 * Actuator attribute list
 */
enum GetPropertyType {
  /**
   * Authentication remain times.
   */
  AUTH_SUB_TYPE = 1,
  /**
   * Authentication remain times.
   */
  REMAIN_TIMES = 2,
  /**
   * Authentication freezing time.
   */
  FREEZING_TIME = 3
}

export class PasswordModel extends BaseModel {
  private TAG = ConfigData.TAG + 'PasswordModel#';
  pinAuth: any;
  userAuth: any;
  userIdentityManager: any;
  password: string;
  pinSubType: number;

  /**
   * constructor
   */
  constructor() {
    super();
    this.userIdentityManager = UserIDM.constructor();
    this.pinAuth = PinAuth.constructor();
    this.userAuth = UserAuth.constructor();
  }

  u8AToStr(val: Uint8Array): any{
    if (!val) {
      LogUtil.debug(`${this.TAG}u8AToStr : param is null.`);
      return ''
    }
    var dataString = "";
    var arrNumber = [];
    for (var i = 0; i < val.length; i++) {
      arrNumber.push(val[i]);
    }
    dataString = JSON.stringify(arrNumber);
    LogUtil.debug(`${this.TAG}u8AToStr out.`);
    return dataString
  }

  /**
   * Convert array json to Uint8Array
   *
   * @return Uint8Array
   */
  strToU8A(val: string): Uint8Array{
    if (!val) {
      LogUtil.debug(`${this.TAG}strToU8A : param is null.`);
      return new Uint8Array([])
    }
    var arr = JSON.parse(val);
    var tmpUint8Array = new Uint8Array(arr);
    LogUtil.debug(`${this.TAG}strToU8A out.`);
    return tmpUint8Array
  }

  /**
   * Convert encode string to Uint8Array
   *
   * @return Uint8Array
   */
  encodeToU8A(val: string): Uint8Array{
    if (!val) {
      LogUtil.debug(`${this.TAG}encodeToU8A : param is null.`);
      return new Uint8Array([])
    }
    var textEncoder = new util.TextEncoder();
    LogUtil.debug(`${this.TAG}encodeToU8A out.`);
    return textEncoder.encode(val);
  }

  /**
   * Register Inputer
   */
  registerInputer(): boolean {
    let result = false;
    try {
      result = this.pinAuth.registerInputer({
        onGetData: (authSubType, inputData) => {
          LogUtil.debug(`${this.TAG}registerInputer->onGetData pAuthSubType:${authSubType}`);
          LogUtil.debug(`${this.TAG}registerInputer->onGetData inAuthSubType:${this.pinSubType}`);
          LogUtil.debug(`${this.TAG}registerInputer->onGetData inPassword:${this.password}`);
          let u8aPwd = this.encodeToU8A(this.password);
          LogUtil.debug(`${this.TAG}registerInputer->onGetData inputData.onSetData : encodeToU8A password:${u8aPwd}`);
          inputData.onSetData(this.pinSubType, u8aPwd);
        }
      });
      LogUtil.debug(`${this.TAG}registerInputer->result:${result}`);
      if(!result){
        this.unregisterInputer();
        result = this.pinAuth.registerInputer({
          onGetData: (authSubType, inputData) => {
            LogUtil.debug(`${this.TAG}registerInputer->onGetData(retry) pAuthSubType:${authSubType}`);
            LogUtil.debug(`${this.TAG}registerInputer->onGetData(retry) inAuthSubType:${this.pinSubType}`);
            LogUtil.debug(`${this.TAG}registerInputer->onGetData(retry) inPassword:${this.password}`);
            let u8aPwd = this.encodeToU8A(this.password);
            LogUtil.info(`${this.TAG}registerInputer->onGetData(retry) inputData.onSetData : encodeToU8A password:${u8aPwd}`);
            inputData.onSetData(this.pinSubType, u8aPwd);
          }
        });
        LogUtil.debug(`${this.TAG}registerInputer->result(retry):${result}`);
      }
    } catch {
      LogUtil.debug(`${this.TAG}registerInputer failed`);
    }
    return result;
  }

  /**
   * UnregisterInputer
   */
  unregisterInputer(): void {
    LogUtil.debug(`${this.TAG}unregisterInputer in.`);
    try {
      this.pinAuth.unregisterInputer();
    } catch {
      LogUtil.debug(`${this.TAG}unregisterInputer failed`);
    }
  }

  /**
   * Open Session
   * A challenge value of 0 indicates that opensession failed
   *
   * @returns challenge value
   */
  openSession(callback: (challenge: string) => void): void {
    try {
      this.userIdentityManager.openSession((data) => {
        LogUtil.debug(`${this.TAG}openSession challenge:${data}`);
        callback(this.u8AToStr(data));
      })
    } catch {
      LogUtil.debug(`${this.TAG}openSession failed`);
      callback('0');
    }
  }

  /**
   * Close session
   */
  closeSession(): void {
    try {
      this.userIdentityManager.closeSession()
      LogUtil.debug(`${this.TAG}closeSession success`);
    } catch (e) {
      LogUtil.debug(`${this.TAG}closeSession failed:` + e);
    }
  }

  /**
   * Cancel entry and pass in challenge value
   *
   * @param challenge challenge value.
   */
  cancel(challenge: string): number {
    let result = ResultCode.FAIL;
    try {
      let data = this.strToU8A(challenge);
      let result = this.userIdentityManager.cancel(data)
      LogUtil.debug(`${this.TAG}cancel success`);
    } catch (e) {
      LogUtil.debug(`${this.TAG}cancel failed:` + e);
    }
    return result;
  }

  /**
   * Add user credential information, pass in credential addition method and credential information
   * (credential type, subclass, if adding user's non password credentials, pass in password authentication token),
   * and get the result callback
   *
   * @param pinSubType pinSubType
   * @param password password
   * @param onResultCall Get results callback.
   */
  addPinCredential(pinSubType: number, password: string, onResultCall: (result: number) => void): void {
    LogUtil.debug(`${this.TAG}addPinCredential in.`);
    try {
      this.pinSubType = pinSubType;
      this.password = password;
      let token = new Uint8Array([]);
      let credentialInfo = {
        credType: AuthType.PIN, credSubType: pinSubType, token: token
      }
      let callback = {
        onResult: (result, extraInfo) => {
          LogUtil.debug(`${this.TAG}addPinCredential result:${JSON.stringify(result)}, extraInfo:${JSON.stringify(extraInfo)}`);
          onResultCall(result);
        }
      };
      this.userIdentityManager.addCredential(credentialInfo, callback);
    } catch (e) {
      LogUtil.info(`${this.TAG}addPinCredential failed:` + e);
    }
  }

  /**
   * Update user credential information
   *
   * @param credentialInfo (credential type, subclass, password authentication token).
   * @param onResult Get results callback.
   */
  updateCredential(pinSubType: number, password: string, token: string, onResultCall: (result: number, extraInfo: {
    credentialId?: string;
  }) => void): void {
    LogUtil.debug(`${this.TAG}updateCredential in.`);
    try {
      this.pinSubType = pinSubType;
      this.password = password;
      let dataToken = this.strToU8A(token);
      let credentialInfo = {
        credType: AuthType.PIN, credSubType: pinSubType, token: dataToken
      }
      let callback = {
        onResult: (result, extraInfo) => {
          LogUtil.debug(`${this.TAG}updateCredential result:${JSON.stringify(result)}`);
          LogUtil.debug(`${this.TAG}updateCredential extraInfo:${JSON.stringify(extraInfo)}`);
          let retExtraInfo = {}
          onResultCall(result, retExtraInfo);
        }
      };
      this.userIdentityManager.updateCredential(credentialInfo, callback);
    } catch (e) {
      LogUtil.debug(`${this.TAG}updateCredential failed:` + e);
    }
  }

  /**
   * Delete all credential information
   *
   * @param token Password authentication token.
   * @param onResultCallback Get results callback.
   */
  delAllCredential(token: string, onResultCallback: (result: number, extraInfo: {}) => void): void {
    LogUtil.debug(`${this.TAG}delAllCredential in.`);
    try{
      let callback = {
        onResult:(result, extraInfo) => {
          LogUtil.debug(`${this.TAG}delAllCredential result:${JSON.stringify(result)}`);
          LogUtil.debug(`${this.TAG}delAllCredential extraInfo:${JSON.stringify(extraInfo)}`);
          let retExtraInfo = {}
          onResultCallback(result, retExtraInfo);
        }
      };
      let data = this.strToU8A(token);
      this.userIdentityManager.delUser(data, callback);
    } catch (e) {
      LogUtil.debug(`${this.TAG}updateCredential failed:` + e);
    }
  }

  /**
   * Check if has pin password
   *
   * @param callback Get results callback.
   */
  hasPinPassword(callback: (havePassword: boolean) => void): void {
    this.getPinAuthInfo((data) => {
      LogUtil.debug(`${this.TAG}hasPinPassword->getPinAuthInfo data:${JSON.stringify(data)}`);
      let passwordHasSet = false;
      if(data?.length && data.length > 0){
        passwordHasSet = true;
      }
      LogUtil.debug(`${this.TAG}hasPinPassword->getPinAuthInfo : before callback: passwordHasSet = ${passwordHasSet}`);
      callback(passwordHasSet)
    });
  }

  /**
   * Get AuthInfo
   *
   * @param authType Credential type.
   * @returns Returns all registered credential information of this type for the current user
   */
  getPinAuthInfo(callback: (data: Array<{
    authType: number;
    authSubType: number;
  }>) => void): void {
    try {
      this.userIdentityManager.getAuthInfo(AuthType.PIN, (data) => {
        LogUtil.debug(`${this.TAG}getPinAuthInfo->getAuthInfo data:${JSON.stringify(data)}`);
        let arrCredInfo = [];
        try{
          for(let i = 0; i < data.length; i++) {
            let credInfo = {
              'authType': data[i].authType,
              'authSubType': data[i].authSubType
            };
            arrCredInfo.push(credInfo);
          }
        } catch(e) {
          console.debug('faceDemo pin.getAuthInfo error = ' + e);
        }
        LogUtil.debug(`${this.TAG}getPinAuthInfo->getAuthInfo before callback: data array:${JSON.stringify(arrCredInfo)}`);
        callback(arrCredInfo);
      })
    } catch (e) {
      LogUtil.error(`${this.TAG}getPinAuthInfo failed:` + e);
    }
  }

  /**
   * Auth
   *
   * @param challenge pass in challenge value.
   * @param password password
   * @param onResult Return results through callback.
   */
  authPin(challenge: string, password: string, onResult: (result: number, extraInfo: {
    token?: string;
    remainTimes?: number;
    freezingTime?: number;
  }) => void): void {
    this.password = password;
    try {
      LogUtil.debug(`${this.TAG}authPin : ( ${challenge},  ${AuthType.PIN},  ${AuthTrustLevel.ATL4} )`);
      this.userAuth.auth(this.strToU8A(challenge), AuthType.PIN, AuthTrustLevel.ATL4, {
        onResult: (result, extraInfo) => {
          try{
            LogUtil.debug(`${this.TAG}userAuth.auth onResult: challenge = ${challenge}, result:${result}, extraInfo:${extraInfo}`);
            if (result === ResultCode.SUCCESS) {
              LogUtil.debug(`${this.TAG}userAuth.auth onResult: result = success`);
            } else {
              LogUtil.debug(`${this.TAG}userAuth.auth onResult: result =  failed`);
            }
            let info = {
              'token':  this.u8AToStr(extraInfo?.token),
              'remainTimes': extraInfo.remainTimes,
              'freezingTime': extraInfo.freezingTime
            }
            LogUtil.debug(`${this.TAG}userAuth.auth onResult: before callback: info = ${JSON.stringify(info)}`);
            onResult(result, info)
          }
          catch(e) {
            LogUtil.debug(`${this.TAG}userAuth.auth onResult error = ${JSON.stringify(e)}`);
          }
        },

        onAcquireInfo: (acquireModule, acquire, extraInfo) => {
          try{
            LogUtil.debug(this.TAG + 'faceDemo pin.auth onAcquireInfo acquireModule = ' + acquireModule);
            LogUtil.debug(this.TAG + 'faceDemo pin.auth onAcquireInfo acquire = ' + acquire);
            LogUtil.debug(this.TAG + 'faceDemo pin.auth onAcquireInfo extraInfo = ' + JSON.stringify(extraInfo));
          }
          catch(e) {
            LogUtil.error(this.TAG + 'faceDemo pin.auth onAcquireInfo error = ' + e);
          }
        }
      })

    } catch (e) {
      LogUtil.error(`${this.TAG}AuthPin failed:` + e);
    }
  }

  /**
   * getProperty
   *
   * @param callback Return results through callback.
   */
   getAuthProperty(callback: (data: {
    result: number;
    authSubType: number;
    remainTimes ?: number;
    freezingTime ?: number;
  }) => void): void {
    try {
      let request = {
        'authType': AuthType.PIN,
        'keys': [GetPropertyType.AUTH_SUB_TYPE, GetPropertyType.REMAIN_TIMES, GetPropertyType.FREEZING_TIME]
      }
      LogUtil.debug(`${this.TAG}getAuthProperty->call api request = ${JSON.stringify(request)}`);

      this.userAuth.getProperty(request)
        .then((data)=> {
          let i =  JSON.stringify(data);
          LogUtil.debug('faceDemo promise.getProperty result i = ' + i);
          LogUtil.debug('faceDemo promise.getProperty result = ' + data);

          LogUtil.debug(`${this.TAG}getAuthProperty->getProperty data:${JSON.stringify(data)}`);
          callback(data);
        })
        .catch(e =>{
          LogUtil.debug(`${this.TAG}getAuthProperty->getProperty failed:` + e);
        });
    } catch (e) {
      LogUtil.info(`${this.TAG}getAuthProperty failed:` + e);
    }
  };
}

let passwordModel = new PasswordModel();
export default passwordModel as PasswordModel;
