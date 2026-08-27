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
import Display from '@ohos.display';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { MultiCheckboxController, ShortKeyButtonController } from '../controller/SelectFunctionController';
import { ExtensionInfo, DIALOG_WIDTH_FOLD_EXPAND } from '../../constant/Constants';
import { getCurrentListPadding } from '../../utils/AccessibilityCommonModel';
import { AccessibilityImageSizeAdjust } from '../../utils/AccessibilityImageSizeAdjust';

const TAG: string = 'ShortKeyDialogComponent: ';

@Styles
function pressedStateStyles() {
  .backgroundColor($r('sys.color.interactive_click'))
}

@Styles
function normalStateStyles() {
  .backgroundColor(Color.Transparent)
}

@CustomDialog
export struct ShortKeyDialogComponent {
  public targetsInfo: ExtensionInfo[] = [];
  shortKeyButtonController?: ShortKeyButtonController;
  controller?: CustomDialogController;
  @State dialogWidth: number | string =
    AccessibilityImageSizeAdjust.checkIsDevicesExpanded() ? DIALOG_WIDTH_FOLD_EXPAND : '100%';
  @State paddingValue: ResourceStr | number =
    AccessibilityImageSizeAdjust.checkIsDevicesExpanded() ? 0 : $r('sys.float.padding_level8');

  build() {
    Column() {
      this.shortKeyDialogBuilder();
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({
      left: this.paddingValue,
      right: this.paddingValue,
    })
  }

  @Builder
  shortKeyDialogBuilder() {
    Column() {
      this.titleBuilder()
      Scroll() {
        this.contentBuilder()
      }
      .width('100%')
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      .constraintSize({
        maxHeight: '40%'
      })

      if (FontScaleUtils.isExtraLargeFontMode()) {
        this.buttonLargeBuilder()
      } else {
        this.buttonBuilder()
      }
    }
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .saturate(0.9)
    .alignItems(HorizontalAlign.Start)
    .borderRadius($r('sys.float.corner_radius_level16'))
    .width(this.dialogWidth)
  }

  @Builder
  contentBuilder() {
    Column() {
      ForEach(this.targetsInfo, (item: ExtensionInfo, index: number) => {
        MultiCheckboxComponent({
          compId: item.id,
          dialogController: this.controller,
          controller: new MultiCheckboxController(item.id, item.name, item.state)
        })

        if (index !== this.targetsInfo.length - 1) {
          this.itemDividerBuilder()
        }
      })
    }
    .width('100%')
    .padding({
      left: 12,
      right: 12
    })
  }

  @Builder
  titleBuilder() {
    Row() {
      Text($r('app.string.accessibility_shortKey'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontSize($r('sys.float.Title_S'))
        .maxFontScale(2)
        .wordBreak(WordBreak.HYPHENATION)
        .fontColor($r('sys.color.font_primary'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(2)
        .textAlign(TextAlign.Center)
        .constraintSize({
          minHeight: $r('app.float.length_27'),
        })
    }
    .accessibilityGroup(true)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .padding({
      top: 15,
      bottom: 15,
      left: 24,
      right: 24
    })
  }

  @Builder
  buttonBuilder() {
    Row() {
      Button($r('app.string.button_tittle_cancel'))
        .width('100%')
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_emphasize'))
        .constraintSize({ minHeight: '40vp' })
        .backgroundColor(Color.Transparent)
        .padding({
          top: FontScaleUtils.getButtonTopPadding(),
          bottom: FontScaleUtils.getButtonTopPadding()
        })
        .onClick(() => {
          LogUtil.info(`${TAG} onClick cancel`);
          this.shortKeyButtonController?.onCancelClick();
        })
    }
    .margin({
      top: $r('sys.float.padding_level4'),
    })
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      bottom: $r('sys.float.padding_level8'),
    })
  }

  @Builder
  buttonLargeBuilder() {
    Row() {
      Button({ type: ButtonType.Normal }) {
        Text($r('app.string.button_tittle_cancel'))
          .maxFontScale(2)
          .maxLines(10)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_emphasize'))
          .wordBreak(WordBreak.HYPHENATION)
      }
      .width('100%')
      .align(Alignment.Center)
      .backgroundColor(Color.Transparent)
      .borderRadius($r('sys.float.corner_radius_level10'))
      .margin({
        top: $r('app.float.margin_4'),
        bottom: $r('app.float.margin_4'),
      })
      .onClick(() => {
        LogUtil.info(`${TAG} onClick cancel`);
        this.shortKeyButtonController?.onCancelClick();
      })
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .margin({
      top: $r('sys.float.padding_level4'),
    })
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      bottom: $r('sys.float.padding_level8'),
    })
  }

  @Builder
  itemDividerBuilder(): void {
    Divider()
      .height(px2vp(2))
      .strokeWidth('1px')
      .color($r('sys.color.comp_divider'))
      .lineCap(LineCapStyle.Square)
      .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
  }

  private handleFoldStateChange(status: number): void {
    LogUtil.debug(`${TAG} on fold status changed: ${status}`);
    if (AccessibilityImageSizeAdjust.checkIsDevicesExpanded() || this.dialogWidth === '100%') {
      this.dialogWidth = DIALOG_WIDTH_FOLD_EXPAND;
      this.paddingValue = 0;
      return;
    }
    if (status === Display.FoldStatus.FOLD_STATUS_HALF_FOLDED) {
      return;
    }
    this.dialogWidth = '100%';
    this.paddingValue = $r('sys.float.padding_level8');
  }

  private callback: Callback<number> = () => {
    this.dialogWidth = AccessibilityImageSizeAdjust.checkIsDevicesExpanded() ? DIALOG_WIDTH_FOLD_EXPAND : '100%';
    this.paddingValue = AccessibilityImageSizeAdjust.checkIsDevicesExpanded() ? 0 : $r('sys.float.padding_level8');
  };

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.shortKeyButtonController = new ShortKeyButtonController(this.controller);
    if (DeviceUtil.isFoldable()) {
      try {
        Display.on('foldStatusChange', (status: number) => {
          this.handleFoldStateChange(status);
        });
      } catch (err) {
        LogUtil.error(`${TAG} register foldStatusChange: code: ${err?.code} message: ${err?.message}`);
      }
    }

    try {
      Display.on('change', this.callback);
    } catch (err) {
      LogUtil.error(`${TAG} failed to register display change, code: ${err?.code}, message: ${err?.message}`);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    if (DeviceUtil.isFoldable()) {
      try {
        Display.off('foldStatusChange');
      } catch (e) {
        LogUtil.error(`${TAG} unregister foldStatusChange: ${e?.message}`);
      }
    }

    try {
      Display.off('change', this.callback);
    } catch (e) {
      LogUtil.error(`${TAG} display unregister change error: ${e?.message}`);
    }
  }
}

@Component
struct MultiCheckboxComponent {
  compId: string = '';
  private dialogController?: CustomDialogController;
  @State controller?: MultiCheckboxController = undefined;

  private closeDialog(): void {
    this.dialogController?.close();
    (AppStorage.get<UIExtensionContentSession>('accessibilityDialogSession') as UIExtensionContentSession)?.terminateSelf();
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Column() {
          Text(this.controller?.targetName)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .wordBreak(WordBreak.HYPHENATION)
            .textOverflow({ overflow: TextOverflow.None })
            .maxLines(20)
        }
        .flexGrow(1)
        .alignItems(HorizontalAlign.Start)

        Checkbox({
          name: this.compId,
          group: 'checkboxGroup'
        })
          .select(this.controller?.isChecked ? true : false)
          .onChange((isChecked: boolean) => {
            if (this.controller) {
              this.controller.isChecked = isChecked;
            }
          })
          .height(DeviceUtil.isDevicePhone() ? $r('app.float.length_20') : $r('app.float.length_24'))
          .width(DeviceUtil.isDevicePhone() ? $r('app.float.length_20') : $r('app.float.length_24'))
          .margin({
            left: $r('sys.float.padding_level6')
          })
          .hitTestBehavior(HitTestMode.None)
          .id(`Checkbox_${this.compId}`)
          .onClick((event) => {
            this.controller?.onMenuChange(this.controller?.isChecked);
            this.closeDialog();
          });
      }
      .width('100%')
      .height('auto')
    }
    .padding({
      left: $r('sys.float.padding_level6'),
      right: $r('sys.float.padding_level6'),
      top: getCurrentListPadding(),
      bottom: getCurrentListPadding(),
    })
    .constraintSize({ minHeight: $r('app.float.wh_value_48') })
    .borderRadius($r('sys.float.corner_radius_level10'))
    .stateStyles({
      normal: normalStateStyles,
      pressed: pressedStateStyles,
    })
    .justifyContent(FlexAlign.Center)
    .onClick((event) => {
      this.controller?.onMenuChange(!this.controller.isChecked);
      this.closeDialog();
    })
  }

  aboutToAppear(): void {
  }
}