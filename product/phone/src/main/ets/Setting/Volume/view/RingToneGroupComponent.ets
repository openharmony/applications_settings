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
import { PADDING_12, PADDING_4, PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  MessagetoneController,
  NotificationtoneController,
  RingtoneController
} from '../controller/RingToneController';
import { VolumeController } from '../controller/VolumeController';
import { VolumeStateInfo } from '../model/VolumeType';
import { RingtonesUtils } from '../utils/RingtonesUtils';

const ENTER_INTERNAL_ENTRY: string = 'enter_internal_entry';

@Component
struct RingToneItem {
  compId: string = '';
  title: ResourceStr = '';
  targetPageUrl: string = '';
  targetEntry: string = '';
  controller: VolumeController | undefined = undefined;
  item?: SettingBaseModel;
  @State stateInfo: VolumeStateInfo = new VolumeStateInfo();
  @State hoverItem: string = '';
  @State isHover: boolean = false;

  private onItemClick(): void {
    let message: string = `pageUrl: ${this.targetPageUrl}`;
    HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
    PageRouter.push(this.targetEntry);
  }

  private isExtraLargeFontMode() {
    return FontScaleUtils.isExtraLargeFontMode();
  }

  aboutToAppear(): void {
    this.controller?.init();
    if (this.controller?.stateInfo) {
      this.stateInfo = this.controller?.stateInfo;
    }
    EventBus.getInstance().on(this.compId + '_event', (data: object) => {
      this.stateInfo = data as VolumeStateInfo;
    });

  }

  aboutToDisappear(): void {
    this.controller?.destroy();
    EventBus.getInstance().detach(this.compId + '_event', () => {});
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }


  @Builder
  ringToneGroupLargeContentBuilder() {
    Row() {
      Column() {
        if (this.stateInfo.primaryState) {
          Text(this.stateInfo.primaryState)
            .id(`${this.compId}_entry_text_card_one`)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Start)
			.wordBreak(WordBreak.BREAK_WORD)
        }
        if (this.stateInfo.secondaryState) {
          Text(this.stateInfo.secondaryState)
            .id(`${this.compId}_entry_text_card_two`)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Start)
            .padding({ top: $r('sys.float.padding_level1') })
			.wordBreak(WordBreak.BREAK_WORD)
        }
        if (this.stateInfo.summaryInfo) {
          Text(this.stateInfo.summaryInfo)
            .id(`${this.compId}_entry_text_summary`)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Start)
			.wordBreak(WordBreak.BREAK_WORD)
        }
      }
      .flexShrink(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ end: PADDING_4 })
      .constraintSize({ minHeight: this.stateInfo.summaryInfo ? $r('app.float.height_48') : $r('app.float.height_64') })
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .id(`entry_image_${this.compId}`)
        .fontColor([$r('sys.color.icon_fourth')])
        .fontSize('24vp')
        .draggable(false)
        .margin({ start: PADDING_4 })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  buildLargeStyle() {
    Column() {
      Text(this.title)
        .id(`comp_${this.compId}_title`)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .wordBreak(WordBreak.BREAK_WORD)
        .textAlign(TextAlign.Start)
      this.ringToneGroupLargeContentBuilder()
    }
    .id(this.compId)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .constraintSize({ minHeight: this.stateInfo.summaryInfo ? $r('app.float.height_48') : $r('app.float.height_64') })
    .borderRadius($r('sys.float.corner_radius_level10'))
    .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6'),
      top: FontScaleUtils.getCurrentTopPadding(), bottom: FontScaleUtils.getCurrentTopPadding() })
    .stateStyles({
      pressed: this.pressedStyles,
      normal: {
        .backgroundColor(ResourceUtil.getStringSync(this.hoverItem) === ResourceUtil.getStringSync(this.title) && 
          this.isHover ? $r('sys.color.interactive_hover') : Color.Transparent)
        .borderRadius($r('sys.float.corner_radius_level8'))
      }
    })
    .onClick(() => {
      this.onItemClick();
    })
    .onHover((hover: boolean) => {
      this.isHover = hover;
      this.hoverItem = ResourceUtil.getStringSync(this.title);
    });
  }

  @Builder
  ringToneGroupContentBuilder() {
    Row() {
      Column() {
        if (this.stateInfo.primaryState) {
          Text(this.stateInfo.primaryState)
            .id(`${this.compId}_entry_text_card_one`)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.End)
        }
        if (this.stateInfo.secondaryState) {
          Text(this.stateInfo.secondaryState)
            .id(`${this.compId}_entry_text_card_two`)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.End)
            .padding({ top: $r('sys.float.padding_level1') })
        }
        if (this.stateInfo.summaryInfo) {
          Text(this.stateInfo.summaryInfo)
            .id(`${this.compId}_entry_text_summary`)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.End)
        }
      }
      .padding({ top: PADDING_8, bottom: PADDING_8 })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.End)
      .margin({ end: PADDING_4 })
      .constraintSize({ minHeight: this.stateInfo.summaryInfo ? $r('app.float.height_48') : $r('app.float.height_64') })
      .flexShrink(1)
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .id(`entry_image_${this.compId}`)
        .fontColor([$r('sys.color.icon_fourth')])
        .fontSize('24vp')
        .draggable(false)
        .margin({ start: PADDING_4 })
        .flexShrink(0)
    }
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
    .flexGrow(1)
    .flexShrink(1)
  }

  build() {
    if (this.isExtraLargeFontMode()) {
      this.buildLargeStyle()
    } else {
      Row() {
        Text(this.title)
          .id(`comp_${this.compId}_title`)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .wordBreak(WordBreak.BREAK_ALL)
          .flexShrink(0)
        this.ringToneGroupContentBuilder()
      }
      .id(this.compId)
      .width('100%')
      .constraintSize({ minHeight: this.stateInfo.summaryInfo ? $r('app.float.height_48') : $r('app.float.height_64') })
      .borderRadius($r('sys.float.corner_radius_level10'))
      .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
      .stateStyles({
        pressed: this.pressedStyles,
        normal: {
          .backgroundColor(ResourceUtil.getStringSync(this.hoverItem) === ResourceUtil.getStringSync(this.title) && 
            this.isHover ? $r('sys.color.interactive_hover') : Color.Transparent)
          .borderRadius($r('sys.float.corner_radius_level8'))
        }
      })
      .onClick(() => {
        this.onItemClick();
      })
      .onHover((hover: boolean) => {
        this.isHover = hover;
        this.hoverItem = ResourceUtil.getStringSync(this.title);
      });
    }
  }
}

@Component
export struct RingToneGroupComponent {
  item?: SettingBaseModel;
  @State isHover: boolean = false;

  @Styles
  normalStateStyle() {
    .backgroundColor(this.getNormalColor())
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  private getNormalColor(): ResourceColor {
    if (this.isHover) {
      return $r('sys.color.interactive_hover');
    }
    return $r('sys.color.comp_background_list_card');
  }

  @Builder
  itemDividerBuilder(): void {
    Divider()
      .strokeWidth(0.5)
      .color($r('sys.color.comp_divider'))
      .lineCap(LineCapStyle.Square)
      .padding({ start: PADDING_12, end: PADDING_12 })
  }

  build() {
    Column() {
      if (!RingtonesUtils.isVoiceCapabilityDisable()) {
        RingToneItem({
          compId: 'ring_tone_settings_phone',
          title: $r('app.string.ring_tone_settings_phone'),
          targetPageUrl: 'pages/volume/RingToneSettings',
          targetEntry: NavEntryKey.RING_TONE_ENTRY,
          controller: new RingtoneController(),
          item: this.item
        })
        this.itemDividerBuilder()

        RingToneItem({
          compId: 'ring_tone_settings_message',
          title: $r('app.string.ring_tone_settings_message'),
          targetPageUrl: 'pages/volume/MessagingTone',
          targetEntry: NavEntryKey.MESSAGING_TONE_ENTRY,
          controller: new MessagetoneController()
        })
        this.itemDividerBuilder()
      }

      RingToneItem({
        compId: 'ring_tone_settings_notification',
        title: $r('app.string.ring_tone_settings_notification'),
        targetPageUrl: 'pages/volume/NotificationTone',
        targetEntry: NavEntryKey.NOTIFICATION_TONE_ENTRY,
        controller: new NotificationtoneController(),
        item: RingtonesUtils.isVoiceCapabilityDisable() ? this.item : undefined
      })
    }
    .width('100%')
    .padding({ top: PADDING_4,
      bottom: PADDING_4,
      start: PADDING_4,
      end: PADDING_4
    })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius($r('sys.float.corner_radius_level10'))
    .clip(true)
  }
}