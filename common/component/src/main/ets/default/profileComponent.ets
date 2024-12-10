/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import LogUtil from '../../../../../utils/src/main/ets/default/baseUtil/LogUtil';
import { emitter } from '@kit.BasicServicesKit';

@Component
export default struct ProfileComponent {
  @State isOn: boolean = false;
  @Link @Watch('onIsEnableChange') isEnable: boolean;
  @State desp?: string | ResourceStr = '';
  @State profileText: string | ResourceStr = '';
  @State textFontColor: ResourceColor = $r('sys.color.font_primary')
  @State despFontColor: ResourceColor = $r('sys.color.font_secondary')
  @State profileId: number = -1;
  @State isShow: boolean = true;
  private onChange?: (isOn: boolean) => void;
  private fontSize?: Resource = $r('sys.float.Body_L');
  private fontWeight?: FontWeight = FontWeight.Medium;

  onIsEnableChange(): void {
    this.isShow = this.isEnable
    LogUtil.info('onIsEnableChange successful')
  }

  aboutToAppear(): void {
    this.monitoringProfile();
  }

  private monitoringProfile(): void {
    let innerEvent: emitter.InnerEvent = { eventId: this.profileId }
    emitter.on(innerEvent, (eventData: emitter.EventData) => {
      if (eventData.data) {
        this.isEnable = eventData.data.Enable;
        this.desp = eventData.data.Description;
        this.isOn = eventData.data.State;
        LogUtil.info('monitoringProfile() = ' + this.profileId + 'this.isOn = ' + this.isOn)
      }
    })
  }

  private getMinMenuHeight(): number {
    return this.desp ? 64 : 48
  }

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      if (this.isShow) {
        Column() {
          Text(this.profileText)
            .fontColor($r('sys.color.font_primary'))
            .fontSize(this.fontSize)
            .fontWeight(this.fontWeight)
            .fontFamily('HarmonyHeiTi')
            .lineHeight(22)

          if (this.desp) {
            Text(this.desp)
              .fontFamily('HarmonyHeiTi')
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Regular)
              .lineHeight(19)
              .margin({
                top: $r('sys.float.padding_level1')
              })
          }
        }
        .padding({
          left: $r('sys.float.padding_level4'),
          right: $r('sys.float.padding_level4')
        })
        .flexGrow(1)
        .alignItems(HorizontalAlign.Start)
      } else {
        Column() {
          Text(this.profileText)
            .fontColor($r('app.color.color_E3E3E3_grey'))
            .fontSize(this.fontSize)
            .fontWeight(this.fontWeight)
            .fontFamily('HarmonyHeiTi')
            .lineHeight(22)

          if (this.desp) {
            Text(this.desp)
              .fontFamily('HarmonyHeiTi')
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('app.color.color_E3E3E3_grey'))
              .fontWeight(FontWeight.Regular)
              .lineHeight(19)
              .margin({
                top: $r('sys.float.padding_level1')
              })
          }
        }
        .padding({
          left: $r('sys.float.padding_level4'),
          right: $r('sys.float.padding_level4')
        })
        .flexGrow(1)
        .alignItems(HorizontalAlign.Start)
      }
      Toggle({
        type: ToggleType.Switch,
        isOn: this.isOn
      })
        .enabled(this.isEnable)
        .id('entry_toggle')
        .selectedColor('#007DFF')
        .onChange(this.onChange as ((isOn: boolean) => void))
        .hoverEffect(HoverEffect.None)
        .responseRegion({ width: 48, height: 48 })
        .margin({
          right: $r('sys.float.padding_level4')
        })
        .flexShrink(0)
        .defaultFocus(true)
    }
    .constraintSize({
      minHeight: this.getMinMenuHeight()
    })
  }
}