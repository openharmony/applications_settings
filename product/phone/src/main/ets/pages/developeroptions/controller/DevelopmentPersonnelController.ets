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

import hgmnapi from '@ohos.libhgmnapi.z.so';
import {
  DialogMessageMenu,
  TransparentButtonMenu,
  DeveloperDialogPageStyle,
  DeveloperDialogTitleStyle,
  DeveloperDialogMessageStyle,
  DeveloperDialogButtonMenuStyle,
  DialogPage,
  DialogTitleMenu
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import usb from '@ohos.usbManager';
import power from '@ohos.power';
import settings from '@ohos.settings';
import { BusinessError } from '@ohos.base';
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import { CheckPsdParams } from '../../password/model/CheckPasswordPage';
import { Controller, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { VERIFY_PASSWORD_ENTRY_FLAG } from '../../password/controller/PasswordEntryController';
import emitter from '@ohos.events.emitter';
import { DialogLifecycleObserverInterface } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import {
  ButtonMenuController,
  MenuController,
  SwitchMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { MenuGroup, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { SecurityUtil } from '@ohos/settings.common/src/main/ets/utils/SecurityUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { DEVELOP_OPTION_STATE } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { HiSysAboutSystemSettingsEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { EventResultConsts } from '@ohos/settings.common/src/main/ets/systemEvent/EventResultConsts';
/* instrument ignore file */
const CHANGE_SETTINGS_CHARGE_TEMPERATURE_SWITCH: string = 'change_settings_charge_temperature_switch';
const SETTINGS_DEVELOPER_CHARGE_TEMPERATURE_CONTROLLER_ENABLE: string = 'settings.developer.charge_temperature_control_enable';
const CHANGE_SETTINGS_CHARGE_ATOMICSERVICE_DEBUG_SWITCH: string = 'change_settings_atomicservice_debug_switch';
const SETTINGS_DEVELOPER_CHARGE_ATOMICSERVICE_DEBUG_ENABLE: string = 'settings.developer.atomicservice_debug_enable';
const CHANGE_SETTINGS_INPUT_SHOW_TOUCH_SWITCH: string = 'change_settings_input_show_touch_switch';
const SETTINGS_INPUT_SHOW_TOUCH_HINT: string = 'settings.input.show_touch_hint';
const CHANGE_SETTINGS_DEVELOPER_SHOW_TOUCH_TRACK_SWITCH: string = 'change_settings_developer_show_touch_track_switch';
const SETTINGS_DEVELOPER_SHOW_TOUCH_TRACK: string = 'settings.developer.show_touch_track';
const INSIGHT_INTENT_DEBUG_SETTING_NAME:string = 'ai_insightintent_debug';
const INSIGHT_INTENT_DEBUG_SETTING_VALUE_CLOSE:string = 'false';
const DISPLAY_REDRAW_AREA_PARAM_NAME: string = 'rosen.dirtyregiondebug.enabled';
const DISPLAY_REDRAW_AREA_PARAM_DEFAULT: string = '0';
const OVERDRAW_PARAM_NAME: string = 'debug.graphic.overdraw';
const OVERDRAW_PARAM_DEFAULT: string = 'false';
const REDRAW_CACHE_PARAM_NAME: string = 'rosen.drawingCache.enabledDfx';
const REDRAW_CACHE_PARAM_DEFAULT: string = '0';
const FREEZE_DETECTOR_PARAM_NAME: string = 'persist.hiview.freeze_detector';
const FREEZE_DETECTOR_PARAM_DEFAULT: string = 'false';
const LEAK_DETECTOR_PARAM_NAME: string = 'persist.hiview.leak_detector';
const LEAK_DETECTOR_PARAM_DEFAULT: string = 'false';
const TRACE_RECORDER_PARAM_NAME: string = 'persist.hiview.trace_recorder';
const TRACE_RECORDER_PARAM_DEFAULT: string = 'false';
const MULTI_WINDOW_DEBUG_PARAM_KEY: string = 'persist.debug.multi_window';
const DISPLAY_LAYOUT_BOUNDARIES_KEY: string = 'persist.ace.debug.boundary.enabled';
const SETTINGS_SWITCH_WLAN_LOGS_KEY: string = 'settings.switch_wlan_logs';
const AUTOMATIC_SYSTEM_UPDATE_KEY: string = 'ota_disable_automatic_update';
const TAG: string = 'DevelopmentPersonnelController : ';
const FUNCTION_TYPE_STORAGE = 512;
const EVENT_ID = 20240105;

interface DeveloperModeConfig {
  version: number,
  enable: number
}




/**
 * 开发人员选项开关控制器
 *
 * @since 2023-03-08
 */
@Observed
export default class DevelopmentPersonnelController extends SwitchMenuController {
  static CreateDevelopmentPersonnelController(menu: SettingsBaseMenu): Controller {
    return new DevelopmentPersonnelController(menu);
  }

  public state: boolean = false;

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    // 1 表示开启， 0 为关闭
    if (this.state !== isChecked) {
      this.openSwtichDialog(isChecked);
    }
    return true;
  }

  /**
   * 打开弹框
   */
  private openSwtichDialog(isChecked: boolean): void {
    LogUtil.info(`${this.tag} openSwtichDialog`);
    let detail = new DialogPage({
      pageUrl: 'pages/display/DisplaySettings/open_developer_mode',
      title: isChecked ? $r('app.string.open_developer_mode') : $r('app.string.close_developer_mode'),
      style: new DeveloperDialogPageStyle(),
      status: isChecked,
      controller: {
        createControllerConstructorInter: FullExpDialogController.CreateFullExpDialogController,
      },
    });
    let menus = [
      new DialogTitleMenu(
        {
          key: 'open_developer_mode',
          index: 10,
          title: isChecked ? $r('app.string.open_developer_mode') : $r('app.string.close_developer_mode'),
          style: new DeveloperDialogTitleStyle(),
        },
      ),
      new DialogMessageMenu(
        {
          key: 'open_developer_mode_message',
          index: 11, // 页面显示顺序
          title: isChecked ? $r('app.string.confirm_development_modal_dialog_content') : $r('app.string.cancel_development_modal_dialog_content'),
          style: new DeveloperDialogMessageStyle() as Style,
        }
      ),
      new TransparentButtonMenu(
        {
          key: 'open_developer_mode_button',
          timestamp: Math.random(),
          index: 101, // 页面显示顺序
          buttonTittle1: ResourceUtil.getStringSync($r('app.string.dialog_cancel')),
          buttonTittle3: isChecked ? $r('app.string.confirm_on') : $r('app.string.confirm_close'),
          style: new DeveloperDialogButtonMenuStyle(),
          controller: {
            createControllerConstructorInter: DialogButtonController.CreateDialogButtonController,
          },
          extra: isChecked,
        }
      ),
    ];
    detail.addMenus(menus);
    this.openDialog(detail, true);
  }

  /**
   * 返回开关的实时状态
   */
  protected updateCheckedState(): boolean {
    emitter.on({
      eventId: EVENT_ID,
      priority: emitter.EventPriority.IMMEDIATE,
    }, (eventData: emitter.EventData) => {
      let isChecked: boolean = eventData?.data?.emitType;
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutSystemSettingsEventGroup.DEVELOPER_MODE_SWITCH,
        isChecked ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF);
      this.setChecked(eventData?.data?.emitType);
      if (eventData?.data?.password) {
        let params: CheckPsdParams =
          new CheckPsdParams(VERIFY_PASSWORD_ENTRY_FLAG, NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY);
        this.menu.pushName(NavEntryKey.CHECK_PSD_ENTRY, new PushParam(params));
      }

    });
    try {
      // 获取系统中开发者模式状态，检查是否处于开发者模式
      let status: string = systemParameterEnhance.getSync('const.security.developermode.state', '0');
      LogUtil.info(`${TAG} const.security.developermode.state success`)
      this.state = JSON.parse(status);
      return JSON.parse(status);
    } catch (err) {
      LogUtil.error(`${TAG} const.security.developermode.state fail`);
      return false;
    }
  }

  updateStatus(): void {
    let isChecked = this.updateCheckedState();
    this.setChecked(isChecked);
    this.refreshUi();
  }

  onPageDestroy() {
    emitter.off(EVENT_ID)
  }
}

@Observed
export class DialogButtonController extends ButtonMenuController {
  static CreateDialogButtonController(menu: SettingsBaseMenu): Controller {
    return new DialogButtonController(menu);
  }

  public tag: string = 'DialogButtonController : ';
  public isChecked: boolean = false;
  private context: Context = AppStorage.get<Context>('pageContext') as Context;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    if (typeof menu?.extra === 'boolean') {
      this.isChecked = menu?.extra;
    }
  }

  protected setReboot(): void {
    try {
      power.reboot('reboot_test');
    } catch (err) {
      LogUtil.error(`reboot failed, err:${err}`)
    }
  }

  protected async setDeveloperMode(isChecked: boolean): Promise<void> {
    try {
      await SearchDataController.getInstance().updateChildItemSearchStatus('developer_options', isChecked);
      await SecurityUtil.setDevelopMode(0);
    } catch (err) {
      LogUtil.error(`${err} setDeveloperMode fail`);
    }

  }

  protected setChecked(isChecked: boolean, password: boolean): void {
    LogUtil.info(`${this.tag} setChecked ${isChecked}}`);
    LogUtil.info(`${this.tag} menu ${this.menu}}`);
    emitter.emit({
      eventId: EVENT_ID,
      priority: emitter.EventPriority.IMMEDIATE,
    }, {
      data: { 'emitType': isChecked, password: password }
    });
    this.closeSelf();
  }

  onButton1Click(): void {
    LogUtil.info(`${this.tag} cancel`);
    this.closeSelf();
    this.setChecked(!this.isChecked, false);
  }

  private resetSwitchState(): void {
    // 关闭开发者模式时通知usb服务下线禁用hdc
    usb.setCurrentFunctions(FUNCTION_TYPE_STORAGE).then(() => {
      LogUtil.info(`${this.tag} usb setCurrentFunctions successfully`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${this.tag} usb setCurrentFunctions failed, code: ${err.code}, message: ${err.message}`);
    });
    try {
      settings.setValueSync(this.context, SETTINGS_DEVELOPER_CHARGE_TEMPERATURE_CONTROLLER_ENABLE, 'false');
      HiSysEventUtil.reportSwitchEvent(CHANGE_SETTINGS_CHARGE_TEMPERATURE_SWITCH, 'off');
      settings.setValueSync(this.context, SETTINGS_DEVELOPER_CHARGE_ATOMICSERVICE_DEBUG_ENABLE, 'false');
      HiSysEventUtil.reportSwitchEvent(CHANGE_SETTINGS_CHARGE_ATOMICSERVICE_DEBUG_SWITCH, 'off');
      settings.setValueSync(this.context, SETTINGS_DEVELOPER_CHARGE_TEMPERATURE_CONTROLLER_ENABLE, 'false');
      HiSysEventUtil.reportSwitchEvent(CHANGE_SETTINGS_CHARGE_TEMPERATURE_SWITCH, 'off');
      // 关闭显示触摸操作开关
      settings.setValueSync(this.context, SETTINGS_INPUT_SHOW_TOUCH_HINT, 'false');
      HiSysEventUtil.reportSwitchEvent(CHANGE_SETTINGS_INPUT_SHOW_TOUCH_SWITCH, 'off');
      settings.setValueSync(this.context, SETTINGS_DEVELOPER_SHOW_TOUCH_TRACK, 'false');
      HiSysEventUtil.reportSwitchEvent(CHANGE_SETTINGS_DEVELOPER_SHOW_TOUCH_TRACK_SWITCH, 'off');
      settings.setValueSync(this.context, INSIGHT_INTENT_DEBUG_SETTING_NAME, INSIGHT_INTENT_DEBUG_SETTING_VALUE_CLOSE,
        settings.domainName.USER_SECURITY);
      systemParameterEnhance.setSync(DISPLAY_REDRAW_AREA_PARAM_NAME, DISPLAY_REDRAW_AREA_PARAM_DEFAULT);
      systemParameterEnhance.setSync(OVERDRAW_PARAM_NAME, OVERDRAW_PARAM_DEFAULT);
      systemParameterEnhance.setSync(REDRAW_CACHE_PARAM_NAME, REDRAW_CACHE_PARAM_DEFAULT);
      systemParameterEnhance.setSync(FREEZE_DETECTOR_PARAM_NAME, FREEZE_DETECTOR_PARAM_DEFAULT);
      systemParameterEnhance.setSync(LEAK_DETECTOR_PARAM_NAME, LEAK_DETECTOR_PARAM_DEFAULT);
      systemParameterEnhance.setSync(TRACE_RECORDER_PARAM_NAME, TRACE_RECORDER_PARAM_DEFAULT);
      systemParameterEnhance.setSync(MULTI_WINDOW_DEBUG_PARAM_KEY, 'false');
      systemParameterEnhance.setSync(DISPLAY_LAYOUT_BOUNDARIES_KEY, 'false');
      systemParameterEnhance.setSync('persist.hdc.mode.tcp', 'disable');
      systemParameterEnhance.setSync('persist.hdc.mode.usb', 'disable');
      SettingsDataUtils.setSettingsData(SETTINGS_SWITCH_WLAN_LOGS_KEY, 'false');
      SettingsDataUtils.setSettingsData(AUTOMATIC_SYSTEM_UPDATE_KEY, '1');
      hgmnapi.setShowRefreshRateEnabled(false);
    } catch (err) {
      LogUtil.error(`${this.tag} systemParam set fail: ${err.message}`);
    }

    LogUtil.info(`${this.tag} resetSwitchState over`);
  }

  async onButton3Click() {
    try {
      this.resetSwitchState();
      LogUtil.info(`${TAG} disable developer mode, reboot now`);
      await this.setDeveloperMode(this.isChecked);
      setTimeout(() => {
        this.setReboot();
      }, 2000);
    } catch (err) {
      LogUtil.error(`${this.tag} reboot fail ${err}`);
    }
  }
}

export class FullExpDialogController extends MenuController implements DialogLifecycleObserverInterface {
  public getObserverKey?: () => string = (): string => {
    return this.menu?.key as string;
  }
  public isChecked: boolean = false;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.isChecked = !menu?.status as boolean;
  }

  static CreateFullExpDialogController(menu: SettingsBaseMenu): Controller {
    return new FullExpDialogController(menu);
  }

  onDialogClose(key?: string, data?: Object): void {

  }

  onDialogCancel(key?: string, data?: Object): void {
    emitter.emit({
      eventId: EVENT_ID,
      priority: emitter.EventPriority.IMMEDIATE,
    }, {
      data: { 'emitType': this.isChecked }
    });
  }

  onDialogOpen(key?: string, data?: Object): void {
  }
}
