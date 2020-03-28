- [SDOSKeyedCodable](#sdoskeyedcodable)
    - [Introducción](#introducción)
    - [Instalación](#instalación)
        - [Cocoapods](#cocoapods)
    - [La librería](#la-librería)
        - [Qué hay en SDOSKeyedCodable](#qué-hay-en-sdoskeyedcodable)
        - [Cómo usar SDOSKeyedCodable](#cómo-usar-sdoskeyedcodable)
        - [Ejemplos de uso de SDOSKeyedCodable](#ejemplos-de-uso-de-sdoskeyedcodable)
    - [Proyecto de ejemplo](#proyecto-de-ejemplo)
    - [Dependencias](#dependencias)
    - [Referencias](#referencias)

# SDOSKeyedCodable

- Para consultar los últimos cambios en la librería consultar el [CHANGELOG.md](https://github.com/SDOSLabs/SDOSKeyedCodable/blob/master/CHANGELOG.md).

- Enlace confluence: https://kc.sdos.es/x/FALLAQ

## Introducción

SDOSKeyedCodable permite implementar manualmente el protocolo [Codable](http://SDOSKeyedCodable) sin tener que escribir el código repetitivo (boilerplate) necesario para implementar Codable.

SDOSKeyedCodable es realmente una versión de la librería [KeyedCodable](https://github.com/dgrzeszczak/KeyedCodable) mantenida por SDOS, con cambios y correcciones de los errores presentados por la librería original.

SDOSKeyedCodable no tiene dependencias.

## Instalación

### Cocoapods

Usaremos [CocoaPods](https://cocoapods.org). Hay que añadir la dependencia al `Podfile`:

Añadir el  "source" al `Podfile`:
```ruby
source 'https://github.com/SDOSLabs/cocoapods-specs.git'
```

Añadir la dependencia al `Podfile`:
```ruby
pod 'SDOSKeyedCodable', '~>1.1.' 
```

## La librería

### Qué hay en SDOSKeyedCodable

SDOSKeyedCodable consta de:

1. **Protocolo Keyedable**
```js
public protocol Keyedable {
    mutating func map(map: KeyMap) throws
}

public extension Keyedable where Self: Encodable {
    public func encode(to encoder: Encoder) throws {
        try KeyedEncoder(with: encoder).encode(from: self)
    }
}
```
Este protocolo nos permite hacer uso de la funcionalidad de SDOSKeyedCodable, como veremos más adelante. Todo objeto que implemente uno de los protocolos `Encodable`, `Decodable` o `Codable`, deberá implementar también el protocolo `Keyedable`.

2. **Operadores para la función `map(map: )`**
```js
// Operador a usar para decode y para encode
infix operator <->

// Operador a usar para decode
infix operator <<-

// Operador a usar para encode
infix operator ->>
```
Deberemos usar estos operadores en la implementación de la función `map(map: )` del protocolo `Keyedable`.

3. **Opciones de customización del parseo.**
```js
public struct KeyOptions {
    public let delimiter: String?
    public let flat: String?
    public let optionalArrayElements: String
    public let arrayMapping: String?

	// Inicializador con opciones por defecto
    public init(delimiter: String? = ".", flat: String? = "", optionalArrayElements: String? = "* ", arrayMapping: String? = "[]") {
        self.delimiter = delimiter
        self.flat = flat
        self.optionalArrayElements = optionalArrayElements
        self.arrayMapping = arrayMapping
    }
}

public struct KeyMap {
public subscript(key: String) -> Mapping {
        return Mapping(map: self, key: Key(stringValue: key), options: KeyOptions())
    }

    public subscript(key: String, options: KeyOptions) -> Mapping {
        return Mapping(map: self, key: Key(stringValue: key), options: options)
    }
}
```
Con el SDOSKeyedCodable podemos realizar el parseo con ciertas opciones avanzadas. Concretamente:

* *Delimiter*: para parsear claves anidadas y configurar el carácter que simboliza el separador. Por defecto, se usa el punto `"."` para indicar una ruta de claves anidadas (por ejemplo, `"response.user.id"` se usaría para acceder directamente al ID del usuario).
* *Flat*: para anidar varias claves en raiz dentro de un objeto. Por defecto se usa el string vacío `""`. Más adelante veremos un ejemplo.
* *OptionalArrayElements*: para parsear un array de objetos opcionales. Esto significa que el array parseado solo contendrá aquellos elementos cuyo parseo se ha podido realizar correctamente. Por defecto se usa el string `"* "`.
* *Array mapping*: para parsear en un array las misma propiedades de arrays de objetos que están al mismo nivel del JSON. Por defecto se usa el string `"[]"`.

* *All Keys*: para intentar el parseo de un mismo objeto en todas las 'keys' del json.

Usando el `KeyOptions` podemos configurar qué strings indican cada una de las funcionalidades anteriores. Por ejemplo, si en un JSON vinieran claves que contuvieran puntos `"."`, usando el `KeyOptions` podríamos cambiar el string que indica un keypath de claves (claves anidadas) para que no haya errores. Así, podríamos representar un keypath como `"response>user>id"`, pasando el argumento KeyOptions(delimiter: `">"`).


### Cómo usar SDOSKeyedCodable

Por lo general, SDOSKeyedCodable intervendrá al declarar los DTOs que se usarán para parsear las respuestas de los servicios web (*decode*). No obstante, también se usará para codificar DTOs que se guardarán en preferencias o que se enviarán como parámetros a servicios web (*encode*) Se debe tener en cuenta:

* Para usar la librería, es imprescindible declarar que el DTO implementa el protocolo `Keyedable`.
* Se debe implementar la función `map(map: )` del protocolo `Keyedable`.
* En la implementación de la función `map(map: )` se pueden usar los operadores:
    * `<<-`  En caso de que el DTO solo se use para decodificar (*decode*).
    * `->>`  Cuando el DTO solo se use para ser codificado (*encode*).
    * `<->`  Cuando el DTO se use tanto para decodificar como para codificar. **Usaremos este operador** para evitar posibles errores.
* En la implementación de `init(from: )` del protocolo `Decodable`, es imprescindible usar el `KeyedDecoder` proporcionado por SDOSKeyedCodable.
    * Puesto que en la implementación de `init(from: )` no se van a setear, a priori, las propiedades del DTO, es necesario que sus propiedades cumplan una de las siguientes condiciones:
        1. Sean opcionales (ya sean opcionales `?` (**recomendado**) o *implicitly unwrapped optionals* `!` (**no recomendado**).
        2. Sean no opcionales con un valor por defecto. En este caso, el valor por defecto no significa nada, pues si la propiedad es no opcional y no se consigue parsear, se devolverá un error de parseo del DTO.

        
SDOSKeyedCodable permite configurar las opciones de mapeo avanzadas que proporciona (`Delimiter`, `Flat`, `OptionalArrayElements` y `arrayMapping`). Esta customización del parseo es independiente para cada propiedad.

* Si las claves del JSON a parsear contuvieran puntos, podemos cambiar el carácter que marcará el separador para el keypath de la ruta a parsear. En este ejemplo, como la clave `".greeting"` contiene un punto, se ha modificado el separador de la ruta al carácter `"+"`.
* Si un array de elementos opcionales viene en una clave que comienza por `"* "`, podemos cambiar el string que denota un array opcional. En el ejemplo, se hace para la propiedad `array1` con el string `"### "`.
* También se puede cambiar el string que denota un parseo *flat* (por defecto es el String vacío `""`). De esta forma podemos parsear el objeto `location` con los valores que vienen dentro de la clave `""`, en lugar de usar la `"latitud"` y `"longitud"` que vienen en la raiz.
* Si la clave inicial del JSON a parsear comenzara por el string `"[]"`, podemos cambiar el string ue denota un parseo de tipo `arrayMapping`.

Todo esto se hace con el `KeyOptions` (ver Ejemplo 5).

### Ejemplos de uso de SDOSKeyedCodable

**Ejemplo 1**. Un ejemplo básico de uso es el siguiente:
```js
import SDOSKeyedCodable

struct UserDTO: Decodable, Keyedable {    
    var id: Int = 0
    var name: String?
    var email: String?
    
    mutating func map(map: KeyMap) throws {
        try id       <-> map["id"]
        try name     <-> map["datos.nombre"]
        try location <-> map["datos.email"]
    }
    
    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }   
}
```
Este DTO podría usarse para parsear el siguiente JSON:
```js
{
	"id" : 12413,
    "datos" : {
		"nombre" : "Alberto",
		"apellido1" : "Alfaro",
		"apellido2" : null,
		"email" : "a.alfaro@sdos.es"
	},
    "cupones" : []
}
```

**Ejemplo 2**. En este ejemplo se refleja la característica de *Flat*.

Tenemos el JSON:
```js
{
    "shop_name" : "Fnac",
    "latitude" : 37.3913259,
    "longitude" : -6.01025
}
```
Y queremos parsearlo usando un DTO que tiene una propiedad `location` (para la latitud y la longitud).
```js
import SDOSKeyedCodable

struct Location: Decodable {
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
}

struct ShopDTO: Decodable, Keyedable {
    var name: String!
    var location: Location?
    
    mutating func map(map: KeyMap) throws {
        try name     <-> map["shop_name"]
        try location <-> map[""]
    }
    
    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
}
```
Por defecto, el string vacío al mapear indica que la propiedad `location` debe parsearse con valores de la raiz del JSON. 

En el struct `Location` que hemos definido, no es necesario usar el protocolo `Keyedable` porque los nombres de las propiedades coinciden exactamente con los nombres de las claves del JSON. `Decodable` es suficiente en este caso.

**Ejemplo 3**. En este ejemplo se refleja la característica de *All Keys*.

Tenemos el JSON:
```js
{
    "vault": {
        "0": {
            "type": "Braintree_CreditCard0"
        },
        "1": {
            "type": "Braintree_CreditCard1"
        },
        "2": {
            "type": "Braintree_PayPalAccount2"
        },
    }
}
```
Y queremos parsear las distintas claves dentro de "vault" como un array. Usamos los siguientes DTOs.
```js
import SDOSKeyedCodable

struct PaymentMethodDTO: Decodable {
    var type: String?
}

struct PaymentMethods: Decodable, Keyedable {
    var userPaymentMethods: [PaymentMethodDTO] = []
    
    mutating func map(map: KeyMap) throws {
        guard case .decoding(let keys) = map.type else { return }
        
        let allKeys = keys.all(for: Key(stringValue: "vault"))
            
            allKeys.forEach {
                var paymentMethod: PaymentMethodDTO?
                try? paymentMethod <-> map[$0]
                if let paymentMethod = paymentMethod {
                    userPaymentMethods.append(paymentMethod)
            }
        }
    }
    
    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
}
```
En este caso, el JSON trae varias claves ("0", "1" y "2") en las que vienen objetos del mismo tipo. Con la implementación de este ejemplo, se puede parsear fácilmente todos esos objetos en un mismo array sin necesidad de tener 3 propiedades (una para cada clave) en el objeto de parseo.

**Ejemplo 4**. En este ejemplo se refleja la característica de *OptionalArrayElements*.

Tenemos el siguiente JSON que contiene un array en el que muchos de sus elementos están incompletos:
```js
{
    "elements": [
        {
            "id": 1,
            "name": "Object 1"
        },
        {
            "id": null,
            "name": "Object 2"
        },
        {
            "id": 3,
            "name": "Object 3"
        },
        {
            "id": 4,
            "name": "Object 4"
        },
        {

        },
        {
            "name": "Object 6"
        }
    ]
}
```
Si intentamos parsear el anterior array de forma normal, se producirá un error de parseo de *todo el array* en cuanto el parseo de uno de sus elementos falle. Con la funcionalidad de `OptionalArrayElements` podemos parsear ese array obteniendo únicamente los elementos que hayan podido ser parseados correctamente. Para ello, usamos el siguiente DTO:
```js
import SDOSKeyedCodable

struct SimpleElementDTO: Decodable {
    var id: Int = 0
    var name: String?
}

struct OptionalArray: Decodable, Keyedable {
    private(set) var array: [SimpleElementDTO]!
    
    mutating func map(map: KeyMap) throws {
        try array <-> map["* elements"]
    }
    
    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
}
```
Obsérvese que, con el String `"* elements"` estamos indicando que el array en la clave `"elements"` debe tratarse como un array de elementos opcionales (es decir, de elementos cuyo parseo puede fallar sin que por eso falle el parseo de todo el array).

**Ejemplo 5**. Este ejemplo más complejo de parseo de JSON combina los casos anteriores y cambia los strings por defecto de las características de mapeo anteriores.

Tenemos el JSON:
```js
{
    "* name": "John",
    "": {
        "latitude" : 4,
        "longitude" : 5,
        ".greeting": "Hallo world",
        "details": {
            "description": "Its nice here"
            }
        },
    "longitude": 3.2,
    "latitude": 3.4,
    "array": [
        {
            "id": 1
        },
        {},
        {
            "name": "nombre prueba"
        },
        {
            "id": 4,
            "name": "nombre 4"
        }
    ],
    "* array1": [
        {
            "id": null
        },
        {},
        {
            "id": 3
        },
        {
            "id": 4,
            "name": "Object 4"
        }
    ]
}
```
Realizamos el mapeo de este JSON con el DTO:
```js
import SDOSKeyedCodable

struct KeyOptionsExampleDTO: Codable, Keyedable {
    private(set) var greeting: String!
    private(set) var description: String!
    private(set) var name: String!
    private(set) var location: Location!
    private(set) var array: [SimpleElementDTO]!
    private(set) var array1: [SimpleElementDTO]!
    
    mutating func map(map: KeyMap) throws {
        try name <-> map["* name"]
        try greeting <-> map["+.greeting", KeyOptions(delimiter: "+", flat: nil)]
        try description <-> map[".details.description", KeyOptions(flat: nil)]
        try location <-> map["", KeyOptions(flat: "__")]
        try array <-> map["* array"]
        try array1 <-> map["### * array1", KeyOptions(optionalArrayElements: "### ")]
    }
    
    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
}
```

**Ejemplo 6**. En este ejemplo se refleja la característica de *array mapping*.

Tenemos el siguiente JSON que contiene información de un país.
```js
{
    "country": {
        "id": 34,
        "name": "Spain",
        "cities": [
            {
                "id": 41,
                "name": "Sevilla",
                "citizens": [
                    {
                        "id": 1,
                        "name": "Pedro",
                        "surname": "Pedregol"
                    },
                    {
                        "id": 2,
                        "name": "Juan",
                        "surname": "Jiménez"
                    },
                    {
                        "id": 3,
                        "name": "Alberto",
                        "surname": "Albero"
                    },
                    {
                        "id": 4,
                        "name": "Mónica",
                        "surname": "Martínez"
                    }
                ]
            },
            {
                "id": 21,
                "name": "Huelva",
                "citizens": [
                    {
                        "id": 5,
                        "name": "Francisco",
                        "surname": "Fernández"
                    },
                    {
                        "id": 6,
                        "name": "Juan",
                        "surname": "Jiménez"
                    },
                    {
                        "id": 7,
                        "name": "Simona",
                        "surname": "Sánchez"
                    },
                    {
                        "id": 8,
                        "name": "Ángel",
                        "surname": "Álvarez"
                    }
                ]
            }
        ]
    }
}
```

 El país tiene un array de ciudades y, cada ciudad tiene un array de ciudadanos. La característica de *array mapping* permite, por ejemplo, parsear en un solo array todos los nombres de todos los ciudadanos del pais. Lo hacemos de la siguiente manera:

 ```js
 struct CountryNames: Decodable, Keyedable {
    
    var name: String?
    var citizenNames: [String]? = []
    
    mutating func map(map: KeyMap) throws {
        try name <<- map["country.name"]
        try citizenNames <<- map["[]country.cities.citizens.name"]
    }
    
    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
    
}
 ```
Obsérvese que la variable `citizenNames` es un array (opcional) de strings. Y, si nos fijamos en el JSON, esos nombres se acceden mediante la ruta: `country` --> `cities` --> dentro de cada elemento --> `citizens`--> dentro de cada elemento --> `name`. Tras el parseo, `citizenNames` contendrá los nombres de todos los ciudadanos de todas las ciudades. 

Esto, no solo puede hacerse con arrays de tipos primitivos (como `[String]` en este caso), sino que también puede hacerse para parsear en un mismo array un tipo `Decodable`. Por ejemplo:

```js
 struct CountryNames: Decodable, Keyedable {
    
    var name: String?
    var citizens: [Citizen]? = []
    
    mutating func map(map: KeyMap) throws {
        try name <<- map["country.name"]
        try citizens <<- map["[]country.cities.citizens"]
    }
    
    init(from decoder: Decoder) throws {
        try KeyedDecoder(with: decoder).decode(to: &self)
    }
    
}
 ```
En este caso, tendríamos en `citizens` un array con todos los ciudadanos de todas las ciudades del pais.


## Proyecto de ejemplo

* Descargar el proyecto SDOSKeyedCodable desde el siguiente enlace: https://github.com/SDOSLabs/SDOSKeyedCodable.
* Comprobar que, al pulsar el botón **Ver ejemplo** se muestra una app que permite probar las distintas funcionalidades de SDOSKeyedCodable.

## Dependencias

SDOSKeyedCodable no tiene dependencias.

## Referencias

* [Codable](https://developer.apple.com/documentation/swift/codable)
* [KeyedCodable](https://github.com/dgrzeszczak/KeyedCodable)
* https://github.com/SDOSLabs/SDOSKeyedCodable
