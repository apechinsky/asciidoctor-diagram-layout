// Asciidoctor.js port of asciidoctor-diagram-layout (layout-rowcol block processor)

const GOLDEN_RATIO = 0.618033988749895
const HUE_RANGE = 360

function javaHash(str) {
  if (!str) return 0
  let h = 0
  for (let i = 0; i < str.length; i++) {
    h = Math.imul(31, h) + str.charCodeAt(i) | 0
  }
  return h
}

function hslToHex(hue, saturation, lightness) {
  const s = saturation / 100
  const l = lightness / 100
  const c = (1 - Math.abs(2 * l - 1)) * s
  const x = c * (1 - Math.abs((hue / 60) % 2 - 1))
  const m = l - c / 2
  let r, g, b
  if (hue < 60)       { r = c; g = x; b = 0 }
  else if (hue < 120) { r = x; g = c; b = 0 }
  else if (hue < 180) { r = 0; g = c; b = x }
  else if (hue < 240) { r = 0; g = x; b = c }
  else if (hue < 300) { r = x; g = 0; b = c }
  else                { r = c; g = 0; b = x }
  const toHex = (n) => Math.round((n + m) * 255).toString(16).padStart(2, '0')
  return `#${toHex(r)}${toHex(g)}${toHex(b)}`
}

function goldenHue(name) {
  const hash = Math.abs(javaHash(name))
  return Math.floor((hash * GOLDEN_RATIO % 1) * HUE_RANGE)
}

function analogousHue(name, baseHue, hueRange) {
  const hash = Math.abs(javaHash(name))
  const offset = Math.floor((hash * GOLDEN_RATIO % 1) * hueRange)
  return (baseHue + offset) % HUE_RANGE
}

function makeGoldenScheme(sat, light) {
  return {
    fill:     (name) => hslToHex(goldenHue(name), sat, light),
    gradEnd:  (name) => hslToHex((goldenHue(name) + 20) % HUE_RANGE, sat, light),
    stroke:   (name) => hslToHex(goldenHue(name), 30, 65),
  }
}

function makeAnalogousScheme(baseHue, hueRange, sat, light) {
  return {
    fill:     (name) => hslToHex(analogousHue(name, baseHue, hueRange), sat, light),
    gradEnd:  (name) => hslToHex((analogousHue(name, baseHue, hueRange) + 15) % HUE_RANGE, sat, light),
    stroke:   (name) => hslToHex(analogousHue(name, baseHue, hueRange), 25, 65),
  }
}

function resolveScheme(palette) {
  switch ((palette || 'rainbow').toLowerCase()) {
    case 'pastel': return makeGoldenScheme(18, 93)
    case 'warm':   return makeAnalogousScheme(30, 60, 25, 86)
    case 'cool':   return makeAnalogousScheme(210, 60, 25, 86)
    case 'mono':   return makeAnalogousScheme(210, 0, 20, 86)
    default:       return makeGoldenScheme(22, 88)
  }
}

// --- Parser ---

const LINE_RE = /^(cols|rows|cell)(?:\((\d+)\))?:(.*)/i

function parse(dsl, implicitDir) {
  const lines = dsl.split('\n')
  const state = { lines, index: 0 }
  const roots = parseChildren(state, 0)
  if (roots.length === 0) throw new Error('Empty input')
  if (roots.length === 1 && roots[0].type !== 'cell') return roots[0]
  return { type: implicitDir || 'rows', size: 'auto', children: roots }
}

function parseChildren(state, indent) {
  const nodes = []
  while (state.index < state.lines.length) {
    const line = state.lines[state.index]
    const trimmed = stripComment(line).trimEnd()
    if (trimmed.trim() === '') { state.index++; continue }
    const lineIndent = countIndent(line)
    if (lineIndent < indent) break
    if (lineIndent > indent) throw new Error(`Unexpected indentation at line ${state.index + 1}`)
    state.index++
    const content = trimmed.trim()
    const m = content.match(LINE_RE)
    if (!m) throw new Error(`Invalid syntax at line ${state.index}: ${JSON.stringify(line)}`)
    const keyword = m[1].toLowerCase()
    const size = m[2] ? parseInt(m[2], 10) : 'auto'
    const rest = m[3].trim()
    nodes.push(buildNode(keyword, size, rest, state, indent, state.index, line))
  }
  return nodes
}

function buildNode(keyword, size, rest, state, indent, lineNum, origLine) {
  if (keyword === 'cell') {
    if (!rest) throw new Error(`cell requires a name at line ${lineNum}`)
    return { type: 'cell', size, name: rest }
  }
  if (rest) throw new Error(`${keyword} must not have a value at line ${lineNum}`)
  const nestedIndent = detectNestedIndent(state, indent, lineNum)
  const children = parseChildren(state, nestedIndent)
  return { type: keyword, size, children }
}

function detectNestedIndent(state, currentIndent, lineNum) {
  while (state.index < state.lines.length) {
    const line = state.lines[state.index]
    const trimmed = stripComment(line).trimEnd()
    if (trimmed.trim() !== '') {
      const ind = countIndent(line)
      if (ind <= currentIndent) throw new Error(`Expected indented block after line ${lineNum}`)
      return ind
    }
    state.index++
  }
  throw new Error(`Expected indented block after line ${lineNum} but reached end of input`)
}

function countIndent(line) {
  let count = 0
  for (const ch of line) {
    if (ch === ' ') count++
    else if (ch === '\t') count += 4
    else break
  }
  return count
}

function stripComment(line) {
  const i = line.indexOf('#')
  return i >= 0 ? line.slice(0, i) : line
}

// --- HTML Renderer ---

const CELL_BASE = 'display:flex; align-items:center; justify-content:center;' +
  ' padding:8px; font-weight:bold; font-family:sans-serif;' +
  ' min-height:60px; box-sizing:border-box; color:#333;'

function renderHtml(root, opts) {
  const scheme = resolveScheme(opts.palette)
  const heightStyle = opts.height ? ` min-height:${opts.height};` : ''
  const wrapperStyle = `display:flex; width:${opts.width || '100%'};${heightStyle}` +
    ' box-sizing:border-box; font-family:sans-serif; overflow:hidden;'
  let html = `<div style="${wrapperStyle}">\n`
  html += renderNode(root, 1, scheme)
  html += '</div>\n'
  if (opts.title) {
    return `<div class="imageblock">\n<div class="content">\n${html}</div>\n` +
      `<div class="title">${escapeHtml(opts.title)}</div>\n</div>`
  }
  return html
}

function renderNode(node, depth, scheme) {
  if (node.type === 'cell') return renderCell(node, depth, scheme)
  return renderContainer(node, depth, scheme)
}

function renderContainer(node, depth, scheme) {
  const flexDir = node.type === 'cols' ? 'row' : 'column'
  const style = `display:flex; flex-direction:${flexDir}; ${sizeStyle(node.size)}` +
    ' align-items:stretch; box-sizing:border-box;'
  const pad = '  '.repeat(depth)
  let html = `${pad}<div style="${style}">\n`
  for (const child of node.children) {
    html += renderNode(child, depth + 1, scheme)
  }
  html += `${pad}</div>\n`
  return html
}

function renderCell(cell, depth, scheme) {
  const color = scheme.fill(cell.name)
  const gradEnd = scheme.gradEnd(cell.name)
  const stroke = scheme.stroke(cell.name)
  const gradient = `linear-gradient(135deg,${color},${gradEnd})`
  const style = `${CELL_BASE} ${sizeStyle(cell.size)} background:${gradient}; border:1px solid ${stroke};`
  const pad = '  '.repeat(depth)
  return `${pad}<div style="${style}">${escapeHtml(cell.name)}</div>\n`
}

function sizeStyle(size) {
  return size === 'auto' ? 'flex:1;' : `flex:0 0 ${size}%; box-sizing:border-box;`
}

function escapeHtml(text) {
  if (!text) return ''
  return text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
}

// --- Asciidoctor.js extension registration ---

module.exports.register = function (registry) {
  registry.block('layout-rowcol', function () {
    const self = this
    self.onContext(['listing', 'literal'])
    self.process(function (parent, reader, attrs) {
      const dsl = reader.read()
      const implicitDir = attrs['direction'] === 'cols' ? 'cols' : 'rows'
      let root
      try {
        root = parse(dsl, implicitDir)
      } catch (e) {
        return self.createBlock(parent, 'paragraph', `[layout-rowcol error: ${e.message}]`, attrs)
      }
      const opts = {
        width:   attrs['width'] || '100%',
        height:  attrs['height'],
        palette: attrs['palette'] || 'rainbow',
        title:   attrs['title'],
      }
      const html = renderHtml(root, opts)
      return self.createPassBlock(parent, html, {})
    })
  })
}
