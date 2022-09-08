# freeside-telcobridges-cdr
Telcobridges CDR import plugin module for Freeside 

* Custom Telcobridges CDR data parser
* Place the module file Telcobridges.pm in following dir
* https://github.com/freeside/Freeside/tree/master/FS/FS/cdr
* Restart the service
* It will parse the Telcobridges CDR data configures fields as Per module

### sample format
`# 2020-03-01 00:55,END,Calling='111111111',Called='2222222222',NAP='NAP_SS7',Duration='7',TerminationCause='NORMAL_CALL_CLEARING',Direction='originate'`

