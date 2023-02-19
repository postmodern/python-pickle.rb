### 0.2.0 / 2023-02-18

* Added missing support for deserializing Python `set` objects.
* Added missing support for out-of-band buffers.
* Added partial support for parsing the `PERSID` and `BINPERSID` instructions.
* Added missing support for deserializing the `INST` and `OBJ` instructions.
* Added missing support for deserializing the `EMPTY_SET`, `FROZENSET`, and
  `ADDITEMS` Pickle instructions.
* Added missing support for deserializing the `NEXT_BUFFER` and
  `READONLY_BUFFER` Pickle instructions.
* Map `__builtin__.set` and `builtins.set` to Ruby's `Set` class.

### 0.1.0 / 2023-02-18

* Changed {Python::Pickle.dump} to raise a `NotImplementedError` exception.
* Fixed a typo in the method signature of {Python::Pickle.dump}.

### 0.1.0 / 2023-02-18

* Initial release:
  * Supports deserializing Python Pickle data into Ruby objects.
  * Supports serializing Ruby objects into Python Pickle data.
  * Optionally supports only parsing Python Pickle data streams for debugging
    purposes.
  * Supports Pickle protocol 0, protocol 1, protocol 2, protocol 3, protocol 4,
    and protocol 5.
    * Can parse both Python 2 and Python 3 Pickled data.
  * Supports deserializing Python `tuple` and `bytearray` objects.
  * Supports mapping Python functions to Ruby methods.
  * Supports mapping Python classes to Ruby classes.

