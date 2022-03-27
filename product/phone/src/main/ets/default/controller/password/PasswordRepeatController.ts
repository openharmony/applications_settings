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
import PasswordModel, {PinSubType, ResultCode} from '../../model/passwordImpl/PasswordModel';
import {Checker} from './Checker';
import Router from '@system.router';

const PASSWORD_SIX_LENGTH = 6

export default class PasswordRepeatController extends BaseSettingsController {
  private TAG = ConfigData.TAG + 'PasswordRepeatController ';
  private checker = new Checker();
  private pinToken: string = undefined
  private passwordType: number = -1
  private inputPassword: string = undefined
  private checkMessage: string | Resource = ''
  private password: string = ''

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
   * Password
   *
   * @param value : inputting password
   */
  passwordOnChange(value: string) {
    LogUtil.info(this.TAG + 'passwordOnChange in.')
    this.password = value;
    this.checkMessage = this.checkInputDigits(value)

    if (this.passwordType == PinSubType.PIN_SIX && !this.checkMessage && this.checker.isNumber6(this.password)) {
      // When password is 6 numbers, finish input
      this.inputFinish();
    }
    LogUtil.info(this.TAG + 'passwordOnChange in.')
  }

/**
   * Input finish. Start simple check.
   */
  inputFinish() {
    if (!this.password) {
      return;
    }

    // check match
    if (!this.checkMessage && this.password != this.inputPassword) {
      // not match
      LogUtil.info(this.TAG + 'inputFinish : not match')
      this.checkMessage = $r('app.string.password_message_repeat_error')
    }

    if (this.checkMessage) {
      LogUtil.info(this.TAG + 'inputFinish return : has error yet.')
      return;
    }

    if (this.pinToken) {
      this.updatePassword()
    } else {
      this.createPassword()
    }
  }

//------------------------------ check ---------------------------
/**
   * Check input password digits.
   * When password type is PIN_SIX, password should be 6 digit numbers.
   * When password type is number or mixed, password should be fewer than 33 digits.
   *
   * @param value inputting password
   * @return error message
   */
  checkInputDigits(value: string): string | Resource {
    LogUtil.info(this.TAG + 'checkInputDigits in.')

    // Check PIN fewer than 33 digits
    if (this.checker.checkMaxDigits(value)) {
      return ''
    }

    // 33 digits check error, show message
    if (this.passwordType == PinSubType.PIN_NUMBER) {
      return $r('app.string.password_PIN_check_max_error')
    } else if (this.passwordType == PinSubType.PIN_MIXED) {
      return $r('app.string.password_check_max_error')
    }
    LogUtil.info(this.TAG + 'checkInputDigits out.');
  }

//------------------------------ Router -----------------------------
/**
   * Return OK result.
   */
  goBackCorrect() {
    Router.back()
  }

//------------------------------ api ---------------------------
/**
   * Call api to create password
   */
  createPassword() {
    PasswordModel.addPinCredential(this.passwordType, this.password, (result) => {
      if (result === ResultCode.SUCCESS) {
        LogUtil.info(`${this.TAG}create password success`);
        this.goBackCorrect()
      } else {
        LogUtil.info(`${this.TAG}create password failed`);
        // show api message to view
        this.checkMessage = 'create failed.'
      }
    });
  }

/**
   * Call api to update password
   */
  updatePassword() {
    PasswordModel.updateCredential(this.passwordType, this.password, this.pinToken, (result, extraInfo) => {
      if (result === ResultCode.SUCCESS) {
        LogUtil.info(`${this.TAG}update password success`);
        this.goBackCorrect()
      } else {
        LogUtil.info(`${this.TAG}update password failed`);
        // show error message to view
        this.checkMessage = 'update failed.'
      }
    });
  }
}
