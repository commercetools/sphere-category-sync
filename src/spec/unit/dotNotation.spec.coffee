_ = require 'underscore'
objDot = require '../../lib/helper/dotNotation'

describe 'ObjectDotNotation', ->
  describe 'setter', ->
    it 'should set a simple value mapped by dotNotation', (done) ->
      expect(objDot.set({}, 'name', '123')).toEqual { name: '123' }
      done()

    it 'should set a nested value mapped by dotNotation', (done) ->
      expect(objDot.set({}, 'a.b.name', '123')).toEqual { a: { b: { name: '123' }}}
      done()

    it 'should set a multiple values mapped by dotNotation', (done) ->
      obj = {}
      objDot.set(obj, 'name', 123)
      objDot.set(obj, 'arr', [1,2,3])
      objDot.set(obj, 'sub.path', 234)
      objDot.set(obj, 'sub.obj', { some: 'value' })
      objDot.set(obj, 'lang.en', 'english')
      objDot.set(obj, 'lang.sp', 'spanish')

      expect(obj).toEqual
        name: 123
        arr: [1,2,3]
        sub:
          path: 234
          obj:
            some: 'value'
        lang:
          en: 'english'
          sp: 'spanish'

      done()

  describe 'getter', ->
    obj = {
      name: "123",
      a: {
        path: "456",
        b: {
          c: "value"
        },
        arr: [1,2,3]
      }
    }

    it 'should get a value from deep object mapped by dotNotation', (done) ->
      expect(objDot.get(obj, 'name')).toBe obj.name
      expect(objDot.get(obj, 'a.path')).toBe obj.a.path
      expect(objDot.get(obj, 'a.arr')).toEqual obj.a.arr
      expect(objDot.get(obj, 'a.b.c')).toEqual obj.a.b.c
      done()

    it 'should get a default value', (done) ->
      expect(objDot.get(obj, 'a.b.d', null)).toBe null
      done()
