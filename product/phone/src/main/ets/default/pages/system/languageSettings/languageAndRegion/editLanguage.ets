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
import LogUtil from '../../../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LanguageAndRegionModel from '../../../../../default/model/systemImpl/languageSettings/LanguageAndRegionModel'
import Router from '@system.router';

/**
 * Home Page Of EditLanguage
 */
@Entry
@Component
struct EditLanguage {
  private TAG = `${ConfigData.TAG} EditLanguage`;

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
            HeadComponent({headName: $r('app.string.editLanguage')});
            EditList();
          }
          .padding({left: $r("app.float.distance_24"), right: $r("app.float.distance_24")})
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

  aboutToAppear(){
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }

  aboutToDisappear(){
    LogUtil.info(`${this.TAG} aboutToDisappear in`);
    LogUtil.info(`${this.TAG} aboutToDisappear out`);
  }

}

/**
 * Edit List Of Added Language
 */
@Component
struct EditList {
  @StorageLink('addedLanguages') addedLanguages:Array<string> = LanguageAndRegionModel.getAddedLanguages();
  @State touchedItem:string = ''

  build(){
    List(){
      ForEach(this.addedLanguages, (item) => {
        ListItem(){
          Flex({justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center}){
            Row(){
              Image($r('app.media.ic_move'))
                .width($r('app.float.wh_value_24'))
                .height($r('app.float.wh_value_24'))
                .objectFit(ImageFit.Contain)
                .margin({right: $r("app.float.distance_11")});

              Column(){
                Text(LanguageAndRegionModel.getSysDisplayLanguage(item))
                  .fontSize($r('app.float.font_16'))
                  .lineHeight($r('app.float.wh_value_22'))
                  .fontWeight(FontWeight.Medium)
                  .margin(LanguageAndRegionModel.isSystemLanguage(item) ? {top: $r("app.float.distance_20"), bottom: $r("app.float.distance_22_5")}: {top: $r("app.float.distance_10"), bottom: $r("app.float.distance_2")})
                  .fontColor(LanguageAndRegionModel.isSystemLanguage(item) ? $r("app.color.font_color_007DFF") : $r("app.color.font_color_182431"))
                  .textAlign(TextAlign.Start);
                Text(LanguageAndRegionModel.getDisplayLanguage(item))
                  .fontSize($r("app.float.font_14"))
                  .height($r("app.float.wh_value_19"))
                  .margin({bottom:$r("app.float.distance_11")})
                  .fontColor($r("app.color.font_color_182431"))
                  .fontWeight(FontWeight.Regular)
                  .textAlign(TextAlign.Start)
                  .visibility(LanguageAndRegionModel.isSystemLanguage(item) ? Visibility.None : Visibility.Visible);
              }
              .alignItems(HorizontalAlign.Start);
            }

            Image($r('app.media.ic_public_close'))
              .width($r('app.float.wh_value_24'))
              .height($r('app.float.wh_value_24'))
              .objectFit(ImageFit.Contain)
              .onClick(() => {
                if(this.addedLanguages.length <= 1){
                  AlertDialog.show({
                    message: $r("app.string.saveLanguage"),
                    confirm: {
                      value: $r("app.string.confirm"),
                      action: () => {
                        console.log('button clicked');
                      }
                    }
                  })
                }else{
                  LanguageAndRegionModel.deleteLanguage(item);
                }
              });
          }
        }
        .align(Alignment.Start)
        .width(ConfigData.WH_100_100)
        .padding({left: $r("app.float.distance_8"), right: $r("app.float.distance_8")})
        .borderRadius($r("app.float.radius_20"))
        .linearGradient(item === this.touchedItem ? {
           angle: 90,
           direction: GradientDirection.Right,
           colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
           } : {
           angle: 90,
           direction: GradientDirection.Right,
           colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]})
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.touchedItem = item;
          }
          if (event.type === TouchType.Up) {
            this.touchedItem = '';
          }
        })
      }, item => item);
    }
    .padding($r("app.float.distance_4"))
    .margin({top:$r("app.float.distance_8")})
    .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
    .borderRadius($r("app.float.radius_24"))
    .divider({strokeWidth:1, color: $r("app.color.color_E3E3E3_grey"), startMargin: $r("sys.float.ohos_id_card_margin_start"), endMargin: $r("sys.float.ohos_id_card_margin_end")})
  }
}

/**
 * Head Component
 */
@Component
struct HeadComponent {
  private headName: string= '';
  @State isTouch: boolean= false;

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems:ItemAlign.Center }) {
      Row(){
        Image($r('app.media.ic_close'))
          .width($r('app.float.wh_value_24'))
          .height($r('app.float.wh_value_24'))
          .margin({ right: $r('app.float.wh_value_16'), top: $r('app.float.wh_value_16'), bottom: $r('app.float.wh_value_16')})
          .backgroundColor(this.isTouch ? $r('app.color.color_E3E3E3_grey') : $r('app.color.color_00000000_transparent'))
          .onClick(()=>{
            Router.back();
          })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.isTouch = true;
            }
            if (event.type === TouchType.Up) {
              this.isTouch = false;
            }
          });
        Text(this.headName)
          .fontSize($r('app.float.font_20'))
          .lineHeight($r('app.float.wh_value_28'))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
          .maxLines(ConfigData.MAX_LINES_1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
          .margin({top: $r('app.float.wh_value_13'), bottom: $r('app.float.wh_value_15')});
      }

      Image($r("app.media.ic_ok"))
        .width($r('app.float.wh_value_24'))
        .height($r('app.float.wh_value_24'))
        .objectFit(ImageFit.Contain);
    }
    .width(ConfigData.WH_100_100)
    .padding({left: $r('sys.float.ohos_id_card_margin_start'), right: $r('sys.float.ohos_id_card_margin_end')})
    .height($r('app.float.wh_value_56'));
  }
}
