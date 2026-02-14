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

import prompt from '@ohos.prompt';
import { i18n } from '@kit.LocalizationKit';
import emitter from '@ohos.events.emitter';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { EVENT_ID_ON_PAGE_TOUCHED } from '@ohos/settings.common/src/main/ets/event/types';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PADDING_4, PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';
/* instrument ignore file */
const TAG: string = 'InlineTextInputComponent:';
const DEFAULT_MAX_LENGTH: number = 64;
const OPACITY_PERCENT_FULL: number = 1;
const OPACITY_PERCENT_FORTY: number = 0.4;

@Component
export struct InlineTextInputComponent {
  title: ResourceStr = '';
  tabInd: number = TabIndexConstants.TAB_INDEX_DEFAULT;
  maxByteLength: number = DEFAULT_MAX_LENGTH;
  @Prop value: string = '';
  onUpdate?: Function;
  @Prop disable: boolean = false;
  @State isEditing: boolean = false;
  // 删除图标
  @State isPressed: boolean = false;
  @State isHover: boolean = false;
  private inputController: TextInputController = new TextInputController();
  private titleFocusKey: string = 'titleFocusKey';
  private inputFocusKey: string = this.titleFocusKey + 'inputFocusKey';
  private isRTL: boolean = i18n.isRTL(i18n.System.getSystemLanguage());
  private onPageTouchCallBack = (data: emitter.EventData) => {
    if (this.isEditing) {
      this.onCloseTextInput();
    }
  };

  build() {
    Row() {
      // 标题
      Text(this.title)
        .fontFamily('HarmonyHeiTi')
        .key(this.titleFocusKey)
        .focusable(true)
        .fontColor(this.disable ? $r('sys.color.gray_04') : $r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .lineHeight(22)
        .fontWeight(FontWeight.Medium)
      // 显示控件
      Text(this.value)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_S'))
        .fontColor(this.disable ? $r('sys.color.gray_04') : $r('sys.color.font_primary'))
        .lineHeight(19)
        .layoutWeight(1)
        .textAlign(this.isRTL ? TextAlign.Start : TextAlign.End)
        .direction(Direction.Ltr)
        .padding({
          left: this.isRTL ? 0 : 16,
          right: this.isRTL ? 16 : 0,
        })
        .margin({
          left: this.isRTL ? 0 : 8,
          right: this.isRTL ? 8 : 0,
        })
        .constraintSize({
          minHeight: 32,
        })
        .onClick(() => {
          this.onEnableTextInput();
        })
        .visibility(this.isEditing ? Visibility.None : Visibility.Visible);
      // 输入控件
      TextInput({ text: this.value, controller: this.inputController })
        .key(this.inputFocusKey)
        .maxLength(this.maxByteLength)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_primary'))
        .textAlign(this.isRTL ? TextAlign.Start : TextAlign.End)
        .direction(Direction.Ltr)
        .borderRadius(0)
        .backgroundColor(Color.Transparent)
        .padding({
          left: this.isRTL ? 8 : 16,
          right: this.isRTL ? 16 : 8,
        })
        .layoutWeight(1)
        .enabled(!this.disable)
        .caretColor(this.value.length === 0 ? '#FA2A2D' : '#0A59F7')
        .onWillInsert((info: InsertValue) => {
          return this.onWillInsert(info?.insertValue);
        })
        .onChange((input) => {
          LogUtil.info(`${TAG} TextInput onChange. input:${input}`);
          this.value = input;
        })
        .onFocus(() => {
          this.inputController.setTextSelection(0, this.value.length);
        })
        .onSubmit((enterKey: EnterKeyType) => {
          LogUtil.info(`${TAG} TextInput onSubmit. enterKey:${enterKey}`);
          this.onCloseTextInput();
        })
        .visibility(this.isEditing ? Visibility.Visible : Visibility.None);
      // 清空按钮
      Row() {
        Image($r('app.media.ic_public_cancel_bt'))
          .fillColor($r('sys.color.icon_primary'))
          .width(24)
          .height(24)
          .padding(0)
          .draggable(false)
          .opacity(this.value.length === 0 ? OPACITY_PERCENT_FORTY : OPACITY_PERCENT_FULL);
      }
      .size({
        height: 32,
        width: 32,
      })
      .borderRadius($r('sys.float.corner_radius_level4'))
      .backgroundColor(this.getBackgroundColor())
      .enabled(!this.disable)
      .justifyContent(FlexAlign.Center)
      .visibility(this.isEditing ? Visibility.Visible : Visibility.None)
      .onHover((isHover?: boolean, event?: HoverEvent) => {
        this.isHover = isHover as boolean;
      })
      .onTouch((event?: TouchEvent) => {
        if (!event) {
          return;
        }
        if (event.type === TouchType.Down) {
          this.isPressed = true;
        } else if (event.type === TouchType.Up) {
          this.isPressed = false;
        }
      })
      .onClick((event?: ClickEvent) => {
        if (this.value.length === 0) {
          return;
        }
        LogUtil.info(`${TAG} onClick clear`);
        this.value = '';
      })
    }
    .onTouch((event: TouchEvent) => {
      (event.stopPropagation as () => void)();
    })
    .padding({
      start: PADDING_8,
      end: this.isEditing ? PADDING_4 : PADDING_8,
    })
    .constraintSize({
      minHeight: 40,
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    emitter.on({
      eventId: EVENT_ID_ON_PAGE_TOUCHED,
      priority: emitter.EventPriority.IMMEDIATE
    }, this.onPageTouchCallBack);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    emitter.off(EVENT_ID_ON_PAGE_TOUCHED, this.onPageTouchCallBack);
  }

  /*
   * 输入前校验长度
   */
  private onWillInsert(info: string): boolean {
    let inputValueLength: number = StringUtil.getStringLength(this.value.toString());
    let valueLength: number = StringUtil.getStringLength(info);
    let length: number = inputValueLength + valueLength;
    LogUtil.info(`${TAG} willInputChange value is: ${valueLength}, textvalue length: ${inputValueLength}`);
    if (length > this.maxByteLength) {
      LogUtil.info(`${TAG} onWillInsert failed. exceeded maxByteLength`);
      try {
        prompt.showToast({
          message: ResourceUtil.getStringSync($r('app.string.input_max_length_message')),
          duration: 2000,
        });
      } catch (error) {
        LogUtil.error(`${TAG} showToast catch error. code:${error?.message} message:${error?.message}`);
      }
      return false;
    }
    return true;
  }

  /*
   * 开启输入控件
   */
  private onEnableTextInput(): void {
    LogUtil.info(`${TAG} onEnableTextInput`)
    this.isEditing = true;
    focusControl.requestFocus(this.inputFocusKey);
    this.inputController.caretPosition(this.value.length);
  }

  /*
   * 关闭输入控件
   */
  private onCloseTextInput(): void {
    LogUtil.info(`${TAG} onCloseTextInput`);
    if (this.value.length === 0) {
      // 没有值的时候不能关闭 继续保持控件获焦态
      let timerId: number = setTimeout(() => {
        focusControl.requestFocus(this.inputFocusKey);
        clearTimeout(timerId);
      });
    } else {
      LogUtil.info(`${TAG} onUpdate`);
      this.isEditing = false;
      focusControl.requestFocus(this.titleFocusKey);
      this.onUpdate?.(this.value);
    }
  }

  private getBackgroundColor(): ResourceColor {
    if (this.value.length === 0) {
      return Color.Transparent;
    } else {
      if (this.isPressed) {
        return $r('sys.color.interactive_click');
      }
      if (this.isHover) {
        return $r('sys.color.interactive_hover');
      }
      return Color.Transparent;
    }
  }
}