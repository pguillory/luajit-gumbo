local ffi = require 'ffi'

local libgumbo = (function()
  local DIR = debug.getinfo(1).source:match('@(.*/)')

  local file = io.open(DIR .. 'gumbo.h')
  ffi.cdef(file:read('*a'))
  file:close()

  local filename = package.searchpath(DIR .. 'lib/libgumbo', '?.dylib;?.so;', '')
  assert(filename, 'libgumbo not found -- try running make')
  return ffi.load(filename)
end)()

local GUMBO_NODE_DOCUMENT   = tonumber(libgumbo.GUMBO_NODE_DOCUMENT)
local GUMBO_NODE_ELEMENT    = tonumber(libgumbo.GUMBO_NODE_ELEMENT)
local GUMBO_NODE_TEXT       = tonumber(libgumbo.GUMBO_NODE_TEXT)
local GUMBO_NODE_CDATA      = tonumber(libgumbo.GUMBO_NODE_CDATA)
local GUMBO_NODE_COMMENT    = tonumber(libgumbo.GUMBO_NODE_COMMENT)
local GUMBO_NODE_WHITESPACE = tonumber(libgumbo.GUMBO_NODE_WHITESPACE)

local function transform_gumbo_node_to_lom_node(gumbo_node)
  local node_type = tonumber(gumbo_node.type)

  if node_type == GUMBO_NODE_DOCUMENT then
    error('Not implemented')
  elseif node_type == GUMBO_NODE_ELEMENT then
    local element = gumbo_node.v.element
    local attributes = ffi.cast('GumboAttribute**', element.attributes.data)
    local children = ffi.cast('GumboNode**', element.children.data)

    local node = {}
    node.tag = ffi.string(libgumbo.gumbo_normalized_tagname(element.tag))
    if node.tag == '' then
      libgumbo.gumbo_tag_from_original_text(element.original_tag)
      node.tag = ffi.string(element.original_tag.data, element.original_tag.length)
    end

    node.attr = {}
    for i = 0, element.attributes.length - 1 do
      local attribute = attributes[i]
      local name = ffi.string(attribute.name)
      local value = ffi.string(attribute.value)
      node.attr[name] = value
      table.insert(node.attr, name)
    end

    for i = 0, element.children.length - 1 do
      table.insert(node, transform_gumbo_node_to_lom_node(children[i]))
    end
    return node
  elseif node_type == GUMBO_NODE_COMMENT then
    return ''
  else
    return ffi.string(gumbo_node.v.text.text)
  end
end

--------------------------------------------------------------------------------
-- gumbo
--------------------------------------------------------------------------------

local gumbo = {}

function gumbo.parse(input)
  local output = libgumbo.gumbo_parse(input)
  local root = transform_gumbo_node_to_lom_node(output.root)
  libgumbo.gumbo_destroy_output(libgumbo.kGumboDefaultOptions, output)
  return root
end

--------------------------------------------------------------------------------
-- TESTS
--------------------------------------------------------------------------------

do
  local input = ''
  local html = gumbo.parse(input)

  assert(html.tag == 'html')
  assert(html.attr[1] == nil)
  assert(html[1].tag == 'head')
  assert(html[1].attr[1] == nil)
  assert(html[1][1] == nil)
  assert(html[2].tag == 'body')
  assert(html[2].attr[1] == nil)
  assert(html[2][1] == nil)
  assert(html[3] == nil)
end

do
  local input = '<div></div>'
  local body = gumbo.parse(input)[2]

  assert(body.tag == 'body')
  assert(body[1].tag == 'div')
  assert(body[1].attr[1] == nil)
  assert(body[2] == nil)
end

do
  local input = 'a & b'
  local body = gumbo.parse(input)[2]
  assert(body.tag == 'body')
  assert(body[1] == 'a & b')
end

do
  local input = '<body><!-- asdf --></body>'
  local body = gumbo.parse(input)[2]
  assert(body.tag == 'body')
  assert(body[1] == '')
end

do
  local input = '<a><b><c><d>'
  local body = gumbo.parse(input)[2]
  assert(body.tag == 'body')
  assert(body[1].tag == 'a')
  assert(body[1][1].tag == 'b')
  assert(body[1][1][1].tag == 'c')
  assert(body[1][1][1][1].tag == 'd')
end

return gumbo
