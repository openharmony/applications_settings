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

import promptAction from '@ohos.promptAction';
import emitter from '@ohos.events.emitter';
import { Controller, UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { HotSpotBlackListUtils } from '@ohos/settings.common/src/main/ets/utils/HotSpotBlackListUtils';
import { EVENT_ID_BLOCK_LIST_CHANGE } from '@ohos/settings.common/src/main/ets/event/types';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { PADDING_15 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysHotspotEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { CommonDialog } from '../../dialog/CommonDialog';
import { DialogButtonType } from '../../dialog/types';
/* instrument ignore file */
const OPACITY_PERCENT_FULL: number = 1;

const ALPHA_DISABLED: Resource = $r('sys.float.ohos_id_alpha_disabled');

export class BlockListInfo {
  public isRemoveBlockList: boolean = false;
  public ipInfo: string = '';
  public macInfo: string = '';
}

const TAG: string = 'ConnectedHotSportComponent: ';

// 黑名单设备数限制8
const BLOCK_LIST_MAX_COUNT: number = 8;

@Component
export struct ConnectedHotSportComponent {
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: Style = undefined;
  @State controller?: Controller = undefined;
  @State message: string = '';
  private info: BlockListInfo = new BlockListInfo();
  private isExtraLargeFontMode() {
    return FontScaleUtils.isExtraLargeFontMode();
  }

  @Builder
  buildLargeText() : void {
    Column() {
        Row() {
          SymbolGlyph(this.menu?.icon as Resource)
            .fontSize(24)
            .fontColor([$r('sys.color.icon_secondary')])
          Text(this.menu?.title)
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontSize('16fp')
            .width('75%')
            .textAlign(TextAlign.Start)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .constraintSize({
              minHeight: '21vp',
            })
            .padding({
              left: '12vp',
            })
            .direction(LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl)
        }
        Text(this.info.ipInfo)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize('14fp')
          .width('100%')
          .textAlign(TextAlign.Start)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .constraintSize({
            minHeight: '19vp',
          })
          .margin({
            top: '2vp',
          })
          .direction(LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl)
        Text(this.info.macInfo)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize('14fp')
          .width('100%')
          .textAlign(TextAlign.Start)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .constraintSize({
            minHeight: '19vp',
          })
          .margin({
            top: '2vp',
          })
          .direction(LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl)
      }
      .enabled(this.menu?.enable as boolean)
      .opacity((this.menu?.enable) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
  }

  @Builder
  buildLargeStyle() : void {
    Column() {
      this.buildLargeText()
      Button() {
        Text(this.info.isRemoveBlockList ? $r('app.string.remove_from_blocklist') :
        $r('app.string.add_to_blocklist'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .constraintSize({
            minHeight: '16vp',
          })
          .fontSize('12fp')
          .fontColor($r('sys.color.font_emphasize'))
          .margin({
            top: $r('sys.float.padding_level5'),
            bottom: $r('sys.float.padding_level5'),
            left: $r('sys.float.padding_level8'),
            right: $r('sys.float.padding_level8'),
          })
          .maxLines(2)
          .ellipsisMode(EllipsisMode.END)
          .textOverflow({overflow: TextOverflow.Ellipsis})
      }
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .width('100%')
      .height('auto')
      .enabled(this.menu?.enable as boolean)
      .opacity((this.menu?.enable) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
      .onClick(() => {
        this.showConfirmDialog();
      })
    }
    .borderRadius($r('sys.float.corner_radius_level10'))
    .padding({
      left: '12vp',
      right: '12vp',
      bottom: '4vp',
    })
  }

  @Builder
  buildContent(): void {
    Column() {
      Text(this.menu?.title)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize('16fp')
        .width('100%')
        .textAlign(TextAlign.Start)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .constraintSize({
          minHeight: '21vp',
        })
        .direction(LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl)

      Text(this.info.ipInfo)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize('14fp')
        .width('100%')
        .textAlign(TextAlign.Start)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .constraintSize({
          minHeight: '19vp',
        })
        .margin({
          top: '2vp',
        })
        .direction(LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl)

      Text(this.info.macInfo)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize('14fp')
        .width('100%')
        .textAlign(TextAlign.Start)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .constraintSize({
          minHeight: '19vp',
        })
        .margin({
          top: '2vp',
        })
        .direction(LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl)
    }
    .padding({
      start: PADDING_15,
    })
    .accessibilityGroup(true)
    .flexShrink(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .height('auto')
    .enabled(this.menu?.enable as boolean)
    .opacity((this.menu?.enable) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
  }

  build() {
    if (this.isExtraLargeFontMode()) {
      this.buildLargeStyle()
    } else {
      Row() {
        SymbolGlyph(this.menu?.icon as Resource)
          .fontSize(24)
          .fontColor([$r('sys.color.icon_secondary')])
        this.buildContent()
        Button() {
          Text(this.info.isRemoveBlockList ? $r('app.string.remove_from_blocklist') :
          $r('app.string.add_to_blocklist'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .constraintSize({
              minHeight: '16vp',
            })
            .fontSize('10vp')
            .fontColor($r('sys.color.font_emphasize'))
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .width('95vp')
        .height('28vp')
        .enabled(this.menu?.enable as boolean)
        .opacity((this.menu?.enable) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
        .onClick(() => {
          this.showConfirmDialog();
        })
      }
      .width('100%')
      .constraintSize({
        minHeight: '96vp',
      })
      .borderRadius($r('sys.float.corner_radius_level10'))
      .padding({
        left: '12vp',
        right: '12vp',
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
  }

  @Builder
  buildConfirmDialogContent() {
    Column() {
      Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        Text(this.message)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(21)
      }
    }.padding({
      right: $r('app.float.margin_8'),
      left: $r('app.float.margin_8')
    })
  }

  aboutToAppear(): void {
    if (!this.menu) {
      LogUtil.error(`${TAG} aboutToAppear: menu is empty.`);
      return;
    }
    this.style = this.menu.style;
    this.controller = this.menu.getControllerInstance(this.uiRefresher);
    if (this.menu?.extra) {
      this.info = this.menu.extra as BlockListInfo;
    }
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }

  showConfirmDialog(): void {
    let res: Resource = this.info.isRemoveBlockList ? $r('app.string.remove_from_blocklist_disconnect') :
    $r('app.string.add_to_blocklist_disconnect');
    this.message = ResourceUtil.getFormatStringSync(res, this.menu?.title as string);
    let confirmDialogController = new CustomDialogController({
      builder: CommonDialog({
        title: ResourceUtil.getStringSync(this.info.isRemoveBlockList ? $r('app.string.remove_from_blocklist') :
        $r('app.string.add_to_blocklist')),
        actionType: DialogButtonType.TWO_BUTTON_HORIZONTAL,
        cancelText: $r('app.string.cancel'),
        cancelCallback: () => {
          confirmDialogController.close();
        },
        confirmText: $r('app.string.ok'),
        confirmCallback: () => {
          this.addOrDelBlockList();
          confirmDialogController.close();
        },
        content: () => {
          this.buildConfirmDialogContent();
        },
        isSupportScroll: true
      }),
    });
    confirmDialogController.open();
  }

  private addOrDelBlockList(): void {
    if (!this.menu?.state) {
      LogUtil.error(`${TAG}, addOrDelBlockList failed. state is undefined.`)
      return;
    }
    // 黑名单数限制8个
    if (!this.info.isRemoveBlockList && HotSpotBlackListUtils.getBlockList().length >= BLOCK_LIST_MAX_COUNT) {
      ResourceUtil.getNumberFormatString($r('app.string.hotspot_blocklist_limit'),
        `${BLOCK_LIST_MAX_COUNT}`).then((tips: string) => {
        try {
          promptAction.showToast({ message: tips });
        } catch (e) {
          LogUtil.error(`${TAG} showToast args error`);
        }
      });
      return;
    }
    let station = HotSpotBlackListUtils.getStationByMac(this.info.isRemoveBlockList, this.menu.state.toString());
    if (!station) {
      LogUtil.error(`${TAG}, addOrDelBlockList failed. station not found.`)
      return;
    }
    if (this.info.isRemoveBlockList) {
      HotSpotBlackListUtils.deleteFromBlackList(station);
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysHotspotEventGroup.REMOVE_FROM_BLOCK_LIST);
    } else {
      HotSpotBlackListUtils.addToBlockList(station);
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysHotspotEventGroup.ADD_TO_BLOCK_LIST);
    }
    emitter.emit({
      eventId: EVENT_ID_BLOCK_LIST_CHANGE,
      priority: emitter.EventPriority.IMMEDIATE,
    });
  }
}