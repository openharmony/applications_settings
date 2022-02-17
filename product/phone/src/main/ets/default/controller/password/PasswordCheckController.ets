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
import BaseSettingsController from '../../../../../../../../common/component/src/main/ets/default/controller/BaseSettingsController.ets';
import ConfigData from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import LogUtil from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import Log from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';
import ISettingsController from '../../../../../../../../common/component/src/main/ets/default/controller/ISettingsController';
import PasswordModel, {ResultCode} from '../../model/passwordImpl/PasswordModel.ets';
import Router from '@system.router';
import Prompt from '@system.prompt';

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

  @Log
  initData(): ISettingsController {
    this.loadData()
    return this
  }

  subscribe(): ISettingsController {
    PasswordModel.registerInputer();
    return this;
  };

  unsubscribe(): ISettingsController {
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
    LogUtil.info(this.TAG + 'passwordOnChange in.')
    this.password = value;
    LogUtil.debug(this.TAG + 'passwordOnChange : passwordType = ' + this.passwordType + ', password = ' + this.password)
    LogUtil.info(this.TAG + 'passwordOnChange out.')  }

//------------------------------ check ---------------------------
/**
   * Input finish. Start simple check.
   */
  inputFinish(event?: ClickEvent) {
    LogUtil.debug(this.TAG + 'inputFinish : password = ' + this.password)

    if (!this.password) {
      LogUtil.info(this.TAG + 'inputFinish return : password is none.')
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
      LogUtil.info(this.TAG + 'checkInputSuccess : checkPasswordCorrect callback : result = ' + result );
      LogUtil.debug(this.TAG + 'checkInputSuccess : checkPasswordCorrect callback : extraInfo = ' + JSON.stringify(extraInfo));
      if (result === ResultCode.SUCCESS) {
        if (extraInfo) {
          if (this.pinChallenge) {
            this.pinToken = extraInfo.token;
          }
        }
        LogUtil.debug(this.TAG + 'checkInputSuccess : callback success. pinChallenge = ' + this.pinChallenge + ', pinToken = ' + this.pinToken);
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
  @Log
  authSuccess() {
    LogUtil.info(`${this.TAG}resultChanged: pageRequestCode = ${this.pageRequestCode}`);
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
  @Log
  gotoPasswordCreatePage() {
    LogUtil.debug(`${this.TAG}gotoPasswordCreatePage : pageRequestCode: ${this.pageRequestCode}, prevPageUri = ${this.prevPageUri}, pageRequestCode: ${this.pageRequestCode}, pinChallenge: ${this.pinChallenge}, pinToken: ${this.pinToken}`);
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
  @Log
  goBackCorrect() {
    Router.back()
  }

//------------------------------ api ---------------------------
/**
   * Call api to check if has the password
   */
  @Log
  loadData() {
    PasswordModel.hasPinPassword((havePassword) => {
      LogUtil.debug(this.TAG + 'hasPinPassword : havePassword = ' + havePassword);
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
    PasswordModel.authPin(this.pinChallenge, this.password, (result, extraInfo) => {
      LogUtil.debug(this.TAG + 'checkPasswordCorrect : result = ' + JSON.stringify(result) + ', extraInfo = ' + JSON.stringify(extraInfo));
      if (result === ResultCode.SUCCESS) {
        LogUtil.info(`${this.TAG}check password correct success`);
      } else {
        LogUtil.info(`${this.TAG}check password correct failed`);
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
      LogUtil.debug(this.TAG + `getAuthProperty data:${JSON.stringify(data)}`);
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
      LogUtil.debug(`${this.TAG}delAllCredential->result:${result}, extraInfo:${JSON.stringify(extraInfo)}`);
      if (result === ResultCode.SUCCESS) {
        LogUtil.info(`${this.TAG}delAllCredential success`);
        this.pinToken = '';
        successCallback();
      } else {
        LogUtil.info(`${this.TAG}delAllCredential failed`);
      }
    })
  }
}
