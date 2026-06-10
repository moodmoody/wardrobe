import test from 'node:test';
import assert from 'node:assert/strict';
import { formatLocationCode, formatLocationLabel } from '../src/domain/location-address.js';

test('formats a hierarchical wardrobe location code', () => {
  const code = formatLocationCode({ wardrobe: 1, zone: 2, compartment: 1, group: 3, item: 4 });

  assert.equal(code, 'W01-Z02-C01-G03-I04');
});

test('formats a stacked shelf location label', () => {
  const label = formatLocationLabel({
    wardrobeName: '主衣橱',
    zoneName: '左侧第二层',
    compartmentName: '右侧叠放组',
    groupName: '第 2 叠',
    orderDirection: 'top_to_bottom',
    orderIndex: 3,
  });

  assert.equal(label, '主衣橱 / 左侧第二层 / 右侧叠放组 / 第 2 叠 / 从上往下第 3 件');
});

test('formats a hanging rod location label', () => {
  const label = formatLocationLabel({
    wardrobeName: '主衣橱',
    zoneName: '右侧挂衣区',
    compartmentName: '挂衣杆',
    groupName: '外套段',
    orderDirection: 'left_to_right',
    orderIndex: 6,
  });

  assert.equal(label, '主衣橱 / 右侧挂衣区 / 挂衣杆 / 外套段 / 从左到右第 6 件');
});

test('formats a drawer location label', () => {
  const label = formatLocationLabel({
    wardrobeName: '主衣橱',
    zoneName: '右侧抽屉区',
    compartmentName: '中抽屉',
    groupName: '前部左侧',
    orderDirection: 'front_to_back',
    orderIndex: 5,
  });

  assert.equal(label, '主衣橱 / 右侧抽屉区 / 中抽屉 / 前部左侧 / 从前往后第 5 件');
});