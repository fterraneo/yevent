# YEvent Framework

YEvent Framework allow to centralize a functional event entry point. This is formalized into the YEvent Family Class that must superclass this class and implements the YEvent Family Interface. The event method call (so, the event trigger) will invoke all method implementations in YEvent Implementation Classes that implements the same YEvent Family Interface.
The propagation is (sadly, for now) obtained by means of a generic logic into the type-pool YEVT that is referenced in this class, and so is inherited in the YEvent Family Class. The YEVT alias YEVT_PROPAGATE must be the first instruction of the event into the YEvent Family Class.

The event management funcitonality is delivered by the use of this objects:

* YEvent Family Interface: Defines all events methods in the functional group (Family). Ex: YIF_YEVTF_LOGISTICS
* YEvent Family Class: Implements YEvent Family Interface and inherits from the core class. Ex: YCL_YEVTF_LOGISTICS
* YEvent Implementation Class: Implements YEvent Family Interface to supply different event execution "endpoints". Ex: YCL_YEVTI_GOOGLE, YCL_YEVTI_SCP

## Usage Steps

To successifully define an event and implements the listeners, the following steps must be implemented:

* Create Family Interface: Create a interface with the prototype(s) of the event. It is called "Family" because the interface groups a collection of events that should be functionally related

```
interface ZIF_FX_EVTF_LOGISTICS
  public .

  methods ON_TU_DOCKING
    importing
      !TU_ID type I .
endinterface.
```

* Create Family Class: Create a class that implmements the Family Interfaces and extends the framework core class (YCL_YEVT_MANAGER). Every event MUST begin with the line "yevt_propagate"

```
class ZCL_FX_EVTF_LOGISTICS definition
  public
  inheriting from YCL_YEVT_MANAGER
  final
  create public .

public section.
  type-pools ZEVT .

  interfaces ZIF_FX_EVTF_LOGISTICS .

  aliases ON_TU_DOCKING
    for ZIF_FX_EVTF_LOGISTICS~ON_TU_DOCKING .
protected section.
private section.
ENDCLASS.


CLASS ZCL_FX_EVTF_LOGISTICS IMPLEMENTATION.


  method ZIF_FX_EVTF_LOGISTICS~ON_TU_DOCKING.

    yevt_propagate.

  endmethod.
ENDCLASS.
```

* Put Event Launch code: Put the call to event method into the business logic to define the event launch
```
    DATA event type ref to zcl_fx_evtf_logistics.

    create object event type zcl_fx_evtf_logistics.

    event->on_tu_docking( 1 ).

    free event.
```

* Create Event Implementation Class: Create a class that implements the Family Interfaces and contains the event listener code. To have many listeners just create many Implementation Classes.
```
class ZCL_FX_EVTI_GOOGLE definition
  public
  final
  create public .

public section.

  interfaces ZIF_FX_EVTF_LOGISTICS .

  aliases ON_TU_DOCKING
    for ZIF_FX_EVTF_LOGISTICS~ON_TU_DOCKING .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FX_EVTI_GOOGLE IMPLEMENTATION.


  method ZIF_FX_EVTF_LOGISTICS~ON_TU_DOCKING.

    data lv_output type string.
    data lv_tuid_str type string.

    move tu_id to lv_tuid_str.
    concatenate 'Hi, i''m google end i am seriously docking the TU no ' lv_tuid_str into lv_output respecting blanks.

    write: / lv_output.

  endmethod.
ENDCLASS.
```
