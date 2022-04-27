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

import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import StorageController from '../controller/storage/storageController';

/**
 * Storage
 */
@Entry
@Component
struct Storage {
  @State storageList: any[] = [];
  private usedSpace: any = '';
  private totalSpace: any = '';
  private freeBytes: any = '';
  @State proportion: number = 0;
  @State usedSpaceList: any[] = [];
  private controller: StorageController = new StorageController();

  build() {
    Column(){
      GridContainer({columns:12, sizeType: SizeType.Auto, gutter: vp2px(1) === 2 ? '12vp' : '0vp', margin: vp2px(1) === 2 ? '24vp' : '0vp'}) {
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
            Stack({ alignContent: Alignment.Center }) {
              Column() {
                DataPanel({ values: this.usedSpaceList, max: 100 })
                  .align(Alignment.Top)
                  .width($r("app.float.dataPanel_distance"))
                  .height($r("app.float.dataPanel_distance"))
              }

              Column() {
                Row() {
                  Blank()
                }.layoutWeight(1)

                Row() {
                  Column() {
                    Blank()
                  }.layoutWeight(1)

                  Text(`${this.proportion}`).fontSize($r("app.float.dataPanel_proportion_font_size"))

                  Flex({ alignItems: ItemAlign.Baseline }) {
                    Text('%').fontSize($r("app.float.dataPanel_percent_font_size"))
                    Text(' ').fontSize($r("app.float.dataPanel_proportion_font_size"))
                  }.layoutWeight(1)
                }.width(ConfigData.WH_100_100)

                Row() {
                  Text($r("app.string.used", this.usedSpace, this.totalSpace))
                    .fontSize($r("app.float.dataPanel_used_font_size"))
                    .fontColor(Color.Grey)
                    .alignSelf(ItemAlign.Start)
                }.layoutWeight(1)
              }
            }
            .width($r("app.float.dataPanel_distance"))
            .height($r("app.float.dataPanel_distance"))
            .margin({ bottom: $r("app.float.distance_96") })

            Row() {
              List() {
                ForEach(this.storageList, (item) => {
                  ListItem() {
                    Row() {
                      Circle()
                        .width($r('sys.float.ohos_id_corner_radius_default_s'))
                        .height($r('sys.float.ohos_id_corner_radius_default_s'))
                        .colorBlend(item.settingIcon)
                        .margin({
                          right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
                        })

                      Text(item.settingTitle)
                        .fontColor($r('sys.color.ohos_id_color_text_primary'))
                        .fontSize( $r('sys.float.ohos_id_text_size_body1'))
                        .textAlign(TextAlign.Start)
                        .layoutWeight(1);

                      Text(item.settingValue)
                        .fontSize($r('sys.float.ohos_id_text_size_body2'))
                        .fontColor($r('sys.color.ohos_id_color_secondary'))
                        .fontWeight(FontWeight.Regular)
                        .height($r('app.float.wh_value_40'))
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
                left: $r('sys.float.ohos_id_card_margin_end'),
                right: $r('sys.float.ohos_id_card_margin_end')
              })
              .divider({
                strokeWidth: 1,
                color: $r('app.color.color_D8D8D8_grey'),
                startMargin: $r('app.float.distance_24'),
              })
            }
            .borderRadius($r("sys.float.ohos_id_corner_radius_default_l"))
            .backgroundColor($r("app.color.white_bg_color"))
            .padding($r('app.float.distance_4'))
          }
          .padding({left:$r('app.float.distance_24'), right:$r('app.float.distance_24')})
          .align(Alignment.Start)
          .height(ConfigData.WH_100_100)
          .width(ConfigData.WH_100_100)
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

  aboutToAppear(): void{
    // bind component and initialize
    if (this.controller) {
      this.controller.bindComponent(this)
        .bindProperties(["storageList", "totalSpace", "freeBytes", "usedSpace", "proportion", "usedSpaceList"])
        .initData();
    }
  }

}



