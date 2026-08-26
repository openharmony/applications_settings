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

import Want from '@ohos.app.ability.Want';
import i18n from '@ohos.i18n';
import uiAppearance from '@ohos.uiAppearance';
import sim from '@ohos.telephony.sim';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import bundleManager from '@ohos.bundle.bundleManager';
import util from '@ohos.util';
import settings from '@ohos.settings';
import Display from '@ohos.display';
import deviceInfo from '@ohos.deviceInfo';
import { rpc } from '@kit.IPCKit';
import { Constants } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import {
  ElderCareEnlargeDisplayConstant
} from '@ohos/settings.common/src/main/ets/constant/ElderCareEnlargeDisplayConstant';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import { SearchCheckUtil } from '@ohos/settings.search/src/main/ets/util/SearchCheckUtil';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  CommonInterfaceCallFaultParams,
  HiSysEventUtil
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysElderCareEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

/* instrument ignore file */
const TAG = 'ElderCareUtils';
const ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED: string = 'accessibility_elder_care_switch_enabled';
const CODE_SUCCESS_ERROR = 0;
const APP_BUNDLE_NAME = 'com.ohos.tips';
const MODULE_NAME_APPGALLERY = 'com.XX.hmsapp.appgallery';
const URI_APPGALLERY = '';
const MODULE_NAME_PHONE = 'phone_widget';
const MODULE_NAME_PC = 'pc_widget';
const URI_FORMATTER = ''
const CODE_BUNDLE_NAME_NOT_FOUND = 17700001;
const HALF_OF_NUMBER: number = 2;
const TABLET_SPLIT_LEFT_MAX_WIDTH: number = 480;
const TABLET_SPLIT_LEFT_PERCENT: number = 0.4;
const TABLET_SPLIT_RIGHT_PERCENT: number = 0.6;
const EXTRA_LARGE_FONT_SIZE_SCALE = 1.45;
const SIM_ID1: number = 0;
const SIM_ID2: number = 1;
const SWITCH_OFF: string = '0';
const SWITCH_ON: string = '1';
const PHONE_LOGO_RATE: number = 0.8;
const TIPS_APP_ID =
  'com.ohos.tips_BB4oLXt8JLOw5djd42S0oLOGzO6kOnT8hZfFRAAel2gbcQBG5jIsO4genni5cn2SQpKpKvkwOA7Ajsc7qf+MZgM=';
const TIPS_APP_IDENTIFIER = '1229502635594278976';
const MALICIOUS_WEB_SWITCH_ID = 'Setting.ElderCareCallFilter.malicious_web.malicious_web_switch';
const HANDLE_FONT_FAULT_CATEGORY: string = 'HANDLE_FONT_FAULT_CATEGORY';
const WALL_PAPER_SERVICE_TOKEN: string = 'ImmersiveConnectStub';
const ELDER_CARE_SCENARIO_TYPE: number = 4;
const REQUEST_CODE: number = 2;
const DISCONNECT_TIME_OUT: number = 3000;
type startAbleContext = common.UIAbilityContext | common.ServiceExtensionContext;

export class ElderCareUtils {
  public static ELDER_CARE_TIPS_FUN_NUM: string = 'SF-10044768_f103';
  public static MORE_TIPS_FUN_NUM: string = 'SF-00000000_f397';
  public static JUMP_TIPS_TYPE: string = '64';
  public static ELDER_CARE_HAS_ENABLED: string = 'elder_care_has_enabled';
  public static ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED: string = 'accessibility_elder_care_switch_enabled';
  public static ELDER_CARE_ZOOM_DISPLAY_LEVEL: string = 'elder_care_font_scale';
  public static DESKTOP_ICON_CHANGE_SIZE: string = 'desktopIconChangeSize';
  public static ELDER_CARE_PRE_SET_LEVEL: string = 'elder_care_font_scale_pre';
  public static DESKTOP_ICON_SIZE_ORIGINAL: string = 'desktop_icon_size_elder_care_original';
  public static DESKTOP_ICON_SIZE_SAVED: string = 'desktop_icon_size_saved';
  public static ELDER_CARE_START_PRE = 0;
  public static SWITCH_ON: string = '1';
  public static SWITCH_OFF: string = '0';
  public static DPI_LIST: number[] = [1, 2, 2, 2, 2, 2, 2]; // 显示大小各档位参数
  public static SCB_ICON_SIZE_LIST: number[] = [4, 4, 6, 8, 8, 8, 8]; // 桌面图标各档位参数
  public static FONT_SIZE_SCALE_LIST: number[] = [
    DisplayConstant.TEXT_FONT_SIZE_NORMAL,
    DisplayConstant.TEXT_FONT_SIZE_LARGE,
    DisplayConstant.TEXT_FONT_SIZE_EXTRA_LARGE,
    DisplayConstant.TEXT_FONT_SIZE_HUGE,
    DisplayConstant.TEXT_FONT_SIZE_HUGE2,
    DisplayConstant.TEXT_FONT_SIZE_HUGE3,
    DisplayConstant.TEXT_FONT_SIZE_HUGE4
  ]; // 字体大小各档位参数
  public static FONT_WEIGHT_SCALE_LIST: number[] = [1, 1, 1.1, 1.1, 1.25, 1.25, 1.25]; // 字体粗细各档位参数
  public static ELDER_CARE_PRE_HAS_CHANGED: string = 'elder_care_pre_has_changed';
  private static connectionId: number = -1;
  private static disconnectTimerId: number | undefined = undefined;

  /**
   * 当前关怀模式开关状态
   */
  static isElderCareOn(): boolean {
    return SettingsDataUtils.getSecureValue(ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED, '0') === '1';
  }

  /**
   * 开启关怀模式
   */
  static enableElderCare(): boolean {
    SettingsDataUtils.setSecureValue(ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED, '1');
    SettingsDataUtils.setSecureValue(ElderCareUtils.ELDER_CARE_HAS_ENABLED, 'true');
    ElderCareUtils.updateElderCareSearchItemStatus(true);
    let elderCareManager = new ElderCareManager(new OpenElderCare());
    elderCareManager.doSetting();
    return true;
  }

  /**
   * 关闭关怀模式
   */
  static disableElderCare(): boolean {
    SettingsDataUtils.setSecureValue(ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED, '0');
    ElderCareUtils.updateElderCareSearchItemStatus(false);
    let elderCareManager = new ElderCareManager(new CloseElderCare());
    elderCareManager.doSetting();
    return true;
  }

  static checkSupportElderCare(): boolean {
    return true;
  }

  /**
   * 跳转到玩机技巧指定页面
   *
   * @param startAbleContext 上下文,类型要求：common.UIAbilityContext | common.ServiceExtensionContext
   * @param funNum:页面FunNum
   * @param type 入口类型ID，用于打点
   * @param moduleName phone_widget:跳转手机，pc_widget：跳转PC
   */
  public static jumpTips(context: startAbleContext, funNum: string, type: string,
    moduleName: string = MODULE_NAME_PHONE): void {
    let uri: string = util.format(URI_FORMATTER, funNum, type);
    ElderCareUtils.jumpTipsByUri(context, uri, moduleName);
  }

  /**
   * 跳转到玩机技巧指定页面，使用uri方式
   *
   * @param startAbleContext 上下文,类型要求：common.UIAbilityContext | common.ServiceExtensionContext
   * @param uri uri格式：hwtips://com.ohos.tips.app?funNum=xxx&type=xxx
   * @param moduleName phone_widget:跳转手机，pc_widget：跳转PC
   */
  public static jumpTipsByUri(context: startAbleContext, uri: string, moduleName: string = MODULE_NAME_PHONE): void {
    if (moduleName !== MODULE_NAME_PHONE && moduleName !== MODULE_NAME_PC) {
      LogUtil.info(`${TAG} unknown moduleName, supported value: "${MODULE_NAME_PHONE}" or "${MODULE_NAME_PC}"`);
      return;
    }
    ElderCareUtils.isAppInstalled().then((isAppInstalled: boolean) => {
      if (isAppInstalled) {
        ElderCareUtils.jumpAppByUri(context, uri);
      } else {
        ElderCareUtils.jumpAppGallery(context);
      }
    }).catch(() => {
      LogUtil.error(`${TAG} jump isAppInstalled error`);
    })
  }

  /**
   * 跳转到鸿蒙应用的指定页面，使用uri方式
   */
  public static jumpAppByUri(context: startAbleContext, uri: string): void {
    if (context === undefined) {
      LogUtil.error(`${TAG} context is undefine `);
      return;
    }
    LogUtil.info(`${TAG} try jump to tips app`);
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri
    };
    context.startAbility(want, (err: BusinessError) => {
      if (err.code !== CODE_SUCCESS_ERROR) {
        LogUtil.error(`${TAG} jump to [tips app] failed, err.msg: ${err.message}, err.code: ${err.code}`);
      } else {
        LogUtil.error(`${TAG} jump to [tips app] success `);
      }
    });
  }

  /**
   * 跳转到应用市场页面，使用uri方式
   */
  static jumpAppGallery(context: startAbleContext) {
    if (!context) {
      LogUtil.error(`${TAG} context is undefine `);
      return;
    }
    LogUtil.info(`${TAG} try jump to atomic service `);
    const want: Want = {
      abilityName: 'MainAbility',
      bundleName: MODULE_NAME_APPGALLERY,
      uri: URI_APPGALLERY
    };
    context.startAbility(want).then(() => {
      LogUtil.info(`${TAG} jump appgallery success`);
    }).catch(() => {
      LogUtil.error(`${TAG} jump appgallery error`);
    })
  }

  private static isAppInstalled(): Promise<boolean> {
    return bundleManager.getBundleInfo(APP_BUNDLE_NAME,
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO).then((info) => {
      if (TIPS_APP_ID === info.signatureInfo.appId && TIPS_APP_IDENTIFIER === info.signatureInfo.appIdentifier) {
        LogUtil.info(`${TAG} tips app is installed`);
        return true;
      } else {
        LogUtil.warn(`${TAG} tips app is forged`);
        return false;
      }
    }).catch((err: BusinessError) => {
      if (err.code === CODE_BUNDLE_NAME_NOT_FOUND) {
        LogUtil.info(`${TAG} tips app is not installed`);
      } else {
        LogUtil.error(`${TAG} failed to check if tips app is installed, err.messag: ${err.message},
          err.code: ${err.message}`);
      }
      return false;
    })
  }

  static setSecureValue(name: string, value: string, context?: Context): boolean {
    return ElderCareUtils.setValueEx(settings.domainName.USER_SECURITY, name, value, context);
  }

  private static setValueEx(domainName: string, name: string, value: string, context?: Context): boolean {
    LogUtil.info(`setValueEx domainName: ${domainName}, name: ${name}, value: ${value}`);
    let result = false;
    try {
      result = settings.setValueSync(context, name, value, domainName);
    } catch (e) {
      LogUtil.error(`setValueEx domainName: ${domainName}, name: ${name} error: ${e}`);
      return result;
    }
    LogUtil.info(`setValueEx domainName: ${domainName}, name: ${name}, value: ${value}, result: ${result}`);
    return result;
  }

  static getSecureValue(name: string, defValue?: string, context?: Context): string {
    return ElderCareUtils.getValueEx(settings.domainName.USER_SECURITY, name, defValue, context);
  }

  private static getValueEx(domainName: string, name: string, defValue?: string, context?: Context): string {
    LogUtil.info(`getValueEx domainName: ${domainName}, name: ${name}, defValue: ${defValue}`);
    let value: string = '';
    try {
      value = settings.getValueSync(context, name, defValue ? defValue : '', domainName);
    } catch (err) {
      LogUtil.error(`getValueEx domainName: ${domainName}, name: ${name}, code: ${err.code} message: ${err.message}`);
      return value;
    }
    LogUtil.error(`getValueEx domainName: ${domainName}, name: ${name}, value: ${value}`);
    return value;
  }

  static getLogoSize(): number {
    let displayClass: Display.Display | null = null;
    try {
      displayClass = Display.getDefaultDisplaySync();
      if (ElderCareUtils.isLeftRightLayoutStatus()) {
        let fortyPercentWidth: number = px2vp(displayClass.width * TABLET_SPLIT_LEFT_PERCENT);
        if (fortyPercentWidth > TABLET_SPLIT_LEFT_MAX_WIDTH) {
          let maxValue: number =
            Math.max(px2vp(displayClass.width) - TABLET_SPLIT_LEFT_MAX_WIDTH, px2vp(displayClass.height));
          let minValue: number =
            Math.min(px2vp(displayClass.width) - TABLET_SPLIT_LEFT_MAX_WIDTH, px2vp(displayClass.height));
          return Math.min(maxValue / HALF_OF_NUMBER, minValue);
        } else {
          let maxValue: number = Math.max(displayClass.width * TABLET_SPLIT_RIGHT_PERCENT, displayClass.height);
          let minValue: number = Math.min(displayClass.width * TABLET_SPLIT_RIGHT_PERCENT, displayClass.height);
          return px2vp(Math.min(maxValue / HALF_OF_NUMBER, minValue)) * PHONE_LOGO_RATE;
        }
      } else {
        let maxValue: number = Math.max(displayClass.width, displayClass.height);
        let minValue: number = Math.min(displayClass.width, displayClass.height);
        return px2vp(Math.min(maxValue / HALF_OF_NUMBER, minValue)) * PHONE_LOGO_RATE;
      }
    } catch (err) {
      LogUtil.error(`${TAG} getImageHeight Failed to get the default display object.
        code: ${err.code} message: ${err.message}`);
    }
    return 0;
  }

  static isLayoutLeftRight(): boolean {
    return deviceInfo.deviceType === Constants.DEVICE_TYPE_TABLET;
  }

  static isLeftRightLayoutStatus(): boolean {
    return (Display.isFoldable() && Display.getFoldStatus() === Display.FoldStatus.FOLD_STATUS_EXPANDED ||
      Display.getFoldStatus() === Display.FoldStatus.FOLD_STATUS_HALF_FOLDED) ||
      deviceInfo.deviceType === Constants.DEVICE_TYPE_TABLET;
  }

  static getTelephonySwitchStatus(): boolean {
    return SettingsDataUtils.getSettingsData('settings.telephony.number_identity_switch', '0') === '1';
  }

  static getTouchSwitchStatus(): boolean {
    return SettingsDataUtils.getSettingsData('physic_navi_haptic_feedback_enabled', '1') == '1';
  }

  static async updateCallFilterSearchItemStatus(toggleState: boolean): Promise<void> {
    let isCurrentPrivateUser: boolean = await AccountUtil.isCurrentPrivate();
    let hasSim: boolean = await SearchCheckUtil.hasSim();
    let isSupportCallFilter: boolean = toggleState && hasSim && !isCurrentPrivateUser;
    LogUtil.info(`${TAG} updateCallFilterSearchItemStatus ${isSupportCallFilter}`);
    SearchDataController.getInstance()
      .updateSearchItemStatus('elder_care_spamshield_main_page_title', isSupportCallFilter);
    SearchDataController.getInstance()
      .updateSearchItemStatus('elder_care_sos_info', isSupportCallFilter);
  }

  /**
   *  开启或关闭关怀模式开关时，更新相关搜索项是否支持搜索状态
   */
  static updateElderCareSearchItemStatus(isAllowed: boolean): void {
    ElderCareUtils.updateCallFilterSearchItemStatus(isAllowed);
    SearchDataController.getInstance().updateChildItemSearchStatus('elder_care_display_size', isAllowed);
  }

  static getCurrentFontScaleStep(fontSize: number): number {
    let zoomDisplayLevel: number = 0;
    switch (fontSize) {
      case DisplayConstant.TEXT_FONT_SIZE_NORMAL:
        zoomDisplayLevel = ElderCareEnlargeDisplayConstant.ENLARGE_DISPLAY_DEFAULT_STEP;
        break;
      case DisplayConstant.TEXT_FONT_SIZE_LARGE:
        zoomDisplayLevel = ElderCareEnlargeDisplayConstant.ENLARGE_DISPLAY_LARGE_ONE_STEP;
        break;
      case DisplayConstant.TEXT_FONT_SIZE_EXTRA_LARGE:
        zoomDisplayLevel = ElderCareEnlargeDisplayConstant.ENLARGE_DISPLAY_LARGE_TWO_STEP;
        break;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE:
        zoomDisplayLevel = ElderCareEnlargeDisplayConstant.ENLARGE_DISPLAY_LARGE_THREE_STEP;
        break;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE2:
        zoomDisplayLevel = ElderCareEnlargeDisplayConstant.ENLARGE_DISPLAY_LARGE_FOUR_STEP;
        break;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE3:
        zoomDisplayLevel = ElderCareEnlargeDisplayConstant.ENLARGE_DISPLAY_LARGE_FIVE_STEP;
        break;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE4_LEGACY:
      case DisplayConstant.TEXT_FONT_SIZE_HUGE4:
        zoomDisplayLevel = ElderCareEnlargeDisplayConstant.ENLARGE_DISPLAY_LARGE_SIX_STEP;
        break;
      default:
        zoomDisplayLevel = ElderCareEnlargeDisplayConstant.ENLARGE_DISPLAY_DEFAULT_STEP;
        break;
    }
    return zoomDisplayLevel;
  }

  static syncElderCareDisplayLevelByFontSize(fontSize: number): void {
    let displayLevel = ElderCareUtils.getCurrentFontScaleStep(fontSize).toString();
    SettingsDataUtils.setSecureValue(ElderCareUtils.ELDER_CARE_ZOOM_DISPLAY_LEVEL, displayLevel);
    SettingsDataUtils.setSecureValue(ElderCareUtils.ELDER_CARE_PRE_SET_LEVEL, displayLevel);
    SettingsDataUtils.setSettingsData(ElderCareUtils.ELDER_CARE_PRE_HAS_CHANGED, 'false');
  }

  /**
   * 建立沉浸光感服务连接
   */
  public static connectAbility(context: common.UIAbilityContext | null): void {
    LogUtil.info(`${TAG} connectAbility`);
    if (context === null) {
      LogUtil.warn(`${TAG} context is null`);
      return;
    }
    const want: Want = {
      bundleName: 'com.ohos.sceneboard',
      abilityName: 'ImmersiveServiceExtAbility',
    };
    const option: common.ConnectOptions = {
      onConnect: (elementName, remote: rpc.IRemoteObject) => {
        if (remote === null) {
          LogUtil.info(`${TAG} onConnect remote is null`);
          return;
        }
        LogUtil.info(`${TAG} onConnect ${elementName}`);
        try {
          const option: rpc.MessageOption = new rpc.MessageOption();
          const data: rpc.MessageSequence = new rpc.MessageSequence();
          const reply: rpc.MessageSequence = new rpc.MessageSequence();
          data.writeInterfaceToken(WALL_PAPER_SERVICE_TOKEN);
          data.writeInt(ELDER_CARE_SCENARIO_TYPE);
          remote.sendMessageRequest(REQUEST_CODE, data, reply, option)
            .then(result => {
              LogUtil.info(`${TAG} Send message success ${result.errCode}`);
            })
            .catch((error: BusinessError) => {
              LogUtil.error(`${TAG} Send message error code:${error.code},message:${error.message}`);
            })
            .finally(() => {
              LogUtil.info(`${TAG} sendMessageRequest ends, reclaim parcel, disconnect service`);
              data.reclaim();
              reply.reclaim();
              if (ElderCareUtils.disconnectTimerId) {
                clearTimeout(ElderCareUtils.disconnectTimerId);
                ElderCareUtils.disconnectTimerId = undefined;
              }
              const currentConnectionId: number = ElderCareUtils.connectionId;
              if (context) {
                ElderCareUtils.disconnectTimerId = setTimeout(() => {
                  context.disconnectServiceExtensionAbility(currentConnectionId).then(() => {
                    LogUtil.info(`${TAG} disconnectServiceExtensionAbility success`);
                    clearTimeout(ElderCareUtils.disconnectTimerId);
                    ElderCareUtils.disconnectTimerId = undefined;
                  }).catch((error: BusinessError) => {
                    LogUtil.error(`${TAG} disconnectServiceExtensionAbility failed, errcode: ${error.code}`);
                  })
                }, DISCONNECT_TIME_OUT)
              }
            })
        } catch (error) {
          LogUtil.error(`${TAG} ConnectService error: ${error?.code} ${error?.message}`);
        }
      },
      onDisconnect: (elementName) => {
        LogUtil.info(`${TAG} onDisconnect ${elementName}`);
      },
      onFailed: (code) => {
        LogUtil.error(`${TAG} Connect onFailed ${code}`);
      }
    }
    ElderCareUtils.connectionId = context.connectServiceExtensionAbility(want, option);
  }
}

/**
 * 开启关闭关怀模式接口
 */
interface ElderCareConfig {
  setFontSizeAndWeight(): void;

  setIconSize(): void;

  handleConnectionChange(): void;
}

/**
 * 开启关怀模式
 *
 * 1.开启时，先保存当前字体大小、字体粗细、显示大小、图标大小elder_care_original
 * 2.读取上次关闭前存储的字体大小、字体粗细、显示大小、图标大小、桌面布局XXX_elder_care_saved
 * 3.并设置实际值
 */
export class OpenElderCare implements ElderCareConfig {
  private isFirstOpen?: boolean;

  constructor(isFirstOpen?: boolean) {
    this.isFirstOpen = isFirstOpen;
  }

  setFontSizeAndWeight() {
    // 读取开启前的字体大小并保存
    let originalFontSize = ElderCareManager.getFontScale();
    LogUtil.info(`${TAG} open elder care original font size is: ${originalFontSize}`);
    SettingsDataUtils.setSecureValue('elder_care_save_font_size', String(originalFontSize));
    // 读开启前的字体粗细并保存
    let originalFontWeight = ElderCareManager.getFontWeightScale();
    SettingsDataUtils.setSecureValue('elder_care_save_font_weight', String(originalFontWeight));
    LogUtil.info(`${TAG} is first time start eldercare ${this.isFirstOpen}`);
    // 判断是否首次开启关怀模式开关,首次开启会继承设置字体挡位
    if (this.isFirstOpen) {
      let enlargeDisplayStep: number = ElderCareUtils.getCurrentFontScaleStep(originalFontSize);
      LogUtil.info(`${TAG} inherit font size step : ${enlargeDisplayStep}`);
      SettingsDataUtils.setSecureValue(ElderCareUtils.ELDER_CARE_ZOOM_DISPLAY_LEVEL, `${enlargeDisplayStep}`);
      if (originalFontWeight !== ElderCareUtils.FONT_WEIGHT_SCALE_LIST[enlargeDisplayStep]) {
        ElderCareManager.setFontWeight(ElderCareUtils.FONT_WEIGHT_SCALE_LIST[enlargeDisplayStep]);
      }
      if (originalFontSize !== ElderCareUtils.FONT_SIZE_SCALE_LIST[enlargeDisplayStep]) {
        ElderCareManager.setFontSize(ElderCareUtils.FONT_SIZE_SCALE_LIST[enlargeDisplayStep]);
      }
    } else {
      let savedFontSize = Number(SettingsDataUtils.getSecureValue('font_size_elder_care_original', '1'));
      LogUtil.info(`${TAG} open elder care saved font size is: ${savedFontSize}`);
      let savedFontWeight = Number(SettingsDataUtils.getSecureValue('font_weight_elder_care_original', '1'));
      let displayLevel: number = Number(SettingsDataUtils.getSecureValue(ElderCareUtils.ELDER_CARE_ZOOM_DISPLAY_LEVEL,
        ElderCareUtils.SWITCH_OFF));
      let targetFontSize = ElderCareUtils.FONT_SIZE_SCALE_LIST[displayLevel];
      let targetFontWeight = ElderCareUtils.FONT_WEIGHT_SCALE_LIST[displayLevel];
      // 根据上次关闭前保存的值，设置实际值, 如果实际档位值与关闭前不一致，以实际档位为准
      ElderCareManager.setFontSize(targetFontSize === savedFontSize ? savedFontSize : targetFontSize);
      ElderCareManager.setFontWeight(targetFontWeight === savedFontWeight ? savedFontWeight : targetFontWeight);
    }
  }

  setIconSize() {
    // 首次开启关怀模式，比较开启前的图标大小和关怀模式档位对应的图标大小，以更大的图标为准；非首次开启，保留用户之前配置的图标大小；
    let originalIconSize: string = SettingsDataUtils.getSecureValue(ElderCareUtils.DESKTOP_ICON_CHANGE_SIZE, '0');
    SettingsDataUtils.setSecureValue(ElderCareUtils.DESKTOP_ICON_SIZE_ORIGINAL, originalIconSize);
    if (this.isFirstOpen) {
      let enlargeDisplayLevel: number =
        Number(SettingsDataUtils.getSecureValue(ElderCareUtils.ELDER_CARE_ZOOM_DISPLAY_LEVEL, '0'));
      if (Number.isNaN(enlargeDisplayLevel) || enlargeDisplayLevel > ElderCareUtils.SCB_ICON_SIZE_LIST.length - 1) {
        LogUtil.error(`${TAG} unexpected numbers in SCB_ICON_SIZE_LIST.`);
        enlargeDisplayLevel = 0;
      }
      let realSetIconSize: string = ElderCareUtils.SCB_ICON_SIZE_LIST[enlargeDisplayLevel] >= Number(originalIconSize) ?
        ElderCareUtils.SCB_ICON_SIZE_LIST[enlargeDisplayLevel].toString() : originalIconSize.toString();
      LogUtil.info(`${TAG} first time set icon size: ${realSetIconSize}`);
      SettingsDataUtils.setSecureValue(ElderCareUtils.DESKTOP_ICON_CHANGE_SIZE, realSetIconSize);
    } else {
      let savedIconSize: string = SettingsDataUtils.getSecureValue(ElderCareUtils.DESKTOP_ICON_SIZE_SAVED, '0');
      LogUtil.info(`${TAG} user saved icon size: ${savedIconSize}`);
      SettingsDataUtils.setSecureValue(ElderCareUtils.DESKTOP_ICON_CHANGE_SIZE, savedIconSize);
    }
  }

  handleConnectionChange(): void {
    ElderCareUtils.connectAbility(getContext() as common.UIAbilityContext);
  }
}

/**
 * 关闭关怀模式
 *
 * 1.保存当前字体大小、字体粗细、显示大小、图标大小、桌面布局，档位为elder_care_saved_XXX
 * 2.对比当前的字体大小、字体粗细、显示大小、图标大小，是否与当前档位里的参数相同，如果不同，则代表做过修改
 * 3.做过修改的，不做改变，未修改的，还原成elder_care_original_XXX
 */
export class CloseElderCare implements ElderCareConfig {
  setFontSizeAndWeight() {
    // 读取当前的字体大小，并保存
    let nowFontSize = ElderCareManager.getFontScale();
    LogUtil.info(`${TAG} close elder care saved font size is:${nowFontSize}`);
    SettingsDataUtils.setSecureValue('font_size_elder_care_original', String(nowFontSize));
    // 读取当前的字体粗细，并保存
    let nowFontWeight = ElderCareManager.getFontWeightScale();
    SettingsDataUtils.setSecureValue('font_weight_elder_care_original', String(nowFontWeight));
    // 读取当前放大显示的档位
    let zoomDisplayLevel =
      Number(SettingsDataUtils.getSecureValue(ElderCareUtils.ELDER_CARE_ZOOM_DISPLAY_LEVEL, '0'));
    // 如果当前数值和档位对应的数值不相等，代表用户做过修改，则不做还原；若相等，代表用户没有做过修改，则还原；
    let needChangeFontSize: boolean = Number(nowFontSize) === ElderCareUtils.FONT_SIZE_SCALE_LIST[zoomDisplayLevel];
    let needChangeFontWeight: boolean =
      Number(nowFontWeight) === ElderCareUtils.FONT_WEIGHT_SCALE_LIST[zoomDisplayLevel];
    let originalFontSize = Number(SettingsDataUtils.getSecureValue('elder_care_save_font_size', '1'));
    LogUtil.info(`${TAG} close elder care original font size is:${originalFontSize}`);
    let originalFontWeight = Number(SettingsDataUtils.getSecureValue('elder_care_save_font_weight', '1'));

    // 如果开启关怀模式期间档位未做过修改，关闭时则还原
    if (needChangeFontSize) {
      ElderCareManager.setFontSize(originalFontSize);
    }

    // 如果开启关怀模式期间档位做过修改并且字体大小小于或等于1.45倍，则关闭时不做还原
    if (!needChangeFontSize && nowFontSize <= EXTRA_LARGE_FONT_SIZE_SCALE) {
      ElderCareManager.setFontSize(Number(nowFontSize));
    }

    // 如果开启关怀模式期间档位做过修改并且字体大小大于1.45倍，则将字体调整到1.45倍
    if (!needChangeFontSize && nowFontSize > EXTRA_LARGE_FONT_SIZE_SCALE) {
      if (nowFontSize === DisplayConstant.TEXT_FONT_SIZE_HUGE4_LEGACY) {
        // 如果当前字体大小为历史最高档兼容值且不是当前关怀档位，则复原到开启前的字体大小
        ElderCareManager.setFontSize(originalFontSize);
      } else {
        ElderCareManager.setFontSize(EXTRA_LARGE_FONT_SIZE_SCALE);
      }
    }
    ElderCareManager.setFontWeight(needChangeFontWeight ? originalFontWeight : Number(nowFontWeight));
  }

  setIconSize() {
    // 关闭关怀模式时，保存当前的用户保留的图标大小，并把实际图标大小还原到开启前的值；
    let nowIconSize: string = SettingsDataUtils.getSecureValue(ElderCareUtils.DESKTOP_ICON_CHANGE_SIZE, '0');
    SettingsDataUtils.setSecureValue(ElderCareUtils.DESKTOP_ICON_SIZE_SAVED, nowIconSize);
    let originalIconSize: string = SettingsDataUtils.getSecureValue(ElderCareUtils.DESKTOP_ICON_SIZE_ORIGINAL, '0');
    SettingsDataUtils.setSecureValue(ElderCareUtils.DESKTOP_ICON_CHANGE_SIZE, originalIconSize);
  }

  handleConnectionChange(): void {
    ElderCareUtils.connectAbility(getContext() as common.UIAbilityContext);
  }
}

export class ElderCareManager {
  private elderCareConfig: ElderCareConfig;

  constructor(elderCareConfig: ElderCareConfig) {
    this.elderCareConfig = elderCareConfig;
  }

  public setSetting(elderCareConfig: ElderCareConfig) {
    this.elderCareConfig = elderCareConfig;
  }

  public doSetting() {
    this.elderCareConfig.setFontSizeAndWeight();
    this.elderCareConfig.setIconSize();
    this.elderCareConfig.handleConnectionChange();
  }

  static setFontSize(fontSize: number) {
    try {
      uiAppearance.setFontScale(fontSize);
      LogUtil.info(`${TAG} uiAppearance.setFontScale: ${fontSize}`);
      SettingsDataUtils.setSettingsDataDomain(settings.display.FONT_SCALE, fontSize.toString(),
        settings.domainName.USER_PROPERTY);
    } catch (paramError) {
      LogUtil.info(`${TAG} set fontSizeScale error.code: ${paramError?.code}, error.message: ${paramError?.message}`);
      ElderCareHandleSystemFontEventUtil.reportFailureEvent(HiSysElderCareEventGroup.SET_FONT_SCALE_FAILED,
        `Code:${paramError?.code ?? 0}`);
    }
  }

  static setFontWeight(fontWeight: number) {
    try {
      uiAppearance.setFontWeightScale(fontWeight);
      LogUtil.info(`${TAG} uiAppearance.setFontWeightScale: ${fontWeight}`);
      SettingsDataUtils.setSettingsDataDomain(DisplayConstant.SETTINGS_DATA_FONT_WEIGHT_SCALE, fontWeight.toString(),
        settings.domainName.USER_PROPERTY);
    } catch (paramError) {
      LogUtil.info(`${TAG} set fontWeightScale error.code: ${paramError?.code}, error.message: ${paramError?.message}`);
      ElderCareHandleSystemFontEventUtil.reportFailureEvent(HiSysElderCareEventGroup.SET_FONT_WEIGHT_FAILED,
        `Code:${paramError?.code ?? 0}`);
    }
  }

  static getFontScale(): number {
    try {
      return uiAppearance.getFontScale();
    } catch (paramError) {
      LogUtil.error(`${TAG} getFontScale fail ${paramError?.code} msg:${paramError?.message}`);
      ElderCareHandleSystemFontEventUtil.reportFailureEvent(HiSysElderCareEventGroup.GET_FONT_SCALE_FAILED,
        `Code:${paramError?.code ?? 0}`);
      return DisplayConstant.TEXT_FONT_SIZE_NORMAL;
    }
  }

  static getFontWeightScale(): number {
    try {
      return uiAppearance.getFontWeightScale();
    } catch (paramError) {
      LogUtil.error(`${TAG} getFontWeight fail ${paramError?.code} msg:${paramError?.message}`);
      ElderCareHandleSystemFontEventUtil.reportFailureEvent(HiSysElderCareEventGroup.GET_FONT_WEIGHT_FAILED,
        `Code:${paramError?.code ?? 0}`);
      return DisplayConstant.TEXT_FONT_WEIGHT_NORMAL;
    }
  }
}

export class SimpleDesktopUtils {
  static getSimpleDesktop(): string {
    const deskTopLayoutModeArr: string[] = ['Normal', 'Simple'];
    let value = SettingsDataUtils.getSettingsData('simple_ui_mode_switch', '0');
    return deskTopLayoutModeArr[Number(value)];
  }

  static setSimpleDesktop(value: string): void {
    SettingsDataUtils.setSettingsData('simple_ui_mode_switch', DeskTopLayoutMode[value]);
    SettingsDataUtils.setSettingsData('simple_ui_mode_switch_elder_care_saved', DeskTopLayoutMode[value]);
  }

  static getSimpleTitle(): string {
    let simpleModeValue = SettingsDataUtils.getSettingsData('simple_ui_mode_switch', '0');
    return ResourceUtil.getStringByName(SimpleDesktopLayoutTitle[simpleModeValue]);
  }

  /**
   * 判断当前设备是否支持简易布局
   */
  static isSupportedDevice(): boolean {
    let isSmallFold: boolean = DeviceUtil.isSmallFoldProduct();
    let isPhone: boolean = DeviceUtil.isDevicePhone() && !DeviceUtil.isFoldable();
    let systemInfo: string = SystemParamUtil.getParam('persist.sceneboard.desktop.simple_mode', 'true');
    if (isSmallFold || isPhone || systemInfo === 'true') {
      return true;
    }
    return false;
  }
}

export class ElderCareDisplay {
  static getDisplayLevel(): number {
    let displayLevel = Number(SettingsDataUtils.getSecureValue(ElderCareUtils.ELDER_CARE_ZOOM_DISPLAY_LEVEL, '0'));
    return displayLevel;
  }

  static getDisplayLevelTitle(): string {
    let displayLevel = Number(SettingsDataUtils.getSecureValue(ElderCareUtils.ELDER_CARE_ZOOM_DISPLAY_LEVEL, '0'));
    if (displayLevel === 0) {
      return ResourceUtil.getStringByName('display_mode_font_size_normal');
    }
    let displayLevelText: string = ResourceUtil.getStringByName('elder_care_display_level');
    if (!displayLevelText) {
      return '';
    } else {
      return displayLevelText.replace(new RegExp('%d', 'gm'), displayLevel + '');
    }
  }

  static setDisplayLevel(value: string): boolean | void {
    let oriFontSize: number = ElderCareManager.getFontScale();
    let oriFontWeight: number = ElderCareManager.getFontWeightScale();
    let oriScbIconSize: number = Number(ElderCareUtils.getSecureValue(ElderCareUtils.DESKTOP_ICON_CHANGE_SIZE, '0',
      getContext()));
    if (Number.isNaN(Number(value)) || Number(value) > ElderCareUtils.FONT_SIZE_SCALE_LIST.length - 1) {
      LogUtil.error(`${TAG} unexpected numbers in FONT_SIZE_SCALE_LIST.`);
      value = '0';
    }
    let targetFontSize = ElderCareUtils.FONT_SIZE_SCALE_LIST[Number(value)];
    let targetFontWeight = ElderCareUtils.FONT_WEIGHT_SCALE_LIST[Number(value)];
    let targetScbIconSize = ElderCareUtils.SCB_ICON_SIZE_LIST[Number(value)];
    if (targetFontSize === oriFontSize && targetFontWeight === oriFontWeight && oriScbIconSize === targetScbIconSize) {
      LogUtil.info(`${TAG} no need updateConfig`);
      return;
    }
    LogUtil.info(`${TAG} fontsize->${targetFontSize}, fontweight->${targetFontWeight}, iconsize->${targetScbIconSize}`)
    SettingsDataUtils.setSecureValue(ElderCareUtils.ELDER_CARE_PRE_SET_LEVEL, value);
    ElderCareManager.setFontSize(targetFontSize);
    ElderCareManager.setFontWeight(targetFontWeight);
    ElderCareUtils.setSecureValue(ElderCareUtils.DESKTOP_ICON_CHANGE_SIZE, targetScbIconSize.toString(),
      getContext());
    SettingsDataUtils.setSecureValue(ElderCareUtils.ELDER_CARE_ZOOM_DISPLAY_LEVEL, value);
  }
}

enum DeskTopLayoutMode {
  'Normal' = '0',
  'Simple' = '1'
}

enum SimpleDesktopLayoutTitle {
  'elder_care_desktop_layout_normal' = 0,
  'elder_care_desktop_layout_easy' = 1
};

export enum EnlargeDisplayLevel {
  'MAX' = 6,
  'MIN' = 0
}

/**
 * 关怀模式调节字体打点工具类
 *
 * @since 2025-07-17
 */
export class ElderCareHandleSystemFontEventUtil {
  /**
   * 上报错误打点
   *
   * @param faultType 错误类型
   * @param faultInfo 错误信息
   */
  public static reportFailureEvent(faultType: string, faultInfo: string): void {
    let params: CommonInterfaceCallFaultParams = {
      FAULT_CATEGORY: HANDLE_FONT_FAULT_CATEGORY,
      FAULT_SUBCATEGORY: faultType,
      FAULT_INFO: faultInfo,
    };
    HiSysEventUtil.reportFaultEvent(HiSysEventUtil.COMMON_INTERFACE_CALL_FAULT_EVENT_NAME, params,
      HiSysEventUtil.COMMON_INTERFACE_CALL_FAULT_EVENT_NAME);
  }
}
