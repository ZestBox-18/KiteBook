/**
 * MIT License
 * 
 * Copyright (c) 2024-present KEKE UI
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software...
 */

export function hsv2rgb(h: number, s: number, v: number): [number, number, number] {
  s = s / 100
  v = v / 100

  let rgb: number[] = []
  const c = v * s
  const hh = h / 60
  const x = c * (1 - Math.abs((hh % 2) - 1))
  const m = v - c

  if (hh >= 0 && hh < 1) {
    rgb = [c, x, 0]
  } else if (hh >= 1 && hh < 2) {
    rgb = [x, c, 0]
  } else if (hh >= 2 && hh < 3) {
    rgb = [0, c, x]
  } else if (h >= 3 && hh < 4) {
    rgb = [0, x, c]
  } else if (h >= 4 && hh < 5) {
    rgb = [x, 0, c]
  } else if (h >= 5 && hh <= 6) {
    rgb = [c, 0, x]
  } else {
    rgb = [0, 0, 0]
  }

  return [Math.round(255 * (rgb[0] + m)), Math.round(255 * (rgb[1] + m)), Math.round(255 * (rgb[2] + m))]
}

export function rgb2hex(r: number, g: number, b: number): string {
  return `#${[r, g, b].map(n => n.toString(16).padStart(2, '0')).join('')}`
}

export function rgb2hsv(r: number, g: number, b: number): [number, number, number] {
  let h: number, s: number, v: number
  const max = Math.max(r, g, b)
  const min = Math.min(r, g, b)
  const delta = max - min

  if (delta === 0) {
    h = 0
  } else if (r === max) {
    h = ((g - b) / delta) % 6
  } else if (g === max) {
    h = (b - r) / delta + 2
  } else {
    h = (r - g) / delta + 4
  }

  h = Math.round(h * 60)
  if (h < 0) h += 360

  s = Math.round((max === 0 ? 0 : delta / max) * 100)

  v = Math.round((max / 255) * 100)

  return [h, s, v]
}

export function hex2rgb(hex: string): [number, number, number] {
  const hexInfo = formatHex(hex)

  return [
    parseInt(hexInfo[0].substring(1, 3), 16),
    parseInt(hexInfo[0].substring(3, 5), 16),
    parseInt(hexInfo[0].substring(5, 7), 16),
  ]
}

export function hex2rgba(hex: string): [number, number, number, number] {
  const hexInfo = formatHex(hex)

  return [
    parseInt(hexInfo[0].substring(1, 3), 16),
    parseInt(hexInfo[0].substring(3, 5), 16),
    parseInt(hexInfo[0].substring(5, 7), 16),
    hexInfo[1],
  ]
}

export function hex2hsv(hex: string): [number, number, number] {
  const rgb = hex2rgb(hex)
  return rgb2hsv(rgb[0], rgb[1], rgb[2])
}

export function hex2hexa(hex: string, alpha: number): string {
  const hexInfo = formatHex(hex)
  return `#${Math.round(alpha * 255).toString(16).padStart(2, '0')}${hexInfo[0].substr(1)}`
}

export function hsva2hex(h: number, s: number, b: number, alpha: number = 1): string {
  const rgb = hsv2rgb(h, s, b)
  const hex = rgb2hex(rgb[0], rgb[1], rgb[2])
  if (alpha !== 1) {
    return hex2hexa(hex, alpha)
  }
  return hex
}

export function hex2hsva(hex: string): [number, number, number, number] {
  const hexInfo = formatHex(hex)
  const hsv = hex2hsv(hexInfo[0])
  return [hsv[0], hsv[1], hsv[2], hexInfo[1]]
}

/**
 * 格式化hex颜色值
 * @param hex
 * @returns hex与alpha
 */
export function formatHex(hex: string): [string, number] {
  const str = hex.replace('#', '')

  if (str.length === 4) {
    return [`#${str[1].repeat(2)}${str[2].repeat(2)}${str[3].repeat(2)}`, parseInt(str[0].repeat(2), 16) / 255]
  } else if (str.length === 3) {
    return [`#${str[0].repeat(2)}${str[1].repeat(2)}${str[2].repeat(2)}`, 1]
  } else if (str.length === 8) {
    return [`#${str.substring(2, 8)}`, parseInt(str.substring(0, 2), 16) / 255]
  } else if (str.length === 6) {
    return [`#${str}`, 1]
  } else {
    throw new Error('Invalid hex color format')
  }
}
