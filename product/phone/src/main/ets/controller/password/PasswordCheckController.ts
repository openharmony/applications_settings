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
import BaseSettingsController from '../../../../../../../common/component/src/main/ets/default/controller/BaseSettingsController';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ISettingsController from '../../../../../../../common/component/src/main/ets/default/controller/ISettingsController';
import PasswordModel, {ResultCode} from '../../model/passwordImpl/PasswordModel';
import Router from '@system.router';
import Prompt from '@system.prompt';

const OPEN_SESSION_FAILED = '0';

export default class PasswordCheckController extends BaseSettingsController {
  private TAG = ConfigData.TAG + 'PasswordCheckController ';
  private pageRequestCode: number = -1;
  private prevPageUri: string = undefined;
  private pinChallenge: string = undefined;
  private pinToken: string = undefined;
  private passwordType: number = -1;
  private freezingTime: number = 0;
  private remainTimes: number = -1;

// private Properties
  private password: string = ''

  initData(): ISettingsController {
    this.loadData()
    return this
  }

  subscribe(): ISettingsController {
    PasswordModel.openSession((data) => {
      if (data === OPEN_SESSION_FAILED) {
        LogUtil.info(`${this.TAG}subscribe->openSession failed`);
      } else {
        LogUtil.info(`${this.TAG}subscribe->openSession success`);
      }
      this.pinChallenge = data;
    });
    PasswordModel.registerInputer();
    return this;
  };

  unsubscribe(): ISettingsController {
    PasswordModel.closeSession();
    PasswordModel.unregisterInputer();
    return this;
  };

//------------------------------ Handler ---------------------------
/**
   * change password type.
   *
   * @param value : inputting password
   */
  passwordOnChange(value: string) {
    LogUtil.info(this.TAG + 'passwordOnChange in.');
    this.password = value;
    LogUtil.info(this.TAG + 'passwordOnChange out.');
  }

//------------------------------ check ---------------------------
/**
   * Input finish. Start simple check.
   */
  inputFinish(event?: ClickEvent) {
    if (!this.password) {
      return;
    }

    // clear page data
    this.freezingTime = 0
    this.remainTimes = -1;

    this.checkInputSuccess()
  }

/**
   * Input check success.
   */
  checkInputSuccess() {
    this.checkPasswordCorrect((result, extraInfo) => {
      LogUtil.info(`${this.TAG} check password correct, result: ${result}`);
      if (result === ResultCode.SUCCESS) {
        if (extraInfo) {
          if (this.pinChallenge) {
            this.pinToken = extraInfo.token;
          }
        }
        this.authSuccess()

      } else {
        if (extraInfo) {
          this.freezingTime = extraInfo.freezingTime;
          this.remainTimes = extraInfo.remainTimes;
        } else {
          LogUtil.info(this.TAG + 'checkInputSuccess : callback not success. And there is no extra info.');
          Prompt.showToast({
            message: 'Pin auth is not success.\nAnd extraInfo has no data.\nresult = ' + result,
            duration: 3500
          })
        }
      }
    });
  }

/**
   * Check password result changed.
   */
  authSuccess() {
    if (this.pinToken && this.pageRequestCode == ConfigData.PAGE_REQUEST_CODE_PASSWORD_CHANGE) {
      this.gotoPasswordCreatePage();
    } else if (this.pinToken && this.pageRequestCode == ConfigData.PAGE_REQUEST_CODE_PASSWORD_DISABLE) {
      this.delCredential(() => {
        this.goBackCorrect();
      });
    } else {
      this.goBackCorrect();
    }
  }

//------------------------------ Router -----------------------------
/**
   * Go to password create page
   */
  gotoPasswordCreatePage() {
    Router.replace({
      uri: 'pages/passwordInput',
      params: {
        'pageRequestCode': this.pageRequestCode,
        'prevPageUri': this.prevPageUri,
        'pinChallenge': this.pinChallenge,
        'pinToken': this.pinToken
      },
    })
  }

/**
   * Auth check ok, return OK result.
   */
  goBackCorrect() {
    Router.back()
  }

//------------------------------ api ---------------------------
/**
   * Call api to check if has the password
   */
  loadData() {
    PasswordModel.hasPinPassword((havePassword) => {
      if (havePassword) {
        this.getAuthProperty();
      } else {
        this.goBackCorrect();
      }
    });
  }

/**
   * Call api to check the password
   *
   * @param value : password type
   */
  checkPasswordCorrect(successCallback: (result: number, extraInfo: any) => void): void {
    LogUtil.info(`${this.TAG} check password correct auth pin.`);
    PasswordModel.authPin(this.pinChallenge, this.password, (result, extraInfo) => {
      if (result === ResultCode.SUCCESS) {
        LogUtil.info(`${this.TAG}check password correct success`);
      } else {
        LogUtil.info(`${this.TAG}check password correct failed`);
        this.password = '';
        LogUtil.info(`${this.TAG} password set empty`);
      }
      successCallback(result, extraInfo)
    });
  }

/**
   * Call api to get passwordType, freezingTime and remainTimes
   *
   * @param successCallback: api success callback
   */
  getAuthProperty() {
    PasswordModel.getAuthProperty((data: any) => {
      if (data.result === ResultCode.SUCCESS) {
        this.passwordType = data.authSubType ? data.authSubType : -1;
        this.freezingTime = data.freezingTime ? data.freezingTime : 0;
        this.remainTimes = data.remainTimes ? data.remainTimes : -1;
        LogUtil.info(`${this.TAG}getAuthProperty success`);
      } else {
        LogUtil.info(`${this.TAG}getAuthProperty failed`);
      }
    });
  }

/**
   * Call api to delete the credential
   *
   * @param successCallback: api success callback
   */
  delCredential(successCallback) {
    PasswordModel.delAllCredential(this.pinToken, (result, extraInfo) => {
      if (result === ResultCode.SUCCESS) {
        LogUtil.info(`${this.TAG}del success`);
        this.pinToken = '';
        successCallback();
      } else {
        LogUtil.info(`${this.TAG}del failed`);
      }
    })
  }
}
