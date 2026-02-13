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
import Log from '../common/utils/Log';
import { PinSubType } from '../common/utils/PasswordUtils';
import { PasswordTypeModel } from '../model/PasswordTypeModel';
import { common } from '@kit.AbilityKit';
import FontScaleUtils from '../common/utils/FontScaleUtils';

const TAG: string = 'SelectPsdTypeDialogComponent: ';
const LIST_INDEX_INIT: number = -1;

@CustomDialog
export struct SelectPsdTypeDialogComponent {
  @Consume('innerPathInfos') innerPathInfos: NavPathStack;
  @Link isNeedPop: boolean;
  @Link passwordType: number;
  @State listClickIndex: number = LIST_INDEX_INIT;
  controller?: CustomDialogController;
  title: Resource | undefined = undefined;
  confirmText: Resource | undefined = undefined;
  data: PasswordTypeModel[] = [];

  cancel: () => void = () => {
  }

  build() {
    Scroll() {
      Column() {
        Column() {
          this.builderTitle();
          this.builderData();
        }
        .margin({ left: $r('app.float.wh_16'), right: $r('app.float.wh_16')})

        Column() {
          this.builderButton();
        }.margin({ left: $r('app.float.wh_16'), right: $r('app.float.wh_16')})
      }
      .constraintSize({ minWidth: $r('app.float.wh_224') })
      .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
      .borderRadius({
        topLeft: $r('app.float.wh_16'),
        bottomLeft: $r('app.float.wh_16'),
        topRight: $r('app.float.wh_16'),
        bottomRight: $r('app.float.wh_16')
      })
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
  }

  @Builder
  builderTitle(): void {
    Row() {
      Text(this.title)
        .maxFontScale(2)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({
      top: 12,
      bottom: 2
    })
    .constraintSize({ minHeight: $r('app.float.wh_56') })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  builderData(): void {
    List({}) {
      ForEach(this.data, (item: PasswordTypeModel, index: number) => {
        ListItem() {
          Text(item.typeName)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .fontSize($r('app.float.font_16'))
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .onClick(() => {
              this.listClickIndex = index;
              this.updatePswTypePage(item);
            })
        }
        .constraintSize({ minHeight: $r('app.float.wh_48') })
        .padding({
          top: FontScaleUtils.getSaveDistance(getContext() as common.UIAbilityContext),
          bottom: FontScaleUtils.getSaveDistance(getContext() as common.UIAbilityContext),
          left: $r('app.float.wh_8'),
          right: $r('app.float.wh_8')
        })
        .borderRadius($r('sys.float.corner_radius_level6'))
        .backgroundColor(index === this.listClickIndex ? $r('sys.color.interactive_click') : Color.Transparent)
        .onTouch((event?: TouchEvent): void => {
          if (!event) {
            return;
          }
          if (event.type === TouchType.Down) {
            this.listClickIndex = index;
          }
          if (event.type === TouchType.Up) {
            this.listClickIndex = LIST_INDEX_INIT;
          }
        })
      })
    }
    .scrollBar(BarState.Off)
    .align(Alignment.TopStart)
    .id('HomePage_scrollable_list')
    .divider({
      strokeWidth: px2vp(1),
      color: $r('sys.color.comp_divider'),
      startMargin: $r('app.float.wh_8'),
      endMargin: $r('app.float.wh_8'),
    })
  }

  @Builder
  builderButton(): void {
    Row() {
      Button() {
        Text(this.confirmText)
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .maxFontScale(2)
      }
      .constraintSize({minHeight: 40})
      .width('100%')
      .backgroundColor('#00000000')
      .onClick(() => {
        this.cancel();
      })
      .hoverEffect(HoverEffect.None)
    }
    .width('100%')
    .constraintSize({ minHeight: $r('app.float.wh_40') })
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: $r('app.float.wh_8'), bottom: $r('app.float.wh_16') })
  }

  private updatePswTypePage(item: PasswordTypeModel): void {
    if (!item) {
      Log.error(TAG, `goto other type password error`);
      return;
    }
    Log.info(TAG, `goto other type ${item.authSubType}`);
    this.isNeedPop = false;

    if (item.authSubType === PinSubType.PIN_SIX) {
      this.cancel();

      this.innerPathInfos.pop();
      this.innerPathInfos.pushPath({ name: 'updatePrivatePwdPinType' }, { launchMode: LaunchMode.NEW_INSTANCE });
      return;
    }

    if (item.authSubType === PinSubType.PIN_NUMBER) {
      this.cancel();
      this.innerPathInfos.pop();
      this.innerPathInfos.pushPath({ name: 'updatePrivatePwdNumberType' }, { launchMode: LaunchMode.NEW_INSTANCE });
      return;
    }

    if (item.authSubType === PinSubType.PIN_MIXED) {
      this.cancel();
      this.innerPathInfos.pop();
      this.innerPathInfos.pushPath({ name: 'updatePrivatePwdMixType' }, { launchMode: LaunchMode.NEW_INSTANCE });
      return;
    }
  }
}
