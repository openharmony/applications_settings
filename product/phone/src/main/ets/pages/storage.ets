/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
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

import display from '@ohos.display';
import mediaquery from '@ohos.mediaquery';
import StorageController from '../controller/storage/storageController';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';

let portraitFunc = null;

/**
 * Storage
 */
@Entry
@Component
struct Storage {
  listener = mediaquery.matchMediaSync('(orientation: landscape)');
  @State storageList: any[] = [];
  @State proportion: number = 0;
  @State usedSpaceList: any[] = [];
  @State screenWidth: number = 360;

  @State @Watch("usedSpaceChange") usedSpace: string = '';
  @State @Watch("totalSpaceChange") totalSpace: string = '';
  @State @Watch("totalSpaceChange") freeBytes: string = '';
  private dpi: number = vp2px(this.screenWidth) / this.screenWidth;
  private controller: StorageController = new StorageController();

  usedSpaceChange() {
    console.error(`usedSpaceChange usedSpace: ${this.usedSpace}`)
  }

  totalSpaceChange() {
    console.error(`totalSpaceChange totalSpace: ${this.totalSpace}`)
  }

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.storageTab'), isActive: true });

          Stack({ alignContent: Alignment.Center }) {
            Column() {
              Progress({ value: this.usedSpaceList[0], type: ProgressType.Ring })
                .align(Alignment.Center)
                .width(this.screenWidth * 0.7)
                .color('#4C89F0')
                .backgroundColor('#E9EBED')
                .height(this.screenWidth * 0.7)
                .style({ strokeWidth: $r("app.float.wh_value_24") })
            }
            .width(this.screenWidth * 0.7)
            .height(this.screenWidth * 0.7)


            Column() {
              Row() {
                Blank()
              }
              .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)

              Row() {
                Column() {
                  Blank()
                }
                .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)

                Text(`${this.proportion}`)
                  .fontSize($r("app.float.dataPanel_proportion_font_size_1"))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r("sys.color.ohos_id_color_primary"))
                  .margin({ right: $r("app.float.distance_2") })

                Flex({ alignItems: ItemAlign.Baseline }) {
                  Text('%')
                    .fontSize($r("app.float.dataPanel_percent_font_size_1"))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r("sys.color.ohos_id_color_secondary"))

                  Text(' ')
                    .fontSize($r("app.float.dataPanel_proportion_font_size"))
                }
                .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)
              }
              .width(ConfigData.WH_100_100)

              Row() {
                Text($r("app.string.used", this.usedSpace, this.totalSpace))
                  .fontSize($r("app.float.dataPanel_used_font_size_1"))
                  .fontColor(Color.Grey)
                  .alignSelf(ItemAlign.Start)
                  .fontColor($r("sys.color.ohos_id_color_primary"))
                  .opacity($r("sys.float.ohos_id_alpha_content_secondary"))
                  .fontWeight(FontWeight.Regular)
              }
              .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)
            }
            .width(this.screenWidth * 0.7)
            .height(this.screenWidth * 0.7)
            .padding({ bottom: $r("app.float.distance_32") })
          }
          .width(this.screenWidth * 0.8)
          .height(this.screenWidth * 0.8)
          .padding({ bottom: $r('sys.float.ohos_id_elements_margin_vertical_m') })
          .margin({ bottom: $r("app.float.progress_bottom") })

          Row() {
            List() {
              ForEach(this.storageList, (item) => {
                ListItem() {
                  Row() {
                    Circle()
                      .width($r('app.float.distance_10'))
                      .height($r('app.float.distance_10'))
                      .colorBlend(item.settingIcon)
                      .margin({ right: $r("app.float.distance_16") })

                    Text(item.settingTitle)
                      .fontColor($r('sys.color.ohos_id_color_text_primary'))
                      .fontSize($r('sys.float.ohos_id_text_size_body1'))
                      .textAlign(TextAlign.Start)
                      .layoutWeight(ConfigData.LAYOUT_WEIGHT_1);

                    Text(item.settingValue)
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .fontColor($r('sys.color.ohos_id_color_secondary'))
                      .fontWeight(FontWeight.Regular)
                      .margin({ left: $r('sys.float.ohos_id_elements_margin_horizontal_l') })
                      .align(Alignment.End);
                  }
                  .height($r("app.float.wh_value_56"))
                  .width(ConfigData.WH_100_100)
                  .borderRadius($r("sys.float.ohos_id_corner_radius_default_l"))
                  .alignItems(VerticalAlign.Center)
                }
              });
            }
            .padding({
              left: $r("sys.float.ohos_id_card_margin_start"),
              right: $r('sys.float.ohos_id_card_margin_end')
            })
            .divider({
              strokeWidth: $r('app.float.divider_wh'),
              color: $r('app.color.color_D8D8D8_grey'),
              startMargin: $r('app.float.wh_value_28'),
            })
          }
          .borderRadius($r("sys.float.ohos_id_corner_radius_default_l"))
          .backgroundColor($r("app.color.white_bg_color"))
          .padding({ top: $r('app.float.distance_4'), bottom: $r('app.float.distance_4') })
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        })
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }

  onPortrait(mediaQueryResult) {
    if (mediaQueryResult.matches) {
      display.getDefaultDisplay()
        .then((disp) => {
          this.screenWidth = disp.height / this.dpi / this.dpi;
        })
    } else {
      display.getDefaultDisplay()
        .then((disp) => {
          this.screenWidth = disp.width / this.dpi;
        })
    }
  }

  aboutToAppear(): void{
    display.getDefaultDisplay()
      .then((display) => {
        if (display.width > display.height) {
          this.screenWidth = display.height / this.dpi / this.dpi;
        } else {
          this.screenWidth = display.width / this.dpi;
        }
      })

    // bind component and initialize
    if (this.controller) {
      this.controller.bindComponent(this)
        .bindProperties(["storageList", "totalSpace", "freeBytes", "usedSpace", "proportion", "usedSpaceList"])
        .initData();

      portraitFunc = this.onPortrait.bind(this);
      this.listener.on('change', portraitFunc);
    }
  }
}
