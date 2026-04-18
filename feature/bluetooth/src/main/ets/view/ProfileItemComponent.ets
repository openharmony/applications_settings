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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  SettingBaseState,
  SettingResultState,
  SettingStateType,
  SettingToggleState} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  BluetoothStrategySwitchMenuController
} from '../controller/BondedDevice/BluetoothStrategySwitchMenuController';

@Component
export struct ProfileItemComponent{
  tag: string = 'ProfileItemComponent: ';
  item?: SettingItemModel;
  compId: string = '';
  controller?: BluetoothStrategySwitchMenuController;
  @State title: ResourceStr = '';
  @State desp: ResourceStr = '已连接';
  @State despFontColor: Resource = $r('sys.color.font_secondary');
  @State titleFontColor: Resource = $r('sys.color.font_primary');
  @State selectedColor: ResourceStr = $r('app.color.default_switch_color');
  @State isToggleEnable: boolean = true;
  @State isChecked: boolean = false;
  private despContentEventCallback = (summaryMsg: ResourceStr) => {
    LogUtil.info(`${this.tag} receive desp content change: ${summaryMsg}`);
    this.desp = summaryMsg;
  };
  private despFontColorEventCallback = (fontColor: Resource) => {
    LogUtil.info(`${this.tag} receive desp fontcolor change: ${fontColor}`);
    if (CheckEmptyUtils.isEmpty(fontColor)) {
      return;
    }
    this.despFontColor = fontColor;
  };
  private titleFontColorEventCallback = (fontColor: Resource) => {
    LogUtil.info(`${this.tag} receive title fontcolor change: ${fontColor}`);
    if (CheckEmptyUtils.isEmpty(fontColor)) {
      return;
    }
    this.titleFontColor = fontColor;
  };
  private switchEnableEventCallback = (isToggleEnable: boolean) => {
    LogUtil.info(`${this.tag} receive toggle enable change: ${isToggleEnable}`);
    this.isToggleEnable = isToggleEnable;
  };
  private switchSelectedColorEventCallback = (selectedColor: Resource) => {
    LogUtil.info(`${this.tag} receive toggle selectedColor change: ${selectedColor}`);
    this.selectedColor = selectedColor;
  };

  private eventCb = (data: object) => {
    if (!(data instanceof Map)) {
      LogUtil.error(`${this.tag} invalid eventbus data type.`);
    }
    this.procEvent(data as Map<SettingStateType, SettingBaseState>);
  };

  private procEvent(data: Map<SettingStateType, SettingBaseState>): void {
    data.forEach((value: SettingBaseState, key: SettingStateType) => {
      switch (key) {
        case SettingStateType.STATE_TYPE_ITEM_RESULT:
          this.isChecked = ((value as SettingResultState).result as SettingToggleState).state
          break;

        default:
          LogUtil.error(`${this.tag} invalid event data key: ${key}`);
          break;
      }
    })
  }

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Column() {
        Text(this.title)
          .fontColor(this.titleFontColor)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyHeiTi')
          .lineHeight(22)

        if (this.desp) {
          Text(this.desp)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_M'))
            .fontColor(this.despFontColor)
            .fontWeight(FontWeight.Regular)
            .lineHeight(19)
            .margin({
              top: $r('sys.float.padding_level1')
            })
        }
      }
      .padding({
        left: $r('sys.float.padding_level4'),
        right: $r('sys.float.padding_level4'),
      })
      .flexGrow(1)
      .alignItems(HorizontalAlign.Start)

      Toggle({ type: ToggleType.Switch, isOn: this.isChecked })
        .id(`entry_toggle`)
        .enabled(this.isToggleEnable ? true : false)
        .onChange((isOn: boolean) => {
          const log = `isOn:${isOn} oldState:${this.isChecked}`;
          LogUtil.info(`${this.tag} Toggle switch, ${log}, compId: ${this.compId}`);
          if (isOn === this.isChecked) {
            LogUtil.info(`${this.tag} Respond passively, no need emit event`);
          } else {
            EventBus.getInstance().emit(`${this.compId}.toggle`, isOn);
          }
        })
        .hoverEffect(HoverEffect.None)
        .responseRegion({ width: 48, height: 48 })
        .margin({
          right: $r('sys.float.padding_level4'),
        })
        .selectedColor(this.selectedColor)
        .flexShrink(0)
        .defaultFocus(true)
    }
    .constraintSize({
      minHeight: this.getMenuHeight(),
    })
  }

  private getMenuHeight(): number {
    if (DeviceUtil.isDevicePc()) {
      return this.desp ? 56 : 40;
    } else {
      return this.desp ? 64 : 48;
    }
  }

  aboutToAppear(): void {
    this.initParam();
    this.registerDataChange();
    LogUtil.info(`${this.tag} aboutToAppear, this.compId: ${this.compId}`);
  }

  private initParam(): void {
    this.controller = this.item?.compControl as BluetoothStrategySwitchMenuController;
    this.compId = this.controller?.compId ?? '';
    this.title = this.item?.title?.content as ResourceStr;
    this.isChecked = this.controller?.isChecked;
    this.desp = this.controller?.summary ?? '';
    this.despFontColor = this.controller?.summaryFontColor;
    this.titleFontColor = this.controller?.titleFontColor;
    this.isToggleEnable = this.controller?.isToggleEnable;
    this.selectedColor = this.controller?.selectedColor;
  }

  private registerDataChange(): void {
    //开关是否打开
    EventBus.getInstance().on(this.compId, this.eventCb);
    // 子标题内容
    EventBus.getInstance().on(`${this.compId}.desp`, this.despContentEventCallback);
    //子标题颜色
    EventBus.getInstance().on(`${this.compId}.desp.fontColor`, this.despFontColorEventCallback);
    //标题颜色
    EventBus.getInstance().on(`${this.compId}.title.fontColor`, this.titleFontColorEventCallback);
    //开关是否使能
    EventBus.getInstance().on(`${this.compId}.toggle.enable`, this.switchEnableEventCallback);

    EventBus.getInstance().on(`${this.compId}.toggle.selectedColor`, this.switchSelectedColorEventCallback);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    EventBus.getInstance().detach(`${this.compId}`, this.eventCb);
    EventBus.getInstance().detach(`${this.compId}.desp`, this.despContentEventCallback);
    EventBus.getInstance().detach(`${this.compId}.desp.fontColor`, this.despFontColorEventCallback);
    EventBus.getInstance().detach(`${this.compId}.title.fontColor`, this.titleFontColorEventCallback);
    EventBus.getInstance().detach(`${this.compId}.toggle.enable`, this.switchEnableEventCallback);
    EventBus.getInstance().detach(`${this.compId}.toggle.selectedColor`, this.switchSelectedColorEventCallback);
  }

  private getMargin(): number {
    if (DeviceUtil.isDevicePc()) {
      return this.desp ? 6 : 8;
    } else {
      return this.desp ? 10 : 13;
    }
  }
}