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

import emitter from '@ohos.events.emitter';
import inputMethod from '@ohos.inputMethod';
import { BusinessError } from '@ohos.base';
import {
  AlignStartDialogMessageStyle,
  DialogMessageMenu,
  DialogMessageTextStyle,
  DialogPage,
  DialogTitleMenu,
  PhoneDialogTitleMenuStyle,
  SwitchMenu,
  TransparentButtonMenu
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import {
  ButtonMenuController,
  MenuController,
  MenuGroupController,
  SwitchMenuController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import {
  extraType,
  MenuGroup,
  SettingsBaseMenu
} from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { DialogLifecycleObserverInterface } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { INPUT_ENABLE_STATE_CHANGE } from '@ohos/settings.common/src/main/ets/event/types';

/* instrument ignore file */
export interface objData {
  enableImeList: Record<string, Array<string>>;
}

export interface fullExperienceData {
  fullExperienceList: Record<string, Array<string>>;
}

const INPUT_SWITCH_MENU: number = 33010;

class FullExperienceMsgDialogMessageStyle extends AlignStartDialogMessageStyle {
  constructor() {
    super();
    if (this.title) {
      (this.title as DialogMessageTextStyle).maxLines = 99;
    }
  }
}

const fullExperienceMsgDialogMessageStyle = new FullExperienceMsgDialogMessageStyle();

export class OtherInputCompleteSwitch extends SwitchMenuController {
  static CreateOtherInputCompleteSwitch(menu: SettingsBaseMenu): Controller {
    return new OtherInputCompleteSwitch(menu);
  }

  public tag: string = 'OtherInputCompleteSwitch :';
  public inputKey: string;
  public inputId: string;
  public isOn: boolean = false;
  private currentInput: inputMethod.InputMethodProperty | undefined = undefined;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.inputKey = (this.menu?.extra as extraType).value as string;
    this.inputId = (this.menu?.extra as extraType).name as string;
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    super.aboutToAppear();
    emitter.on({
      eventId: INPUT_SWITCH_MENU,
      priority: emitter.EventPriority.IMMEDIATE,
    }, (eventData: emitter.EventData) => {
      let oldSwitchState: boolean = this.isOn;
      LogUtil.info(`${this.tag} oldSwitchState ${oldSwitchState}`);
      this.isOn = eventData?.data?.emitType;
      LogUtil.info(`${this.tag} emitter.on ${this.isOn}`);
      this.updateCheckedState();
      if (oldSwitchState !== eventData?.data?.emitType) {
        LogUtil.info(`${this.tag} updateFullExperienceSwitch ${this.isOn}`);
        this.updateFullExperienceSwitch();
      }
      this.setChecked(eventData?.data?.emitType);
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    super.aboutToDisappear();
    emitter.off(INPUT_SWITCH_MENU);
  }

  private getFullExperienceMenu(): SettingsBaseMenu[] {
    let result: SettingsBaseMenu[] = [];
    result.push(
      new MenuGroup(
        {
          key: 'full_experience_dialog_group',
          index: 10,
        },
        [
          new DialogTitleMenu(
            {
              key: 'full_experience_dialog_title',
              index: 1,
              title: $r('app.string.inputRadioTitle'),
              style: new PhoneDialogTitleMenuStyle(),
            }
          ),
          new DialogMessageMenu(
            {
              key: 'full_experience_msg',
              index: 10,
              title: $r('app.string.inputRadioContext'),
              style: fullExperienceMsgDialogMessageStyle,
            }
          ),
          new TransparentButtonMenu({
            key: 'full_experience_button',
            index: 100,
            buttonTittle1: $r('app.string.input_cancle'),
            buttonTittle3: $r('app.string.input_enable'),
            controller: {
              createControllerConstructorInter: FullExpDialogButtonController.CreateFullExpDialogButtonController,
            }
          }),
        ]
      )
    )
    return result;
  }

  protected handleCheckedChange(isChecked: boolean): boolean {
    if (isChecked) {
      let dialogPage: DialogPage = new DialogPage({
        pageUrl: 'pages/input/inputSettings/otherInputDetailSettings',
        title: $r('app.string.inputRadioTitle'),
        controller: { createControllerConstructorInter: FullExpDialogController.CreateFullExpDialogController }
      });
      dialogPage.addMenu(
        ...this.getFullExperienceMenu()
      );
      this.openDialog(dialogPage, true);
    } else {
      // 关闭完整体验开关
      this.isOn = false;
      this.closeFullExperienceSwitch();
      this.setChecked(false);
    }
    return true;
  }

  private closeFullExperienceSwitch(): void {
    if (this.currentInput) {
      inputMethod.getSetting()
        .enableInputMethod(this.inputKey, this.inputId, inputMethod.EnabledState.BASIC_MODE)
        .then(() => {
          EventBus.getInstance()
            .emit(INPUT_ENABLE_STATE_CHANGE,
              { data: { 'inputName': this.inputKey, 'enabledState': inputMethod.EnabledState.BASIC_MODE } });
        })
        .catch((err: BusinessError) => {
          LogUtil.info(`${this.tag} enableInputMethod err code: ${err?.code} message: ${err?.message}`);
        })
    }
  }

  private updateFullExperienceSwitch(): void {
    if (this.isOn) {
      if (this.currentInput) {
        LogUtil.info(`${this.tag} enableFullExperienceSwitch`);
        inputMethod.getSetting()
          .enableInputMethod(this.inputKey, this.inputId, inputMethod.EnabledState.FULL_EXPERIENCE_MODE)
          .then(() => {
            EventBus.getInstance()
              .emit(INPUT_ENABLE_STATE_CHANGE,
                {
                  data: { 'inputName': this.inputKey, 'enabledState': inputMethod.EnabledState.FULL_EXPERIENCE_MODE }
                });
          })
          .catch((err: BusinessError) => {
            LogUtil.info(`${this.tag} enableInputMethod err code: ${err?.code} message: ${err?.message}`);
          })
      }
    } else {
      this.closeFullExperienceSwitch();
    }
  }

  updateCheckedState(): boolean {
    LogUtil.info(`${this.tag} updateCheckedState`);
    const allInputMethod = this.getAllInputMethodsSync();
    this.currentInput = allInputMethod.find(item => item.name === this.inputKey);
    if (this.currentInput) {
      return this.currentInput.enabledState === inputMethod.EnabledState.FULL_EXPERIENCE_MODE;
    }
    return false;
  }

  updateStatus(): void {
    let isChecked = this.updateCheckedState();
    this.setChecked(isChecked);
    this.isOn = isChecked;
  }

  private getAllInputMethodsSync(): inputMethod.InputMethodProperty[] {
    let arr: inputMethod.InputMethodProperty[] = [];
    try {
      arr = inputMethod.getSetting().getAllInputMethodsSync();
    } catch (err) {
      LogUtil.error(`${this.tag} getAllInputMethodsSync failed code: ${err?.code} message: ${err?.message}`);
    }
    return arr;
  }
}

export class FullExpDialogController extends MenuController implements DialogLifecycleObserverInterface {
  public getObserverKey?: () => string = (): string => {
    return this.menu?.key as string;
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateFullExpDialogController(menu: SettingsBaseMenu): Controller {
    return new FullExpDialogController(menu);
  }

  onDialogClose(key?: string, data?: Object): void {

  }

  onDialogCancel(key?: string, data?: Object): void {
    emitter.emit({
      eventId: INPUT_SWITCH_MENU,
      priority: emitter.EventPriority.IMMEDIATE,
    }, {
      data: { 'emitType': false }
    });
  }

  onDialogOpen(key?: string, data?: Object): void {
  }
}

@Observed
class FullExpDialogButtonController extends ButtonMenuController {
  public tag: string = 'fullExpDialogButtonController : ';
  public isSureButtonEnable: boolean = false;
  public password: string = '';
  public pinChallenge: string = '';

  static CreateFullExpDialogButtonController(menu: SettingsBaseMenu): Controller {
    return new FullExpDialogButtonController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    LogUtil.info(`${this.tag} aboutToAppear`);
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
    LogUtil.info(`${this.tag} aboutToDisappear`);
  }

  onButton1Click(): void {
    LogUtil.info(`${this.tag} onButton1Click`);
    emitter.emit({
      eventId: INPUT_SWITCH_MENU,
      priority: emitter.EventPriority.IMMEDIATE,
    }, {
      data: { 'emitType': false }
    });
    this.closeSelf();
  }

  onButton3Click(): void {
    LogUtil.info(`${this.tag} onButton3Click`);
    emitter.emit({
      eventId: INPUT_SWITCH_MENU,
      priority: emitter.EventPriority.IMMEDIATE,
    }, {
      data: { 'emitType': true }
    });
    this.closeSelf();
  }
}

export class OtherInputSwitch extends SwitchMenuController {
  static CreateOtherInputSwitch(menu: SettingsBaseMenu): Controller {
    return new OtherInputSwitch(menu);
  }

  private static switchState: boolean = true;
  public inputKey: string;
  public inputId: string;
  public currentInput: inputMethod.InputMethodProperty | undefined = undefined;
  public currentUserInput: Array<string> = [];
  public isChecked: boolean = false;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.inputKey = (this.menu?.extra as extraType).value as string;
    this.inputId = (this.menu?.extra as extraType).name as string;
  }

  /**
   * 返回开关的实时状态
   */
  protected updateCheckedState(): boolean {
    const allInputMethod = this.getAllInputMethodsSync();
    this.currentInput = allInputMethod.find(item => item.name === this.inputKey);
    if (this.currentInput) {
      return (this.currentInput.enabledState === inputMethod.EnabledState.BASIC_MODE) ||
        (this.currentInput.enabledState === inputMethod.EnabledState.FULL_EXPERIENCE_MODE);
    }
    return false;
  }


  updateStatus(): void {
    let isChecked = this.updateCheckedState();
    this.setChecked(isChecked);
    this.publishDataChange(isChecked);
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    this.isChecked = isChecked;
    this.updateEnableSwitch();
    this.setChecked(isChecked);
    this.publishDataChange(isChecked);
    return true;
  }

  private updateEnableSwitch(): void {
    if (!this.currentInput) {
      LogUtil.info(`${this.tag} updateEnableSwitch currentInput is null`);
      return;
    }
    const enabledState: inputMethod.EnabledState =
      this.isChecked ? inputMethod.EnabledState.BASIC_MODE : inputMethod.EnabledState.DISABLED;
    inputMethod.getSetting()
      .enableInputMethod(this.inputKey, this.inputId, enabledState)
      .then(() => {
        EventBus.getInstance()
          .emit(INPUT_ENABLE_STATE_CHANGE, { data: { 'inputName': this.inputKey, 'enabledState': enabledState } });
      })
      .catch((err: BusinessError) => {
        LogUtil.info(`${this.tag} enableInputMethod err code: ${err?.code} message: ${err?.message}`);
      })
  }

  private getAllInputMethodsSync(): inputMethod.InputMethodProperty[] {
    let arr: inputMethod.InputMethodProperty[] = [];
    try {
      arr = inputMethod.getSetting().getAllInputMethodsSync();
    } catch (err) {
      LogUtil.error(`${this.tag} getAllInputMethodsSync failed code: ${err?.code} message: ${err?.message}`);
    }
    return arr;
  }
}

export class SwitchListController extends MenuGroupController {
  static CreateSwitchListController(menu: SettingsBaseMenu): Controller {
    return new SwitchListController(menu);
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  getListenerName(): string {
    return this.menu.key ?? ' ';
  }

  registerDataChange() {
    this.registerControllerDataChange('input_switch_pc');
  }

  onDataChange(fromKey: string, data: boolean): void {
    if (data) {
      this.addChildren([
        new SwitchMenu(
          {
            key: 'input_complete_switch',
            index: 20,
            title: ResourceUtil.getStringSync($r('app.string.complete_input_Mode')),
            controller: {
              createControllerConstructorInter: OtherInputCompleteSwitch.CreateOtherInputCompleteSwitch,
            },
            extra: this.menu?.extra
          }
        )
      ]);
    } else {
      this.removeChildren('input_complete_switch');
    }
    this.refreshUi();
  }
}