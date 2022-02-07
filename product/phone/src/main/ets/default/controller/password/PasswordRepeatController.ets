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
import {LogAll} from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';
import PasswordModel, {PinSubType, ResultCode} from '../../model/passwordImpl/PasswordModel.ets';
import Router from '@system.router';

let PASSWORD_MAX_LENGTH = 32

@LogAll
export default class PasswordRepeatController extends BaseSettingsController {
  private TAG = ConfigData.TAG + 'PasswordRepeatController ';
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
    LogUtil.info(this.TAG + 'inputFinish : password = ' + this.password + ', inputPassword = ' + this.inputPassword)

    if (!this.password) {
      LogUtil.info(this.TAG + 'inputFinish return : password is none.')
      return;
    }

    if (this.checkMessage) {
      LogUtil.info(this.TAG + 'inputFinish return : has error yet.')
      return;
    }

    if (this.password == this.inputPassword) {
      if (this.pinToken) {
        this.updatePassword()
      } else {
        this.createPassword()
      }
    } else {
      // not match
      LogUtil.info(this.TAG + 'inputFinish : not match')
      this.checkMessage = $r('app.string.password_message_repeat_error')
    }
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
      LogUtil.info(this.TAG + 'createPassword->result = ' + JSON.stringify(result));
      if (result === ResultCode.SUCCESS) {
        LogUtil.info(`${this.TAG}createPassword success`);
        this.goBackCorrect()
      } else {
        LogUtil.info(`${this.TAG}createPassword failed`);
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
      LogUtil.info(this.TAG + 'updateCredential->result = ' + JSON.stringify(result));
      LogUtil.info(this.TAG + 'updateCredential->extraInfo = ' + JSON.stringify(extraInfo));
      if (result === ResultCode.SUCCESS) {
        LogUtil.info(`${this.TAG}updatePassword success`);
        this.goBackCorrect()
      } else {
        LogUtil.info(`${this.TAG}updatePassword failed`);
        //TODO show error message to view
        this.checkMessage = 'update failed.'
      }
    });
  }

}