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
import Log from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';
import PasswordModel, {PinSubType, ResultCode} from '../../model/passwordImpl/PasswordModel.ets';
import {Checker} from './Checker.ets';
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

  @Log
  subscribe(): ISettingsController {
    PasswordModel.registerInputer();
    return this;
  };

  @Log
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
    LogUtil.info(this.TAG + 'passwordOnChange : passwordType = ' + this.passwordType + ', password = ' + this.password)
    this.checkMessage = this.checkInputDigits(value)
    LogUtil.info(this.TAG + 'passwordOnChange : checkInputDigits over : checkMessage = ' + JSON.stringify(this.checkMessage));

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
    LogUtil.debug(this.TAG + 'inputFinish : password = ' + this.password + ', inputPassword = ' + this.inputPassword)

    if (!this.password) {
      LogUtil.info(this.TAG + 'inputFinish return : password is none.')
      return;
    }

    // check match
    if (!this.checkMessage && this.password != this.inputPassword) {
      // not match
      LogUtil.info(this.TAG + 'inputFinish : not match')
      this.checkMessage = $r('app.string.password_message_repeat_error')
    }

    LogUtil.info(this.TAG + 'inputFinish ：check over : checkMessage = ' + JSON.stringify(this.checkMessage));
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
  @Log
  checkInputDigits(value: string): string | Resource {

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

  }

//------------------------------ Router -----------------------------
/**
   * Return OK result.
   */
  @Log
  goBackCorrect() {
    Router.back()
  }

//------------------------------ api ---------------------------
/**
   * Call api to create password
   */
  createPassword() {
    PasswordModel.addPinCredential(this.passwordType, this.password, (result) => {
      LogUtil.info(this.TAG + 'create password->result = ' + JSON.stringify(result));
      if (result === ResultCode.SUCCESS) {
        LogUtil.info(`${this.TAG}create password success`);
        this.goBackCorrect()
      } else {
        LogUtil.info(`${this.TAG}create password failed`);
        //TODO show api message to view
        this.checkMessage = 'create failed.'
      }
    });
  }

/**
   * Call api to update password
   */
  updatePassword() {
    PasswordModel.updateCredential(this.passwordType, this.password, this.pinToken, (result, extraInfo) => {
      LogUtil.info(this.TAG + 'update credential->result = ' + JSON.stringify(result));
      LogUtil.debug(this.TAG + 'update credential->extraInfo = ' + JSON.stringify(extraInfo));
      if (result === ResultCode.SUCCESS) {
        LogUtil.info(`${this.TAG}update password success`);
        this.goBackCorrect()
      } else {
        LogUtil.info(`${this.TAG}update password failed`);
        //TODO show error message to view
        this.checkMessage = 'update failed.'
      }
    });
  }

}
