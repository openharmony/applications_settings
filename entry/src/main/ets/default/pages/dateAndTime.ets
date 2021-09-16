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
import HeadComponent from './component/headComponent.ets';
import EntryComponent from './component/entryComponent.ets';
import AboutDeviceModel from '../model/dateAndTimeImpl/DateAndTimeModel.ets'
import ConfigData from '../common/baseUtil/ConfigData.ets';
import DateAndTime from '../common/baseUtil/DateAndTimeUtil.ets';
import DateAndTimeModel from '../model/dateAndTimeImpl/DateAndTimeModel.ets'
import LogUtil from '../common/baseUtil/LogUtil.ets';

@Entry
@Component
struct dateAndTime {
  private arr: number[] = [1, 2];
  private date: string = '';
  private time: string = '';
  private image: string = '';
  private dateMark: string = 'date';
  private timeMark: string = 'time';
  private intervalFlag;
  private setTimeoutFlag;
  @State dateAndTimeList: any[] = [];
  timeDialogController : CustomDialogController = new CustomDialogController({
    builder: TimeDialog({action: this.onAccept}),
    cancel: this.existApp,
    autoCancel: true
  });
  dateDialogController : CustomDialogController = new CustomDialogController({
    builder: DateDialog({action: this.onAccept}),
    cancel: this.existApp,
    autoCancel: true
  });

  build() {
    Column() {
      HeadComponent({ headName: $r('app.string.dateAndTimeTab'), isActive: true })
      List() {
        ForEach(this.dateAndTimeList, (item) => {
          ListItem() {
            Row() {
              Text(item.settingTitle)
                .fontSize(ConfigData.font_22)
                .fontColor(ConfigData.color_333333)
                .width(ConfigData.WH_45_100)
                .textAlign(TextAlign.Start);
              Text(item.settingValue)
                .fontSize(ConfigData.font_22)
                .fontColor(ConfigData.color_999999)
                .width(ConfigData.WH_45_100)
                .textAlign(TextAlign.End);
              Image(item.settingArrow)
                .width(ConfigData.value_40)
                .height(ConfigData.value_40);
            }
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.value_80)
          .onClick(() => {
            LogUtil.info('dialog come in' + JSON.stringify(item))
              if (item.settingAlias === 'date') {
                LogUtil.info('date dialog come in')
                this.dateDialogController.open()
              }
              if (item.settingAlias === 'time') {
                LogUtil.info('time dialog come in')
                this.timeDialogController.open()
              }
          })
          .width(ConfigData.WH_100_100)
          .height(ConfigData.value_70);
        },item => JSON.stringify(item))
      }
      .divider({ strokeWidth: ConfigData.value_1, color: ConfigData.color_E3E3E3, startMargin: ConfigData.value_15, endMargin: ConfigData.value_15 })
      .width(ConfigData.WH_100_100)
      .height('100%')
      .margin({ left: ConfigData.value_15, right: ConfigData.value_15 })
      .align(Alignment.TopStart);
    }
  }

  onAccept() {
    console.log("onAccept");
  }
  existApp() {
    console.log("Cancel dialog!");
  }

  changeValue() {
    this.dateAndTimeList = [];
    this.dateAndTimeList.push(
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
    );

  }

  private aboutToAppear(): void {
    this.dateAndTimeList = AboutDeviceModel.dateAndTimeListener();
    this.image = this.dateAndTimeList[0].settingArrow;
    this.time = DateAndTime.getSystemTime();
    this.date = DateAndTime.getSystemDate();
    this.changeValue();
    this.getNowTime();
  }

  private getNowTime(): void {
    this.intervalFlag = setInterval(() => {
      console.log('get time come in');
      this.time = DateAndTime.getSystemTime();
      this.date = DateAndTime.getSystemDate();
      console.log('get time end in' + this.time);
      this.changeValue();
    },1000);
  }


  private aboutToDisappear(): void {
    clearInterval(this.intervalFlag);
  }

  onBackPress() {
    Navigator().active(true);
  }
}

@CustomDialog
@Component
struct TimeDialog {
  controller: CustomDialogController;
  action: () => void;
  private currentTime;
  private formatTime;

  build() {
    Column() {
      Column() {
        Text($r('app.string.time'))
          .height(60)
          .margin({left:30})
          .width('100%')
          .fontSize(28);
        DatePicker({selected: this.currentTime,type: DatePickerType.Time })
          .useMilitaryTime(true)
          .onChange((date: DatePickerResult)=>{
          this.currentTime = DateAndTime.fill(date.hour)  + ':' + DateAndTime.fill(date.minute)
          console.info("JDY::onchange " + this.currentTime);
        })
          .width('100%')
          .height(280)
      }
      Row() {
        Button('取消')
          .margin({left:80})
          .onClick(() => {
          this.controller.close();
          this.action();
        })
        Button('确定')
          .margin({left: 160})
          .onClick(() => {
          LogUtil.info("button confirm");
          let datetime = new Date();
          let y = datetime.getFullYear();
          let m = datetime.getMonth() + 1;
          let d = datetime.getDate();
          this.formatTime = y + '-' + DateAndTime.fill(m) + '-' + DateAndTime.fill(d)
          + 'T' + this.currentTime + ':' + '00';
          LogUtil.info("format time" + this.formatTime);
          let s = (new Date(this.formatTime)).getTime();
          LogUtil.info("change time second" + this.formatTime);
          DateAndTimeModel.setTime(s);
          this.controller.close();
          this.action();
        })
      }
      .width('100%')
      .height(60)
    }
    .height(400)
    .width('100%')
  }
}

@CustomDialog
@Component
struct DateDialog {
  controller: CustomDialogController;
  action: () => void;
  private currentDate;
  private formatDate;

  build() {
    Column() {
      Column() {
        Text($r('app.string.date'))
          .height(60)
          .margin({left:15})
          .width('100%')
          .fontSize(28)
        DatePicker({ start: new Date('2008-12-21'), end: new Date('2030-12-12'),
          selected: this.currentDate,type:  DatePickerType.Date})
          .onChange((date: DatePickerResult)=>{
          let datetime = new Date();
          let h = datetime.getHours();
          let min = datetime.getMinutes();
          let s = datetime.getSeconds();
          this.formatDate = date.year + '-' + DateAndTime.fill(date.month+1) + '-' + DateAndTime.fill(date.day) + 'T' +
          DateAndTime.fill(h) + ':' + DateAndTime.fill(min) + ':' + DateAndTime.fill(s);
          console.info("onchange " + this.formatDate);
        })
          .width('100%')
          .height(280);
      }
      Row() {
        Button('取消')
          .margin({left:80})
          .onClick(() => {
          this.controller.close();
          this.action();
        })
        Button('确定')
          .margin({left: 160})
          .onClick(() => {
          let s = (new Date(this.formatDate)).getTime();
          DateAndTimeModel.setTime(s);
          this.controller.close();
          this.action();
        })
      }
      .width('100%')
      .height(60);
    }
    .height(400)
    .width('100%');
  }
}




