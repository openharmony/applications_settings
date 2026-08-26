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
import { dataShare } from '@kit.ArkData';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ItemResultType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingDialogState,
  SettingResultState,
  SettingStateType,
  SettingToggleState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PADDING_0, PADDING_16, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { ZoomGestureDialogContentComponent } from '../view/ZoomGestureDialogContentComponent';
import {
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  SCREEN_MAGNIFICATION,
  SCREEN_MAGNIFICATION_TRIGGER_METHOD,
  SCREEN_MAGNIFICATION_TRIGGER_SINGLE_FINGER_TRIPLE_TAP,
  ZOOM_GESTURE_DIALOG_OPEN
} from '../constant/Constants';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';

const TAG: string = 'ZoomGestureSwitchController : ';

@Builder
export function zoomGestureDialogContentBuilder(param: SettingItemModel) {
  ZoomGestureDialogContentComponent({ item: param });
}

/**
 * 放大手势页面控制器
 *
 * @since 2024-08-18
 */
export class ZoomGestureSwitchController implements ComponentControl {
  public zoomGestureState: boolean = false;
  protected dataHelper?: dataShare.DataShareHelper;
  private compId: string = '';
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }
    let isChecked: boolean = toggleState.state;
    LogUtil.info(`${TAG} toggleState: ${isChecked}`)
    this.handleCheckedChange(isChecked);
  };

  async getAccessibilityConfig(): Promise<void> {
    let isEnabled: boolean = SettingsDataUtils.getSecureValue(SCREEN_MAGNIFICATION,
      CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    this.zoomGestureState = isEnabled;
    LogUtil.info(`${TAG} get zoomGestureState success:${isEnabled}`);
  }

  /**
   * 数据库监听回调
   */
  public onDataChange = () => {
    this.zoomGestureState = SettingsDataUtils.getSecureValue(SCREEN_MAGNIFICATION,
      CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    HiSysEventUtil.reportDefaultBehaviorEventByUE(
      HiSysAccessibilityEventGroup.ZOOM_GESTURE_SWITCH, this.zoomGestureState ? 'on' : 'off');
    this.refreshUi(this.zoomGestureState);
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    if (isChecked) {
      let zoomGestureDialogOpen: boolean = SettingsDataUtils.getSecureValue(
        ZOOM_GESTURE_DIALOG_OPEN, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
      if (!zoomGestureDialogOpen) {
        SettingsDataUtils.setSecureValue(ZOOM_GESTURE_DIALOG_OPEN, CLICK_SWITCH_ON);
        this.alertZoomGestureDialog();
      } else {
        SettingsDataUtils.setSecureValue(SCREEN_MAGNIFICATION, CLICK_SWITCH_ON);
        // 设置页按单指三击引导，显式写入触发方式
        SettingsDataUtils.setSecureValue(SCREEN_MAGNIFICATION_TRIGGER_METHOD,
          SCREEN_MAGNIFICATION_TRIGGER_SINGLE_FINGER_TRIPLE_TAP);
        this.zoomGestureState = true;
        this.updateZoomGestureSearchItemStatus(true);
      }
    } else {
      SettingsDataUtils.setSecureValue(SCREEN_MAGNIFICATION, CLICK_SWITCH_OFF);
      this.zoomGestureState = false;
      this.updateZoomGestureSearchItemStatus(false);
    }
    return true;
  }

  /**
   * 监听开关的实时状态
   */
  protected registerDataChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.registerSecurityDataChange(this.dataHelper, SCREEN_MAGNIFICATION,
        this.onDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(SCREEN_MAGNIFICATION) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper | undefined) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerSecurityDataChange(this.dataHelper, SCREEN_MAGNIFICATION,
              this.onDataChange);
          }
        })
    }
    LogUtil.info(`{TAG} zoom gesture state listener registerd`);
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper as dataShare.DataShareHelper,
      SCREEN_MAGNIFICATION);
  }

  // 打开放大手势确认弹框
  private alertZoomGestureDialog(): void {
    notifyCompStateChange(`${this.compId}`, new Map(
      [[SettingStateType.STATE_TYPE_ITEM_DIALOG, {
        contentBuilder: wrapBuilder(zoomGestureDialogContentBuilder),
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
              LogUtil.info(`${TAG} zoom gesture dialog cancel`);
              this.zoomGestureState = false;
              this.updateZoomGestureSearchItemStatus(false);
              this.refreshUi(false);
              this.closeDialog();
            }
          },
          {
            value: $r(`app.string.dialog_enable`),
            style: {
              buttonStyle: ButtonStyleMode.TEXTUAL,
            },
            action: () => {
              LogUtil.info(`${TAG} zoom gesture dialog enable`);
              SettingsDataUtils.setSecureValue(SCREEN_MAGNIFICATION, CLICK_SWITCH_ON);
              // 设置页按单指三击引导，显式写入触发方式
              SettingsDataUtils.setSecureValue(SCREEN_MAGNIFICATION_TRIGGER_METHOD,
                SCREEN_MAGNIFICATION_TRIGGER_SINGLE_FINGER_TRIPLE_TAP);
              this.zoomGestureState = true;
              this.updateZoomGestureSearchItemStatus(true);
              this.refreshUi(true);
              this.closeDialog();
            }
          },
        ],
        buttonVertical: FontScaleUtils.isExtraLargeFontMode() ? false : true,
      } as SettingDialogState]]
    ));
  }

  // 关闭弹框
  private closeDialog(): void {
    notifyCompStateChange(`${this.compId}`, new Map(
      [[SettingStateType.STATE_TYPE_ITEM_DIALOG, {} as SettingBaseState]]
    ));
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    await this.getAccessibilityConfig();
    this.refreshUi(this.zoomGestureState);
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.registerDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.unRegisterDataChange()
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  /**
   *  开启或关闭放大手势开关时，更新放大区域是否支持搜索
   */
  private updateZoomGestureSearchItemStatus(isAllowed: boolean): void {
    LogUtil.info(`${TAG} updateZoomGestureSearchItemStatus： ${isAllowed}`);
    SearchDataController.getInstance().updateSearchItemStatus('zoom_zone_text', isAllowed);
  }

  private refreshUi(isEnabled: boolean): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: { state: isEnabled }
        } as SettingResultState]]));
  }
}
