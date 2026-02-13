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

/* instrument ignore file */
import inputMethod from '@ohos.inputMethod';
import InputMethodSubtype from '@ohos.InputMethodSubtype';
import { LogHelper } from '@ohos/settings.common/src/main/ets/framework/common/LogHelper';

const TAG: string = 'PasswordIconVM';

export enum InputSubTypeModeEnum {
  UPPER = 'upper',
  LOWER = 'lower',
}

export interface IPasswordIconVMConfig {
  enableCapsIcon: boolean;
  onPwdIconClick?: () => void;
}

@Observed
export class PasswordIconVM {
  public static readonly SHOW_CAPS_TIPS_DURATION: number = 3000;
  public static readonly ICON_SIZE: number = 25;
  public enableCapsIcon: boolean; // 启用大小写图标
  public isFocused: boolean = false; // 是否编辑中
  public isCapsIconVisible: boolean = false; // 显示大小写图标
  public isCapsOn: boolean = false; // 是否开启了大写
  public isPwdVisible: boolean = false; // 密码文本是否可见
  public isCapsTipsVisible: boolean = false; // 显示大小写文本提示
  public hasCapsTipsShown: boolean = false; // 是否显示过大小写文本提示，每次 focus 时重置
  public onPwdIconClick: () => void;
  private capsEventCallback: ((property: inputMethod.InputMethodProperty,
    subType: InputMethodSubtype) => void) | undefined = undefined;

  constructor(config: IPasswordIconVMConfig) {
    this.enableCapsIcon = config.enableCapsIcon;
    this.onPwdIconClick = config.onPwdIconClick || (() => {});
  }

  /**
   * 清理 viewModel
   */
  public clear(): void {
    LogHelper.info(TAG, 'clear invoked');
    this.unregisterCapsEvent();
  }

  public getInputMethodSubType(): InputSubTypeModeEnum {
    LogHelper.info(TAG, 'getInputMethodSubType invoked');
    try {
      const subType = inputMethod.getCurrentInputMethodSubtype();
      LogHelper.info(TAG, `getInputMethodSubType mode ${subType.mode}`);
      return subType.mode === InputSubTypeModeEnum.UPPER ? InputSubTypeModeEnum.UPPER : InputSubTypeModeEnum.LOWER;
    } catch (err) {
      LogHelper.error(TAG, `getInputMethodSubType failed. Error ${err?.code} ${err?.message}`);
      return InputSubTypeModeEnum.LOWER;
    }
  }

  /**
   * 订阅大小写变化
   */
  public registerCapsEvent(): void {
    LogHelper.info(TAG, 'registerCapsEvent invoked');
    try {
      const inputMethodSetting = inputMethod.getSetting();
      const callback = (property: inputMethod.InputMethodProperty, subType: InputMethodSubtype): void => {
        LogHelper.info(TAG, `capsEventCallback invoked. mode: ${subType.mode}`);
        this.isCapsOn = subType.mode === InputSubTypeModeEnum.UPPER;
        LogHelper.info(TAG, `isFocused ${this.isFocused} isCapsOn ${this.isCapsOn}`);
        this.setIsCapsIconVisible(this.isFocused && this.isCapsOn);
      };
      this.capsEventCallback = callback; // 记录订阅回调的引用，用于解除订阅
      inputMethodSetting.on('imeChange', callback);
    } catch (err) {
      LogHelper.error(TAG, `registerCapsEvent failed. Error ${err?.code} ${err?.message}`);
    }
  }

  /**
   * 取消订阅大小写变化
   */
  public unregisterCapsEvent(): void {
    LogHelper.info(TAG, 'unregisterCapsEvent invoked');
    try {
      const inputMethodSetting = inputMethod.getSetting();
      if (this.capsEventCallback) {
        inputMethodSetting.off('imeChange', this.capsEventCallback);
      }
    } catch (err) {
      LogHelper.error(TAG, `unregisterCapsEvent failed. Error ${err?.code} ${err?.message}`);
    }
  }

  /**
   * 显示大小写文本提示，3s 后关闭
   */
  public showCapsTips(): void {
    if (this.hasCapsTipsShown) {
      return;
    }
    this.hasCapsTipsShown = true;
    this.isCapsTipsVisible = true;
    setTimeout(() => {
      this.isCapsTipsVisible = false;
    }, PasswordIconVM.SHOW_CAPS_TIPS_DURATION);
  }

  /**
   * 获取密码图标（眼睛开启/关闭）
   * @returns 图标资源
   */
  public getPwdIcon(): Resource {
    LogHelper.info(TAG, `getPwdIcon invoked. isPwdVisible ${this.isPwdVisible}`);
    return this.isPwdVisible ? $r('sys.symbol.eye') : $r('sys.symbol.eye_slash');
  }

  /**
   * 设置输入框编辑状态
   * @param isFocused 是否编辑中
   */
  public setIsFocused(isFocused: boolean): void {
    LogHelper.info(TAG, `setIsFocused invoked. isFocused ${isFocused}`);
    if (this.isFocused === isFocused) {
      return;
    }
    this.isFocused = isFocused;
    if (this.isFocused) {
      this.hasCapsTipsShown = false;
      this.isCapsOn = this.getInputMethodSubType() === InputSubTypeModeEnum.UPPER;
      this.registerCapsEvent();
    } else {
      this.unregisterCapsEvent();
      this.setIsCapsIconVisible(false);
    }
  }

  /**
   * 设置大小写图标是否可见，同时会影响提示文本的显示状态
   * @param visible 是否可见
   */
  public setIsCapsIconVisible(visible: boolean): void {
    LogHelper.info(TAG, `setIsCapsIconVisible invoked`);
    if (this.isCapsIconVisible === visible) {
      return;
    }
    this.isCapsIconVisible = visible;
    if (visible) {
      this.showCapsTips();
    } else {
      this.isCapsTipsVisible = false;
    }
  }
}