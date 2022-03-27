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

import BaseSettingsController from '../../../../../../../../common/component/src/main/ets/default/controller/BaseSettingsController';
import ConfigData from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LogUtil from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ISettingsController from '../../../../../../../../common/component/src/main/ets/default/controller/ISettingsController';
import {PinSubType} from '../../model/passwordImpl/PasswordModel';
import {Checker} from './Checker';
import Router from '@system.router';

const PASSWORD_SIX_LENGTH = 6
const AUTH_SUB_TYPE_DEFAULT = PinSubType.PIN_SIX

export default class PasswordInputController extends BaseSettingsController {
  private TAG = ConfigData.TAG + 'PasswordInputController ';
  private checker = new Checker();
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
    if (!this.passwordType || this.passwordType < 0) {
      LogUtil.info(this.TAG + 'initData : passwordType set DEFAULT')
      this.passwordType = AUTH_SUB_TYPE_DEFAULT;
    }

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
    LogUtil.info(this.TAG + 'passwordOnChange in.')
    this.password = value;
    let tempMessage = this.checkInputDigits(value);
    if (this.checkMessage != tempMessage) {
      this.checkMessage = tempMessage;
      AppStorage.SetOrCreate("checkMessage", this.checkMessage);
    }
    if (this.passwordType == PinSubType.PIN_SIX && !this.checkMessage && this.checker.isNumber6(this.password)) {
      // When password is 6 numbers, finish input
      this.inputFinish();
    }
    LogUtil.info(this.TAG + 'passwordOnChange out.')
  }

  /**
   * Input finish. Start simple check.
   */
  inputFinish() {
    if (!this.password) {
      LogUtil.info(this.TAG + 'inputFinish return : password is none.')
      return;
    }

    if (!this.checkMessage) {
      this.checkMessage = this.checkInputDigits(this.password)

      // PIN must more than 4 digits
      if (!this.checker.checkMinDigits(this.password)) {
        if (this.passwordType == PinSubType.PIN_NUMBER) {
          this.checkMessage = $r('app.string.password_PIN_check_min_error')
        } else if (this.passwordType == PinSubType.PIN_MIXED) {
          this.checkMessage = $r('app.string.password_check_min_error')
        }
      }
    }
    AppStorage.SetOrCreate("checkMessage", this.checkMessage);
    if (this.checkMessage) {
      LogUtil.info(this.TAG + 'inputFinish return : has error yet.')
      return;
    }

    this.checkInputSuccess()
  }

  //------------------------------ check ---------------------------
  /**
   * Check input password digits.
   * When password type is SIX, password should be 6 digit numbers.
   * When password type is NUMBER, password should be 4 ~ 33 digits numbers.
   * When password type is MIXED, password should be 4 ~ 33 digits and .
   *
   * @param value inputting password
   * @return error message
   */
  checkInputDigits(pwd: string): string | Resource {
    LogUtil.info(this.TAG + 'checkInputDigits in.')
    switch (this.passwordType) {

      case PinSubType.PIN_SIX:

      // PIN must be 6 numbers
        if (!this.checker.isOnlyNumber(pwd) || pwd?.length > PASSWORD_SIX_LENGTH) {
          return $r('app.string.password_PIN_must_be_6_numbers')
        }
        break;

      case PinSubType.PIN_NUMBER:

      // PIN must less than 33 digits
        if (!this.checker.checkMaxDigits(pwd)) {
          return $r('app.string.password_PIN_check_max_error')
        }

      // PIN must be numbers
        if (!this.checker.isOnlyNumber(pwd)) {
          return $r('app.string.password_PIN_must_be_numbers')
        }
        break;

      case PinSubType.PIN_MIXED:

      // Password must less than 33 digits
        if (!this.checker.checkMaxDigits(pwd)) {
          return $r('app.string.password_check_max_error')
        }

      // Check illegal character
        if (this.checker.isContainIllegalCharacter(pwd)) {
          return $r('app.string.password_illegal_character')
        }

      // When password is more than 4 digits, check password must contains letter.
        if (this.checker.checkMinDigits(pwd) && !this.checker.isContainLetters(pwd)) {
          return $r('app.string.password_check_char_error')
        }
        break;
    }

    return '';
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
