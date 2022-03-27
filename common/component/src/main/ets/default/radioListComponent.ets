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
import ComponentConfig from './ComponentConfig.ets';
import LogUtil from '../../../../../utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../utils/src/main/ets/default/baseUtil/LogDecorator';
import { RadioListItem } from '../../../../../utils/src/main/ets/default/bean/RadioListItem';

/**
 * Radio component
 */
@Component
export default
struct RadioListComponent {
  @State dataList: RadioListItem[] = [];
  @State checkedValue: string | Resource = '';
  private showRadio: boolean = true;
  private onChange?: (item : RadioListItem) => void;

  build() {
    Column() {
      List() {
        ForEach(this.dataList, (item: RadioListItem) => {
          ListItem() {
            RadioComponent({
              radioItem: item,
              showRadio: this.showRadio,
              isChecked: (this.checkedValue == item.settingValue),
              onChange:() => {
                this.checkedValue = item.settingValue;
                if (this.onChange) {
                  LogUtil.info('settings RadioListComponent : onChange: settingValue = ' + item.settingValue)
                  this.onChange(item);
                }
              }
            });
          }
          .height(item.settingIcon ? $r('app.float.audio_no_icon_height') : $r('app.float.audio_icon_height'));
        });
      }
      .divider({
        strokeWidth: 1,
        color: $r('app.color.color_E3E3E3_grey'),
        startMargin: $r('app.float.audio_start_end_margin_left'),
        endMargin: $r('app.float.audio_start_end_margin_left')
      })
      .width(ComponentConfig.WH_100_100)
      .alignSelf(ItemAlign.Start);
    }
    .width(ComponentConfig.WH_100_100);
  }
}

/**
 * set up radio component
 */
@Component
struct RadioComponent {
  private radioItem: RadioListItem;
  private isChecked: boolean = false;
  private onChange?: () => void;
  private showRadio: boolean = true;

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      Row() {
        Image(this.radioItem.settingIcon)
          .width($r('app.float.audio_image_common_size'))
          .height($r('app.float.audio_image_common_size'))
          .margin({ right: $r('app.float.audio_image_margin_right') })
          .visibility(this.radioItem.settingIcon ? Visibility.Visible : Visibility.None)
          .objectFit(ImageFit.Contain);
        Column() {
          Text(this.radioItem.settingTitle)
            .fontColor($r('app.color.color_333333_grey'))
            .fontSize($r('app.float.control_common_font_size'))
            .textAlign(TextAlign.Start)
            .maxLines(ComponentConfig.MAX_LINES_3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: $r('app.float.audio_subtitle_margin_top'), bottom: $r('app.float.audio_subtitle_margin_bottom') });

          Text(this.radioItem.settingSummary)
            .fontColor($r('app.color.color_999999_grey'))
            .fontSize($r('app.float.audio_subtitle_font_size'))
            .textAlign(TextAlign.Start)
            .maxLines(ComponentConfig.MAX_LINES_1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .visibility(this.radioItem.settingSummary ? Visibility.Visible : Visibility.None)
            .margin({ bottom: $r('app.float.audio_summary_subtitle_margin_bottom') });
        }
        .margin({ left: $r('app.float.audio_title_summary_margin_left') })
        .alignItems(HorizontalAlign.Start);
      }
      .flexShrink(0)
      .alignItems(VerticalAlign.Center)
      .align(Alignment.Start);

      Row() {
        Radio( {value: this.radioItem.settingValue, group: ''} )
          .height($r('app.float.radio_component_height'))
          .margin({ right: $r('app.float.radio_component_margin_bottom_right') })
          .align(Alignment.End)
          .enabled(false)
          .checked(this.isChecked)
          .visibility(this.showRadio ? Visibility.Visible : Visibility.None)
      }
      .align(Alignment.End);
    }
    .margin({ left: $r('app.float.audio_margin_left') })
    .width(ComponentConfig.WH_100_100)
    .onClick(() => {
      LogUtil.info('settings RadioComponent : call onClick.')
      if (this.onChange) {
        this.onChange()
      }
    });
  }

}
