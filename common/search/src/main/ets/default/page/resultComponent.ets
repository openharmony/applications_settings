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
import ResourceUtil from '../common/ResourceUtil';
import SearchData from '../model/SearchData';
import LogUtil from '../../../../../../utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../utils/src/main/ets/default/baseUtil/LogDecorator';
import ConfigData from '../../../../../../utils/src/main/ets/default/baseUtil/ConfigData';

/**
 * result component
 */
@Component
export default struct ResultComponent {
  private TEXT_TYPE_NORMAL = 1
  private TEXT_TYPE_KEYWORD = 2
  @Link highlightKeyword: string
  @State icon: string = ''
  @State data: SearchData = new SearchData()
  @State columnSpace: string = '2vp';

  @Builder HighlightText(
    spans: string[],
    fontColor: Color | Resource,
    fontSize: Resource,
    highlightFontColor: Color | Resource) {

    Text() {
      ForEach(spans.map((item1, index1) => {
        return { index: index1, data: item1 };
      }), item => {

        if (item.data.type == this.TEXT_TYPE_NORMAL) {
          Span(item.data.text).fontColor(fontColor).fontSize(fontSize).fontWeight(FontWeight.Medium)
        } else if (item.data.type == this.TEXT_TYPE_KEYWORD) {
          Span(item.data.text).fontColor(highlightFontColor).fontSize(fontSize).fontWeight(FontWeight.Regular)
        }
      },
        item => item.index)
    }
    .textAlign(TextAlign.Start)
    .maxLines(3)
    .textOverflow({ overflow: TextOverflow.Ellipsis })
  }

  build() {
    Row() {
      Image(this.icon)
        .width($r('app.float.item_icon_size'))
        .height($r('app.float.item_icon_size'))
        .margin({ right: $r('app.float.sys_elements_margin_horizontal_l') })
        .visibility(this.icon ? Visibility.Visible : Visibility.Hidden)
        .objectFit(ImageFit.Contain);

      Column({space: this.columnSpace}){
        this.HighlightText(
          this.splitToHighlightText(this.data.keyword),
          $r('app.color.search_result_text_color'),
          $r('app.float.search_result_item_title_font_size'),
          $r('app.color.search_result_text_color_highlight'),
        )

        if (this.data.summary) {
          this.HighlightText(
            this.splitToHighlightText(this.data.summary),
            $r('sys.color.ohos_id_color_text_secondary'),
            $r('app.float.search_result_item_summary_font_size'),
            $r('app.color.search_result_text_color_highlight'),
          )
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Image("/res/image/ic_settings_arrow.svg")
        .width($r('app.float.item_arrow_width'))
        .height($r('app.float.item_icon_size'))
        .margin({ left: $r('app.float.sys_elements_margin_horizontal_m') })
        .fillColor($r("sys.color.ohos_id_color_fourth"))
    }
    .padding({
      left: $r('sys.float.ohos_id_card_margin_start'),
      right: $r('sys.float.ohos_id_card_margin_end')
    })
    .flexShrink(0)
    .alignItems(VerticalAlign.Center)
    .align(Alignment.Start)
  }

  @Log
  aboutToAppear(){
    ResourceUtil.getString($r('app.float.distance_2')).then(value => this.columnSpace = value);
  }

  /**
   * split to highlight text
   * @param text
   */
  @Log
  splitToHighlightText(text: string): any[] {
    let spans: any[] = []

    var lowerSpans: string[] = text.toLowerCase().split(this.highlightKeyword.toLowerCase())
    var keywordStartIndex = 0
    var keywordLength = this.highlightKeyword.length

    for (var i = 0; i < lowerSpans.length; i++) {
      var normalText = text.substr(keywordStartIndex, lowerSpans[i].length)
      spans.push({
        type: this.TEXT_TYPE_NORMAL,
        text: normalText
      })
      LogUtil.debug(ConfigData.TAG + 'ResultComponent splitToHighlightText : i = [' + i + '] push normal : ' +
        JSON.stringify(normalText));

      // if not at last, append highlight keyword
      if (i != lowerSpans.length - 1) {
        keywordStartIndex += lowerSpans[i].length
        var keywordText = text.substr(keywordStartIndex, keywordLength)
        spans.push({
          type: this.TEXT_TYPE_KEYWORD,
          text: keywordText
        })
        LogUtil.debug(ConfigData.TAG + 'ResultComponent splitToHighlightText : i = [' + i + '] push keyword : ' +
          JSON.stringify(keywordText));
        keywordStartIndex += keywordLength
      }
    }

    return spans
  }
}