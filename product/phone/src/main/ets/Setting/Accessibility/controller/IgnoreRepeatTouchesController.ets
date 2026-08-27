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
import config from '@ohos.accessibility.config';
import accessibility from '@ohos.accessibility';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { DisplayUtils, SheetDialogStyle } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingDialogState,
  SettingModalState,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ItemResultType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AccessibilitySettingModel } from '@ohos/settings.accessibility/src/main/ets/model/AccessibilitySettingModel';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PADDING_0, PADDING_16, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import {
  ACCESSIBILITY_IGNORE_REPEAT_CLICK_ENABLED,
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  IGNORE_REPEATED_EXPERIMENT_MODEL_SHOW_EVENT,
  IGNORE_REPEATED_EXPERIMENT_MODEL_SHOW_FLAG,
  IGNORE_REPEATED_SHOW_DIALOG,
  IGNORE_REPEATED_TIME_SELECT_MODEL_SHOW_EVENT,
  IGNORE_REPEATED_CLOSE_REFRESH_EVENT,
  INGORE_REPEAT_CLICK_RECONFIRM,
  SCREEN_HEIGHT_RATE
} from '../constant/Constants';
import { a11yInitData } from '../sendable/A11yInitData';
import { IgnoreRepeatClickReConfirmDialogComponent } from '../view/IgnoreRepeatClickReConfirmDialogComponent';
import { IgnoreRepeatedStateModel } from '../utils/AccessibilityIgnoreRepeatedModel';

const TAG: string = 'IgnoreRepeatedTouchesController: ';
const BUNDLE_NAME: string = 'com.ohos.screenreader';

@Builder
export function ignoreRepeatClickOpenDialogBuilder(param: SettingItemModel) {
  IgnoreRepeatClickReConfirmDialogComponent({
    item: param,
    dialogType: 'open'
  });
}

@Builder
export function ignoreRepeatClickChangeDialogBuilder(param: SettingItemModel) {
  IgnoreRepeatClickReConfirmDialogComponent({
    item: param,
    dialogType: 'change',
    originalValue: IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValue,
    currentValue: IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache
  });
}

export class IgnoreRepeatedTouchesController implements ComponentControl {
  public ignoreRepeatClick: boolean = false;
  public itemEnable: boolean = true;
  public ignoreRepeatIntervalText: ResourceStr = $r('app.string.ignore_touch_close');
  public static diaLogEnable: boolean = false;
  private static switchState: boolean = true;
  private compId: string = '';
  private itemModel?: SettingItemModel;
  private showDialogEventCallback = (visible: boolean, changeType: string) => {
    if (visible === undefined || changeType === undefined) {
      LogUtil.error(`${TAG} showDialogEventCallback is invalid`);
      return;
    }
    LogUtil.info(`${TAG} showDialogEventCallback state : ${visible}`);
    this.handleCheckedChange(visible, changeType);
  };
  private ignoreExperimentModelShowCallback = (itemInfo: boolean | undefined) => {
    if (itemInfo === undefined) {
      LogUtil.error(`${TAG} itemInfo is undefined.`);
      return;
    }
    LogUtil.info(`${TAG} ignoreExperimentModelShowCallback: ${itemInfo}`);
    let compid: string = 'Setting.AccessibilityTouchscreenPage.ignore_repeated_experiment_group.ignoreExperimentModel';
    this.showModelBegin(compid, itemInfo);
  };
  private ignoreTimeSelectModelShowCallback = (itemInfo: boolean | undefined) => {
    if (itemInfo === undefined) {
      LogUtil.error(`${TAG} itemInfo is undefined.`);
      return;
    }
    LogUtil.info(`${TAG} ignoreTimeSelectModelShowCallback: ${itemInfo}`);
    let compid: string =
      'Setting.AccessibilityTouchscreenPage.ignore_repeated_touches_group.ignore_repeated_touches_switch';
    this.showModelBegin(compid, itemInfo);
  };
  private configObserver = (data: boolean): void => {
    if (IgnoreRepeatedTouchesController.switchState === data) {
      IgnoreRepeatedTouchesController.switchState = !data;
    }
    this.ignoreRepeatClick = data;
    a11yInitData.ignoreRepeatClick = data;
    this.setIgnoreRepeatClickEnableState(data);
    // 试用页面，第一次关闭忽略开关触发刷新
    if (!data && IgnoreRepeatedStateModel.getInstance().ignoreRepeatClickOriginal) {
      this.ignoreRepeatIntervalText = $r('app.string.ignore_touch_close');
      this.updateStatus();
      return;
    }
    IgnoreRepeatedStateModel.getInstance().ignoreRepeatClick = data;
    if (data) {
      this.ignoreRepeatIntervalText = IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValue;
    } else {
      this.ignoreRepeatIntervalText = $r('app.string.ignore_touch_close');
    }
    LogUtil.info(`${TAG} ignoreRepeatTouches state change:${data}`);
    this.updateStatus();
  };
  private configObserverInterval = (data: config.RepeatClickInterval): void => {
    LogUtil.info(`${TAG} configObserverInterval state change:${data}, ignoreRepeatClick: ${this.ignoreRepeatClick}`);
    // 如果data为undefined或者忽略重复点击关闭的时候，不用刷新忽略时延
    if (this.ignoreRepeatClick === false || data === undefined) {
      return;
    }
    this.ignoreRepeatIntervalText = IgnoreRepeatedStateModel.getSelectIgnoreRepeatClickIntervalName(data);
    IgnoreRepeatedStateModel.getInstance().ignoreRepeatClick = true;
    this.updateStatus();
  };
  private screenReaderObserver = (data: boolean): void => {
    LogUtil.info(`${TAG} screenReaderObserver state change: ${data}`);
    this.itemEnable = !data;
    this.updateEnabledState();
    let isTrialModelClosed: boolean = SettingsDataUtils.getSettingsData(
      IGNORE_REPEATED_EXPERIMENT_MODEL_SHOW_FLAG, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    if (isTrialModelClosed) {
      LogUtil.info(`${TAG} screenReaderObserver try to close TrialModel.`);
      this.ignoreExperimentModelShowCallback(false);
      this.ignoreTimeSelectModelShowCallback(false);
    }
    if (data) {
      IgnoreRepeatedStateModel.getInstance().closeRepeatClickState();
      this.notifyDialogClose();
      this.configObserver(false);
    }
  };

  protected showModelBegin(compid: string, visible: boolean): void {
    LogUtil.info(`${TAG} showModelBegin`);
    // 弹出半模态
    notifyCompStateChange(compid,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
        {
          state: visible,
          sheetHeight: DisplayUtils.getSheetStyle() === SheetDialogStyle.BOTTOM_DIALOG_STYLE ?
          SheetSize.LARGE : DisplayUtils.getScreenHeight() * SCREEN_HEIGHT_RATE,
          sheetDetents: [DisplayUtils.getSheetStyle() === SheetDialogStyle.BOTTOM_DIALOG_STYLE ?
          SheetSize.LARGE : DisplayUtils.getScreenHeight() * SCREEN_HEIGHT_RATE],
        } as SettingModalState]]
      ));
  }

  async getAccessibilityConfig(): Promise<void> {
    try {
      await config.ignoreRepeatClick.get().then((value: boolean) => {
        if (this.ignoreRepeatClick !== value) {
          LogUtil.info(`${TAG} initializationState refresh`);
          this.ignoreRepeatClick = value;
          a11yInitData.ignoreRepeatClick = value;
          IgnoreRepeatedStateModel.getInstance().ignoreRepeatClick = value;
        }
        this.clearRepeatClickIntervalCache();
      });
      if (this.ignoreRepeatClick !== false) {
        await config.repeatClickInterval.get().then((value) => {
          this.ignoreRepeatIntervalText = IgnoreRepeatedStateModel.getSelectIgnoreRepeatClickIntervalName(value);
        });
      } else {
        this.getRepeatClickInterval();
      }
      LogUtil.info(`${TAG} get ignoreRepeatIntervalText success:${this.ignoreRepeatIntervalText}`);
    } catch (err) {
      LogUtil.error(`${TAG} get ignoreRepeatIntervalText error: ${err?.message}`);
    }
  }

  async checkScreenReaderEnable(): Promise<void> {
    try {
      let enabledServiceList: accessibility.AccessibilityAbilityInfo[] =
        await accessibility.getAccessibilityExtensionList('all', 'enable');
      for (let enabledService of enabledServiceList) {
        if (enabledService.bundleName === BUNDLE_NAME) {
          this.itemEnable = false;
          this.updateEnabledState();
          LogUtil.info(`${TAG} checkScreenReaderEnable screenreader is open`);
          break;
        }
      }
    } catch (err) {
      LogUtil.error(`${TAG} checkScreenReaderEnable error: ${err?.message}`);
    }
  }

  /**
   * 忽略重复点击开关关闭时，清理缓存状态 （外部页面关闭忽略重复点击，缓存状态没有清理）
   */
  private clearRepeatClickIntervalCache(): void {
    LogUtil.info(`${TAG} clearRepeatClickIntervalCache.`);
    if (!this.ignoreRepeatClick && IgnoreRepeatedStateModel.getInstance().ignoreRepeatClick) {
      IgnoreRepeatedStateModel.getInstance().ignoreRepeatClick = false;
    }
    IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValue = '';
    IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache = '';
  }

  private getRepeatClickInterval(): void {
    config.repeatClickInterval.get().then((value) => {
      IgnoreRepeatedStateModel.getSelectIgnoreRepeatClickIntervalName(value);
    });
  }

  public static isIgnoreRepeatClickEnable(): boolean {
    let ignoreRepeatClickState: boolean = SettingsDataUtils.getSettingsData(
      ACCESSIBILITY_IGNORE_REPEAT_CLICK_ENABLED, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    LogUtil.info(`${TAG} isIgnoreRepeatClickEnable: ${ignoreRepeatClickState}`)
    return ignoreRepeatClickState;
  }

  /**
   * 返回开关的实时状态
   */
  public updateStatus(): void {
    IgnoreRepeatedTouchesController.switchState = this.ignoreRepeatClick;
    this.refreshUi();
    LogUtil.info(`${TAG} get Ignore Repeat Touches success： ${this.ignoreRepeatClick}`);
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean, changeType: string): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    if (IgnoreRepeatedTouchesController.switchState || isChecked) {
      IgnoreRepeatedTouchesController.switchState = true;
    }
    this.setIgnoreRepeatClickEnableState(isChecked);
    if (IgnoreRepeatedTouchesController.isIgnoreRepeatClickEnable() === true && isChecked) {
      this.alertIgnoreRepeat(changeType);
    }
    return true;
  }

  /**
   * 监听开关的实时状态
   */
  protected registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange`);
    try {
      config.ignoreRepeatClick.on(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe ignoreRepeatTouches, because ${err?.message}`);
    }

    try {
      config.repeatClickInterval.on(this.configObserverInterval);
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe repeatClickInterval, because ${err?.message}`);
    }
  }

  /**
   * 监听屏幕朗读的实时状态
   */
  protected registerScreenReaderChange(): void {
    try {
      accessibility.on('screenReaderStateChange', this.screenReaderObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe registerScreenReaderChange, because ${err?.message}`);
    }
  }

  private cancelStateChange(): void {
    LogUtil.info(`${TAG} cancelStateChange ignoreRepeatClickOriginal:${IgnoreRepeatedStateModel.getInstance().ignoreRepeatClickOriginal}`);
    if (IgnoreRepeatedStateModel.getInstance().ignoreRepeatClickOriginal) {
      AccessibilitySettingModel.accessibilityConfigSetting('ignoreRepeatTouches', true);
      IgnoreRepeatedStateModel.getInstance().ignoreRepeatClick = true;
      IgnoreRepeatedStateModel.getInstance().ignoreRepeatClickOriginal = false;
      IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache = '';
    }
  }

  private enableStateChange(): void {
    IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValue =
      IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache;
    IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache = ''
    IgnoreRepeatedStateModel.getInstance().ignoreRepeatClick = true;
    AccessibilitySettingModel.accessibilityConfigSetting('ignoreRepeatTouches', true);
    let repeatClickTime: config.RepeatClickInterval =
      IgnoreRepeatedStateModel.getSelectIgnoreRepeatClickIntervalKey();
    HiSysEventUtil.reportDefaultBehaviorEventByUE(
      HiSysAccessibilityEventGroup.IGNORE_REPEAT_TOUCHES_SWITCH, 'on');
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAccessibilityEventGroup.TIME_INTERVAL_CHANGE,
      repeatClickTime);
    AccessibilitySettingModel.accessibilityIgnoreRepeatClickTimeSet(repeatClickTime);
    IgnoreRepeatedTouchesController.diaLogEnable = true;
    this.ignoreRepeatIntervalText = IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValue;
    this.updateStatus();
  }

  public notifyDialogClose(): void {
    LogUtil.info(`${TAG} notifyDialogClose compId: ${this.compId}`);
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingDialogState>([
      [SettingStateType.STATE_TYPE_ITEM_DIALOG, {} as SettingDialogState]
    ]));
  }

  private alertIgnoreRepeat(changeType: string): void {
    SettingsDataUtils.setSecureValue(INGORE_REPEAT_CLICK_RECONFIRM, CLICK_SWITCH_ON);
    notifyCompStateChange(`${this.compId}`, new Map(
      [[SettingStateType.STATE_TYPE_ITEM_DIALOG, {
        contentBuilder: changeType === 'open' ? wrapBuilder(ignoreRepeatClickOpenDialogBuilder)
          : wrapBuilder(ignoreRepeatClickChangeDialogBuilder),
        style: {
          contentButtonSpace: PADDING_0,
          padding: { top: PADDING_16, start: PADDING_24, end: PADDING_24 }
        },
        buttons: [
          {
            value: $r('app.string.dialog_cancel'),
            style: {
              buttonStyle: ButtonStyleMode.TEXTUAL,
            },
            action: () => {
              this.cancelStateChange();
              this.closeDialog();
            }
          },
          {
            value: $r(`app.string.dialog_enable`),
            style: {
              buttonStyle: ButtonStyleMode.TEXTUAL,
            },
            action: () => {
              this.closeDialog();
              this.enableStateChange();
            }
          },
        ],
        buttonVertical: !FontScaleUtils.isExtraLargeFontMode(),
      } as SettingDialogState]]
    ));
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    try {
      config.ignoreRepeatClick.off(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe ignoreRepeatTouches, because ${err?.message}`);
    }

    try {
      config.repeatClickInterval.off(this.configObserverInterval);
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe repeatClickInterval, because ${err?.message}`);
    }
  }

  /**
   * 取消监听屏幕朗读的实时状态
   */
  protected unRegisterScreenReaderChange(): void {
    LogUtil.info(`${TAG} unRegisterScreenReaderChange`);
    try {
      accessibility.off('screenReaderStateChange', this.screenReaderObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed unRegisterScreenReaderChange, because ${err?.message}`);
    }
  }

  private setIgnoreRepeatClickEnableState(data: boolean): void {
    SettingsDataUtils.setSettingsData(ACCESSIBILITY_IGNORE_REPEAT_CLICK_ENABLED,
      data ? CLICK_SWITCH_ON : CLICK_SWITCH_OFF);
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init, state:${a11yInitData.ignoreRepeatClick}`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    this.itemModel = compParam.component as SettingItemModel;
    EventBus.getInstance().on(IGNORE_REPEATED_CLOSE_REFRESH_EVENT, this.configObserver);
    await this.getAccessibilityConfig();
    await this.checkScreenReaderEnable();
    this.updateStatus();
    EventBus.getInstance().on(IGNORE_REPEATED_SHOW_DIALOG, this.showDialogEventCallback);
    EventBus.getInstance().on(IGNORE_REPEATED_EXPERIMENT_MODEL_SHOW_EVENT, this.ignoreExperimentModelShowCallback);
    EventBus.getInstance().on(IGNORE_REPEATED_TIME_SELECT_MODEL_SHOW_EVENT, this.ignoreTimeSelectModelShowCallback);
    this.registerDataChange();
    this.registerScreenReaderChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    EventBus.getInstance().detach(IGNORE_REPEATED_SHOW_DIALOG, this.showDialogEventCallback);
    EventBus.getInstance().detach(IGNORE_REPEATED_EXPERIMENT_MODEL_SHOW_EVENT, this.ignoreExperimentModelShowCallback);
    EventBus.getInstance().detach(IGNORE_REPEATED_TIME_SELECT_MODEL_SHOW_EVENT, this.ignoreTimeSelectModelShowCallback);
    EventBus.getInstance().detach(IGNORE_REPEATED_CLOSE_REFRESH_EVENT, this.configObserver);
    this.unRegisterDataChange();
    this.unRegisterScreenReaderChange();
    this.cancelStateChange();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private formatIgnoreString(): ResourceStr {
    if (typeof this.ignoreRepeatIntervalText !== 'string') {
      return this.ignoreRepeatIntervalText;
    }
    return ResourceUtil.getAnyStrFormatStringSync($r('app.string.ignore_repeated_time_shortest'),
      String(ResourceUtil.getLocalNumberFormat(IgnoreRepeatedStateModel.getInstance().ConvertIntervalValue(
        this.ignoreRepeatIntervalText))));
  }

  private refreshUi(): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: this.formatIgnoreString() }
        } as SettingResultState]]));
  }

  private closeDialog(): void {
    notifyCompStateChange(`${this.compId}`, new Map(
      [[SettingStateType.STATE_TYPE_ITEM_DIALOG, {} as SettingBaseState]]
    ));
  }

  private updateEnabledState(): void {
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_ENABLED, { state: this.itemEnable } as SettingCompState]]));
  }
}

