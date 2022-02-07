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
import ISettingsController from '../../../../../../../../common/component/src/main/ets/default/controller/ISettingsController';
import { LogAll } from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';
import { PinSubType } from '../../model/passwordImpl/PasswordModel.ets';
import Router from '@system.router';

let PASSWORD_MAX_LENGTH = 32
let AUTH_SUB_TYPE_DEFAULT = PinSubType.PIN_SIX

@LogAll
export default class PasswordInputController extends BaseSettingsController {
  private TAG = ConfigData.TAG + 'PasswordInputController ';
  private pageRequestCode: number = -1
  private prevPageUri: string = undefined
  private pinChallenge: string = undefined
  private pinToken: string = undefined
  private password: string = ''
  private passwordType: number = -1
  private checkMessage: string | Resource = ''

/**
   * Initialize data.
   */
  initData(): ISettingsController {

    LogUtil.info(this.TAG + 'initData start : passwordType = ' + this.passwordType)
    if (!this.passwordType || this.passwordType < 0) {
      LogUtil.info(this.TAG + 'initData : passwordType set DEFAULT')
      this.passwordType = AUTH_SUB_TYPE_DEFAULT;
    }

    LogUtil.info(this.TAG + 'initData : passwordType = ' + this.passwordType)

    return super.initData();
  }

//------------------------------ Handler ---------------------------
/**
   * Change password type
   *
   * @param value : password type
   */
  changePasswordType(value) {
    this.passwordType = value;
  }

/**
   * Password
   *
   * @param value : inputting password
   */
  passwordOnChange(value: string) {
    this.password = value;
    LogUtil.info(this.TAG + 'passwordOnChange : passwordType = ' + this.passwordType + ', password = ' + this.password)
    this.checkMessage = ''
    this.checkInputDigits(value)
  }

/**
   * Check input password digits.
   * When password type is PIN_SIX, password should be 6 digit numbers.
   * When password type is number or mixed, password should be fewer than 33 digits.
   *
   * @param value : inputting password
   */
  checkInputDigits(value: string) {

    // When password type is PIN_SIX, check number 6 digits
    if (this.passwordType == PinSubType.PIN_SIX) {
      this.checkMessage = ''
      if (value.length == 6) {
        this.inputFinish();
      }
    }

    // Other type, check PIN fewer than 33 digits
    else if (this.checkMaxDigits(value)) {
      this.checkMessage = ''
    }

    // 33 digits check error, show message
    else if (this.passwordType == PinSubType.PIN_NUMBER) {
      this.checkMessage = $r('app.string.password_PIN_check_max_error')
    } else if (this.passwordType == PinSubType.PIN_MIXED) {
      this.checkMessage = $r('app.string.password_check_max_error')
    }

    LogUtil.info(this.TAG + 'checkInputDigits : checkMessage = ' + JSON.stringify(this.checkMessage));
  }

//------------------------------ check ---------------------------
/**
   * check if the password less than 33 digits
   *
   * @param value : inputting password
   */
  checkMaxDigits(value: string): boolean {
    return value.length <= PASSWORD_MAX_LENGTH;
  }

/**
   * Input finish. Start simple check.
   */
  inputFinish() {
    LogUtil.info(this.TAG + 'inputFinish : password = ' + this.password)

    if (!this.password) {
      LogUtil.info(this.TAG + 'inputFinish return : password is none.')
      return;
    }

    if (this.checkMessage) {
      LogUtil.info(this.TAG + 'inputFinish return : has error yet.')
      return;
    }

    this.checkInputSuccess()
  }

/**
   * Input check success.
   */
  checkInputSuccess() {
    this.gotoRepeatPage();
  }

//------------------------------ Router ---------------------------
/**
   * When password illegality check is ok, go to repeat input password page.
   */
  gotoRepeatPage() {
    Router.replace({
      uri: 'pages/passwordRepeat',
      params: {
        'prevPageUri': this.prevPageUri,
        'pageRequestCode': this.pageRequestCode,
        'pinChallenge': this.pinChallenge,
        'pinToken': this.pinToken,
        'inputPassword': this.password,
        'passwordType': this.passwordType
      }
    });
  }

}