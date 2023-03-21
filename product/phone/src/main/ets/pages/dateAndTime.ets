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

import deviceInfo from '@ohos.deviceInfo';
import CommonEvent from '@ohos.commonEvent';
import DateAndTimeModel from '../model/dateAndTimeImpl/DateAndTimeModel';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { BaseData } from '../../../../../../common/utils/src/main/ets/default/bean/BaseData';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import ResourceUtil from '../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import DateAndTime from '../../../../../../common/utils/src/main/ets/default/baseUtil/DateAndTimeUtil';
import { DialogButtonLayout } from '../../../../../../common/component/src/main/ets/default/dialogComponent';
import { TextComponentWithEndText } from '../../../../../../common/component/src/main/ets/default/textComponent';

const MODULE_TAG = ConfigData.TAG + '.dateAndTime -> ';
const deviceTypeInfo = deviceInfo.deviceType;

/**
 * date and time
 */
@Entry
@Component
struct dateAndTime {
  @State dateAndTimeList: BaseData[] = [];
  private date: string = '';
  private time: Resource | string = '';
  private image: string | Resource = '';
  private dateMark: string = 'date';
  private timeMark: string = 'time';
  private subscriber;
  private headName: string = '';
  private commonEventSubscribeInfo = {
    events: [
      CommonEvent.Support.COMMON_EVENT_TIME_CHANGED,
      CommonEvent.Support.COMMON_EVENT_TIMEZONE_CHANGED,
      CommonEvent.Support.COMMON_EVENT_TIME_TICK,
      CommonEvent.Support.COMMON_EVENT_DATE_CHANGED,
    ]
  };

  timeDialogController: CustomDialogController = new CustomDialogController({
    builder: TimeDialog24H({ action: this.onAccept }),
    cancel: this.existApp,
    autoCancel: true,
    alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
    offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 }),
  });

  dateDialogController: CustomDialogController = new CustomDialogController({
    builder: DateDialog({ action: this.onAccept }),
    cancel: this.existApp,
    autoCancel: true,
    alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
    offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 }),
  });

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.dateAndTimeTab'), isActive: true });

          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            Text($r('app.string.timeFormat'))
              .fontSize($r('app.float.font_16'))
              .fontColor($r('app.color.font_color_182431'))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
              .margin({
                top: $r("app.float.wh_value_4"),
                bottom: $r("app.float.wh_value_4"),
                left: $r("app.float.wh_value_12")
              })

            Toggle({ type: ToggleType.Switch, isOn: this.is24hTimeFormat() })
              .margin({ right: $r('app.float.wh_value_6') })
              .width('36vp')
              .height('20vp')
              .selectedColor('#007DFF')
              .onChange((isOn: boolean) => {
                let timeFormat :boolean = this.is24hTimeFormat();
                LogUtil.info(MODULE_TAG + 'Toggle come onChange timeFormat ' + timeFormat);
                if (this.is24hTimeFormat()) {
                  this.setTimeFormatAs12H();
                } else {
                  this.setTimeFormatAs24H();
                }
                this.time = DateAndTime.getSystemTime(timeFormat);
                this.changeValue();
              });
          }
          .height($r('app.float.wh_value_56'))
          .width(ConfigData.WH_100_100)
          .backgroundColor($r("app.color.white_bg_color"))
          .margin({ bottom: $r("app.float.wh_value_12"), top: $r("app.float.distance_8") })
          .borderRadius($r('app.float.radius_24'));

          List() {
            ForEach(this.dateAndTimeList, (item) => {
              ListItem() {
                TextComponentWithEndText({ title: item.settingTitle, endText: item.settingValue, clickEvent: () => {
                  LogUtil.info(MODULE_TAG + 'dialog come in' + JSON.stringify(item));
                  if (item.settingAlias === 'date') {
                    LogUtil.info(MODULE_TAG + 'date dialog come in');
                    this.dateDialogController.open();
                  }
                  if (item.settingAlias === 'time') {
                    LogUtil.info(MODULE_TAG + 'time dialog come in');
                    this.timeDialogController.open();
                  }
                } });
              }
            }, item => JSON.stringify(item))
          }
          .padding($r('app.float.wh_value_4'))
          .divider({
            strokeWidth: $r('app.float.divider_wh'),
            color: $r('sys.color.ohos_id_color_list_separator'),
            startMargin: $r('app.float.wh_value_15'),
            endMargin: $r('app.float.wh_value_15')
          })
          .borderRadius($r("app.float.radius_24"))
          .backgroundColor($r("app.color.white_bg_color"))
          .visibility(this.dateAndTimeList.length > 0 ? Visibility.Visible : Visibility.None)
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        })
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }

  /**
   * Successfully built Dialog
   */
  onAccept() {
    LogUtil.info(MODULE_TAG + 'onAccept');
  }

  /**
   * Cancel Dialog
   */
  existApp() {
    LogUtil.info(MODULE_TAG + 'Cancel dialog!');
  }

  /**
   * modify date and time
   */
  changeValue() {
    this.dateAndTimeList = [
      {
        settingSummary: '',
        settingTitle: $r('app.string.date'),
        settingValue: this.date,
        settingAlias: this.dateMark,
        settingArrow: this.image,
      },
      {
        settingSummary: '',
        settingTitle: $r('app.string.time'),
        settingValue: this.time,
        settingAlias: this.timeMark,
        settingArrow: this.image,
      }
    ]
  }

  aboutToAppear(): void {
    this.image = "/res/image/ic_settings_arrow.svg";
    this.time = DateAndTime.getSystemTime(this.is24hTimeFormat());
    this.date = DateAndTime.getSystemDate();
    this.changeValue();
    this.getNowTime();
    DateAndTimeModel.registerObserver(this.getNowTime.bind(this));

    CommonEvent.createSubscriber(this.commonEventSubscribeInfo)
      .then(subscriber => {
        this.subscriber = subscriber;
        CommonEvent.subscribe(this.subscriber, (error, commonEventData) => {
          this.getNowTime();
          LogUtil.info(`${MODULE_TAG}, CommonEvent Subscribe callback in, error: ${error}, commonEventData: ${commonEventData}`);
        });
      });
  }

  /**
   * get current system time
   */
  private getNowTime(): void {
    LogUtil.info(MODULE_TAG + 'get time come in');
    this.time = DateAndTime.getSystemTime(this.is24hTimeFormat());
    this.date = DateAndTime.getSystemDate();
    LogUtil.info(MODULE_TAG + 'get time end in date=' + this.date);
    LogUtil.info(MODULE_TAG + 'get time end in time=' + this.time);
    this.changeValue();
  }

  aboutToDisappear(): void {
    CommonEvent.unsubscribe(this.subscriber, (error, commonEventData) => {
      LogUtil.info(`${MODULE_TAG}, CommonEvent unSubscribe callback in, error: ${error}, commonEventData: ${commonEventData}`);
      DateAndTimeModel.unregisterObserver();
    });
   
  }

  private setTimeFormatAs24H() {
    DateAndTimeModel.setTimeFormatAs24H();
  }

  private setTimeFormatAs12H() {
    DateAndTimeModel.setTimeFormatAs12H();
  }

  private is24hTimeFormat(): boolean {
    let result = DateAndTimeModel.getTimeFormat();
    if (result === ConfigData.TIME_FORMAT_24) {
      return true;
    }
    return false;
  }
}

/**
 * set time 24h format dialog
 */
@CustomDialog
@Component
struct TimeDialog24H {
  controller: CustomDialogController;
  action: () => void;
  private currentTime;
  private formatTime;

  build() {
    Column() {
      Column() {
        Text($r('app.string.settingTime'))
          .height($r('app.float.wh_value_56'))
          .width(ConfigData.WH_100_100)
          .textAlign(TextAlign.Center)
          .fontSize($r('app.float.font_20'))
          .fontColor($r("sys.color.ohos_id_color_primary"))
          .fontWeight(FontWeight.Medium);

        TimePicker({ selected: this.currentTime })
          .useMilitaryTime(this.isNeedMilitaryTime())
          .onChange((date: TimePickerResult) => {
            this.currentTime = DateAndTime.concatTime(date.hour, date.minute);
            LogUtil.info(MODULE_TAG + 'onchange currentTime' + this.currentTime);
          })
          .width(ConfigData.WH_100_100)
          .height($r('app.float.wh_value_200'))
      }
      .padding({ left: $r('sys.float.ohos_id_max_padding_start'), right: $r('app.float.wh_value_21') })

      DialogButtonLayout({
        firstClickEvent: () => {
          this.controller.close();
          this.action();
        },
        secondClickEvent: () => {
          LogUtil.info(MODULE_TAG + 'button confirm');
          let datetime = new Date();
          let y = datetime.getFullYear();
          let m = datetime.getMonth() + 1;
          let d = datetime.getDate();
          this.formatTime = y + '-' + DateAndTime.fill(m) + '-' + DateAndTime.fill(d)
          + 'T' + this.currentTime + ':' + '00';
          LogUtil.info(MODULE_TAG + 'onchange format time' + this.formatTime);
          let s = (new Date(this.formatTime)).getTime();
          LogUtil.info('onchange time second' + s);
          DateAndTimeModel.setTime(s);
          this.controller.close();
          this.action();
        }
      })
    }
    .width(ConfigData.WH_100_100)
  }

  private isNeedMilitaryTime(): boolean {
    let result = DateAndTimeModel.getTimeFormat();
    // 24h time format need using military time
    if (result === ConfigData.TIME_FORMAT_24) {
      return true;
    }
    return false;
  }
}

/**
 * set date dialog
 */
@CustomDialog
@Component
struct DateDialog {
  controller: CustomDialogController;
  action: () => void;
  private minDate: Date = new Date('1970-01-01');
  private maxDate: Date = new Date('2037-12-31');
  private selectedDate: Date = this.initValidDate();
  @State date: string = '';
  @State day: string = '';

  build() {
    Column() {
      Column() {
        Row() {
          Text(this.date)
            .fontSize($r('app.float.font_20'))
            .fontWeight(500)
            .fontColor($r("sys.color.ohos_id_color_primary"))

          Text(this.day)
            .fontSize($r('app.float.font_20'))
            .fontWeight(500)
            .fontColor($r("sys.color.ohos_id_color_primary"))
        }
        .height($r('app.float.wh_value_56'))

        DatePicker({ start: this.minDate, end: this.maxDate, selected: this.selectedDate })
          .onChange((result: DatePickerResult) => {
            let fmt = result.year + '-' + DateAndTime.fill(result.month + 1) + '-' + DateAndTime.fill(result.day);
            this.selectedDate = new Date(fmt);
            LogUtil.info(MODULE_TAG + 'onchange user select date fmt is : ' + fmt);
            LogUtil.info(MODULE_TAG + 'onchange user select date is :' + this.selectedDate);
            this.date = DateAndTime.concatDate(result.year, result.month + 1, result.day);
            let resource = DateAndTime.convert(result.year, result.month + 1, result.day);
            ResourceUtil.getString(resource).then(value => {
              this.day = value;
              LogUtil.info(MODULE_TAG + 'onchange refresh the show date is : ' + this.date);
              LogUtil.info(MODULE_TAG + 'onchange refresh the show day is : ' + this.day);
            });
          })
          .width(ConfigData.WH_100_100)
          .height($r('app.float.wh_value_200'))
          .padding({ right: $r('app.float.wh_37') })
      }
      .padding({ left: $r('app.float.wh_padding_32'), right: $r('app.float.wh_padding_33') })

      DialogButtonLayout({
        firstClickEvent: () => {
          this.controller.close();
          this.action();
        },
        secondClickEvent: () => {
          LogUtil.info(MODULE_TAG + 'start set date to : ' + this.selectedDate);
          let sysTime = new Date();
          let fmt = this.selectedDate.getFullYear() + '-' +
          DateAndTime.fill(this.selectedDate.getMonth() + 1) + '-' +
          DateAndTime.fill(this.selectedDate.getDate()) + 'T' +
          DateAndTime.fill(sysTime.getHours()) + ':' +
          DateAndTime.fill(sysTime.getMinutes()) + ':' +
          DateAndTime.fill(sysTime.getSeconds());
          LogUtil.info(MODULE_TAG + 'set date fmt is : ' + fmt);
          let s = (new Date(fmt)).getTime();
          DateAndTimeModel.setTime(s);
          this.controller.close();
          this.action();
        }
      })
    }
    .width(ConfigData.WH_100_100);
  }

  aboutToAppear() {
    let datetime = new Date();
    let y = datetime.getFullYear();
    let m = datetime.getMonth() + 1;
    let d = datetime.getDate();
    this.date = DateAndTime.getSystemDate();
    ResourceUtil.getString(DateAndTime.convert(y, m, d)).then(value => {
      this.day = value;
    });
  }

  private initValidDate() {
    let sysDate = new Date();
    let sysDateTime = sysDate.getTime();
    LogUtil.info(MODULE_TAG + 'init sysDate is :' + sysDateTime);
    if (sysDateTime < this.minDate.getTime()) {
      return this.minDate;
    }
    if (sysDateTime > this.maxDate.getTime()) {
      return this.maxDate;
    }
    return sysDate;
  }
}