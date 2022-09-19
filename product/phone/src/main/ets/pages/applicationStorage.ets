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
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import EntryComponent from '../../../../../../common/component/src/main/ets/default/entryComponent';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Router from '@system.router';
import ApplicationStorageController from '../controller/application/ApplicationStorageController'
import Log from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import {SubHeader} from '../../../../../../common/component/src/main/ets/default/textComponent';

let appInfo;
/**
 * Application storage
 */
@Entry
@Component
struct ApplicationStorage {
  @State cacheValue: number = 0;
  @State storageList: any[]= [];
  @State isTouched: boolean = false;
  private controller: ApplicationStorageController = new ApplicationStorageController();

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
            HeadComponent({ headName: $r('app.string.storageTab'), isActive: true });
            // head
            Row() {
              Image(appInfo.settingIcon)
                .width($r('app.float.wh_value_64'))
                .height($r('app.float.wh_value_64'))
                .margin({ right: $r('app.float.distance_16'), left: $r('sys.float.ohos_id_card_margin_start') })
              Column() {
                Text(appInfo.settingTitle)
                  .fontColor($r('app.color.font_color_182431'))
                  .fontSize($r('app.float.font_16'))
                  .maxLines(ConfigData.MAX_LINES_3)
                  .margin({ top: $r('app.float.wh_value_10'), bottom: $r('app.float.wh_value_5') })
                  .alignSelf(ItemAlign.Start);
                Row() {
                  Text(appInfo.settingSummary)
                    .fontColor($r('app.color.font_color_182431'))
                    .fontSize($r('app.float.font_14'))
                    .maxLines(ConfigData.MAX_LINES_1)
                    .margin({ bottom: $r('app.float.distance_11') });
                }
                .alignSelf(ItemAlign.Start)
              }
              .width(ConfigData.WH_100_100)
              .height($r('app.float.wh_value_64'))
            }.width(ConfigData.WH_100_100)
            .margin({ bottom: $r('app.float.wh_value_32'), top: $r("app.float.distance_16") });

            SubHeader({ titleContent: $r('app.string.senior') })

            // body
            Row() {
              List() {
                ForEach(this.storageList, (item) => {
                  ListItem() {
                    EntryComponent({
                      settingIcon: '',
                      settingTitle: item.settingTitle,
                      settingSummary: item.settingSummary,
                      settingValue: item.settingValue,
                      settingArrow: item.settingArrow,
                      settingArrowStyle: '',
                      settingUri: '',
                      heights: $r('app.float.wh_value_48'),
                      fontSize: $r('app.float.font_16')
                    });
                  }
                });
              }
              .divider({
                strokeWidth: $r('app.float.divider_wh'),
                color: $r('app.color.color_E3E3E3_grey'),
                startMargin: $r('app.float.storage_common_margin'),
                endMargin: $r('app.float.storage_common_margin')
              })
            }
            .borderRadius($r("sys.float.ohos_id_corner_radius_default_l"))
            .backgroundColor($r("app.color.white_bg_color"))

            ButtonComponent({ text: $r("app.string.deleteDataTab"), onClickEvent: () => {
              this.showDialog(this.controller.clearUpApplicationData.bind(this, appInfo.settingBundleName));
            } })

            Row() {
              Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                Row() {
                  Text($r('app.string.cacheTab'))
                    .fontColor($r('app.color.color_333333_grey'))
                    .fontSize($r('app.float.font_16'))
                    .textAlign(TextAlign.Start)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .height($r('app.float.wh_value_48'))
                    .margin({ left: $r('sys.float.ohos_id_card_margin_start') })
                }

                Text(`${this.cacheValue} B`)
                  .fontSize($r('app.float.font_14'))
                  .fontColor($r('app.color.color_999999_grey'))
                  .height($r('app.float.wh_value_48'))
                  .align(Alignment.End)
                  .margin({
                    right: $r('sys.float.ohos_id_card_margin_end'),
                    top: $r('app.float.distance_15'),
                    bottom: $r('app.float.distance_14')
                  });
              }
              .backgroundColor(this.isTouched ? $r("app.color.color_D8D8D8_grey") : $r("sys.color.ohos_id_color_foreground_contrary"))
              .onTouch((event: TouchEvent) => {
                if (event.type === TouchType.Down) {
                  this.isTouched = true;
                }
                if (event.type === TouchType.Up) {
                  this.isTouched = false;
                }
              })
              .height(ConfigData.WH_100_100)
              .width(ConfigData.WH_100_100)
              .borderRadius($r("sys.float.ohos_id_corner_radius_default_l"))
            }
            .padding($r('app.float.distance_4'))
            .height($r('app.float.wh_value_56'))
            .borderRadius($r("sys.float.ohos_id_corner_radius_default_l"))
            .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"));

            ButtonComponent({ text: $r("app.string.clearCacheTab"), onClickEvent: () => {
              this.controller.cleanBundleCacheFiles(appInfo.settingBundleName);
            } })

          }
          .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .padding({ left: $r('sys.float.ohos_id_card_margin_start'), right: $r('sys.float.ohos_id_card_margin_end') })
          .align(Alignment.Start)
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
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }

  @Log
  aboutToAppear() {
    // bind component and initialize
    if (this.controller) {
      this.controller.bindComponent(this)
        .bindProperties(["storageList"])
        .initData();
    }
    appInfo = Router.getParams();
    LogUtil.info('settings ApplicationInfo aboutToAppear this.item:' + JSON.stringify(appInfo));
  }

  @Log
  onBackPress() {
    LogUtil.info('settings ApplicationStorage onBackPress');
  }

  /**
   * Disconnect Dialog
   */
  @Log
  showDialog(callback) {
    AlertDialog.show({
      title: $r('app.string.delete_data_prompt_title'),
      message: $r("app.string.delete_data_prompt"),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          LogUtil.info(ConfigData.TAG + 'Closed callbacks');
        }
      },
      secondaryButton: {
        value: $r('app.string.confirm'),
        action: () => {
          LogUtil.info(ConfigData.TAG + `AlertDialog success:`);
          callback();
          LogUtil.info(ConfigData.TAG + `callback success:`);
        }
      },
      alignment: DialogAlignment.Bottom
    })
  }
}

@Component
struct ButtonComponent {
  @State isTouched: boolean = false;
  private text;
  private onClickEvent = () => {
  };

  build() {
    Column() {
      Button(this.text)
        .fontSize($r('app.float.application_button_subtitle_size'))
        .fontColor($r('app.color.font_color_007DFF'))
        .width($r('app.float.component_button_width'))
        .height($r('app.float.application_button_height'))
        .margin({ top: $r("app.float.wh_value_24"), bottom: $r("app.float.wh_value_32") })
        .borderRadius($r('app.float.radius_20'))
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .onClick(() => {
          this.onClickEvent();
        })
    }
    .align(Alignment.Center);
  }
}