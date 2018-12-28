# YEvent Framework

YEvent Framework allow to centralize a functional event entry point. This is formalized into the YEvent Family Class that must superclass this class and implements the YEvent Family Interface. The event method call (so, the event trigger) will invoke all method implementations in YEvent Implementation Classes that implements the same YEvent Family Interface.
The propagation is (sadly, for now) obtained by means of a generic logic into the type-pool YEVT that is referenced in this class, and so is inherited in the YEvent Family Class. The YEVT alias YEVT_PROPAGATE must be the first instruction of the event into the YEvent Family Class.

YEvent Family Interface: Define all events methods in the functional group (Family). Ex: YIF_YEVTF_LOGISTICS
YEvent Family Class: Implements YEvent Family Interface and inherits from the core class. Ex: YCL_YEVTF_LOGISTICS
YEvent Implementation Class: Implements YEvent Family Interface to supply different event execution "endpoints". Ex: YCL_YEVTI_GOOGLE, YCL_YEVTI_SCP
