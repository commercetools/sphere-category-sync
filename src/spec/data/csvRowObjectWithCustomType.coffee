module.exports = {
  'name.en': 'categoryName',
  key: 'categoryKeys',
  externalId: 'categoryExternalId',
  'slug.en': 'category-en-slug',
  customType: {
    id: 'bcb4f88a-bd42-4478-bf20-9a6ad4936e2e',
    version: 1,
    createdAt: '2019-03-20T19:25:04.550Z',
    lastModifiedAt: '2019-03-20T19:25:04.550Z',
    lastModifiedBy: {
      clientId: 'sphere.impex.1.0',
      user: {
        typeId: 'user',
        id: '13afec11-66cd-4c46-9e6d-d301ba5be33a'
      }
    },
    createdBy: {
      clientId: 'sphere.impex.1.0',
      user: {
        typeId: 'user',
        id: '13afec11-66cd-4c46-9e6d-d301ba5be33a'
      }
    },
    key: 'customTypeKey',
    name: {
      de: 'CustomTypeDe',
      en: 'CustomTypeEn'
    },
    description: {
      en: 'Extending category object'
    },
    resourceTypeIds: ['category'],
    fieldDefinitions: [{
      name: 'booleanAttr',
      label: {
        en: 'boolean attribute'
      },
      required: false,
      type: {
        name: 'Boolean'
      },
      inputHint: 'SingleLine'
    }, {
      name: 'booleanAttrFalse',
      label: {
        en: 'boolean attribute false'
      },
      required: false,
      type: {
        name: 'Boolean'
      },
      inputHint: 'SingleLine'
    }, {
      name: 'stringAttr',
      label: {
        en: 'string attribute'
      },
      required: false,
      type: {
        name: 'String'
      },
      inputHint: 'SingleLine'
    }, {
      name: 'ltextAttr',
      label: {
        en: 'ltext attribute'
      },
      required: false,
      type: {
        name: 'LocalizedString'
      },
      inputHint: 'SingleLine'
    }, {
      name: 'reference',
      label: {
        en: 'reference attribute'
      },
      required: false,
      type: {
        name: 'Reference',
        referenceTypeId: 'category'
      },
      inputHint: 'SingleLine'
    }, {
      name: 'moneyAttr',
      label: {
        en: 'Money attribute'
      },
      required: false,
      type: {
        name: 'Money'
      },
      inputHint: 'SingleLine'
    }, {
      name: 'enumAttr',
      label: {
        en: 'Enum attribute'
      },
      required: false,
      type: {
        name: 'Enum',
        values: [{
          key: 'enumKey1',
          label: 'Enum1'
        }, {
          key: 'enumKey2',
          label: 'Enum2'
        }]
      },
      inputHint: 'SingleLine'
    }, {
      name: 'lenumAttr',
      label: {
        en: 'Lenum attribute'
      },
      required: false,
      type: {
        name: 'LocalizedEnum',
        values: [{
          key: 'lenumKey1',
          label: {
            de: 'Lenum1De',
            en: 'Lenum1En'
          }
        }, {
          key: 'lenumKey2',
          label: {
            de: 'Lenum2De',
            en: 'Lenum2En'
          }
        }]
      },
      inputHint: 'SingleLine'
    }, {
      name: 'setOfString',
      label: {
        en: 'Set of String'
      },
      required: false,
      type: {
        name: 'Set',
        elementType: {
          name: 'String'
        }
      },
      inputHint: 'SingleLine'
    }, {
      name: 'setOfLtext',
      label: {
        en: 'Set of Ltext'
      },
      required: false,
      type: {
        name: 'Set',
        elementType: {
          name: 'LocalizedString'
        }
      },
      inputHint: 'SingleLine'
    }, {
      name: 'number',
      label: {
        en: 'Number'
      },
      required: false,
      type: {
        name: 'Number'
      },
      inputHint: 'SingleLine'
    }, {
      name: 'setOfNumber',
      label: {
        en: 'Set of Number'
      },
      required: false,
      type: {
        name: 'Set',
        elementType: {
          name: 'Number'
        }
      },
      inputHint: 'SingleLine'
    }, {
      name: 'SetOfEnum',
      label: {
        en: 'Set of Enum'
      },
      required: false,
      type: {
        name: 'Set',
        elementType: {
          name: 'Enum',
          values: [{
            key: 'setOfEnumKey1',
            label: 'SetEnum1'
          }, {
            key: 'setOfEnumKey2',
            label: 'SetEnum2'
          }]
        }
      },
      inputHint: 'SingleLine'
    }, {
      name: 'SetOfLenum',
      label: {
        en: 'Set of Lenum'
      },
      required: false,
      type: {
        name: 'Set',
        elementType: {
          name: 'LocalizedEnum',
          values: [{
            key: 'setOflenumKey1',
            label: {
              de: 'SetLenum1De',
              en: 'Lenum1En'
            }
          }, {
            key: 'setOflenumKey2',
            label: {
              de: 'SetLenum2De',
              en: 'Lenum2En'
            }
          }]
        }
      },
      inputHint: 'SingleLine'
    }]
  },
  'customField.number': '123',
  'customField.moneyAttr': 'EUR 1234',
  'customField.lenumAttr': 'lenumKey1',
  'customField.setOfString': 'setOfStringVal1;setOfStringVal2',
  'customField.SetOfLenum': 'setOflenumKey1;setOflenumKey2',
  'customField.stringAttr': 'string value',
  'customField.SetOfEnum': 'setOfEnumKey1;setOfEnumKey2',
  'customField.booleanAttr': 'true',
  'customField.setOfNumber': '1;2;3',
  'customField.enumAttr': 'enumKey1',
  'customField.ltextAttr.en': 'En value',
  'customField.ltextAttr.de': 'De value',
  'customField.setOfLtext.en': 'setLtextEn1;setLtextEn2',
  'customField.setOfLtext.de': 'setLtextDe1;setLtextDe2'
}