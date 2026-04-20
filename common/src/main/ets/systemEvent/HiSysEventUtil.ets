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

import hiSysEvent from '@ohos.hiSysEvent';
import { BusinessError } from '@ohos.base';
import taskpool from '@ohos.taskpool';
import { LogUtil } from '../utils/LogUtil';
import { HiSysAiBarEventGroup, HisysScreenAndSleepEventGroup, HiSysSpaceManagerGroup } from './BehaviorEventConsts';
import { HiSysModeConnectStaticEventGroup } from './StaticEventConsts';

export interface CommonInterfaceCallFaultParams {
  FAULT_CATEGORY: string;
  FAULT_SUBCATEGORY: string;
  FAULT_INFO?: string;
}

interface ReportParams {
  PACKAGE_NAME: string;
  PROCESS_NAME: string;
  NAME: string;
  VALUE?: string | string[];
  STATUS?: string;
}

interface UeReportParams {
  PNAMEID: string;
  PVERSIONID: string;
  VALUE?: string | string[];
}

interface AbilityUeReportParams {
  PNAMEID: string;
  PVERSIONID: string;
  NAME: string | string[];
  VALUE?: string | string[];
  STATUS?: string;
}

interface UeReportRingTonetParams {
  PNAMEID: string;
  PVERSIONID: string;
  SIM_CARD: string;
  IS_SYSTEM_RINGTONE: string;
  VALUE: string;
}

interface UeReportPowerManagerParams {
  PNAMEID: string;
  PVERSIONID: string;
  SCREENOFF_AC_TIMEOUT?: string;
  SCREENOFF_DC_TIMEOUT?: string;
  POWER_KEY_SETTINGS?: string;
  SWITCH_AC_SETTINGS?: string;
  SWITCH_DC_SETTINGS?: string;
  IS_HIBERNATE?: string;
  WAKE_ON_LID_OPEN?: string;
}

enum HwSystemManagerFormPage {
  HWSYSTEMMANAGERFORM_STORAGE = 'HWSYSTEMMANAGERFORM_STORAGE',
  HWSYSTEMMANAGERFORM_BATTERY = 'HWSYSTEMMANAGERFORM_BATTERY',
  HWSYSTEMMANAGERFORM_DATA_USAGE = 'HWSYSTEMMANAGERFORM_DATA_USAGE',
  HWSYSTEMMANAGERFORM_BLOCKLIST = 'HWSYSTEMMANAGERFORM_BLOCKLIST',
}

interface UeReportAccRecommendationParam {
  TRANSACTION_ID: string,
  RECOMMENDATION_ID: string,
  COUNT: number,
  PNAMEID: string,
  PVERSIONID: string,
}

interface FloatingNavReportParams {
  PNAMEID: string;
  PVERSIONID: string;
  IS_ON?: string;
}

interface SpaceManagerReportParam {
  CREATE_TYPE?: number;
  DELETE_TYPE?: number;
  CREATE_RES?: number;
  DELETE_RES?: number;
}

interface CallerReportParam {
  PNAMEID: string,
  PVERSIONID: string,
  CALLER_BUNDLE_NAME?: string,
  APP_IDENTIFIER?: string,
  CALLER_ABILITY?: string,
  URI?: string
}

@Concurrent
async function getApplicationVersionConcurrent(): Promise<string> {
  const bundleManager = await import('@ohos.bundle.bundleManager');
  let bundleInfo =
    await bundleManager.default.getBundleInfoForSelf(bundleManager.default.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
  LogUtil.info(`getApplicationVersion ${bundleInfo?.versionName}`);

  return bundleInfo?.versionName;
}

@Concurrent
function writeHiSysEvent(info: hiSysEvent.SysEventInfo): void {
  hiSysEvent.write(info).then(() => {
    LogUtil.info(`HiSysEventUtil write ${info.name} success.`);
  }).catch((err: BusinessError) => {
    LogUtil.error(`HiSysEventUtil write ${info.name}  error. code: ${err?.code} ,message: ${err?.message}`);
  });
}

/**
 * 应用打点工具类
 *
 * @since 2022-11-8
 */
export class HiSysEventUtil {
  public static tag: string = 'HiSysEventUtil : ';
  public static applicationVersion: string;
  public static readonly SETTING_DOMAIN_UE: string = 'SETTINGS_APP_UE';
  private static readonly SETTING_DOMAIN: string = 'SETTINGS_APP';
  public static PACKAGE_NAME: string = 'com.ohos.settings';
  public static COMMON_INTERFACE_CALL_FAULT_EVENT_NAME: string = 'COMMON_INTERFACE_CALL_FAULT';
  private static PROCESS_NAME: string = 'Settings';
  private static ENTER_ENTRY_EVENT: string = 'ENTER_ENTRY_EVENT';
  private static CLICK_BUTTON_EVENT: string = 'CLICK_BUTTON_EVENT';
  private static SWITCH_EVENT: string = 'SWITCH_EVENT';
  private static RADIO_EVENT: string = 'RADIO_EVENT';
  private static OPTIONS_EVENT: string = 'OPTIONS_EVENT';
  private static SLIDER_EVENT: string = 'SLIDER_EVENT';
  private static SEARCH_EVENT: string = 'SEARCH_EVENT';
  private static GET_SETTING_SWITCH: string = 'GET_SETTING_SWITCH';
  private static SET_SETTING_SWITCH: string = 'SET_SETTING_SWITCH';
  private static GET_SETTING_SEEKBAR: string = 'GET_SETTING_SEEKBAR';
  private static SET_SETTING_SEEKBAR: string = 'SET_SETTING_SEEKBAR';
  private static GET_SETTING_OPTION: string = 'GET_SETTING_OPTION';
  private static SET_SETTING_OPTION: string = 'SET_SETTING_OPTION';
  private static SETTING_PAGE_JUMP: string = 'SETTING_PAGE_JUMP';
  private static HWSYSTEMMANAGERFORM_REDIRECT: string = 'HWSYSTEMMANAGERFORM_REDIRECT';
  private static SYSTEM_NAV_UE: string = 'SYSTEM_NAV_UE';
  private static FEATURE_EVENT: string = 'FEATURE_EVENT';
  private  static readonly SPACE_MGR_UE: string = 'SPACE_MGR_UE';
  private static CARD_ONE: string = '1';
  private static CARD_TWO: string = '2';
  private static RINGTONE_CARD_ONE: number = 0;
  private static RINGTONE_CARD_TWO: number = 1;
  private static MESSAGE_CARD_ONE: number = 20;
  private static MESSAGE_CARD_TWO: number = 21;
  private static NOTIFICATION_CARD_TWO: number = 40;

  private static async reportEvent(eventType: hiSysEvent.EventType, eventName: string,
    msg: Object, name: string, domain?: string): Promise<void> {
    LogUtil.info(`${HiSysEventUtil.tag} event_name: ${eventName} ; name: ${name} ;`);
    let info: hiSysEvent.SysEventInfo = {
      domain: domain ?? HiSysEventUtil.SETTING_DOMAIN,
      name: eventName,
      eventType: eventType,
      params: msg
    };
    try {
      let writeTask: taskpool.Task = new taskpool.Task(writeHiSysEvent, info);
      taskpool.execute(writeTask, taskpool.Priority.MEDIUM);
    } catch (error) {
      LogUtil.error(`${HiSysEventUtil.tag} catch exception when writeHiSysEvent, errmsg: ${error?.message}`);
    }
    return;
  }

  static async reportDefaultBehaviorEvent(evenName: string, value?: string): Promise<void> {
    let param = {
      PACKAGE_NAME: HiSysEventUtil.getPkgName(),
      PROCESS_NAME: HiSysEventUtil.getProcessName(),
      VALUE: value,
    } as ReportParams;
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, evenName, param, evenName);
    return;
  }

  /**
   * 铃声类型枚举
   */
  private static changeToneTypeUtils(toneType: string) {
    if (toneType === 'ring_tone_settings') {
      return 'UPDATE_RINGTONE'
    } else if (toneType === 'Messaging_tone_settings') {
      return 'UPDATE_SMS_RINGTONE'
    } else if (toneType === 'notification_tone_settings') {
      return 'UPDATE_NOTIFICATION_RINGTONE'
    } else {
      return ''
    }
  }

  /**
   * 振动类型枚举
   */
  private static changeVibrateTypeUtils(vibrateType: number) {
    if (vibrateType === HiSysEventUtil.RINGTONE_CARD_ONE ||
      vibrateType === HiSysEventUtil.RINGTONE_CARD_TWO) {
      return 'SET_RINGTONE_VIBRATION_MODE'
    } else if (vibrateType === HiSysEventUtil.MESSAGE_CARD_ONE ||
      vibrateType === HiSysEventUtil.MESSAGE_CARD_TWO) {
      return 'SET_SMS_RINGTONE_VIBRATE_MODE'
    } else if (vibrateType === HiSysEventUtil.NOTIFICATION_CARD_TWO) {
      return 'SET_NOTIFY_RINGTONE_VIBRATE_MODE'
    } else {
      return ''
    }
  }

  static async reportChoseRingToneBehaviorEventByUE(value: string, navKey: string,
    isSystem: boolean, card: boolean): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    const evenName: string = HiSysEventUtil.changeToneTypeUtils(navKey);
    let param = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      SIM_CARD: card ? HiSysEventUtil.CARD_ONE : HiSysEventUtil.CARD_TWO,
      IS_SYSTEM_RINGTONE: isSystem ? '1' : '0',
      VALUE: value
    } as UeReportRingTonetParams;
    await HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR,
      evenName, param, evenName, HiSysEventUtil.SETTING_DOMAIN_UE);
    return;
  }

  static async reportChoseVibtateBehaviorEventByUE(value: string | undefined, card: number): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    const evenName: string = HiSysEventUtil.changeVibrateTypeUtils(card);
    let param = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      SIM_CARD: String(card),
      VALUE: value
    } as UeReportRingTonetParams;
    await HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR,
      evenName, param, evenName, HiSysEventUtil.SETTING_DOMAIN_UE);
    return;
  }

  static async reportDefaultBehaviorEventByUE(evenName: string, value?: string | number): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let param = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      VALUE: value
    } as UeReportParams;
    await HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR,
      evenName, param, evenName, HiSysEventUtil.SETTING_DOMAIN_UE);
    return;
  }

  static async reportBehaviorEventByUE(evenName: string, param: Record<string, Object>): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      HiSysEventUtil.getApplicationVersion();
    }
    param.PNAMEID = HiSysEventUtil.getPkgName();
    param.PVERSIONID = HiSysEventUtil.applicationVersion;
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR,
      evenName, param, evenName, HiSysEventUtil.SETTING_DOMAIN_UE);
    return;
  }

  static async abilityReportDefaultBehaviorEventByUE(evenName: string, name?: string, value?: string): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      HiSysEventUtil.getApplicationVersion();
    }
    let params = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      NAME: name,
      VALUE: value,
    } as AbilityUeReportParams;
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR,
      evenName, params, evenName, HiSysEventUtil.SETTING_DOMAIN_UE);
    return;
  }

  static async serviceStatusDefaultBehaviorEventByUE(evenName: string, name?: string,
    value?: string, status?: string): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      HiSysEventUtil.getApplicationVersion();
    }
    let params = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      NAME: name,
      VALUE: value,
      STATUS: status,
    } as AbilityUeReportParams;
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR,
      evenName, params, evenName, HiSysEventUtil.SETTING_DOMAIN_UE);
    return;
  }

  public static async getApplicationVersion(): Promise<void> {
    let versionTask: taskpool.Task = new taskpool.Task(getApplicationVersionConcurrent);
    let versionName: string = await taskpool.execute(versionTask, taskpool.Priority.MEDIUM) as string;
    HiSysEventUtil.applicationVersion = versionName;
  }

  private static reportBehaviorEvent(eventName: string, msg: Object, name: string): void {
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, eventName, msg, name);
    return;
  }

  static reportBehaviorEventEx(eventName: string, msg: Object, name: string, domain: string): void {
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, eventName, msg, name, domain);
    return;
  }

  static async reportDefaultFaultEvent(eventName: string, name: string, value?: string): Promise<void> {
    let params = {
      PACKAGE_NAME: HiSysEventUtil.getPkgName(),
      PROCESS_NAME: HiSysEventUtil.getProcessName(),
      NAME: name,
      VALUE: value,
    } as ReportParams;
    await HiSysEventUtil.reportEvent(hiSysEvent.EventType.FAULT, eventName, params, name);
    return;
  }

  static reportFaultEvent(eventName: string, msg: Object, name: string): void {
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.FAULT, eventName, msg, name);
    return;
  }

  static reportStatisticEvent(eventName: string, msg: Object, name: string): void {
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.STATISTIC, eventName, msg, name);
    return;
  }

  static reportStatisticEventByDomain(eventName: string, msg: Object, name: string, domain: string): void {
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.STATISTIC, eventName, msg, name, domain);
    return;
  }

  static reportStatusStatisticEvent(eventName: string, value: string): void {
    if (eventName === HiSysModeConnectStaticEventGroup.COLLABORATION_SERVICE_SCHEDULED) {
      HiSysEventUtil.reportUEStatisticEvent(eventName, value);
      return;
    }
    let params = {
      PACKAGE_NAME: HiSysEventUtil.getPkgName(),
      PROCESS_NAME: HiSysEventUtil.getProcessName(),
      VALUE: value,
    } as ReportParams;
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.STATISTIC, eventName, params, eventName,
      HiSysEventUtil.SETTING_DOMAIN_UE);
    return;
  }

  static async reportUEStatisticEvent(eventName: string, value: string): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let params: UeReportParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      VALUE: value,
    }
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.STATISTIC, eventName,
      params, eventName, HiSysEventUtil.SETTING_DOMAIN_UE);
  }

  static async reportStatisticEventByUE(evenName: string, param: Record<string, Object>): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      HiSysEventUtil.getApplicationVersion();
    }
    param.PNAMEID = HiSysEventUtil.getPkgName();
    param.PVERSIONID = HiSysEventUtil.applicationVersion;
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.STATISTIC,
      evenName, param, evenName, HiSysEventUtil.SETTING_DOMAIN_UE);
  }

  static async reportNotDisturbEvent(evenName: string, param: object): Promise<void> {
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, evenName, param, evenName,
      HiSysEventUtil.SETTING_DOMAIN_UE);
    return;
  }

  static getPkgName(): string {
    return HiSysEventUtil.PACKAGE_NAME;
  }

  static getProcessName(): string {
    return HiSysEventUtil.PROCESS_NAME;
  }

  /**
   * 跳转设置页面打点
   */
  static reportEntryEventByUE(name: string, value?: string) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: name,
      VALUE: value
    };
    HiSysEventUtil.reportBehaviorEventEx(HiSysEventUtil.ENTER_ENTRY_EVENT, params, name,
      HiSysEventUtil.SETTING_DOMAIN_UE);
  }

  /**
   * 菜单入口打点
   */
  static reportEntryEvent(name: string, value?: string) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: name,
      VALUE: value
    };
    HiSysEventUtil.reportBehaviorEvent(HiSysEventUtil.ENTER_ENTRY_EVENT, params, name);
  }

  /**
   * 操作按钮打点
   */
  static reportButtonEvent(name: string, value: string) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: name,
      VALUE: value
    }
    HiSysEventUtil.reportBehaviorEvent(HiSysEventUtil.CLICK_BUTTON_EVENT, params, name);
  }

  /**
   * 开关项打点
   */
  static reportSwitchEvent(name: string, status: string) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: name,
      STATUS: status
    }
    HiSysEventUtil.reportBehaviorEvent(HiSysEventUtil.SWITCH_EVENT, params, name);
  }

  /**
   * 单选项打点
   */
  static reportRadioEvent(name: string, value: string) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: name,
      VALUE: value
    }
    HiSysEventUtil.reportBehaviorEvent(HiSysEventUtil.RADIO_EVENT, params, name);
  }

  /**
   * 复选项打点
   */
  static reportOptionsEvent(name: string, value: string) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: name,
      VALUE: value
    }
    HiSysEventUtil.reportBehaviorEvent(HiSysEventUtil.OPTIONS_EVENT, params, name);
  }

  /**
   * 多选项打点
   */
  static reportCheckboxEvent(name: string, value: string[]) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: name,
      VALUE: value
    }
    HiSysEventUtil.reportBehaviorEvent(HiSysEventUtil.OPTIONS_EVENT, params, name);
  }

  /**
   * 滑动条打点
   */
  static reportSliderEvent(name: string, value: string) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: name,
      VALUE: value
    }
    HiSysEventUtil.reportBehaviorEvent(HiSysEventUtil.SLIDER_EVENT, params, name);
  }

  /**
   * 搜索数据初始化打点
   */
  static searchReportEvent(name: string, value: string) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: name,
      VALUE: value
    }
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysEventUtil.SEARCH_EVENT, params, name);
    return;
  }

  /**
   * 意图框架查询开关类状态打点
   */
  static getSwitchReportEvent(name: string, value: string) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: name,
      VALUE: value
    }
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysEventUtil.GET_SETTING_SWITCH, params, name);
    return;
  }

  /**
   * 意图框架设置开关类状态打点
   */
  static setSwitchReportEvent(name: string, value: string) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: name,
      VALUE: value
    }
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysEventUtil.SET_SETTING_SWITCH, params, name);
    return;
  }

  /**
   * 意图框架查询滑动条类状态打点
   */
  static getSeekbarReportEvent(name: string, value: string) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: name,
      VALUE: value
    }
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysEventUtil.GET_SETTING_SEEKBAR, params, name);
    return;
  }

  /**
   * 意图框架设置滑动条类状态打点
   */
  static setSeekbarReportEvent(name: string, value: string) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: name,
      VALUE: value
    }
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysEventUtil.SET_SETTING_SEEKBAR, params, name);
    return;
  }

  /**
   * 意图框架查询选项类类状态打点
   */
  static getOptionReportEvent(name: string, value: string) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: name,
      VALUE: value
    }
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysEventUtil.GET_SETTING_OPTION, params, name);
    return;
  }

  /**
   * 意图框架设置选项类状态打点
   */
  static setOptionReportEvent(name: string, value: string) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: name,
      VALUE: value
    }
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysEventUtil.SET_SETTING_OPTION, params, name);
    return;
  }

  /**
   * 设置意图框架页面跳转打点
   */
  static settingPageJumpReportEvent(name: string) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: name
    }
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysEventUtil.SETTING_PAGE_JUMP, params, name);
    return;
  }

  /**
   * AI横条设置页开关
   * @param switchType 开关名
   * @param isOn 是否开启
   */
  static reportAiBarSettingSwitchParams(switchType: string, isOn: boolean): void {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: switchType,
      STATUS: isOn + ''
    }
    HiSysEventUtil.reportBehaviorEventEx(HiSysAiBarEventGroup.AI_BAR_SWITCH, params, HiSysAiBarEventGroup.AI_BAR_SWITCH,
      HiSysEventUtil.SYSTEM_NAV_UE);
  }

  /**
   * 系统导航页三键导航开关
   * @param switchType 开关名
   * @param isOn 是否开启
   */
  static async reportFloatingNavSwitchParams(switchType: string, isOn: boolean): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let param: FloatingNavReportParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      IS_ON: isOn + ''
    };
    HiSysEventUtil.reportBehaviorEventEx(HiSysAiBarEventGroup.FLOATING_NAV_SWITCH, param,
      HiSysAiBarEventGroup.FLOATING_NAV_SWITCH, HiSysEventUtil.SYSTEM_NAV_UE);
  }

  /**
   * 系统导航页悬浮球开关
   * @param switchType 开关名
   * @param isOn 是否开启
   */
  static async reportFloatingBallSwitchParams(switchType: string, isOn: boolean): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let param: FloatingNavReportParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      IS_ON: isOn + ''
    };
    HiSysEventUtil.reportBehaviorEventEx(HiSysAiBarEventGroup.FLOATING_BALL_SWITCH, param,
      HiSysAiBarEventGroup.FLOATING_BALL_SWITCH, HiSysEventUtil.SYSTEM_NAV_UE);
  }

  /**
   * 高級安全模式下不安全弹框按钮打点
   */
  /**
   * 高級安全模式下不安全弹框按钮打点
   * @param securityType 安全类型
   * @param code 1表示继续加入 0表示放弃
   */
  static reportUnsafeWifiDialogButtonEvent(securityType: string, isJoin: boolean) {
    let params: ReportParams = {
      PACKAGE_NAME: HiSysEventUtil.PACKAGE_NAME,
      PROCESS_NAME: HiSysEventUtil.PROCESS_NAME,
      NAME: 'WIFI_PROTOCOL',
      VALUE: securityType,
      STATUS: isJoin ? '1' : '0'
    }
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysEventUtil.FEATURE_EVENT, params, 'WIFI_PROTOCOL');
    return;
  }

  /**
   * 手机管家桌面卡片跳转设置页面打点
   * @param originPageName 页面uri
   */
  static async hwSystemManagerFormPageJumpReportEvent(originPageName: string): Promise<void> {
    const mappedPageName: string = (() => {
      switch (originPageName) {
        case 'storage_settings':
          return HwSystemManagerFormPage.HWSYSTEMMANAGERFORM_STORAGE;
        case 'battery':
          return HwSystemManagerFormPage.HWSYSTEMMANAGERFORM_BATTERY;
        case 'mobile_data_manage_entry':
          return HwSystemManagerFormPage.HWSYSTEMMANAGERFORM_DATA_USAGE;
        case 'privacy_settings':
          return HwSystemManagerFormPage.HWSYSTEMMANAGERFORM_BLOCKLIST;
        default:
          LogUtil.warn(`Unknown pageName: ${originPageName}`);
          return originPageName;
      }
    })();
    LogUtil.info(`Report event for: ${mappedPageName}`);
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    const params: UeReportParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      VALUE: mappedPageName,
    }
    await HiSysEventUtil.reportEvent(
      hiSysEvent.EventType.BEHAVIOR,
      HiSysEventUtil.HWSYSTEMMANAGERFORM_REDIRECT,
      params,
      HiSysEventUtil.HWSYSTEMMANAGERFORM_REDIRECT,
      HiSysEventUtil.SETTING_DOMAIN_UE,
    );
    return;
  }

  /**
   * 账号建议事件上报
   * @param eventName 事件名称
   * @param transactionId 事务id，可以跟账号全局服务中的打点进行关联
   * @param recommendationId 建议id
   * @param count 建议数量
   */
  static async reportAccountRecommendationEvent(eventName: string, transactionId: string,
    recommendationId: string, count: number) {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }

    if (count === 0) {
      recommendationId = '0';
    }
    let params: UeReportAccRecommendationParam = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      TRANSACTION_ID: transactionId,
      RECOMMENDATION_ID: recommendationId,
      COUNT: count
    }
    await HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR,
      eventName, params, eventName, HiSysEventUtil.SETTING_DOMAIN_UE);
  }

  /**
   * 电源管理事件枚举
   */
  private static powerManagerEventNameUtils(evenName: string, value?: string): UeReportPowerManagerParams {
    let param = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion
    } as UeReportPowerManagerParams;
    switch (evenName) {
      case HisysScreenAndSleepEventGroup.CHOOSE_SCREENOFF_ACTIMEOUT_RADIO:
        param.SCREENOFF_AC_TIMEOUT = value;
        break;
      case HisysScreenAndSleepEventGroup.CHOOSE_SCREENOFF_DCTIMEOUT_RADIO:
        param.SCREENOFF_DC_TIMEOUT = value;
        break;
      case HisysScreenAndSleepEventGroup.CHOOSE_POWER_KEY_SETTINGS_RADIO:
        param.POWER_KEY_SETTINGS = value;
        break;
      case HisysScreenAndSleepEventGroup.CHOOSE_SWITCH_AC_SETTINGS_RADIO:
        param.SWITCH_AC_SETTINGS = value;
        break;
      case HisysScreenAndSleepEventGroup.CHOOSE_SWITCH_DC_SETTINGS_RADIO:
        param.SWITCH_DC_SETTINGS = value;
        break;
      case HisysScreenAndSleepEventGroup.CHOOSE_HIBERNATE_TOGGLE:
        param.IS_HIBERNATE = value;
        break;
      case HisysScreenAndSleepEventGroup.CHOOSE_WAKE_ON_LID_OPEN_TOGGLE:
        param.WAKE_ON_LID_OPEN = value;
        break;
      default:
        LogUtil.warn(`powerManagerEventNameUtils Unknown eventName: ${evenName}`);
        break;
    }
    return param;
  }

  /**
   * 电源管理事件上报
   * @param eventName 事件名称
   * @param value 事件参数
   */
  static async reportPowerEventByUE(evenName: string, value?: string): Promise<void> {
    try {
      if (!HiSysEventUtil.applicationVersion) {
        await HiSysEventUtil.getApplicationVersion();
      }
      let param: UeReportPowerManagerParams = HiSysEventUtil.powerManagerEventNameUtils(evenName, value);
      await HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR,
        evenName, param, evenName, HiSysEventUtil.SETTING_DOMAIN_UE);
      return;
    } catch (e) {
      LogUtil.error(`reportPowerEventByUE error: ${e?.code}`);
      return;
    }
  }

  /**
   * 空间事件上报
   * @param eventName 事件名称
   * @param typeId 事务id
   * @param res 执行结果
   */
  static async reportSpaceEventByUE(evenName: string, typeId: number, res: number): Promise<void> {
    let param: SpaceManagerReportParam = {};
    switch (evenName) {
      case HiSysSpaceManagerGroup.SPACE_CREATE_EVENT:
        param.CREATE_TYPE = typeId;
        param.CREATE_RES = res;
        break;
      case HiSysSpaceManagerGroup.SPACE_DELETE_EVENT:
        param.DELETE_TYPE = typeId;
        param.DELETE_RES = res;
        break;
      default:
        LogUtil.warn(`reportSpaceEventByUE Unknown eventName: ${evenName}`);
        break;
    }
    await HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR,
      evenName, param, evenName, HiSysEventUtil.SPACE_MGR_UE);
  }

  static async reportEnterSettingEventByUE(evenName: string, callerInfo: string): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    try {
      let caller: Record<string, string> = JSON.parse(callerInfo) as Record<string, string>;
      let param: CallerReportParam = {
        PNAMEID: HiSysEventUtil.getPkgName(),
        PVERSIONID: HiSysEventUtil.applicationVersion,
        CALLER_BUNDLE_NAME: caller?.['bundleName'],
        APP_IDENTIFIER: caller?.['appIdentifier'],
        CALLER_ABILITY: caller?.['abilityName'],
        URI: caller?.['uri']
      };
      await HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR,
        evenName, param, evenName, HiSysEventUtil.SETTING_DOMAIN_UE);
    } catch (e) {
      LogUtil.error(`reportEnterSettingEventByUE error: ${e?.code} ${e?.message}`);
    }
  }
}
