/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import { ScreenModeModel } from '../model/displayAndBrightnessImpl/display/ScreenMode';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import { BaseData } from '../../../../../../../common/utils/src/main/ets/default/bean/BaseData';


/**
 * ScreenMode setting
 */
@Entry
@Component
struct ScreenMode {
  @StorageLink('supportedScreenModes') supportedScreenModes: [] = [];
  @State screenModeModel: ScreenModeModel = new ScreenModeModel();
  private TAG = ConfigData.TAG + 'ScreenMode ';

  build() {
    Column() {
      GridContainer({
        columns: 12,
        sizeType: SizeType.Auto,
        gutter: vp2px(1) === 2 ? '12vp' : '0vp',
        margin: vp2px(1) === 2 ? '24vp' : '0vp'
      }) {
        Row({}) {
          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 0 }, sm: { span: 0, offset: 0 },
            md: { span: 0, offset: 0 }, lg: { span: 2, offset: 0 }
          });

          Column() {
            HeadComponent({ headName: $r('app.string.screenResolution'), isActive: true });
            Text($r('app.string.screenResolutionWarning'))
              .fontSize($r("sys.float.ohos_id_text_size_body2"))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontWeight(FontWeight.Regular)
              .textAlign(TextAlign.Start)
              .margin({ top: $r('app.float.distance_24'), bottom: $r('app.float.distance_24') })
              .padding({ left: $r('app.float.wh_value_12'), right: $r('app.float.wh_value_12'), })
              .width(ConfigData.WH_100_100)

            List() {
              ForEach(this.supportedScreenModes, (item: BaseData) => {
                ListItem() {
                  Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                    Column() {
                      Text(`${this.screenModeModel.getScreenModeWidth(item)} x ${this.screenModeModel.getScreenModeHeight(item)}`)
                        .fontColor($r('sys.color.ohos_id_color_text_primary'))
                        .fontSize($r("app.float.font_16"))
                        .lineHeight($r("app.float.lineHeight_22"))
                        .fontWeight(FontWeight.Medium)
                        .margin({ top: $r('app.float.distance_13'), bottom: $r('app.float.distance_13') })
                        .textAlign(TextAlign.Start);

                    }
                    .alignItems(HorizontalAlign.Start)

                    Radio({ value: this.TAG, group: '' })
                      .colorBlend($r("sys.color.ohos_id_color_switch_bg_off"))
                      .width('20vp')
                      .height('20vp')
                      .enabled(false)
                      .checked(this.screenModeModel.isSysScreenMode(item))
                      .onClick(() => {
                        LogUtil.info('settings RadioListComponent : onChange: settingValue = ' + item.settingValue)
                        this.screenModeModel.setSysScreenMode(0);
                      })
                  }
                }
                .height($r('app.float.wh_value_48'))
                .width(ConfigData.WH_100_100)

              }, item => JSON.stringify(item));
            }
            .padding({
              left: $r('app.float.wh_value_12'),
              right: $r('app.float.wh_value_12'),
              top: $r('app.float.distance_4'),
              bottom: $r('app.float.distance_4')
            })
            .divider({ strokeWidth: $r('app.float.divider_wh'), color: $r("app.color.color_E3E3E3_grey") })
            .borderRadius($r("app.float.radius_24"))
            .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"));
          }
          .align(Alignment.Start)
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 12, offset: 0 }, sm: { span: 12, offset: 0 },
            md: { span: 12, offset: 0 }, lg: { span: 8, offset: 2 }
          });

          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 12 }, sm: { span: 0, offset: 12 },
            md: { span: 0, offset: 12 }, lg: { span: 2, offset: 10 }
          })
        }
        .width(ConfigData.WH_100_100)
        .height(ConfigData.WH_100_100);
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .padding({
      left: $r('sys.float.ohos_id_card_margin_start'),
      right: $r('sys.float.ohos_id_card_margin_end')
    })
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }

  @Log
  aboutToAppear(): void{
    LogUtil.info(this.TAG + 'aboutToAppear in');
    this.screenModeModel.registerObserver();
    LogUtil.info(this.TAG + 'aboutToAppear out');
  }

  @Log
  aboutToDisappear(): void{
    LogUtil.info(this.TAG + 'aboutToDisappear in');
    this.screenModeModel.unregisterObserver();
    LogUtil.info(this.TAG + 'aboutToDisappear out');
  }
}