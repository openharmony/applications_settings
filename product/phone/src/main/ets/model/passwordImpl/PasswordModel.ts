/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
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
import BaseModel from '../../../../../../../common/utils/src/main/ets/default/model/BaseModel';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { PasswordSettingItem } from '../../../../../../../common/utils/src/main/ets/default/bean/PasswordSettingItem';
import util from '@ohos.util';
import osAccount from '@ohos.account.osAccount'

/**
  * Credential type for authentication
  */
export enum AuthType {
  /**
   * Indicates the PIN authentication type.
   */
  PIN = 1,

  /**
   * Indicates the FACE authentication type.
   */
  FACE = 2
}

export enum PinSubType {
  /**
   * Indicates the 6-digit credential.
   */
  PIN_SIX = 10000,

  /**
   * Indicates the self-defined digital credential.
   */
  PIN_NUMBER = 10001,

  /**
   * Indicates the self-defined mixed credential.
   */
  PIN_MIXED = 10002,

  /**
   * Indicates the 2D face credential.
   */
  FACE_2D = 20000,

  /**
   * Indicates the 3D face credential.
   */
  FACE_3D = 20001
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
  private passwordList: PasswordSettingItem[][] = [
    [
      {
        "settingIsSectionTitle": true,
        "settingShouldDisplay": false,
        "settingTitle": $r('app.string.biometrics'),
        "settingAlias": "biometrics_section_title"
      },
      {
        "settingIsSectionTitle": false,
        "settingShouldDisplay": true,
        "settingTitle": $r('app.string.face_recognition'),
        "settingAlias": "face_recognition",
        "settingArrow": $r("app.media.ic_settings_arrow"),
      }
    ],
    [
      {
        "settingIsSectionTitle": true,
        "settingShouldDisplay": false,
        "settingTitle": $r('app.string.password'),
        "settingAlias": "password_section_title"
      },
      {
        "settingIsSectionTitle": false,
        "settingShouldDisplay": true,
        "settingTitle": $r('app.string.password_lock_screen'),
        "settingAlias": "password_lock_screen",
        "settingArrow": $r("app.media.ic_settings_arrow"),
        "settingRequestCode": ConfigData.PAGE_REQUEST_CODE_PASSWORD_CREATE,
        "settingUri": "pages/passwordInput"
      },
      {
        "settingIsSectionTitle": false,
        "settingShouldDisplay": false,
        "settingTitle": $r('app.string.password_change_password'),
        "settingAlias": "password_change_password",
        "settingArrow": $r("app.media.ic_settings_arrow"),
        "settingRequestCode": ConfigData.PAGE_REQUEST_CODE_PASSWORD_CHANGE,
        "settingUri": "pages/passwordCheck"
      },
      {
        "settingIsSectionTitle": false,
        "settingShouldDisplay": false,
        "settingTitle": $r('app.string.password_disable_password'),
        "settingAlias": "password_disable_password",
        "settingArrow": "",
        "settingRequestCode": ConfigData.PAGE_REQUEST_CODE_PASSWORD_DISABLE,
        "settingUri": "pages/passwordCheck"
      }
    ]
  ]

  /**
   * constructor
   */
  constructor() {
    super();
    this.userIdentityManager = new osAccount.UserIdentityManager();
    this.pinAuth = new osAccount.PINAuth();
    this.userAuth = new osAccount.UserAuth();
  }

  /**
   * Get password list data
   * @return password list data
   */
  getPageData(): any[] {
    return this.passwordList;
  }

  u8AToStr(val: Uint8Array): any{
    LogUtil.debug(`${this.TAG}u8AToStr in.`);
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
    LogUtil.debug(`${this.TAG}strToU8A in.`);
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
    LogUtil.debug(`${this.TAG}encodeToU8A in.`);
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
    LogUtil.debug(`${this.TAG}registerInputer in.`);
    let result = false;
    try {
      result = this.pinAuth.registerInputer({
        onGetData: (authSubType, inputData) => {
          let u8aPwd = this.encodeToU8A(this.password);
          LogUtil.info(`${this.TAG} before set data, type: ${this.pinSubType}.`);
          inputData.onSetData(this.pinSubType, u8aPwd);
        }
      });
      if(!result){
        this.unregisterInputer();
        result = this.pinAuth.registerInputer({
          onGetData: (authSubType, inputData) => {
            let u8aPwd = this.encodeToU8A(this.password);
            inputData.onSetData(this.pinSubType, u8aPwd);
          }
        });
      }
    } catch {
      LogUtil.error(`${this.TAG}registerInputer failed`);
    }
    LogUtil.info(`${this.TAG}registerInputer out.`);
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
    LogUtil.debug(`${this.TAG}unregisterInputer out.`);
  }

  /**
   * Open Session
   * A challenge value of 0 indicates that opensession failed
   *
   * @returns challenge value
   */
  openSession(callback: (challenge: string) => void): void {
    LogUtil.debug(`${this.TAG}openSession in.`);
    try {
      this.userIdentityManager.openSession()
                              .then((data) =>{
                                callback(this.u8AToStr(data));
                                LogUtil.info(`${this.TAG} openSession success`);
                              })
                              .catch((err) => {
                                LogUtil.error(`${this.TAG} openSession failed` + JSON.stringify(err));
                              })
    } catch {
      LogUtil.error(`${this.TAG}openSession failed`);
      callback('0');
    }
    LogUtil.debug(`${this.TAG}openSession out.`);
  }

  /**
   * Close session
   */
  closeSession(): void {
    LogUtil.debug(`${this.TAG}closeSession in.`);
    try {
      this.userIdentityManager.closeSession()
      LogUtil.debug(`${this.TAG}closeSession success`);
    } catch (e) {
      LogUtil.error(`${this.TAG}closeSession failed:` + e);
    }
    LogUtil.debug(`${this.TAG}closeSession out.`);
  }

  /**
   * Cancel entry and pass in challenge value
   *
   * @param challenge challenge value.
   */
  cancel(challenge: string): number {
    LogUtil.debug(`${this.TAG}cancel in.`);
    let result = ResultCode.FAIL;
    try {
      let data = this.strToU8A(challenge);
      let result = this.userIdentityManager.cancel(data)
      LogUtil.debug(`${this.TAG}cancel success`);
    } catch (e) {
      LogUtil.debug(`${this.TAG}cancel failed:` + e);
    }
    LogUtil.debug(`${this.TAG}cancel out.`);
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
          LogUtil.info(`${this.TAG} Add pin credential, result: ${result}`);
          onResultCall(result);
        }
      };
      this.userIdentityManager.addCredential(credentialInfo, callback);
    } catch (e) {
      LogUtil.debug(`${this.TAG}addPinCredential failed:` + e);
    }
    LogUtil.debug(`${this.TAG}addPinCredential out.`);
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
    LogUtil.info(`${this.TAG}updateCredential in.`);
    try {
      this.pinSubType = pinSubType;
      this.password = password;
      let dataToken = this.strToU8A(token);
      let credentialInfo = {
        credType: AuthType.PIN, credSubType: pinSubType, token: dataToken
      }
      let callback = {
        onResult: (result, extraInfo) => {
          LogUtil.info(`${this.TAG} update credential, result: ${result}`);
          let retExtraInfo = {}
          onResultCall(result, retExtraInfo);
        }
      };
      this.userIdentityManager.updateCredential(credentialInfo, callback);
    } catch (e) {
      LogUtil.debug(`${this.TAG}updateCredential failed:` + e);
    }
    LogUtil.debug(`${this.TAG}updateCredential out.`);
  }

  /**
   * Delete all credential information
   *
   * @param token Password authentication token.
   * @param onResultCallback Get results callback.
   */
  delAllCredential(token: string, onResultCallback: (result: number, extraInfo: {}) => void): void {
    LogUtil.info(`${this.TAG}delAllCredential in.`);
    try{
      let callback = {
        onResult:(result, extraInfo) => {
          LogUtil.info(`${this.TAG} delete all credentials, result: ${result}`);
          let retExtraInfo = {}
          onResultCallback(result, retExtraInfo);
        }
      };
      let data = this.strToU8A(token);
      this.userIdentityManager.delUser(data, callback);
    } catch (e) {
      LogUtil.debug(`${this.TAG}updateCredential failed:` + e);
    }
    LogUtil.debug(`${this.TAG}delAllCredential out.`);
  }

  /**
   * Check if has pin password
   *
   * @param callback Get results callback.
   */
  hasPinPassword(callback: (havePassword: boolean) => void): void {
    LogUtil.debug(`${this.TAG}hasPinPassword in.`);
    this.getPinAuthInfo((data) => {
      let passwordHasSet = false;
      if(data?.length && data.length > 0){
        passwordHasSet = true;
      }
      callback(passwordHasSet)
    });
    LogUtil.debug(`${this.TAG}hasPinPassword out.`);
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
    LogUtil.debug(`${this.TAG}getPinAuthInfo in.`);
    try {
      this.userIdentityManager.getAuthInfo(AuthType.PIN)
                              .then((data) => {
                                LogUtil.info(`${this.TAG} get pin auth info data.`);
                                let arrCredInfo = [];
                                try {
                                  for(let i = 0; i < data.length; i++) {
                                    let credInfo = {
                                      'authType': data[i].authType,
                                      'authSubType': data[i].authSubType
                                    };

                                    if (credInfo.authType == AuthType.PIN) {
                                      this.pinSubType = credInfo.authSubType;
                                    }
                                    arrCredInfo.push(credInfo);
                                  }
                                } catch(e) {
                                  LogUtil.info('faceDemo pin.getAuthInfo error = ' + e);
                                }
                                callback(arrCredInfo);
                                LogUtil.info(`${this.TAG} getAuthInfo success.`);
                              })
                              .catch((err) => {
                                LogUtil.error(`${this.TAG} getAuthInfo failed.` + JSON.stringify(err));
                              })
    } catch (e) {
      LogUtil.error(`${this.TAG}getPinAuthInfo failed:` + e);
    }
    LogUtil.debug(`${this.TAG}getPinAuthInfo out.`);
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
    LogUtil.debug(`${this.TAG}authPin in.`);
    this.password = password;
    try {
      LogUtil.info(`${this.TAG} before userAuth auth pin`);
      this.userAuth.auth(this.strToU8A(challenge), AuthType.PIN, AuthTrustLevel.ATL4, {
        onResult: (result, extraInfo) => {
          try{
            if (result === ResultCode.SUCCESS) {
              LogUtil.debug(`${this.TAG}userAuth.auth onResult: result = success`);
            } else {
              LogUtil.debug(`${this.TAG}userAuth.auth failed onResult: result =  ${result}`);
            }
            let info = {
              'token':  this.u8AToStr(extraInfo?.token),
              'remainTimes': extraInfo.remainTimes,
              'freezingTime': extraInfo.freezingTime
            }
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
          }
          catch(e) {
            LogUtil.error(this.TAG + 'faceDemo pin.auth onAcquireInfo error = ' + e);
          }
        }
      })

    } catch (e) {
      LogUtil.error(`${this.TAG}AuthPin failed:` + e);
    }
    LogUtil.debug(`${this.TAG}authPin out.`);
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
     LogUtil.info(`${this.TAG} getAuthProperty in.`);
    try {
      let request = {
        'authType': AuthType.PIN,
        'keys': [GetPropertyType.AUTH_SUB_TYPE, GetPropertyType.REMAIN_TIMES, GetPropertyType.FREEZING_TIME]
      }

      this.userAuth.getProperty(request)
        .then((data)=> {
          let i =  JSON.stringify(data);
          callback(data);
        })
        .catch(e =>{
          LogUtil.debug(`${this.TAG}getAuthProperty->getProperty failed:` + e);
        });
    } catch (e) {
      LogUtil.debug(`${this.TAG}getAuthProperty failed:` + e);
    }
     LogUtil.debug(`${this.TAG}getAuthProperty out.`);
  };
}

let passwordModel = new PasswordModel();
export default passwordModel as PasswordModel;
