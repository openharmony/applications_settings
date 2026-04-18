/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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

/* instrument ignore file */
import image from '@ohos.multimedia.image';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { ScreenWallpaperUtil } from '../utils/WallPaperUtil';
import { DeviceType } from '../utils/DeviceUtil';
import { DisplayConstants as Constants } from '../constant/DisplayConstant';
import { DragController, Point } from '../controller/DragController';
import { DeviceDisplayType, DeviceInfo, DevicesController } from '../controller/DevicesController';
import { RemoteDevicesController } from '../controller/RemoteDevicesController';
import { PADDING_8, PADDING_4 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';

@Observed
class ImageRadius {
  public topLeft: Length = 0;
  public topRight: Length = 0;
  public bottomLeft: Length = 0;
  public bottomRight: Length = 0;

  constructor(topLeft: Length, topRight: Length, bottomLeft: Length, bottomRight: Length) {
    this.topLeft = topLeft;
    this.topRight = topRight;
    this.bottomLeft = bottomLeft;
    this.bottomRight = bottomRight;
  }
}

const REFRESH_NUMBER: number = 1000;
const TAG = 'ImageDrag'
const ARROW_WIDTH = 12;

/*
  图片拖拽
 */
@Component
struct ImageDrag {
  private tempPositionsFlag: boolean = false;
  // 允许的误差
  private diff: number = Constants.DEFAULT_DIFF;
  @Prop isKeyMouseEntry: boolean = false;
  // 可拖拽领域四角坐标
  @State dragLeft: number = 0;
  @State dragTop: number = 0;
  @State dragRight: number = Constants.DEFAULT_DRAG_AREA_WIDTH;
  @State dragBottom: number = Constants.DEFAULT_DRAG_AREA_HEIGHT;
  // 方位信息
  @State positions: Point[] = [];
  // 图片显示标记
  @State visibilities: Visibility[] = [];
  // 悬浮窗显示标记
  @State handlePopup: boolean[] = [];
  private isHovering: boolean[] = [];
  // 当前拖拽图片index
  @State currentDragIndex: number = 0;
  @State isDrag: boolean = false;
  @State image: ResourceStr | PixelMap | null = '';
  @State lineVisibility: Visibility = Visibility.Visible;
  // 交界线坐标(是否保留存疑)
  @State lineStart: Point = new Point(0, 0, 0, 0, null);
  @State lineEnd: Point = new Point(0, 0, 0, 0, null);
  @State imageRadius: ImageRadius[] = [];
  // 设备顺序标记(非连接设备相关)
  @State deviceLocationOrder: number[] = [];
  @State refreshId: number = 0;
  // 拖拽处理器
  private dragController: DragController = DragController.getInstance();
  // 设备处理器
  private devicesController: DevicesController = DevicesController.getInstance();

  private onDragEndEvent: () => void = () => {};

  // 是否在误差范围内
  private withinTheDiff(num1: number, num2: number) {
    return Math.abs(num1 - num2) < this.diff;
  }

  // 初始化冒泡窗、图片显隐
  private initVisibility() {
    this.positions.forEach((item) => {
      this.visibilities.push(Visibility.Visible);
      this.handlePopup.push(false);
      this.isHovering.push(false);
    })
  }

  // 初始化控制器数据
  private initDragController(tempPositionsFlag: boolean = false) {
    LogUtil.info(`initDragController tempPositionsFlag: ${tempPositionsFlag}`);
    this.dragController.initPositions(tempPositionsFlag);
    this.positions = this.dragController.getPositions();
    LogUtil.info(`initDragController positions: ${this.positions.map((point) => [point.x, point.y])}`)
    this.initVisibility();
    this.dragController.setDragLeft(this.dragLeft);
    this.dragController.setDragRight(this.dragRight);
    this.dragController.setDragTop(this.dragTop);
    this.dragController.setDragBottom(this.dragBottom);
    // 强制方位限制
    this.dragController.dropping(this.positions[0], 0, 0, 0);
    // 吸附并居中
    this.dragController.snapping(this.currentDragIndex);
    this.dragController.snappingOthers();
    this.dragController.autoAlign();
    this.dragController.autoToCenter();
    this.dragController.getLinePoint();
    this.syncData();
  }

  private syncData() {
    this.lineStart = this.dragController?.getLineStart() as Point;
    this.lineEnd = this.dragController?.getLineEnd() as Point;
    this.positions = [];
    this.imageRadius = [];
    let temPositions: Point[] = this.dragController.getPositions();
    temPositions.forEach((point, index) => {
      this.imageRadius.push(new ImageRadius(
        this.topLeft(point),
        this.topRight(point),
        this.bottomLeft(point),
        this.bottomRight(point)
      ));
      this.positions.push(Point.createByPoint(point));
    });
    this.deviceLocationOrder = this.dragController?.getDeviceLocationOrder() as number[];
  }

  private imageDragReloadCurrentWallpaper = async () => {
    LogUtil.info(`ImageDrag: subscribe refresh current wallpaper`);
    this.image = await ScreenWallpaperUtil.getCurrentWallpaper();
    LogUtil.info(`ImageDrag: subscribe refresh current wallpaper end`);
  }

  private deviceInfoChangeCallback = (device: DeviceInfo) => {
    LogUtil.info(`eventbus deviceInfoChangePositions`);
    this.initDragController();
  }

  async aboutToAppear(): Promise<void> {
    LogUtil.info(`ImageDrag about to appear`);
    this.dragController.setHasDraggedState(false);
    this.initDragController(this.tempPositionsFlag);
    this.image = await ScreenWallpaperUtil.getCurrentWallpaper();
    EventBus.getInstance().on('deviceInfoChangePositions', this.deviceInfoChangeCallback);
    EventBus.getInstance().on('ReloadCurrentWallpaper', this.imageDragReloadCurrentWallpaper);
  }

  aboutToDisappear(): void {
    LogUtil.info(`Image drag disappear`)
    if (this.dragController.getHasDraggedState()) {
      this.dragController.setHasDraggedState(false);
      RemoteDevicesController.getInstance().getRemoteDeviceList();
    }
    EventBus.getInstance().detach('ReloadCurrentWallpaper', this.imageDragReloadCurrentWallpaper);
    EventBus.getInstance().detach('deviceInfoChangePositions', this.deviceInfoChangeCallback);
  }

  // 拖拽开始前数据处理
  private beforeDrag(index: number) {
    LogUtil.info(`current drag device: ${this.positions[index].deviceInfo?.key}`);
    this.isDrag = true;
    this.dragController.setHasDraggedState(true);
    this.currentDragIndex = index;
    this.refreshId++;
    if (this.refreshId > REFRESH_NUMBER) {
      this.refreshId = 0;
    }
  }

  // 放手处理
  private afterDrag(index: number) {
    LogUtil.info(`after drag, current device: ${this.positions[index].deviceInfo?.key}, this.isKeyMouseEntry = ${this.isKeyMouseEntry}`);
    if (this.isKeyMouseEntry) {
      this.dragController.setHasDraggedState(false);
    }
    this.visibilities[index] = Visibility.Visible;
    this.dragController?.afterDrag(index);
    this.syncData();
    this.onDragEndEvent();
    if (this.isKeyMouseEntry) {
      LogUtil.showInfo(TAG, `refresh positions start`);
      DragController.getInstance().setSettingsData();
      DragController.getInstance().multiPositionsRefresh();
      DragController.getInstance().setRemoteDevicePosition();
      LogUtil.showInfo(TAG, `refresh positions end`);
    }
    this.refreshId++;
    if (this.refreshId > REFRESH_NUMBER) {
      this.refreshId = 0;
    }
    setTimeout(() => {
      this.handlePopup.fill(false);
      this.isHovering.fill(false);
      this.isDrag = false;
      LogUtil.showInfo(TAG, `set this.isDrag false`);
    }, 100);
  }

  // 左上圆角处理
  private topLeft(item: Point): number | Resource {
    let topLeftFlag = this.withinTheDiff(this.lineStart.x, item.x) &&
    this.withinTheDiff(this.lineStart.y, item.y);
    LogUtil.info(`ComponentInfo item: ${item.deviceInfo?.key} | RADIUS topLeft flag: ${topLeftFlag}`);
    return topLeftFlag && !this.isDrag ? 0 : Constants.DEFAULT_BORDER_RADIUS;
  }

  // 右上圆角处理
  private topRight(item: Point): number | Resource {
    // 右上角为起点
    let topRightStartFlag = this.withinTheDiff(this.lineStart.x, item.right) &&
    this.withinTheDiff(this.lineStart.y, item.y);
    // 右上角为终点
    let topRightEndFlag = this.withinTheDiff(this.lineStart.x + this.lineEnd.x, item.right) &&
    this.withinTheDiff(this.lineStart.y + this.lineEnd.y, item.y);
    LogUtil.info(`ComponentInfo item: ${item.deviceInfo?.key} | RADIUS topRight
    topRightStartFlag: ${topRightStartFlag} | topRightEndFlag: ${topRightEndFlag}`);

    return (topRightStartFlag || topRightEndFlag) && !this.isDrag ? 0 : Constants.DEFAULT_BORDER_RADIUS;
  }

  // 左下圆角处理
  private bottomLeft(item: Point): number | Resource {
    // 左下角为起点
    let bottomLeftStartFlag = this.withinTheDiff(this.lineStart.y, item.bottom) &&
    this.withinTheDiff(this.lineStart.x, item.x);
    // 左下角为终点
    let bottomLeftEndFlag = this.withinTheDiff(this.lineStart.x + this.lineEnd.x, item.x) &&
    this.withinTheDiff(this.lineStart.y + this.lineEnd.y, item.bottom);
    LogUtil.info(`ComponentInfo item: ${item.deviceInfo?.key} | RADIUS bottomLeft
    bottomLeftStartFlag: ${bottomLeftStartFlag} |bottomLeftEndFlag: ${bottomLeftEndFlag}`);

    return (bottomLeftStartFlag || bottomLeftEndFlag) && !this.isDrag ? 0 : Constants.DEFAULT_BORDER_RADIUS;
  }

  // 右下圆角处理
  private bottomRight(item: Point): number | Resource {
    let bottomRightFlag = this.withinTheDiff(this.lineStart.x + this.lineEnd.x, item.right) &&
    this.withinTheDiff(this.lineStart.y + this.lineEnd.y, item.bottom);
    LogUtil.info(`ComponentInfo item: ${item.deviceInfo?.key} | RADIUS bottomRight flag: ${bottomRightFlag}`);

    return bottomRightFlag && !this.isDrag ? 0 : Constants.DEFAULT_BORDER_RADIUS;
  }

  private getMediaToPixelMap(resource: ResourceStr | image.PixelMap): image.PixelMap {
    let resourceManager = (AppStorage.get<Context>('pageContext') as Context)?.resourceManager;
    try {
      return resourceManager.getDrawableDescriptor((resource as Resource).id, 0, 1).getPixelMap();
    } catch (error) {
      return resource as image.PixelMap;
    }
  }

  @Builder
  foldableImageStack(item: Point, index: number) {
    Stack({ alignContent: Alignment.Center }) {
      Image(item.deviceInfo?.wallpaper ?? this.image)
        .id(`${item.deviceInfo?.key}_drag_image`)
        .align(Alignment.Start)
        .visibility(this.visibilities[index])
        .sourceSize(item.deviceInfo?.deviceType === DeviceDisplayType.OTHERS ?
          { width: Math.max(item.width, item.height), height: Math.max(item.width, item.height) } :
          { width: item.width, height: item.height })
        .objectFit(ImageFit.Cover)
        .draggable(false) // 不可拖拽
        .syncLoad(true)
        .border(this.isDrag && this.handlePopup[index] ?
          { width: Constants.DEFAULT_BORDER_WIDTH, color: $r('sys.color.interactive_focus') } :
          { width: 1, color: $r('sys.color.comp_divider') })
        .borderRadius(Constants.DEFAULT_BORDER_RADIUS)
      Line()
        .width(item.width)
        .height(Constants.DEFAULT_LINE_HEIGHT)
        .strokeWidth(Constants.DEFAULT_LINE_HEIGHT)
        .backgroundColor('#40FFFFFF')
    }
    .width(item.width)
    .height(item.height * 2)
    .padding({
      start: Constants.DRAG_IMAGE_SPACE,
      end: Constants.DRAG_IMAGE_SPACE,
      top: Constants.DRAG_IMAGE_SPACE,
      bottom: Constants.DRAG_IMAGE_SPACE
    })
    .gesture(
      GestureGroup(GestureMode.Sequence, LongPressGesture({ repeat: true, duration: 1 }), // 当长按手势识别
        PanGesture({ distance: 1 }) // 当长按之后进行拖动，PanGesture手势被触发
          .onActionStart(() => {
            this.beforeDrag(index);
          }) // 当该手势被触发时，根据回调获得拖动的距离，修改该组件的位移距离从而实现组件的移动
          .onActionUpdate((event: GestureEvent | undefined) => {
            if (event) { // 拖拽后对应的位置进行限制
              this.dragController?.dropping(item, event.offsetX, event.offsetY, this.currentDragIndex);
              this.syncData();
            }
          })
          .onActionEnd(() => {
            LogUtil.info(`pan up end event`);
            this.afterDrag(index);
          })
          .onActionCancel(() => {
            LogUtil.info(`drag cancle event`);
            this.afterDrag(index);
          })
      )
    )
    .onClick((event: ClickEvent) => {
      LogUtil.showInfo(TAG, `foldableImageStack onClick source = ${event.sourceTool}, index = ${index}`);
      let isShow: boolean = this.handlePopup[index];
      this.handlePopup.fill(false);
      this.handlePopup[index] = !isShow;
    })
    .focusable(false)
    .onHover((isHover) => {
      LogUtil.showInfo(TAG, `image isHover = ${isHover}, index = ${index}`);
      this.hoverStateChage(isHover, index);
    })
    .bindPopup((this.handlePopup[index] && !this.isDrag), {
      builder: this.hoverTips(item, index),
      showInSubWindow: true,
      placement: this.lineStart.y === item.y && this.lineEnd.y === 0 ? Placement.Left : Placement.Top,
      mask: false,
      transition: TransitionEffect.IDENTITY
    })
  }

  @Builder
  imageBuild(item: Point, index: number) {
    Stack({ alignContent: Alignment.Center }) {
      Image(item.deviceInfo?.wallpaper ?? this.image)
        .id(`${item.deviceInfo?.key}_drag_image`)
        .align(Alignment.Start)
        .visibility(this.visibilities[index])
        .sourceSize(item.deviceInfo?.deviceType === DeviceDisplayType.OTHERS ?
          { width: Math.max(item.width, item.height), height: Math.max(item.width, item.height) } :
          { width: item.width, height: item.height })
        .objectFit(ImageFit.Cover)
        .draggable(false) // 不可拖拽
        .syncLoad(true)
        .border(this.isDrag && this.handlePopup[index] ?
          { width: Constants.DEFAULT_BORDER_WIDTH, color: $r('sys.color.interactive_focus') } :
          { width: 1, color: $r('sys.color.comp_divider') })
        .borderRadius(Constants.DEFAULT_BORDER_RADIUS)
      Text(item.deviceInfo?.name)
        .backgroundColor('#1A000000')
        .wordBreak(WordBreak.BREAK_ALL)
        .borderRadius(4)
        .borderWidth(1)
        .borderColor('#1AFFFFFF')
        .fontColor('#FFFFFF')
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(item.deviceInfo?.deviceModel === DeviceType.TYPE_PHONE ? 2 : 1)
        .fontSize(item.deviceInfo?.deviceModel === DeviceType.TYPE_PHONE ? 9 : 12)
        .margin({
          left: 2,
          right: 2
        })
        .padding(2)
    }
    .width(item.width)
    .height(item.height)
    .padding({
      start: Constants.DRAG_IMAGE_SPACE,
      end: Constants.DRAG_IMAGE_SPACE,
      top: Constants.DRAG_IMAGE_SPACE,
      bottom: Constants.DRAG_IMAGE_SPACE
    })
    .gesture(
      GestureGroup(GestureMode.Sequence, LongPressGesture({ repeat: true, duration: 1 }), // 当长按手势识别
        PanGesture({ distance: 1 }) // 当长按之后进行拖动，PanGesture手势被触发
          .onActionStart(() => {
            this.beforeDrag(index);
          }) // 当该手势被触发时，根据回调获得拖动的距离，修改该组件的位移距离从而实现组件的移动
          .onActionUpdate((event: GestureEvent | undefined) => {
            if (event) { // 拖拽后对应的位置进行限制
              this.dragController?.dropping(item, event.offsetX, event.offsetY, this.currentDragIndex);
              this.syncData();
            }
          })
          .onActionEnd(() => {
            LogUtil.info(`pan up end event`);
            this.afterDrag(index);
          })
          .onActionCancel(() => {
            LogUtil.info(`drag cancle event`);
            this.afterDrag(index);
          })
      )
    )
    .onClick((event: ClickEvent) => {
      LogUtil.showInfo(TAG, `image onClick source = ${event.sourceTool}, index = ${index}`);
      let isShow: boolean = this.handlePopup[index];
      this.handlePopup.fill(false);
      this.handlePopup[index] = !isShow;
    })
    .focusable(false)
    .onHover((isHover) => {
      LogUtil.showInfo(TAG, `image isHover = ${isHover}, index = ${index}`);
      this.hoverStateChage(isHover, index);
    })
    .bindPopup((this.handlePopup[index] && !this.isDrag), {
      builder: this.hoverTips(item, index),
      showInSubWindow: true,
      placement: this.lineStart.y === item.y && this.lineEnd.y === 0 ? Placement.Left : Placement.Top,
      mask: false,
      arrowWidth: ARROW_WIDTH,
      transition: TransitionEffect.IDENTITY,
      focusable:(this.isKeyMouseEntry && item.deviceInfo?.deviceType === DeviceDisplayType.OTHERS) ? true : false
    })
  }

  hoverStateChage(isHover: boolean, index: number) {
    this.isHovering.fill(false);
    this.isHovering[index] = isHover;
    if (isHover) {
      this.handlePopup.fill(false);
      this.handlePopup[index] = isHover;
    } else {
      setTimeout(() => {
        if (this.isHovering[index]) {
          return;
        }
        this.handlePopup[index] = isHover;
      }, 200)
    }
  }

  @Builder
  hoverTips(item: Point, index: number) {
    Row() {
      Text(ResourceUtil.getStringSync(item.deviceInfo?.name))
        .fontWeight(FontWeight.Regular)
        .fontSize('14fp')
        .constraintSize({
          maxWidth: '80%'
        })
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
      if (this.isKeyMouseEntry && item.deviceInfo?.deviceType === DeviceDisplayType.OTHERS) {
        Button(){
          Text($r('app.string.location_set_tips_disconnect'))
            .fontColor('#E84026')
            .fontWeight(FontWeight.Regular)
            .fontSize('14fp')
        }
        .height(40)
        .stateEffect(true)
        .backgroundColor(Color.Transparent)
        .onClick((event: ClickEvent) => {
          LogUtil.showInfo(TAG, `click disconnect`);
          this.handlePopup.fill(false);
          RemoteDevicesController.getInstance().disconnectCurrentDevice(item.deviceInfo?.key);
        })
        .margin({ start: PADDING_8, end: PADDING_4})
      }
    }
    .padding({
      start: PADDING_8,
      end: PADDING_8,
      top: PADDING_8,
      bottom: PADDING_8
    })
    .onHover((isHover) => {
      this.isHovering.fill(false);
      this.isHovering[index] = isHover;
      if (isHover) {
        this.handlePopup[index] = isHover;
      } else {
        setTimeout(() => {
          if (this.isHovering[index]) {
            return;
          }
          this.handlePopup[index] = isHover;
        }, 200)
      }
      LogUtil.showInfo(TAG, `hoverTips isHover = ${isHover}`);
    })
  }

  @Builder
  positionBuild() {
    ForEach(this.positions, (item: Point, index) => {
      ListItem() {
        this.imageBuild(item, index);
      }
      .position({ x: item.x, y: item.y })
    })
  }

  build() {
    Column() {
      List() {
        this.positionBuild();
      }
      .focusable(false)
      .listDirection(Axis.Horizontal)
      .borderRadius($r('sys.float.corner_radius_level8'))
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .borderRadius($r('sys.float.corner_radius_level8'))
    .onSizeChange((oldSize, newSize) => {
      if (newSize.height === 0 || newSize.width === 0) {
        LogUtil.showError(TAG, `onSizeChange error newSize.width = ${newSize.width}, newSize.height = ${newSize.height}`);
        return;
      }
      if (this.tempPositionsFlag) {
        this.tempPositionsFlag = false;
      }
      this.dragController.saveTempPositions();
      this.dragRight = newSize.width as number;
      this.dragBottom = newSize.height as number;
      let zoomSize: number = newSize.width as number / Constants.DEFAULT_DIALOG_WIDTH;
      if (this.isKeyMouseEntry) {
        let zoomSizeHeight: number = newSize.height as number / Constants.DEFAULT_DRAG_AREA_HEIGHT;
        zoomSize = zoomSize > zoomSizeHeight ? zoomSizeHeight : zoomSize
      }
      this.dragController.setAreaZoom(zoomSize);
      this.initDragController(true);
      LogUtil.info(`dragRight:${this.dragRight} --- dragBottom:${this.dragBottom}, zoomSize = ${zoomSize}`);
    })
  }
}

export { ImageDrag };