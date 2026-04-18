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

import Settings from '@ohos.settings';
import screen from '@ohos.screen';
import window from '@ohos.window';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  DeviceDisplayType,
  DeviceInfo,
  DevicesController,
  DeviceUserType,
  USER_SET_DEVICE_MODE_EDID
} from './DevicesController';
import { RemoteDevicesController } from './RemoteDevicesController';
import { DisplayConstants } from '../constant/DisplayConstant';

/* instrument ignore file */
const DEFAULT_NUMBER: number = 0;
const MAX_LOCAL_DEVICE_COUNT: number = 2;
const DEVICE_POSITIONS: string = 'user_set_relative_position';
const DEFAULT_SNAP: number = 0.15;
const DEFAULT_ZOOM: number = 0.1;
const DEFAULT_DRAG_AREA_RIGHT: number = 11210;
const DEFAULT_DRAG_AREA_BOTTOM: number = 6475;
const SPACE_BETWEEN_DEVICES: number = 8;
const MAX_HEIGHT: number = 130.0;
const MAX_WIDTH: number = DisplayConstants.DEFAULT_DRAG_AREA_WIDTH;
const POINT_DATA_LEN: number = 3;
// 字串分割符
const DELIMITER: string = ';';
// 允许的交界坐标误差
const WITHIN_ERROR_RANGE: number = 0.1;
const FOLD_PC_PORTRAIT_ZOOM_SIZE = 1.6;

@Observed
export class Point extends Object {
  /** 最左坐标 */
  public x: number;
  /** 最上坐标 */
  public y: number;
  /** 宽度 */
  public width: number;
  /** 高度 */
  public height: number;
  /** 设备信息 */
  public deviceInfo: DeviceInfo | null;
  /** 最右坐标 */
  public right: number;
  /** 最下坐标 */
  public bottom: number;

  constructor(x: number, y: number, width: number, height: number, deviceInfo: DeviceInfo | null) {
    super()
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.deviceInfo = deviceInfo;
    this.right = this.x + width;
    this.bottom = this.y + height;
  }

  /**
   * 将设备信息存入相应点位
   *
   * @param device 设备信息
   * @param x 坐标X
   * @param y 坐标Y
   * @param zoom 缩放
   * @returns 点位信息对象
   */
  public static buildByDevice(device: DeviceInfo, x: number, y: number, zoom: number): Point {
    if (zoom <= 0) {
      zoom = DEFAULT_ZOOM;
    }
    let point = new Point(x, y, device.width * zoom, device.height * zoom, device);
    return point;
  }

  /**
   * 复制point创建新对象
   *
   * @param point
   * @returns
   */
  public static createByPoint(point: Point): Point {
    let newPoint = new Point(point.x, point.y, point.width, point.height, point.deviceInfo);
    return newPoint;
  }
}

const TAG = `DragController`;
const DOMAIN_NAME: string = Settings.domainName.USER_PROPERTY;

@Observed
export class DragController {
  private static controller: DragController;

  private devicesController: DevicesController = DevicesController.getInstance();
  // 最小吸附
  private snap: number = DEFAULT_SNAP;
  // 默认缩放
  private zoom: number = DEFAULT_ZOOM;
  // 区域变化缩放
  private areaZoom: number = 1;
  // 点位信息
  private positions: Point[] = [];
  // 拖拽领域限制
  private dragLeft: number = 0;
  private dragTop: number = 0;
  private dragRight: number = 0;
  private dragBottom: number = 0;
  // 交界线对应坐标
  private lineStart: Point = new Point(0, 0, 0, 0, null);
  private lineEnd: Point = new Point(0, 0, 0, 0, null);
  // 设备排列顺序
  private deviceLocationOrder: Array<number | string> = [];
  // 持久化方位信息
  private positionsDataList: string[] = [];
  // 临时方位信息
  private tempPositionsList: string[] = [];
  private isStartService: boolean = false;

  // 设备拖动过
  private hasDragged: boolean = false;

  public static getInstance(): DragController {
    if (!DragController.controller) {
      DragController.controller = new DragController();
    }
    return DragController.controller;
  }

  constructor() {
    this.initPositions();
    this.startService();
  }

  public startService() {
    if (!this.isStartService) {
      // 当监听到位置初始化事件时强制初始化位置信息
      EventBus.getInstance().on('positions_init', (refreshPositions: boolean = false) => {
        LogUtil.info(`change current mode and init positions`);
        this.initPositions();
        // 强制方位限制
        this.dropping(this.positions[0], 0, 0, 0);
        this.afterDrag(0);
        this.setSettingsData();
        if (refreshPositions) {
          this.multiPositionsRefresh();
        }
      });
      this.registerSplitScreenStatusListener();
      this.isStartService = true;
    }
  }

  public destroy(): void {
    LogUtil.info(`${TAG} destory`);
    EventBus.getInstance().off('positions_init');
    this.isStartService = false;
  }

  /**
   * 初始化点位信息列表
   * @param tempPositionsFlag 使用临时方位信息的标志
   */
  public initPositions(tempPositionsFlag: boolean = false): void {
    LogUtil.showInfo(TAG, `initPositions start`);
    this.positions = [];
    let devices = this.devicesController.getDevices();
    this.deviceLocationOrder = devices.map((item) => item.key);
    let extendDevice = devices.find((device) => device.deviceType !== DeviceDisplayType.BUILTIN &&
      device.deviceType !== DeviceDisplayType.OTHERS);
    let mainScreenIndex = devices.findIndex((d) =>
      (d.deviceUserFor === DeviceUserType.MAIN_SCREEN && extendDevice?.deviceUserFor !== DeviceUserType.ONLY_SCREEN) ||
        (d.deviceUserFor === DeviceUserType.ONLY_SCREEN)
    ) as number;
    if (mainScreenIndex === -1) {
      LogUtil.showError(TAG, `mainScreenIndex = -1; not found MAIN_SCREEN`);
      return;
    }
    this.initZoom();
    // 从数据库中获取保存的设备方位信息（后续可优化），未保存则使用默认布局
    this.positionsDataList = this.getPositionDataList();
    if (tempPositionsFlag) {
      this.positionsDataList = this.tempPositionsList;
      LogUtil.info(`${TAG} get temp positions: ${this.positionsDataList}`);
    }
    // 筛选非镜像非无线设备、仅第二屏下非内置屏设备
    let filterDevices = devices.filter((d) => d.deviceType !== DeviceDisplayType.OTHERS &&
      d.deviceUserFor !== DeviceUserType.MIRROR &&
      !(d.deviceType === DeviceDisplayType.BUILTIN && extendDevice?.deviceUserFor === DeviceUserType.ONLY_SCREEN));
    let newPointOfDevice = false;
    // 检查是否有未保存方位信息的设备
    filterDevices.forEach((d) => {
      let data = this.positionsDataList.find((data) => Number(data.split(' ')[0]) === d.key);
      if (!data) {
        newPointOfDevice = true;
        return;
      }
    });
    this.refreshAllPositionsData();
    // 初始化方位信息数组
    filterDevices.forEach((d, index) => {
      if (newPointOfDevice) { // 有未保存方位信息的设备，做方位初始化
        LogUtil.info(`init positions, new device, create default positions`);
        // 默认（0,0）布局
        let point = Point.buildByDevice(d, 0, 0, this.zoom) as Point;
        if (index !== 0) { // 外接显示器默认布局左侧靠主显示器
          point = Point.buildByDevice(d, filterDevices[index - 1].width * this.zoom, 0, this.zoom) as Point;
        }
        this.positions.push(point);
        let dataIndex = this.positionsDataList.findIndex((data) => Number(data.split(' ')[0]) === d.key);
        let data = `${d.key} ${point.x / this.zoom} ${point.y / this.zoom}`;
        if (dataIndex !== -1) {
          this.positionsDataList[dataIndex] = data;
        } else {
          this.positionsDataList.push(data);
        }
      } else { // 直接从数据库里获取数据
        let data = this.positionsDataList.find((data) => Number(data.split(' ')[0]) === d.key);
        LogUtil.info(`init positions, get data to create positions`);
        if (data) {
          let point = Point.buildByDevice(d,
            Number(data.split(' ')[1]) * this.zoom, Number(data.split(' ')[2]) * this.zoom, this.zoom);
          this.positions.push(point);
        }
      }
    })
    LogUtil.info(`${TAG} init positions`);
    RemoteDevicesController.getInstance().sendRefreshDevicePosition(this.positionsDataList);

    LogUtil.showInfo(TAG, `getOtherDeviceCount ${DevicesController.getInstance().getOtherDeviceCount()}`)
    if (DevicesController.getInstance().getOtherDeviceCount() >= 1) {
      this.initOtherOptions();
    }
  }

  /**
   * 将内屏位置设置为（0，0），其他设备位置跟随偏移
   */
  private refreshAllPositionsData() {
    let offSetX = 0;
    let offSetY = 0;
    let positionsData = this.positionsDataList.find((data) => Number(data.split(' ')[0]) === 0);
    // 获取内屏设置成（0，0）时偏移量
    if (positionsData) {
      let data = positionsData.split(' ');
      if (data.length >= POINT_DATA_LEN) {
        offSetX = 0 - Number(data[1]);
        offSetY = 0 - Number(data[2]);
      } else {
        LogUtil.error(`${TAG} data does not include position`)
      }
    }
    LogUtil.info(`${TAG} get main positions offset: ${offSetX} - ${offSetY}`);
    // 所有相对位置偏移
    this.positionsDataList.forEach((data, index) => {
      let dataStr = data.split(' ');
      if (dataStr.length >= POINT_DATA_LEN) {
        dataStr[1] = String((Number(dataStr[1]) + offSetX));
        dataStr[2] = String((Number(dataStr[2]) + offSetY));
      }
      this.positionsDataList[index] = `${dataStr[0]} ${dataStr[1]} ${dataStr[2]}`;
      LogUtil.info(`${TAG} position data refresh: ${this.positionsDataList[index]}`);
    });
    LogUtil.info(`${TAG} refresh all positions data end`);
  }

  private initOtherOptions(): void {
    // 获取键鼠locations
    let devices = this.devicesController.getDevices();
    // 初始化deviceLocationOrder列表
    LogUtil.info(`ImageDrag initOtherOptions`);
    // 排列列表中主机所在下标
    let mainIndex = this.deviceLocationOrder.findIndex((dlo) => dlo === 0);
    let mainPoint = this.positions.find((p) => p.deviceInfo?.deviceUserFor === DeviceUserType.MAIN_SCREEN ||
      p.deviceInfo?.deviceUserFor === DeviceUserType.ONLY_SCREEN);
    if (mainPoint === undefined) {
      LogUtil.showError(TAG, `mainPoint = undefined`);
      return;
    }
    let leftPW = this.dragRight;
    let rightPW = 0;
    this.positions.forEach((p) => {
      if (p.deviceInfo?.deviceType !== DeviceDisplayType.OTHERS) {
        leftPW = leftPW < p.x ? leftPW : p.x;
        rightPW = rightPW > p.right ? rightPW : p.right;
      }
      if (p.deviceInfo?.deviceUserFor === DeviceUserType.MAIN_SCREEN ||
        p.deviceInfo?.deviceUserFor === DeviceUserType.ONLY_SCREEN) {
        mainPoint = p;
      }
    });
    // 主机设备左侧开始初始化
    for (let i = mainIndex - 1; i >= 0; i--) {
      let device: DeviceInfo | undefined = devices.find((d) => d.key === this.deviceLocationOrder[i]);
      if (device && device.deviceUserFor === DeviceUserType.OTHERS) {
        let point =
          new Point(leftPW - device.width * this.zoom, mainPoint.y, device.width * this.zoom, device.height * this.zoom,
            device);
        this.positions.push(point);
        leftPW = point.x;
      }
    }
    // 主机设备右侧开始初始化
    for (let i = mainIndex + 1; i < devices.length; i++) {
      let device: DeviceInfo | undefined = devices.find((d) => d.key === this.deviceLocationOrder[i]);
      if (device && device.deviceUserFor === DeviceUserType.OTHERS) {
        let point = new Point(rightPW + device.width * this.zoom, mainPoint.y, device.width * this.zoom,
          device.height * this.zoom, device);
        this.positions.push(point);
        rightPW = point.right;
      }
    }
    this.positions.forEach((p) => {
      LogUtil.info(`ImageDrag point : ${p.deviceInfo?.key} - ${p.x} - ${p.y} - ${p.width} - ${p.height}`);
    });
  }

  /**
   * 初始化缩放比例
   */
  private initZoom() {
    // 实际分辨率映射到界面上的缩放比例
    this.zoom = DEFAULT_ZOOM;
    let maxHeight = 0;
    let maxWidth = 0;
    // 筛选设备最大分辨率高
    this.devicesController.getDevices().forEach((device) => {
      maxHeight = device.height > maxHeight ? device.height : maxHeight;
      maxWidth += device.width;
      if (device.deviceType === DeviceDisplayType.OTHERS) {
        maxWidth += MAX_WIDTH;
      }
    });
    if (maxHeight !== 0) {
      let heightZoom = MAX_HEIGHT / maxHeight;
      let widthZoom = MAX_WIDTH / maxWidth;
      this.zoom = Math.min(heightZoom, widthZoom);
    }
    LogUtil.info(`refresh device data zoom: ${this.zoom}`);
    let tempZoom = this.areaZoom;
    if (this.devicesController.isFoldPcAndPortrait()) {
      tempZoom = this.areaZoom * FOLD_PC_PORTRAIT_ZOOM_SIZE;
    }
    this.zoom = this.zoom * tempZoom;
    LogUtil.info(`refresh device data zoom after multiply by areaZoom: ${this.zoom}`);
  }

  /**
   * 图片界面居中
   */
  public autoToCenter(): void {
    // 组件中心点 在组件中的坐标
    let centerPointX = (this.dragRight - this.dragLeft) / 2;
    let centerPointY = (this.dragBottom - this.dragTop) / 2;

    // 整体图片的 四周坐标
    let imagePointLeft = DEFAULT_DRAG_AREA_RIGHT;
    let imagePointRight = DEFAULT_NUMBER;
    let imagePointTop = DEFAULT_DRAG_AREA_BOTTOM;
    let imagePointBottom = DEFAULT_NUMBER;
    this.positions.forEach((point) => {
      imagePointLeft = Math.min(point.x, imagePointLeft);
      imagePointRight = Math.max(point.right, imagePointRight);
      imagePointTop = Math.min(point.y, imagePointTop);
      imagePointBottom = Math.max(point.bottom, imagePointBottom);
    })

    // 图片整体的中心点
    let imageCenterX = (imagePointLeft + imagePointRight) / 2;
    let imageCenterY = (imagePointTop + imagePointBottom) / 2;

    // 中心点差值
    let differX = centerPointX - imageCenterX;
    let differY = centerPointY - imageCenterY;

    for (let index = 0; index < this.positions.length; index++) {
      let temp = this.positions[index];
      this.positions[index] =
        new Point(temp.x + differX, temp.y + differY, temp.width, temp.height, temp.deviceInfo);
    }
  }

  /**
   * 其他设备与内置显示器底部横向对齐
   */
  public autoAlign(): void {
    let mainPoint = this.positions.find((p) => {
      return p.deviceInfo?.deviceUserFor === DeviceUserType.MAIN_SCREEN ||
        p.deviceInfo?.deviceUserFor === DeviceUserType.ONLY_SCREEN;
    })
    for (let index = 0; index < this.positions.length; index++) {
      if (this.positions[index].deviceInfo?.deviceType === DeviceDisplayType.OTHERS) {
        this.positions[index] = new Point(
          this.positions[index].x,
          mainPoint?.bottom as number - this.positions[index].height,
          this.positions[index].width,
          this.positions[index].height,
          this.positions[index].deviceInfo
        );
      }
    }
  }

  /**
   * 判断两点位是否相交
   * @param p1 图片1点位信息
   * @param p2 图片2点位信息
   * @returns ture=相交 false=不相交
   */
  public isCrossing(p1: Point, p2: Point): boolean {
    if (!p1 || !p2) { // 点位不存在则不相交
      LogUtil.error(`point is null`);
      return false;
    }
    let overLeftOrRight: boolean = false;
    let overOverOrUp: boolean = false;
    // 两点位左右相交
    if (p1.x < p2.right && p1.x >= p2.x || (p2.x < p1.right && p2.x >= p1.x)) {
      overLeftOrRight = true;
    }
    // 两点位上下相交
    if (p1.y < p2.bottom && p1.y >= p2.y || (p2.y < p1.bottom && p2.y >= p1.y)) {
      overOverOrUp = true;
    }
    // 相交时必定是左右相交和上下相交同时存在
    return (overLeftOrRight && overOverOrUp);
  }

  /**
   * 获取交界线起始点坐标
   */
  public getLinePoint(): void {
    if (this.positions.length <= 1) { // 点位不足形成交界
      return;
    }
    let point1 = this.positions[0];
    let point2 = this.positions[1];
    if (point1.deviceInfo?.deviceType === DeviceDisplayType.OTHERS ||
      point2.deviceInfo?.deviceType === DeviceDisplayType.OTHERS) { // 其他设备与主机不交界
      return;
    }
    if (point1.x === point2.right || point1.right === point2.x) { // 左右交界，交界线为竖直方向，x坐标一致
      this.lineStart.x = point1.x === point2.right ? point1.x : point2.x;
      this.lineEnd.x = 0;
      let lineArr: number[] = [point1.y, point1.bottom, point2.y, point2.bottom];
      lineArr.sort((a, b) => {
        return a - b;
      });
      this.lineStart.y = lineArr[1];
      this.lineEnd.y = lineArr[2] - lineArr[1];
    } else if (this.isEqualWithinTheDiff(point1.y, point2.bottom) ||
      this.isEqualWithinTheDiff(point1.bottom, point2.y)) {
      // 上下交界，交界线为水平方向，y坐标一致
      this.lineStart.y = this.isEqualWithinTheDiff(point1.y, point2.bottom) ? point1.y : point2.y;
      this.lineEnd.y = 0;
      let lineArr: number[] = [point1.x, point1.right, point2.x, point2.right];
      lineArr.sort((a, b) => {
        return a - b;
      });
      this.lineStart.x = lineArr[1];
      this.lineEnd.x = lineArr[2] - lineArr[1];
    } else {
      this.lineStart.x = this.lineStart.y = this.lineEnd.x = this.lineEnd.y = 0;
    }
    this.lineStart = new Point(this.lineStart.x, this.lineStart.y, this.lineStart.width, this.lineStart.height, null);
    LogUtil.info(`ComponentInfo lineStart : ${this.lineStart.x} - ${this.lineStart.y}`);
    this.lineEnd = new Point(this.lineEnd.x, this.lineEnd.y, this.lineEnd.width, this.lineEnd.height, null);
    LogUtil.info(`ComponentInfo lineEnd : ${this.lineEnd.x} - ${this.lineEnd.y}`);
  }

  /**
   * 主机设备吸附
   * @param currentDragIndex 当前拖拽设备对应点位数组下标
   */
  public snapping(currentDragIndex: number): void {
    if (currentDragIndex < MAX_LOCAL_DEVICE_COUNT && currentDragIndex >= 0 &&
      this.positions.length > currentDragIndex) {
      // 当前仅考虑两屏
      let point1 = this.positions[currentDragIndex];
      let point2 = this.positions[(currentDragIndex + 1) % 2];

      if (!point2) {
        LogUtil.error(`target device is not exist`);
        return;
      }

      let snapWidth = Math.min(point1.width, point2.width) * this.snap;
      let snapHeight = Math.min(point1.height, point2.height) * this.snap;
      // 左右交界时
      if (point1.x === point2.right || point1.x === point2.x - point1.width) {
        // 上下差值小于最小边15%
        if (Math.abs(point1.y - point2.bottom) < snapHeight) {
          point1.y = point2.bottom - snapHeight;
        } else if (point1.y >= point2.bottom) {
          point1.y = point2.bottom;
        } else if (Math.abs(point1.bottom - point2.y) < snapHeight) {
          point1.y = point2.y - point1.height + snapHeight;
        } else if (point1.bottom <= point2.y) {
          point1.y = point2.y - point1.height;
        }
      } else if (point1.y === point2.bottom || point1.y === point2.y - point1.height) { // 上下交界时
        // 左右差值小于最小边15%
        if (Math.abs(point1.x - point2.right) < snapWidth) {
          point1.x = point2.right - snapWidth;
        } else if (point1.x >= point2.right) {
          point1.x = point2.right;
        } else if (Math.abs(point1.right - point2.x) < snapWidth) {
          point1.x = point2.x - point1.width + snapWidth;
        } else if (point1.right <= point2.x) {
          point1.x = point2.x - point1.width;
        }
      }

      this.positions[currentDragIndex] =
        new Point(point1.x, point1.y, point1.width, point1.height, point1.deviceInfo);
    }
  }

  /**
   * 其他设备吸附(以本机为中心吸附)
   */
  public snappingOthers(): void {
    let localDeviceIndex = -1;
    for (let index = 0; index < this.deviceLocationOrder.length; index++) {
      let point = this.positions.find((p) => p.deviceInfo?.key === this.deviceLocationOrder[index]);
      if (point?.deviceInfo?.deviceType !== DeviceDisplayType.OTHERS) {
        localDeviceIndex = index;
        break;
      }
    }
    if (localDeviceIndex !== -1) {
      // 距离本机位置近的先吸附
      for (let i = localDeviceIndex - 1; i >= 0; i--) {
        let index = this.positions.findIndex((p) => p.deviceInfo?.key === this.deviceLocationOrder[i]);
        if (this.positions[index]?.deviceInfo?.deviceType === DeviceDisplayType.OTHERS) {
          this.snapOthers(index);
        }
      }
      for (let i = localDeviceIndex + 1; i < this.deviceLocationOrder.length; i++) {
        let index = this.positions.findIndex((p) => p.deviceInfo?.key === this.deviceLocationOrder[i]);
        if (this.positions[index]?.deviceInfo?.deviceType === DeviceDisplayType.OTHERS) {
          this.snapOthers(index);
        }
      }
    } else {
      LogUtil.error(`local device is not exist`);
    }
  }

  /**
   * 其他设备向本机吸附(只限制X轴)
   * @param index 点位吸附的其他设备对应下标
   */
  public snapOthers(index: number): void {
    if (index < 0 || index >= this.positions.length) {
      return;
    }
    let item = this.positions[index];
    let leftP = this.dragRight;
    let rightP = DEFAULT_NUMBER;
    let itemIndex = this.deviceLocationOrder.findIndex((location) => item.deviceInfo?.key === location);
    let localDeviceStartIndex = -1;
    for (let index = 0; index < this.deviceLocationOrder.length; index++) {
      let point = this.positions.find((p) => p.deviceInfo?.key === this.deviceLocationOrder[index]);
      if (point?.deviceInfo?.deviceType !== DeviceDisplayType.OTHERS) {
        localDeviceStartIndex = index;
        break;
      }
    }
    let start = itemIndex > localDeviceStartIndex ? 0 : itemIndex + 1;
    let end = itemIndex > localDeviceStartIndex ? itemIndex : this.deviceLocationOrder.length;
    for (let index = start; index < end; index++) {
      let point = this.positions.find((p) => p.deviceInfo?.key === this.deviceLocationOrder[index]);
      if (point) {
        leftP = Math.min(leftP, Number(point?.x));
        rightP = Math.max(rightP, Number(point?.right));
      }
    }
    let centerItem = (item.x + item.right) / 2;
    let centerP = (leftP + rightP) / 2;
    item.x = centerItem < centerP ? leftP - SPACE_BETWEEN_DEVICES - item.width : rightP + SPACE_BETWEEN_DEVICES;
    LogUtil.info(`ImageDrag point item ${item.deviceInfo?.key} left : ${leftP} | right : ${rightP}`);
    this.positions[index] = Point.createByPoint(item) as Point;
  }

  /**
   * 根据当前图片位置,对设备进行排序
   */
  public sortDeviceOrder(): void {
    let center: string[] = [];
    let displayDevice: (Point | number | string)[] = [];
    // 对显示器和键鼠设备进行分类，并保存键鼠设备中心点位置
    for (let deviceKey of this.deviceLocationOrder) {
      let device1 = this.positions.find((p) => p.deviceInfo?.key === deviceKey) as Point;
      if (!device1?.deviceInfo) {
        displayDevice.push(deviceKey);
        continue;
      }
      if (device1.deviceInfo.deviceUserFor !== DeviceUserType.OTHERS) {
        displayDevice.push(device1);
      } else {
        let device1CenterX = (Number(device1.x) + Number(device1.right)) / 2;
        center.push(deviceKey + '-' + device1CenterX);
      }
    }
    let minX: number = Number.MAX_VALUE;
    let maxRight: number = Number.MIN_VALUE;
    // 获取显示器中心点坐标，并保存
    for (let device of displayDevice) {
      if (typeof device !== 'object') {
        continue;
      }
      minX = Math.min(device.x, minX);
      maxRight = Math.max(device.right, maxRight);
    }
    center.push(`0-${(minX + maxRight) / 2}`);
    // 按照中心点对显示器排序
    displayDevice.sort((d1, d2) => {
      if (typeof d1 !== 'object' || typeof d2 !== 'object') {
        return 1;
      }
      let device1CenterX = (Number(d1.x) + Number(d1.right)) / 2;
      let device2CenterX = (Number(d2.x) + Number(d2.right)) / 2;
      return device1CenterX - device2CenterX;
    });
    // 对所有设备排序
    center.sort((c1, c2) => {
      let key1: string[] = c1.split('-');
      let key2: string[] = c2.split('-');
      return Number(key1[1]) - Number(key2[1]);
    });
    this.deviceLocationOrder = this.sortOrder(center, displayDevice);
  }

  public sortOrder(center: string[], displayDevice: (Point | number | string)[]): (number | string)[] {
    let tempOrder: (number | string)[] = [];
    for (let element of center) {
      let key1: string[] = element.split('-');
      if (key1[0] !== '0') {
        tempOrder.push(key1[0]);
        continue;
      }
      for (let element of displayDevice) {
        let content = typeof element !== 'object' ? element : (element.deviceInfo?.key ?? 0);
        tempOrder.push(content);
      }
    }
    return tempOrder;
  }

  /**
   * 当前拖拽设备对其他设备位置的特殊处理
   * @param item 当前拖拽设备点位信息
   */
  public crossingOthersHandle(item: Point): void {
    if (!item) {
      return;
    }
    if (item.deviceInfo?.deviceType !== DeviceDisplayType.OTHERS) { // 本机处理
      this.snappingOthers();
    } else {
      let locationIndex = this.deviceLocationOrder.findIndex((d) => d === item.deviceInfo?.key);
      if (locationIndex !== 0 && locationIndex !== this.deviceLocationOrder.length - 1) {
        let device1 = this.positions.find((p) => p.deviceInfo?.key === this.deviceLocationOrder[locationIndex - 1]);
        let device2 = this.positions.find((p) => p.deviceInfo?.key === this.deviceLocationOrder[locationIndex + 1]);
        if (device1?.deviceInfo?.deviceType !== DeviceDisplayType.OTHERS &&
          device2?.deviceInfo?.deviceType !== DeviceDisplayType.OTHERS) { // 其他设备不会出现在本机设备之间
          let temp = this.deviceLocationOrder[locationIndex - 1];
          this.deviceLocationOrder[locationIndex - 1] = this.deviceLocationOrder[locationIndex];
          this.deviceLocationOrder[locationIndex] = temp;
        }
      }
    }
    this.sortDeviceOrder();
  }

  /**
   * 主机拖拽限制拖拽范围
   * @param item 当前拖拽点位信息
   * @param offsetX X偏移量
   * @param offsetY Y偏移量
   * @param currentDragIndex 拖拽设备对应下标
   */
  private dropRestrictions(item: Point, offsetX: number, offsetY: number, currentDragIndex: number): void {
    if (currentDragIndex >= this.positions.length || currentDragIndex < 0 ||
      currentDragIndex >= MAX_LOCAL_DEVICE_COUNT) {
      LogUtil.error(`DropRestrictions: grag index error`);
      return;
    }
    let p2 = this.positions[(currentDragIndex + 1) % 2];
    if (!p2) {
      LogUtil.error(`DropRestrictions: other local device is not exist`);
      return;
    }
    // 确保限制范围对标设备不为其他设备
    if (p2.deviceInfo?.deviceType !== DeviceDisplayType.OTHERS) {
      if (offsetX >= p2.right) {
        offsetX = p2.right;
      } else if (offsetX <= p2.x - item.width) {
        offsetX = p2.x - item.width;
      }
      if (offsetY >= p2.bottom) {
        offsetY = p2.bottom;
      } else if (offsetY <= p2.y - item.height) {
        offsetY = p2.y - item.height;
      }
      let p1 = new Point(offsetX, offsetY, item.width, item.height, item.deviceInfo);
      this.positions[currentDragIndex] = this.snapCrossing(p1, p2);
    } else {
      this.positions[currentDragIndex] = new Point(item.x, item.y, item.width, item.height, item.deviceInfo);
    }
  }

  /**
   * 可折叠主机拖拽限制拖拽范围
   * @param item 当前拖拽点位信息
   * @param offsetX X偏移量
   * @param offsetY Y偏移量
   * @param currentDragIndex 拖拽设备对应下标
   */
  private foldableDropRestrictions(item: Point, offsetX: number, offsetY: number, currentDragIndex: number): void {
    if (currentDragIndex >= this.positions.length || currentDragIndex < 0 ||
      currentDragIndex >= MAX_LOCAL_DEVICE_COUNT) {
      LogUtil.error(`FoldableDropRestrictions: grag index error`);
      return;
    }
    let p2 = this.positions[(currentDragIndex + 1) % 2];
    if (!p2) {
      LogUtil.error(`FoldableDropRestrictions: other local device is not exist`);
      return;
    }
    // 确保限制范围对标设备不为其他设备
    if (p2.deviceInfo?.deviceType !== DeviceDisplayType.OTHERS) {
      if (offsetX >= p2.right) {
        offsetX = p2.right;
      } else if (offsetX <= p2.x - item.width) {
        offsetX = p2.x - item.width;
      } else {
        offsetX = offsetX;
      }
      if (item.deviceInfo?.deviceType === DeviceDisplayType.BUILTIN) {
        if (offsetY >= p2.bottom) {
          offsetY = p2.bottom;
        } else if (offsetY <= p2.y - item.height) {
          offsetY = p2.y - item.height;
        }
        let point1 = new Point(offsetX, offsetY, item.width, item.height + p2.height, item.deviceInfo);
        let point2 = p2;
        if (this.isCrossing(point1, point2) || this.isCrossing(point2, point1)) {
          let p2CenterX = (p2.x + p2.right) / 2;
          offsetX = offsetX >= p2CenterX ? p2.right : p2.x - item.width;
        }
      } else {
        if (offsetY >= p2.bottom) {
          offsetY = p2.bottom;
        } else if (offsetY <= p2.y - item.height) {
          offsetY = p2.y - item.height;
        }
        let point1 = new Point(offsetX, offsetY, item.width, item.height, item.deviceInfo);
        let point2 = new Point(p2.x, p2.bottom, p2.width, item.height, p2.deviceInfo);
        if (this.isCrossing(point1, point2) || this.isCrossing(point2, point1)) {
          let p2CenterX = (p2.x + p2.right) / 2;
          offsetX = offsetX >= p2CenterX ? p2.right : p2.x - item.width;
        }
      }
      let p1 = new Point(offsetX, offsetY, item.width, item.height, item.deviceInfo);
      this.positions[currentDragIndex] = this.snapCrossing(p1, p2);
    } else {
      this.positions[currentDragIndex] = new Point(item.x, item.y, item.width, item.height, item.deviceInfo);
    }
  }

  /**
   * 拖拽过程限制
   * @param item 当前拖拽点位信息
   * @param x X偏移量
   * @param y Y偏移量
   * @param currentDragIndex 拖拽设备对应下标
   */
  public dropping(item: Point, x: number, y: number, currentDragIndex: number): void {
    if (!item) {
      LogUtil.error(`dropping item is undefinded`);
      return;
    }
    if (currentDragIndex >= 0 && this.positions.length > currentDragIndex) {
      let offsetX = item.x + x;
      let offsetY = item.y + y;
      if (item.deviceInfo?.deviceType !== DeviceDisplayType.OTHERS) {
        this.devicesController.isFoldablePC() ?
        this.foldableDropRestrictions(item, offsetX, offsetY, currentDragIndex) :
        this.dropRestrictions(item, offsetX, offsetY, currentDragIndex);
        this.crossingOthersHandle(this.positions[currentDragIndex]);
      } else { // 其他设备Y轴限制
        offsetY = item.y;
        let p1 = new Point(offsetX, offsetY, item.width, item.height, item.deviceInfo);
        this.positions[currentDragIndex] = p1;
        this.crossingOthersHandle(this.positions[currentDragIndex]);
      }
    }
  }

  /**
   * 相交情况下方位更新
   *
   * @param point1 拖拽主体的点位信息
   * @param point2 客体的点位信息
   * @returns 主体新的点位信息
   */
  public snapCrossing(point1: Point, point2: Point): Point {
    if (!point1 || !point2) {
      LogUtil.error(`crossing point is null`);
      return new Point(0, 0, 0, 0, null);
    }
    if (this.isCrossing(point1, point2) || this.isCrossing(point2, point1)) { // 方位相交，处理p1应该出现的方位
      // p1、p2中心点位置
      let p1CenterX = (point1.x + point1.right) / 2;
      let p1CenterY = (point1.y + point1.bottom) / 2;
      let p2CenterX = (point2.x + point2.right) / 2;
      let p2CenterY = (point2.y + point2.bottom) / 2;
      //可折叠设备本机判断标志
      let builtinFlag = this.devicesController.isFoldablePC() &&
        point1.deviceInfo?.deviceType === DeviceDisplayType.BUILTIN;
      //可折叠设备非本机判断标志
      let notBuiltinFlag = this.devicesController.isFoldablePC() &&
        point1.deviceInfo?.deviceType !== DeviceDisplayType.BUILTIN;
      // 判断p1中心点与p2中心点的位置关系
      if (p1CenterX >= point2.right) { // p1在矩形外侧
        point1 = new Point(point2.right, point1.y, point1.width, point1.height, point1.deviceInfo);
      } else if (p1CenterX <= point2.x) {
        point1 = new Point(point2.x - point1.width, point1.y, point1.width, point1.height, point1.deviceInfo);
      } else if (p1CenterY >= point2.bottom) {
        point1 = new Point(point1.x, point2.bottom, point1.width, point1.height, point1.deviceInfo);
      } else if (p1CenterY <= point2.y) {
        point1 = builtinFlag ? new Point(point1.x, point2.bottom, point1.width, point1.height, point1.deviceInfo) :
          new Point(point1.x, point2.y - point1.height, point1.width, point1.height, point1.deviceInfo);
      } else { // p1在矩形内测
        if (p1CenterX - p2CenterX === 0) {
          if (p1CenterY >= p2CenterY) { // p1靠p2上侧
            point1 = builtinFlag ? new Point(point1.x, point2.bottom, point1.width, point1.height, point1.deviceInfo) :
              new Point(point1.x, point2.y - point1.height, point1.width, point1.height, point1.deviceInfo);
          } else { // p1靠p2下侧
            point1 = notBuiltinFlag ?
              new Point(point1.x, point2.y - point1.height, point1.width, point1.height, point1.deviceInfo) :
              new Point(point1.x, point2.bottom, point1.width, point1.height, point1.deviceInfo);
          }
        } else { // 将p2对角线分成4份，判断中心点位置，默认往左上靠
          // 中心点到左上角斜率
          let p2ToTopLeft = (p2CenterY - point2.y) / (p2CenterX - point2.x);
          // 中心点到右上角斜率
          let p2ToTopRight = (p2CenterY - point2.y) / (p2CenterX - point2.right);
          // P1中心到左上角斜率
          let p1ToTopLeft = (p1CenterY - point2.y) / (p1CenterX - point2.x);
          // P1中心点到右上角斜率
          let p1ToTopRight = (p1CenterY - point2.y) / (p1CenterX - point2.right);
          if (p1ToTopLeft >= p2ToTopLeft && p1ToTopRight >= p2ToTopRight) { // P1靠P2左侧
            point1 = new Point(point2.x - point1.width, point1.y, point1.width, point1.height, point1.deviceInfo);
          } else if (p1ToTopLeft >= p2ToTopLeft && p1ToTopRight < p2ToTopRight) { // P1靠P2下侧
            point1 = notBuiltinFlag ?
              new Point(point1.x, point2.y - point1.height, point1.width, point1.height, point1.deviceInfo) :
              new Point(point1.x, point2.bottom, point1.width, point1.height, point1.deviceInfo);
          } else if (p1ToTopLeft < p2ToTopLeft && p1ToTopRight >= p2ToTopRight) { // P1靠P2上侧
            point1 = builtinFlag ?
              new Point(point1.x, point2.bottom, point1.width, point1.height, point1.deviceInfo) :
              new Point(point1.x, point2.y - point1.height, point1.width, point1.height, point1.deviceInfo);
          } else { // P1靠P2右侧
            point1 = new Point(point2.right, point1.y, point1.width, point1.height, point1.deviceInfo);
          }
        }
      }
    }
    return point1;
  }

  /**
   * 放手处理
   * @param index 放手设备下标
   */
  public afterDrag(index: number): void {
    if (this.positions.length > index) {
      this.sortDeviceOrder();
      if (this.positions[index].deviceInfo?.deviceType === DeviceDisplayType.OTHERS) {
        this.snapOthers(index);
      }
      this.snapping(index); // 吸附
      this.snappingOthers(); // 其他设备吸附
      this.autoAlign(); // 横向对齐
      this.autoToCenter(); // 整体居中
      this.getLinePoint(); // 交界线获取
    }
  }

  /**
   * 将数据存入设置数据库中，做持久化处理
   */
  public setSettingsData(): void {
    LogUtil.info(`${TAG} set settings data begin`);
    // 原点坐标 ———— 整体位置的左上方为原点
    let originX = this.dragRight;
    let originY = this.dragBottom;
    const localPositions = this.positions.filter((point) => point.deviceInfo?.deviceType !== DeviceDisplayType.OTHERS);
    localPositions.forEach((point) => {
      originX = originX > point.x ? point.x : originX;
      originY = originY > point.y ? point.y : originY;
    })
    // 偏移量 ———— 内屏与数据库中值的偏差
    let offSetX = 0;
    let offSetY = 0;
    let extendedDeviceSN = '';
    this.positions.forEach((point) => {
      // 获取内屏的方位偏移量
      if (point.deviceInfo?.deviceType === DeviceDisplayType.BUILTIN) {
        let positionsData = this.positionsDataList.find((data) => Number(data.split(' ')[0]) === point.deviceInfo?.key);
        if (positionsData) {
          let data = positionsData.split(' ');
          if (data.length >= POINT_DATA_LEN) {
            offSetX = ((point.x - originX) / this.zoom) - Number(data[1]);
            offSetY = ((point.y - originY) / this.zoom) - Number(data[2]);
          }
        }
        LogUtil.info(`${TAG} main screen offset: ${offSetX} - ${offSetY}`);
        return;
      } else if (point.deviceInfo?.deviceType === DeviceDisplayType.EXTENDED) {
        extendedDeviceSN = point.deviceInfo?.serialNumber!;
      }
    })
    // 所有数据库中相对位置均需要偏移
    this.positionsDataList.forEach((data, index) => {
      let dataStr = data.split(' ');
      if (dataStr.length < POINT_DATA_LEN) {
        LogUtil.error(`${TAG} dataStr does not include position`)
      } else {
        let point = this.positions.find((p) => p.deviceInfo?.key === Number(dataStr[0]));
        if (point) {
          dataStr[1] = String(Math.round((point.x - originX) / this.zoom));
          dataStr[2] = String(Math.round((point.y - originY) / this.zoom));
        } else {
          // 未连接但数据库中仍保存的数据，跟随内屏方位变化而作相应的变化
          dataStr[1] = String((Number(dataStr[1]) + offSetX));
          dataStr[2] = String((Number(dataStr[2]) + offSetY));
        }
        this.positionsDataList[index] = `${dataStr[0]} ${dataStr[1]} ${dataStr[2]}`;
      }
    })
    SettingsDataUtils.setSettingsDataAsync(DEVICE_POSITIONS, JSON.stringify(this.positionsDataList), DOMAIN_NAME);
    this.setSettingsEDIDPositions(extendedDeviceSN);
    RemoteDevicesController.getInstance().sendRefreshDevicePosition(this.positionsDataList);
  }

  /**
   *  全屏->分屏，分屏->全屏，保存临时方位变量
   */
  public saveTempPositions() {
    LogUtil.info(`${TAG} saving temp positions`);
    // 原点坐标 ———— 整体位置的左上方为原点
    let originX = this.dragRight;
    let originY = this.dragBottom;
    const localPositions = this.positions.filter((point) => point.deviceInfo?.deviceType !== DeviceDisplayType.OTHERS);
    localPositions.forEach((point) => {
      originX = originX > point.x ? point.x : originX;
      originY = originY > point.y ? point.y : originY;
    })
    this.tempPositionsList = [];
    this.positionsDataList.forEach((data, index) => {
      let dataStr = data.split(' ');
      let point = this.positions.find((p) => p.deviceInfo?.key === Number(dataStr[0]));
      if (point) {
        dataStr[1] = String(Math.round((point.x - originX) / this.zoom));
        dataStr[2] = String(Math.round((point.y - originY) / this.zoom));
      }
      this.tempPositionsList.push(`${dataStr[0]} ${dataStr[1]} ${dataStr[2]}`);
    })
    LogUtil.info(`${TAG} saved temp positions: ${JSON.stringify(this.tempPositionsList)}`);
  }

  public setRemoteDevicePosition(): void {
    const tempPositions = this.positions.concat();
    tempPositions.sort((position1, position2) => position1.x - position2.x);
    const deviceOrders: (string | number)[] = [];
    for (const position of tempPositions) {
      if (position.deviceInfo !== null) {
        let keyIsNumber = typeof position.deviceInfo.key === 'number';
        deviceOrders.push(keyIsNumber ? 0 : position.deviceInfo.key)
      }
    }
    RemoteDevicesController.getInstance().saveDevicePosition(deviceOrders);
    RemoteDevicesController.getInstance().sendRefreshDevicePosition(this.positionsDataList);
  }

  /**
   * 保存EDID方位信息 结构为SN号;内屏模式 外屏模式;内屏方位;外屏方位
   * @param extendedDeviceSN 扩展屏SN号
   */
  private setSettingsEDIDPositions(extendedDeviceSN: string) {
    // 仅第二屏下不保存EDID方位信息
    let onlyScreenDevice =
      this.devicesController.getDevices().find((d) => d.deviceUserFor === DeviceUserType.ONLY_SCREEN);
    if (onlyScreenDevice) {
      LogUtil.info(`${TAG} only screen do not save positions`);
      return;
    }
    let deviceEDIDList = this.devicesController.getDeviceEDIDList();
    LogUtil.info(`${TAG} get connect device data list: ${deviceEDIDList}`);
    let connectDeviceIndex: number = deviceEDIDList.findIndex((data) => data.split(DELIMITER)[0] === extendedDeviceSN);
    // 数据库中方位信息替换为当前信息
    if (connectDeviceIndex !== -1) {
      let connectDeviceData: string[] = deviceEDIDList[connectDeviceIndex].split(DELIMITER);
      if (connectDeviceData.length >= 2) {
        connectDeviceData = connectDeviceData.slice(0, 2);
      }
      connectDeviceData.push(...this.positionsDataList);
      // 替换当前SN设备信息方位
      deviceEDIDList[connectDeviceIndex] = connectDeviceData.join(DELIMITER);
    }
    SettingsDataUtils.setSettingsDataAsync(USER_SET_DEVICE_MODE_EDID, JSON.stringify(deviceEDIDList), DOMAIN_NAME);
  }

  private getPositionDataList(): string[] {
    let devices = this.devicesController.getDevices();
    let extendDevice = devices.find((d) => d.deviceType === DeviceDisplayType.EXTENDED);
    if (!extendDevice) {
      LogUtil.info(`${TAG} not exist extend device`);
      return [];
    }
    let extendDeviceSN = extendDevice.serialNumber;
    let deviceDataList: string[] = this.devicesController.getDeviceEDIDList();
    let connectDeviceData = deviceDataList.find((data) => data.split(DELIMITER)[0] === extendDeviceSN);
    if (!connectDeviceData) {
      LogUtil.info(`${TAG} not exist connect device data`);
      return [];
    }
    LogUtil.info(`${TAG} get connect device data: ${connectDeviceData}`);
    let connectDeviceDataList: string[] = connectDeviceData.split(DELIMITER);
    if (connectDeviceDataList.length <= 2) {
      LogUtil.info(`${TAG} not exist connect device positions data`);
      return [];
    }
    let connectDevicePositions = connectDeviceDataList.splice(2);
    // displayID不匹配的情况下，调整displayID
    if (connectDevicePositions.length > 1) {
      let extendDevicePosition: string[] = connectDevicePositions[1].split(' ');
      if (extendDevicePosition[0] !== String(extendDevice.key)) {
        LogUtil.info(`${TAG} port numer not match`);
        extendDevicePosition[0] = String(extendDevice.key);
      }
      connectDevicePositions[1] = extendDevicePosition.join(' ');
      LogUtil.info(`${TAG} change position data: ${connectDevicePositions}`);
    }
    return connectDevicePositions;
  }

  /**
   * 将方位信息下发刷新
   */
  public async multiPositionsRefresh(): Promise<void> {
    this.devicesController.checkDevice();
    // 只有一个本机设备，当前设备方位信息不足以下发方位数据
    if (this.devicesController.getLocalDeviceCount() <= 1 || this.positions.length <= 1) {
      LogUtil.error('setMultiScreenRelativePosition should be two or more devices');
      return;
    }
    try {
      let devices = this.devicesController.getDevices();
      // 从数据库中获取点位信息
      let mainDeviceId = 0;
      let secondDeviceId = 0;
      devices.forEach((d) => {
        LogUtil.info(`positions device type: ${d.deviceUserFor}`)
        if (d.deviceType === DeviceDisplayType.BUILTIN) {
          mainDeviceId = d.key as number;
        } else if (d.deviceType !== DeviceDisplayType.OTHERS) {
          secondDeviceId = d.key as number;
        }
      });
      if (secondDeviceId !== mainDeviceId) {
        // 目前仅支持两个屏幕方位设置
        LogUtil.info(`refresh main Device: ${mainDeviceId} | second Device: ${secondDeviceId}`);
        let mainData = (this.positionsDataList.find(
          (data) => Number(data.split(' ')[0]) === mainDeviceId
        ) as string).split(' ');
        let mainScreen: screen.MultiScreenPositionOptions = {
          id: Number(mainData[0]), startX: Number(mainData[1]), startY: Number(mainData[2])
        };
        let secondData = (this.positionsDataList.find(
          (data) => Number(data.split(' ')[0]) === secondDeviceId
        ) as string).split(' ');
        let secondScreen: screen.MultiScreenPositionOptions = {
          id: Number(secondData[0]), startX: Number(secondData[1]), startY: Number(secondData[2])
        }
        screen.setMultiScreenRelativePosition(mainScreen, secondScreen);
      }
    } catch (e) {
      LogUtil.showError(TAG, `setMultiScreenRelativePosition error`);
    }
  }

  /**
   * 注册设置窗口分屏模式监听事件
   */
  public registerSplitScreenStatusListener(): void {
    try {
      const stage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
      stage?.getMainWindow((err, data) => {
        if (err.code || data === undefined) {
          LogUtil.error(`${TAG} Failed to obtain the main window.`);
          return;
        }
        data?.on('windowStatusChange', (windowType: window.WindowStatusType) => {
          LogUtil.info(`${TAG} windowStatusChange: ${windowType}`);
          EventBus.getInstance().emit('window_split_screen_changed', windowType === window.WindowStatusType.SPLIT_SCREEN);
        });
      })
    } catch (err) {
      LogUtil.error(`${TAG} register window stage listener failed: code: ${err?.code} message: ${err?.message}`);
    }
  }

  /**
   * 查询设置窗口是否为分屏模式
   */
  public isSplitScreenStatus(): boolean {
    LogUtil.info(`${TAG} getSettingsWindowStatusType`);
    try {
      let mainWindow: window.Window | undefined = AppStorage.get<window.Window>('mainWindow');
      if (!mainWindow) {
        mainWindow = AppStorage.get<window.WindowStage>('windowStage')?.getMainWindowSync();
      }
      if (!mainWindow) {
        LogUtil.error(`${TAG} getSettingsWindowStatusType get mainWindow failed.`);
        return false;
      }
      let windowStatusType: window.WindowStatusType = mainWindow.getWindowStatus();
      LogUtil.info(`${TAG} WindowStatusType ${windowStatusType}`);
      return windowStatusType === window.WindowStatusType.SPLIT_SCREEN;
    } catch (err) {
      LogUtil.error(`${TAG} getSettingsWindowStatusType failed. Error code: ${err.code} message: ${err.message}`);
      return false;
    }
  }

  /**
   * 可用区域变化时，调整areaZoom
   */
  public setAreaZoom(areaChangeZoom: number): void {
    LogUtil.info(`DragController onAreaChange areaZoom: ${areaChangeZoom}`);
    this.areaZoom = areaChangeZoom;
  }

  public setPositions(positions: Point[]) {
    this.positions = positions;
  }

  public setDragLeft(dragLeft: number) {
    this.dragLeft = dragLeft;
  }

  public setDragRight(dragRight: number) {
    this.dragRight = dragRight;
  }

  public setDragTop(dragTop: number) {
    this.dragTop = dragTop;
  }

  public setDragBottom(dragBottom: number) {
    this.dragBottom = dragBottom;
  }

  public setDeviceLocationOrder(deviceLocationOrder: Array<number | string>) {
    this.deviceLocationOrder = deviceLocationOrder;
  }

  public getPositions(): Point[] {
    return this.positions;
  }

  public getLineStart(): Point {
    return this.lineStart;
  }

  public getLineEnd(): Point {
    return this.lineEnd;
  }

  public getDeviceLocationOrder(): Array<number | string> {
    return this.deviceLocationOrder;
  }

  public getHasDraggedState(): boolean {
    return this.hasDragged;
  }

  public setHasDraggedState(flag: boolean): void {
    LogUtil.info(`${TAG} setHasDraggedState ${flag}`);
    this.hasDragged = flag;
  }

  /**
   * 在误差范围内则认为两个数值相等
   */
  private isEqualWithinTheDiff(num1: number, num2: number) {
    return Math.abs(num1 - num2) < WITHIN_ERROR_RANGE;
  }
}