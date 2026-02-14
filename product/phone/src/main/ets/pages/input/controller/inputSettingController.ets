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

import promptAction from '@ohos.promptAction';
import inputMethod from '@ohos.inputMethod';
import { BusinessError } from '@ohos.base';
import { emitter } from '@kit.BasicServicesKit';
import {
  InputSettingMenuStyle,
  NavigationCheckboxEntry,
  SingleChoiceEntryMenu,
  SingleSelectMenuItem,
  TransparentButtonMenuStyle,
  TransparentButtonStyle,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import {
  NavCheckboxMenuController,
  RadioMenuController,
  SingleChoiceListController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { extraType, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HiSysEventUtil, } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import {
  DialogLifecycleObserverInterface,
  PageLifecycleOwner
} from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import {
  BundleStatusChangeListener,
  BundleStatusChangeManager
} from '@ohos/settings.common/src/main/ets/bundle/BundleStatusChangeManager';
import {
  PageLifecycleMenuGroupController
} from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { EventBus, EventCb } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  EVENT_ID_DEFAULT_INPUT_METHOD_CHANGE,
  INPUT_ENABLE_STATE_CHANGE
} from '@ohos/settings.common/src/main/ets/event/types';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { BaseEntryMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { HiSysSystemAndUpdatesEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
/* instrument ignore file */
const DEFAULT_INPUT_LABELID: string = 'com.ohos.inputmethod';
const WAITING_TIME: number = 100;

export class InputSettingController extends PageLifecycleMenuGroupController {
  public tag: string = 'inputSettingController : ';
  public pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  public pageContext: Context = AbilityContextManager.getContext();
  public currentInputArray: string[] = [];
  public currentInputSwitchArray: string[] = [];
  public allInputMethod: inputMethod.InputMethodProperty[] = [];

  static InputSettingController(menu: SettingsBaseMenu): Controller {
    return new InputSettingController(menu);
  }

  private readonly bundleStatusCallback: BundleStatusChangeListener = {
    getListenerName: () => {
      return '';
    },
    onBundleAdd: (bundleName, user) => {
      LogUtil.info(`${this.tag} bundleStatusCallback add, bundleName: ${bundleName} user: ${user}`);
      setTimeout(() => {
        this.sendEmit();
        this.defaultInputSettingList();
      }, WAITING_TIME);
    },
    onBundleRemove: (bundleName, user) => {
      LogUtil.info(`${this.tag} bundleStatusCallback remove, bundleName: ${bundleName} user: ${user}`);
      setTimeout(() => {
        this.sendEmit();
        this.defaultInputSettingList();
      }, WAITING_TIME);
    },
    onBundleUpdate: (bundleName, user) => {
      LogUtil.info(`${this.tag} bundleStatusCallback update, bundleName: ${bundleName} user: ${user}`);
      setTimeout(() => {
        this.sendEmit();
        this.defaultInputSettingList();
      }, WAITING_TIME);
    }
  };

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  getListenerName(): string {
    return this.menu.key ?? ' ';
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    LogUtil.info(`${this.tag} aboutToAppear`);
    BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(this.bundleStatusCallback);
    BundleStatusChangeManager.getInstance().registerBundleChangedListener(this.bundleStatusCallback);
    this.defaultInputSettingList();
  }

  aboutToDisappear(): void {
    BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(this.bundleStatusCallback);
    LogUtil.info(`${this.tag} aboutToDisappear`);
  }

  getAllInputMethodsSync(): inputMethod.InputMethodProperty[] {
    let arr: inputMethod.InputMethodProperty[] = [];
    try {
      arr = inputMethod.getSetting().getAllInputMethodsSync();
    } catch (err) {
      LogUtil.error(`${this.tag} getAllInputMethodsSync failed code: ${err?.code} message: ${err?.message}`);
    }
    return arr;
  }

  private async defaultInputSettingList(): Promise<void> {
    this.allInputMethod = this.getAllInputMethodsSync();
    LogUtil.info(`${this.tag} allInputMethod: ${JSON.stringify(this.allInputMethod)}`);
    // 将小艺输入法排到第一个
    const item = this.allInputMethod.find((item) => item.name === DEFAULT_INPUT_LABELID);
    if (item) {
      this.allInputMethod = [
        item,
        ...this.allInputMethod.filter((item) => item.name !== DEFAULT_INPUT_LABELID)
      ];
    }
    let radioIconAndTextList: NavigationCheckboxEntry[] = [];
    if (!this.allInputMethod.length) {
      return;
    }
    this.allInputMethod.forEach((input: inputMethod.InputMethodProperty) => {
      const menu = this.createInputMenu(input);
      if (menu?.key?.includes(DEFAULT_INPUT_LABELID)) {
        if (!menu?.selected) {
          menu.selected = true;
          LogUtil.info(`${this.tag} xiaoyi selected, sendEmit DEFAULT_INPUT_METHOD_CHANG`);
          EventBus.getInstance()
            .emit(EVENT_ID_DEFAULT_INPUT_METHOD_CHANGE, { data: { 'emitType': 'switchInputMethod' } });
          this.menu.state = undefined;
        }
        menu.enable = false;
        LogUtil.info(`${this.tag} xiaoyi default selected and disabled`)
      }
      radioIconAndTextList.push(menu);
    });
    // 如果只有一个启用，则不允许操作
    if (radioIconAndTextList.filter((item => item.selected)).length === 1) {
      const item = radioIconAndTextList.find((item => item.selected));
      if (item) {
        item.enable = false;
      }
    }
    if (this.getChildren().length > 0) {
      this.clearChildren();
    }
    this.addChildren(radioIconAndTextList);
    this.refreshUi();
  }

  private createInputMenu(entry: inputMethod.InputMethodProperty): NavigationCheckboxEntry {
    const enabledState = entry.enabledState
    LogUtil.info(`${this.tag} enabledState : ${enabledState}`);
    let currentInputState = (enabledState === inputMethod.EnabledState.FULL_EXPERIENCE_MODE);
    let currentInputSwitchState = currentInputState || (enabledState === inputMethod.EnabledState.BASIC_MODE);
    let menu = new NavigationCheckboxEntry(entry);
    menu.title = entry.label;
    menu.extra = {
      name: entry.id,
      value: entry.name,
    };
    menu.selected = currentInputSwitchState;
    menu.style = new InputSettingMenuStyle();
    menu.key = `${entry.name}_${new Date().getTime().toString()}`;
    menu.state = currentInputSwitchState ? currentInputState ?
    $r('app.string.complete_input_Mode') : $r('app.string.input_enable') : $r('app.string.input_not_enabled');
    menu.stateIcon = $r('app.media.ic_settings_arrow');
    menu.pathInfos = this.menu.pathInfos;
    menu.controller = {
      createControllerConstructorInter: InputEntryController.createInputEntryController,
    };
    // 小艺输入法 不需要 state 也不可取消使能
    if (entry.name === DEFAULT_INPUT_LABELID) {
      menu.state = undefined;
      menu.enable = false;
    }
    return menu;
  }

  sendEmit(): void {
    LogUtil.info(`${this.tag} sendEmit DEFAULT_INPUT_METHOD_CHANG`);
    EventBus.getInstance().emit(EVENT_ID_DEFAULT_INPUT_METHOD_CHANGE, { data: { 'emitType': 'switchInputMethod' } });
  }
}

export class InputPushParam {
  public extra: extraType;
  public title: string;

  constructor(extra: extraType, title: string) {
    this.extra = extra;
    this.title = title
  }
}

export class InputEntryController extends NavCheckboxMenuController {
  public tag: string = 'InputEntryController :';

  private enableStateChange: EventCb = (eventData: emitter.EventData) => {
    if (this.menuKey && this.menuKey === eventData.data?.inputName) {
      (this.menu as NavigationCheckboxEntry).selected =
        eventData.data?.enabledState !== inputMethod.EnabledState.DISABLED;
      switch (eventData.data?.enabledState) {
        case inputMethod.EnabledState.BASIC_MODE:
          this.menu.state = $r('app.string.input_enable');
          break;
        case inputMethod.EnabledState.FULL_EXPERIENCE_MODE:
          this.menu.state = $r('app.string.complete_input_Mode');
          break;
        default:
          this.menu.state = $r('app.string.input_not_enabled');
          break;
      }
    }
  }

  static createInputEntryController(menu: SettingsBaseMenu): Controller {
    return new InputEntryController(menu);
  }

  public menuKey: string;
  public menuId: string;
  public allEnableInputMethods: inputMethod.InputMethodProperty[] = [];

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.menuKey = (this.menu?.extra as extraType)?.value as string;
    this.menuId = (this.menu?.extra as extraType)?.name as string;
  }

  aboutToAppear(): void {
    EventBus.getInstance().on(INPUT_ENABLE_STATE_CHANGE, this.enableStateChange);
  }

  aboutToDisappear(): void {
    EventBus.getInstance().detach(INPUT_ENABLE_STATE_CHANGE, this.enableStateChange);
  }

  onCheckboxChange(value: boolean): void {
    // 找列表所有menus
    const listController = this.menu.getControllerFromPage('input_group_list');
    const menus = ((listController as InputSettingController)?.getChildren() || []) as NavigationCheckboxEntry[];
    const enabledState = value ? inputMethod.EnabledState.BASIC_MODE : inputMethod.EnabledState.DISABLED;
    inputMethod.getSetting()
      .enableInputMethod(this.menuKey, this.menuId, enabledState)
      .then(() => {
        (this.menu as NavigationCheckboxEntry).selected = value;
        // 刷新一下同步选项数据
        this.sendEmit();
        this.menu.state = value ? $r('app.string.input_enable') : $r('app.string.input_not_enabled');
        // 小艺输入法 不需要 state
        if (this.menuKey?.includes(DEFAULT_INPUT_LABELID)) {
          this.menu.state = undefined;
        }
        this.refreshUi();
      }).catch((err: BusinessError) => {
      LogUtil.info(`${this.tag} enableInputMethod err code: ${err?.code} message: ${err?.message}`);
      this.refreshUi();
    })
  }

  sendEmit(): void {
    LogUtil.info(`${this.tag} sendEmit DEFAULT_INPUT_METHOD_CHANG`);
    EventBus.getInstance().emit(EVENT_ID_DEFAULT_INPUT_METHOD_CHANGE, { data: { 'emitType': 'switchInputMethod' } });
  }

  onMenuClick(): boolean {
    LogUtil.info(`${this.tag} onMenuClick`)
    if (!(this.menu instanceof BaseEntryMenu)) {
      let obj: InputPushParam = new InputPushParam(this.menu.extra as extraType, this.menu.title as string);
      if (this.menuKey?.includes(DEFAULT_INPUT_LABELID)) {
        this.menu.pushName(NavEntryKey.INPUT_UIEXTENSION_LIST, new PushParam(obj));
      } else {
        this.menu.pushName(NavEntryKey.OTHER_INPUT_DETAIL_SETTINGS, new PushParam(obj));
      }
    } else {
      this.promptActionShowToast($r('app.string.uncompleted'));
    }
    return true;
  }

  promptActionShowToast(tips: string | Resource): void {
    try {
      promptAction.showToast({ message: tips });
    } catch (error) {
      LogUtil.error(`showToast args error code is ${error?.code}, message is ${error?.message}`);
    }
  }
}

class CancelButtonMenuStyle extends TransparentButtonMenuStyle {
  public buttonStyle1 = new TransparentButtonStyle();
  public menuContainerPadding: Padding = {
    left: $r('app.float.margin_16'),
    right: $r('app.float.margin_16'),
  };
}

/**
 * 默认输入法选择控制器
 *
 * @since 2023-11-29
 */
class SingleSelectMenuItemExpand extends SingleSelectMenuItem {
  public extra?: inputMethod.InputMethodProperty;
}

export class DefaultInputController extends SingleChoiceListController implements DialogLifecycleObserverInterface {
  public tag: string = 'defaultInputController :';

  static createDefaultInputController(menu: SettingsBaseMenu): Controller {
    return new DefaultInputController(menu);
  }

  private inputList: inputMethod.InputMethodProperty[] = [];
  private currentSelectedName: ResourceStr | undefined = undefined;
  // 切换语输入法回调
  private inputMenuEventCallBack = () => {
    LogUtil.info(`${this.tag} inputMenuEventCallBack`);
    this.updateStatus();
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  public getObserverKey = (): string => {
    return this.menu?.key ?? '';
  }

  onPageShow(): void {
    this.updateStatus();
  }

  onPageHide(): void {
    LogUtil.info(`${this.tag} onPageHide`);
  }

  onBindMenuAppear() {
    this.openSelectMenu();
  }

  private openSelectMenu(): void {
    if (this.menu instanceof SingleChoiceEntryMenu) {
      this.menu.singleChoiceData = this.generateSelectMenu();
    }
  }

  private generateSelectMenu(): Array<SingleSelectMenuItemExpand> {
    LogUtil.info(`${this.tag} generateSelectMenu start`);
    let singleChoiceData: SingleSelectMenuItemExpand[] = [];
    let currentSelectedId: string = '';
    try {
      // 获取输入法唯一标识 name+id
      const inputInfo = inputMethod.getCurrentInputMethod();
      currentSelectedId = inputInfo?.name + inputInfo?.id;
      this.inputList = inputMethod.getSetting().getInputMethodsSync(true);
      LogUtil.info(`${this.tag} currentSelectedId: ${currentSelectedId}`);
    } catch (err) {
      LogUtil.error(`Failed to getInputMethodsSync code: ${err?.code} message: ${err?.message}`);
    }
    this.inputList.forEach((input, index) => {
      // 获取输入法唯一标识 name+id
      const inputOnlyTag = input?.name + input?.id;
      let menu: SingleSelectMenuItemExpand = {
        key: `input_select_${index}`,
        title: input.label,
        isSelect: inputOnlyTag === currentSelectedId,
        extra: input
      };
      singleChoiceData.push(menu);
    })
    return singleChoiceData;
  }

  onDialogOpen(): void {
    LogUtil.info('updateStatus');
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    super.aboutToAppear();
    EventBus.getInstance().on(EVENT_ID_DEFAULT_INPUT_METHOD_CHANGE, this.inputMenuEventCallBack);
    // 监听输入法切换
    try {
      inputMethod.getSetting().on('imeChange', () => {
        LogUtil.info(`${this.tag} imeChange start`);
        this.updateStatus()
      });
    } catch (err) {
      LogUtil.error(`${this.tag} Failed to unsubscribing inputMethodProperty. code:${err?.code} mssage:${err?.mssage}`);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    super.aboutToDisappear();
    EventBus.getInstance().detach(EVENT_ID_DEFAULT_INPUT_METHOD_CHANGE, this.inputMenuEventCallBack);
    inputMethod.getSetting().off('imeChange');
  }

  updateStatus(): void {
    LogUtil.info(`${this.tag} updateStatus start`);
    this.currentSelectedName = inputMethod.getCurrentInputMethod()?.label ?? '';
    this.menu.state = this.currentSelectedName;
    this.openSelectMenu();
    this.refreshUi();
    LogUtil.info(`${this.tag} updateStatus this.menu.state:${this.menu.state}`);
  }

  registerDataChange() {
    LogUtil.info(`${this.tag} registerDataChange`);
    this.registerControllerDataChange('input_group_list');
  }

  onDataChange(fromKey: string, data: boolean): void {
    LogUtil.info(`${this.tag} onDataChange fromKey: ${fromKey} data: ${data}`);
    try {
      let defaultIme = inputMethod.getDefaultInputMethod();
      let allInputMethods: inputMethod.InputMethodProperty[] = inputMethod.getSetting().getInputMethodsSync(true);
      let defaultInput = allInputMethods.filter(input => input.id === defaultIme.id).pop();
      try {
        inputMethod.switchInputMethod(defaultInput).then((result: boolean) => {
          if (result) {
            this.menu.state = inputMethod.getCurrentInputMethod()?.label ?? '';
          } else {
            LogUtil.error('Failed to onDataChange.');
          }
        }).catch((err: BusinessError) => {
          LogUtil.error(`Failed to onDataChange code: ${err?.code} message: ${err?.message}`);
        })
      } catch (err) {
        LogUtil.error(`Failed to onDataChange code: ${err?.code} message: ${err?.message}`);
      }
    } catch (err) {
      LogUtil.error(`Failed to onDataChange code: ${err?.code} message: ${err?.message}`);
    }
    this.refreshUi();
  }

  onDialogClose(key?: string, data?: ResourceStr): void {
    LogUtil.info(`${this.tag} onDialogClose`);
    try {
      this.currentSelectedName = data ?? inputMethod.getCurrentInputMethod()?.label ?? ''
    } catch (err) {
      LogUtil.error(`Failed to getCurrentInputMethod code: ${err?.code} message: ${err?.message}`);
    }
    this.updateStatus();
  }

  onDialogCancel(key?: string, data?: Object): void {
    LogUtil.info(`${this.tag} onDialogCancel`);
    try {
      this.currentSelectedName = inputMethod.getCurrentInputMethod()?.label ?? ''
    } catch (err) {
      LogUtil.error(`Failed to getCurrentInputMethod code: ${err?.code} message: ${err?.message}`);
    }
    this.updateStatus();
  }

  onSelectMenuChanged(key: number): void {
    LogUtil.info(`${this.tag} onSelectMenuChanged data = ${key}`);
    try {
      const singleChoiceData: SingleSelectMenuItemExpand[] = (this.menu as SingleChoiceEntryMenu).singleChoiceData!!;
      const inputValue: SingleSelectMenuItemExpand = singleChoiceData?.find((item) => {
        return item.key === key
      })!!;
      let selectedInput: inputMethod.InputMethodProperty = inputValue?.extra as inputMethod.InputMethodProperty;
      this.menu.state = selectedInput.label;
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.CHOOSE_INPUT_METHOD,
        selectedInput?.label);
      inputMethod.switchInputMethod(selectedInput).then((result: boolean) => {
        if (result) {
          LogUtil.info('Succeeded in switching inputmethod.');
        } else {
          LogUtil.error('Failed to switchInputMethod.');
        }
      }).catch((err: BusinessError) => {
        LogUtil.error(`Failed to switchInputMethod code: ${err?.code} message: ${err?.message}`);
      }).finally(() => {
        LogUtil.info(`${this.tag} onSelectMenuChanged finally start`);
        this.sendEmit();
      })
    } catch (err) {
      this.sendEmit();
      LogUtil.error(`Failed to switchInputMethod code: ${err?.code} message: ${err?.message}`);
    }
  }

  sendEmit(): void {
    LogUtil.info(`${this.tag} emit DEFAULT_INPUT_METHOD_CHANG`);
    EventBus.getInstance().emit(EVENT_ID_DEFAULT_INPUT_METHOD_CHANGE, { data: { 'emitType': 'switchInputMethod' } });
  }
}

export class InputChooseRadioController extends RadioMenuController {
  static CreateInputChooseRadioController(menu: SettingsBaseMenu): Controller {
    return new InputChooseRadioController(menu);
  }

  updateStatus(): void {
    try {
      let curInput = inputMethod.getCurrentInputMethod()?.label ?? '';
      if (curInput == (this.menu?.extra as inputMethod.InputMethodProperty)?.label) {
        this.setRadio(true);
      }
    } catch (err) {
      LogUtil.error(`Failed to getCurrentInputMethod code: ${err?.code} message: ${err?.message}`);
    }
  }

  onRadioChange(isChecked: boolean): void {
    LogUtil.info(`onRadioChange ${isChecked}}`);
    this.setRadio(isChecked);
    try {
      let selectedInput: inputMethod.InputMethodProperty = this.menu?.extra as inputMethod.InputMethodProperty;
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.CHOOSE_INPUT_METHOD,
        selectedInput?.label);
      inputMethod.switchInputMethod(selectedInput).then((result: boolean) => {
        if (result) {
          LogUtil.info('Succeeded in switching inputmethod.');
        } else {
          LogUtil.error('Failed to switchInputMethod.');
        }
      }).catch((err: BusinessError) => {
        LogUtil.error(`Failed to switchInputMethod code: ${err?.code} message: ${err?.message}`);
      }).finally(() => {
        LogUtil.info(`${this.tag} onRadioChange finally start`);
        this.sendEmit();
      })
    } catch (err) {
      this.sendEmit();
      LogUtil.error(`Failed to switchInputMethod code: ${err?.code} message: ${err?.message}`);
    }
    this.closeSelf((this.menu?.extra as inputMethod.InputMethodProperty).label);
  }

  sendEmit(): void {
    LogUtil.info(`${this.tag} emit DEFAULT_INPUT_METHOD_CHANG`);
    EventBus.getInstance().emit(EVENT_ID_DEFAULT_INPUT_METHOD_CHANGE, { data: { 'emitType': 'switchInputMethod' } });
  }
}