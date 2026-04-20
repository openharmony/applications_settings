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

import { PADDING_0, PADDING_12, PADDING_8 } from '../../constant/StyleConstant';
import { LogUtil } from '../../utils/LogUtil';
import { PageConfig } from '../common/PageConfig';
import {
  DefaultSettingItemModel,
  DialogButton,
  DialogButtonStyle,
  DialogLayoutStyle,
  SettingDialogModel,
  SettingItemModel
} from '../model/SettingItemModel';
/* instrument ignore file */
const TAG: string = 'SettingDialog';

@Extend(Button) function customButtonStyle(style?: DialogButtonStyle) {
  .type(style?.type)
  .borderRadius(style?.borderRadius)
  .width(style?.width)
  .height(style?.height)
  .alignSelf(style?.alignSelf)
  .constraintSize(style?.constraintSize)
  .padding(style?.padding)
  .fontColor(style?.fontColor)
  .backgroundColor(style?.background)
  .buttonStyle(style?.buttonStyle)
  .role(style?.role)
  .controlSize(ControlSize.NORMAL)
}

@Component
struct SettingDialog {
  item: SettingItemModel = DefaultSettingItemModel.get();
  dialog?: SettingDialogModel;
  closeDialog?: () => void;
  private layout: DialogLayoutStyle = {};
  private isDialogClosedClick: boolean = false;

  private needDivider(primary: DialogButton, secondary: DialogButton): boolean {
    const primaryStyle = PageConfig.getInstance().getDialogButtonStyle(primary);
    const secondaryStyle = PageConfig.getInstance().getDialogButtonStyle(secondary);
    return (primaryStyle?.buttonStyle === ButtonStyleMode.TEXTUAL &&
      secondaryStyle?.buttonStyle === ButtonStyleMode.TEXTUAL)
  }

  private onButtonClick(button: DialogButton, item: SettingItemModel): void {
    if (this.isDialogClosedClick) {
      LogUtil.showWarn(TAG, 'close dialog clicked, not deal');
      return;
    }
    this.isDialogClosedClick = true;
    button.action(item);
    this.closeDialog?.();
  }

  @Builder twoVerticalButton(primary: DialogButton, secondary: DialogButton): void {
    Row({ space: this.needDivider(primary, secondary) ? 0 : this.layout.buttonSpaceVertical as number }) {
      Button() {
        Text(primary.value)
        .fontWeight(primary.style?.fontWeight)
      }
        .layoutWeight(1)
        .customButtonStyle(PageConfig.getInstance().getDialogButtonStyle(primary))
        .constraintSize({ minHeight: 40 })
        .padding(primary.style?.padding)
        .onClick(() => {
          this.onButtonClick(primary, this.item);
        })
        .defaultFocus(primary.focused ?? false)

      if (this.needDivider(primary, secondary)) {
        Divider()
          .vertical(true)
          .height(24)
          .strokeWidth(px2vp(2))
          .color($r('sys.color.ohos_id_color_list_separator'))
          .margin({ start: PADDING_8, end: PADDING_8 })
      }

      Button() {
        Text(secondary.value)
        .fontWeight(secondary.style?.fontWeight)
      }
        .layoutWeight(1)
        .customButtonStyle(PageConfig.getInstance().getDialogButtonStyle(secondary))
        .padding(secondary.style?.padding)
        .constraintSize({ minHeight: 40 })
        .onClick(() => {
          this.onButtonClick(secondary, this.item);
        })
        .defaultFocus(secondary.focused ?? false)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder horizontalButton(buttons: DialogButton[]): void {
    ForEach(buttons, (item: DialogButton) => {
      Button(){
        Text(item.value)
          .maxFontScale(2)
          .maxLines(1)
          .ellipsisMode(EllipsisMode.END)
      }
        .customButtonStyle(PageConfig.getInstance().getDialogButtonStyle(item))
        .width(item.style?.width ?? '100%')
        .constraintSize({ minHeight: 40 })
        .onClick(() => {
          this.onButtonClick(item, this.item);
        })
        .defaultFocus(item.focused ?? false)
    })
  }

  @Builder contentTextBuilder(message: ResourceStr): void {
    Text(message)
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Regular)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_primary'))
      .lineHeight(21)
      .width('100%')
      .wordBreak(WordBreak.BREAK_WORD)
      .textAlign(this.layout.contentStyle?.textAlign)
  }

  aboutToAppear(): void {
    if (this.dialog) {
      this.layout = PageConfig.getInstance().getDialogStyle(this.dialog);
    }
  }

  build() {
    Scroll() {
      Column() {
        Column() {
          // 标题区域
          if (this.dialog?.title) {
            Text(this.dialog.title)
              .width('100%')
              .constraintSize({ minHeight: this.layout.titleHeight })
              .fontSize($r('sys.float.Title_S'))
              .minFontSize(this.layout.titleStyle?.minFontSize)
              .maxFontScale(2)
              .maxLines(this.layout.titleStyle?.maxLines)
              .textOverflow({overflow: TextOverflow.Ellipsis})
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Bold)
              .padding({
                top: PADDING_12,
                bottom: PADDING_12,
              })
              .textAlign(this.layout.titleStyle?.textAlign)
          }
          // 内容区域
          if (this.dialog?.contentBuilder) {
            this.dialog?.contentBuilder?.builder(this.item);
          } else if (this.dialog?.message) {
            this.contentTextBuilder(this.dialog.message);
          }
        }
        // 如果有标题 上边距为0 没有就是24
        // 如果有按钮 下边距为0 没有就是24
        .padding({
          top: this.layout.padding?.top,
          start: this.layout.padding?.start,
          end: this.layout.padding?.end,
          bottom: (this.dialog?.buttons && this.dialog?.buttons?.length > 0) ? PADDING_0 : this.layout.padding?.bottom,
        })

        // 按钮区域
        if (this.dialog?.buttons && this.dialog?.buttons.length > 0) {
          Column({ space: this.layout.buttonSpaceHorizontal?.value }) {
            if (this.dialog?.buttonVertical && this.dialog.buttons.length === 2) {
              this.twoVerticalButton(this.dialog.buttons[0], this.dialog.buttons[1])
            } else {
              this.horizontalButton(this.dialog?.buttons)
            }
          }
          .width('100%')
          .padding({
            start: this.layout.buttonPad,
            end: this.layout.buttonPad,
            top: this.layout.contentButtonSpace,
            bottom: this.layout.buttonPad,
          })
        }
      }
    }
    .id('SettingDialog_Scroll')
    .scrollBar(BarState.Off)
  }
}

@Builder export function settingDialog(item: SettingItemModel, dialog: SettingDialogModel,
  closeDialog: () => void): void {
  SettingDialog({ item: item, dialog: dialog, closeDialog: closeDialog })
}